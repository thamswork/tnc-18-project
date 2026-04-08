#!/bin/bash
# ============================================================
# TNC.18 — Fix CMS Admin Page
# ============================================================

set -e
echo ""
echo "🔧 Fixing CMS admin page..."
echo ""

# Fix the worker to send the message in the format Decap expects
cat > ../tnc-18-auth-worker/worker.js << 'ENDOFFILE'
const CLIENT_ID = 'Ov23lisGdx81mmYszHp3';

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // Step 1: Start OAuth flow
    if (url.pathname === '/auth') {
      const scope = url.searchParams.get('scope') || 'repo,user';
      const githubUrl = new URL('https://github.com/login/oauth/authorize');
      githubUrl.searchParams.set('client_id', CLIENT_ID);
      githubUrl.searchParams.set('scope', scope);
      githubUrl.searchParams.set('redirect_uri', `${url.origin}/callback`);
      return Response.redirect(githubUrl.toString(), 302);
    }

    // Step 2: Handle callback — exchange code for token
    if (url.pathname === '/callback') {
      const code = url.searchParams.get('code');

      if (!code) {
        return new Response('Missing code parameter', { status: 400 });
      }

      const tokenRes = await fetch('https://github.com/login/oauth/access_token', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          client_id: CLIENT_ID,
          client_secret: env.GITHUB_CLIENT_SECRET,
          code,
          redirect_uri: `${url.origin}/callback`,
        }),
      });

      const tokenData = await tokenRes.json();

      if (tokenData.error) {
        return new Response(`GitHub OAuth error: ${tokenData.error_description}`, { status: 400 });
      }

      const token = tokenData.access_token;
      const provider = 'github';

      // This is the exact message format Decap CMS expects
      const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>Authenticating...</title>
</head>
<body>
  <p style="font-family:system-ui;text-align:center;padding:3rem;color:#8A8680;">
    Authenticating with GitHub...
  </p>
  <script>
    (function() {
      // The exact postMessage format Decap CMS requires
      const message = 'authorization:${provider}:success:' + JSON.stringify({
        token: '${token}',
        provider: '${provider}'
      });

      // Try to send to opener
      if (window.opener) {
        window.opener.postMessage(message, '*');
        setTimeout(function() { window.close(); }, 500);
      } else {
        // Fallback: redirect back with token in hash
        document.querySelector('p').textContent = 'Authentication complete. You can close this window.';
      }
    })();
  </script>
