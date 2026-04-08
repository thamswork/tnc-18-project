#!/bin/bash
# ============================================================
# TNC.18 — Final CMS Fix
# Uses Decap CMS with GitHub OAuth App directly
# No proxy needed — GitHub handles auth natively
# ============================================================

set -e
cd "/Users/marketingworks/Downloads/tnc-18-project/tnc-18"

echo ""
echo "🔧 Final CMS fix..."
echo ""

# Step 1: Rewrite admin index.html with correct Decap version
cat > public/admin/index.html << 'ENDOFFILE'
<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>TNC.18 — Content Manager</title>
</head>
<body>
  <script src="https://unpkg.com/decap-cms@3.3.3/dist/decap-cms.js"></script>
</body>
</html>
ENDOFFILE
echo "✅  admin/index.html — pinned to decap-cms@3.3.3"

# Step 2: Write clean config.yml pointing to our working worker
cat > public/admin/config.yml << 'ENDOFFILE'
backend:
  name: github
  repo: thamswork/tnc-18-project
  branch: main
  base_url: https://tnc-18-auth.tyme-sak.workers.dev

media_folder: public/images/uploads
public_folder: /images/uploads

collections:
  - name: projects
    label: Projects
    label_singular: Project
    folder: src/content/projects
    create: true
    delete: true
    slug: "{{slug}}"
    identifier_field: title
    fields:
      - { label: "Title (EN)",           name: title,          widget: string }
      - { label: "Title (TH)",           name: title_th,       widget: string,   required: false }
      - { label: "Year",                 name: year,           widget: number,   value_type: int }
      - label: "Category"
        name: category
        widget: select
        options: [Residential, Commercial, Interior, Mixed-Use, Hospitality]
      - { label: "Category (TH)",        name: category_th,    widget: string,   required: false }
      - { label: "Cover Image",          name: cover,          widget: image }
      - { label: "Description (EN)",     name: description,    widget: text,     required: false }
      - { label: "Description (TH)",     name: description_th, widget: text,     required: false }
      - label: "Gallery Images"
        name: gallery
        widget: list
        required: false
        field: { label: Image, name: image, widget: image }
      - { label: "Client",               name: client,         widget: string,   required: false }
      - { label: "Location",             name: location,       widget: string,   required: false }
      - { label: "Area (sqm)",           name: area,           widget: number,   required: false }
      - { label: "Featured on homepage", name: featured,       widget: boolean,  default: false }
      - { label: "Body Content",         name: body,           widget: markdown, required: false }

  - name: services
    label: Services
    folder: src/content/services
    create: true
    delete: true
    slug: "{{slug}}"
    fields:
      - { label: "Order",            name: order,          widget: number, value_type: int }
      - { label: "Title (EN)",       name: title,          widget: string }
      - { label: "Title (TH)",       name: title_th,       widget: string, required: false }
      - { label: "Description (EN)", name: description,    widget: text,   required: false }
      - { label: "Description (TH)", name: description_th, widget: text,   required: false }

  - name: news
    label: "News & Updates"
    folder: src/content/news
    create: true
    delete: true
    slug: "{{year}}-{{month}}-{{slug}}"
    fields:
      - { label: "Title (EN)", name: title,  widget: string }
      - { label: "Date",       name: date,   widget: datetime, date_format: YYYY-MM-DD, time_format: false }
      - { label: "Cover",      name: cover,  widget: image,    required: false }
      - { label: "Body",       name: body,   widget: markdown }

  - name: settings
    label: "Global Settings"
    delete: false
    editor: { preview: false }
    files:
      - name: contact
        label: "Contact & Social"
        file: src/content/settings/contact.json
        fields:
          - { label: Phone,         name: phone,     widget: string }
          - { label: Email,         name: email,     widget: string }
          - { label: "Line OA URL", name: line,      widget: string, required: false }
          - { label: Instagram,     name: instagram, widget: string, required: false }
          - { label: TikTok,        name: tiktok,    widget: string, required: false }
      - name: siteinfo
        label: "Site Info"
        file: src/content/settings/siteinfo.json
        fields:
          - { label: "Site Name",        name: site_name, widget: string }
          - { label: "Tagline (EN)",     name: tagline,   widget: string }
          - { label: "Meta Description", name: meta_desc, widget: text }
ENDOFFILE
echo "✅  admin/config.yml — clean config with worker base_url"

# Step 3: Redeploy the OAuth worker with the correct postMessage
cd ../tnc-18-auth-worker

cat > worker.js << 'ENDOFFILE'
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

    if (url.pathname === '/auth') {
      const scope = url.searchParams.get('scope') || 'repo,user';
      const githubUrl = new URL('https://github.com/login/oauth/authorize');
      githubUrl.searchParams.set('client_id', CLIENT_ID);
      githubUrl.searchParams.set('scope', scope);
      githubUrl.searchParams.set('redirect_uri', `${url.origin}/callback`);
      return Response.redirect(githubUrl.toString(), 302);
    }

    if (url.pathname === '/callback') {
      const code = url.searchParams.get('code');
      if (!code) {
        return new Response('Missing code', { status: 400 });
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

      const data = await tokenRes.json();

      if (data.error) {
        return new Response(`Error: ${data.error_description}`, { status: 400 });
      }

      const token = data.access_token;

      // Exact format Decap CMS 3.x expects
      const script = `
        <script>
          (function() {
            function sendMessage(e) {
              window.opener.postMessage(
                'authorization:github:success:{"token":"${token}","provider":"github"}',
                e.origin
              );
            }
            window.addEventListener("message", function(e) {
              if (e.data === "authorizing:github") {
                sendMessage(e);
              }
            }, false);
            window.opener.postMessage("authorizing:github", "*");
          })();
        </script>
      `;

      return new Response(`<!DOCTYPE html><html><body>${script}</body></html>`, {
        headers: { 'Content-Type': 'text/html' },
      });
    }

    if (url.pathname === '/') {
      return new Response('TNC.18 OAuth Worker OK', {
        headers: corsHeaders,
      });
    }

    return new Response('Not found', { status: 404 });
  },
};
ENDOFFILE

wrangler deploy
echo "✅  OAuth worker redeployed with correct Decap 3.x handshake"

# Step 4: Commit and push
cd "/Users/marketingworks/Downloads/tnc-18-project/tnc-18"
git add .
git commit -m "fix: Decap 3.3.3 + correct OAuth postMessage handshake"
git push origin main

echo ""
echo "════════════════════════════════════════════════════"
echo "✅  Done — wait 1 min then:"
echo ""
echo "1. Open in a FRESH private/incognito window:"
echo "   https://tnc-18-project.pages.dev/admin"
echo ""
echo "2. Click Login with GitHub"
echo "3. Authorize the app on GitHub"
echo "4. Window closes → you're in the CMS"
echo "════════════════════════════════════════════════════"
echo ""