</body>
</html>`;

      return new Response(html, {
        headers: {
          'Content-Type': 'text/html',
          ...corsHeaders,
        },
      });
    }

    // Health check
    if (url.pathname === '/') {
      return new Response(JSON.stringify({
        status: 'TNC.18 OAuth Worker',
        worker: 'tnc-18-auth',
        ready: true
      }), {
        headers: { 'Content-Type': 'application/json', ...corsHeaders },
      });
    }

    return new Response('Not found', { status: 404 });
  },
};
ENDOFFILE

# Redeploy worker
cd ../tnc-18-auth-worker
wrangler deploy
echo "✅  Worker redeployed"

cd "/Users/marketingworks/Downloads/tnc-18-project/tnc-18"

# Fix admin index.html — use correct Decap CMS version with proper init
cat > public/admin/index.html << 'ENDOFFILE'
<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>TNC.18 — Content Manager</title>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: 'Poppins', system-ui, sans-serif;
      background: #F7F4EF;
    }
    #loading {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100vh;
      flex-direction: column;
      gap: 1rem;
      color: #8A8680;
    }
    #loading p {
      font-size: 0.85rem;
      letter-spacing: 0.1em;
      text-transform: uppercase;
    }
    .logo {
      font-size: 1.5rem;
      font-weight: 500;
      letter-spacing: 0.1em;
      color: #1C1A17;
    }
    .logo em { font-style: normal; color: #A67C4E; }
  </style>
</head>
<body>
  <div id="loading">
    <div class="logo">TNC<em>.</em>18</div>
    <p>Loading Content Manager...</p>
  </div>

  <script src="https://unpkg.com/decap-cms@^3.0.0/dist/decap-cms.js"></script>

  <script>
    // Hide loading once CMS mounts
    document.addEventListener('DOMContentLoaded', function() {
      setTimeout(function() {
        var loading = document.getElementById('loading');
        if (loading) loading.style.display = 'none';
      }, 2000);
    });
  </script>
</body>
</html>
ENDOFFILE
echo "✅  public/admin/index.html fixed"

# Update config.yml — make sure backend is correct
cat > public/admin/config.yml << 'ENDOFFILE'
local_backend: false

backend:
  name: github
  repo: thamswork/tnc-18-project
  branch: main
  base_url: https://tnc-18-auth.tyme-sak.workers.dev
  auth_endpoint: /auth

media_folder: public/images/uploads
public_folder: /images/uploads

site_url: https://tnc-18-project.pages.dev
display_url: https://tnc-18-project.pages.dev

collections:

  - name: projects
    label: Projects
    label_singular: Project
    folder: src/content/projects
    create: true
    delete: true
    slug: "{{slug}}"
    identifier_field: title
    summary: "{{title}} — {{year}}"
    fields:
      - { label: "Title (EN)",             name: title,          widget: string }
      - { label: "Title (TH)",             name: title_th,       widget: string,   required: false }
      - { label: "Year",                   name: year,           widget: number,   value_type: int }
      - label: "Category"
        name: category
        widget: select
        options: [Residential, Commercial, Interior, Mixed-Use, Hospitality]
      - { label: "Category (TH)",          name: category_th,    widget: string,   required: false }
      - { label: "Cover Image",            name: cover,          widget: image }
      - { label: "Description (EN)",       name: description,    widget: text,     required: false }
      - { label: "Description (TH)",       name: description_th, widget: text,     required: false }
      - label: "Gallery Images"
        name: gallery
        widget: list
        required: false
        field: { label: Image, name: image, widget: image }
      - { label: "Client",                 name: client,         widget: string,   required: false }
      - { label: "Location",               name: location,       widget: string,   required: false }
      - { label: "Area (sqm)",             name: area,           widget: number,   required: false }
      - { label: "Featured on homepage",   name: featured,       widget: boolean,  default: false }
      - { label: "Body Content",           name: body,           widget: markdown, required: false }

  - name: services
    label: Services
    label_singular: Service
    folder: src/content/services
    create: true
    delete: true
    slug: "{{slug}}"
    summary: "{{order}}. {{title}}"
    fields:
      - { label: "Order",            name: order,          widget: number, value_type: int }
      - { label: "Title (EN)",       name: title,          widget: string }
      - { label: "Title (TH)",       name: title_th,       widget: string, required: false }
      - { label: "Description (EN)", name: description,    widget: text,   required: false }
      - { label: "Description (TH)", name: description_th, widget: text,   required: false }

  - name: news
    label: "News & Updates"
    label_singular: Article
    folder: src/content/news
    create: true
    delete: true
    slug: "{{year}}-{{month}}-{{slug}}"
    fields:
      - { label: "Title (EN)",   name: title,       widget: string }
      - { label: "Title (TH)",   name: title_th,    widget: string,   required: false }
      - { label: "Date",         name: date,        widget: datetime, date_format: YYYY-MM-DD, time_format: false }
      - { label: "Cover Image",  name: cover,       widget: image,    required: false }
      - { label: "Excerpt (EN)", name: excerpt,     widget: text,     required: false }
      - { label: "Excerpt (TH)", name: excerpt_th,  widget: text,     required: false }
      - { label: "Body",         name: body,        widget: markdown }

  - name: settings
    label: "Global Settings"
    delete: false
    editor: { preview: false }
    files:

      - name: contact
        label: "Contact & Social"
        file: src/content/settings/contact.json
        fields:
          - { label: Phone,         name: phone,      widget: string }
          - { label: Email,         name: email,      widget: string }
          - { label: "Address (EN)",name: address,    widget: text,   required: false }
          - { label: "Address (TH)",name: address_th, widget: text,   required: false }
          - { label: "Line OA URL", name: line,       widget: string, required: false }
          - { label: Instagram,     name: instagram,  widget: string, required: false }
          - { label: TikTok,        name: tiktok,     widget: string, required: false }

      - name: colors
        label: "Brand Colors"
        file: src/content/settings/colors.json
        fields:
          - { label: "Stone (background)", name: stone,    widget: color, default: "#F7F4EF" }
          - { label: "Charcoal (text)",    name: charcoal, widget: color, default: "#1C1A17" }
          - { label: "Gold (accent)",      name: gold,     widget: color, default: "#A67C4E" }
          - { label: "Blue (hover)",       name: blue,     widget: color, default: "#1B3F7A" }

      - name: siteinfo
        label: "Site Info"
        file: src/content/settings/siteinfo.json
        fields:
          - { label: "Site Name",        name: site_name, widget: string }
          - { label: "Tagline (EN)",     name: tagline,   widget: string }
          - { label: "Tagline (TH)",     name: tagline_th,widget: string, required: false }
          - { label: "Meta Description", name: meta_desc, widget: text }
ENDOFFILE
echo "✅  public/admin/config.yml updated"

git add .
git commit -m "fix: CMS admin OAuth postMessage format + auth_endpoint"
git push origin main

echo ""
echo "════════════════════════════════════════════════"
echo "✅  Done — wait 1 min then try:"
echo "    https://tnc-18-project.pages.dev/admin"
echo "════════════════════════════════════════════════"
echo ""
