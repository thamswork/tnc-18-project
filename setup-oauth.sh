#!/bin/bash
# ============================================================
# TNC.18 — GitHub OAuth Worker Setup
# Deploys a Cloudflare Worker to handle CMS login
# ============================================================

set -e
echo ""
echo "🔐 Setting up GitHub OAuth for TNC.18 CMS..."
echo ""

# ── Install Wrangler if not present ──────────────────────────
if ! command -v wrangler &> /dev/null; then
  npm install -g wrangler
  echo "✅  Wrangler installed"
else
  echo "✅  Wrangler already installed"
fi

# ── Create oauth worker directory ────────────────────────────
mkdir -p ../tnc-18-auth-worker
cd ../tnc-18-auth-worker

# ── Create worker package.json ───────────────────────────────
cat > package.json << 'ENDOFFILE'
{
  "name": "tnc-18-auth-worker",
  "version": "1.0.0",
  "private": true
}
ENDOFFILE

# ── Create wrangler.toml ─────────────────────────────────────
cat > wrangler.toml << 'ENDOFFILE'
name = "tnc-18-auth"
main = "worker.js"
compatibility_date = "2024-01-01"

[vars]
GITHUB_CLIENT_ID = "Ov23lisGdx81mmYszHp3"
ALLOWED_DOMAINS = "tnc-18-project.pages.dev"
ENDOFFILE

# ── Create the OAuth worker ───────────────────────────────────
cat > worker.js << 'ENDOFFILE'
// TNC.18 GitHub OAuth Worker
// Handles CMS login via GitHub OAuth

const CLIENT_ID = 'Ov23lisGdx81mmYszHp3';
const ALLOWED_ORIGINS = [
  'https://tnc-18-project.pages.dev',
  'http://localhost:4321',
];

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const origin = request.headers.get('Origin') || '';

    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0],
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // Step 1: Redirect to GitHub OAuth
    if (url.pathname === '/auth') {
      const state = crypto.randomUUID();
      const githubUrl = new URL('https://github.com/login/oauth/authorize');
      githubUrl.searchParams.set('client_id', CLIENT_ID);
      githubUrl.searchParams.set('scope', 'repo,user');
      githubUrl.searchParams.set('state', state);
      githubUrl.searchParams.set('redirect_uri', `${url.origin}/callback`);
      return Response.redirect(githubUrl.toString(), 302);
    }

    // Step 2: Handle callback from GitHub
    if (url.pathname === '/callback') {
      const code = url.searchParams.get('code');
      const state = url.searchParams.get('state');

      if (!code) {
        return new Response('Missing code', { status: 400 });
      }

      // Exchange code for access token
      const tokenResponse = await fetch('https://github.com/login/oauth/access_token', {
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

      const tokenData = await tokenResponse.json();

      if (tokenData.error) {
        return new Response(`OAuth error: ${tokenData.error_description}`, { status: 400 });
      }

      const token = tokenData.access_token;

      // Return HTML that sends token back to CMS
      const html = `<!DOCTYPE html>
<html>
<head><title>TNC.18 CMS — Authenticating...</title></head>
<body>
<script>
  (function() {
    function receiveMessage(e) {
      window.removeEventListener("message", receiveMessage, false);
    }
    window.addEventListener("message", receiveMessage, false);

    window.opener.postMessage(
      'authorization:github:success:{"token":"${token}","provider":"github"}',
      "*"
    );
  })();
</script>
<p style="font-family:sans-serif;text-align:center;padding:2rem;color:#8A8680;">
  Authenticated. You may close this window.
</p>
</body>
</html>`;

      return new Response(html, {
        headers: { 'Content-Type': 'text/html' },
      });
    }

    // Health check
    if (url.pathname === '/') {
      return new Response(JSON.stringify({ status: 'TNC.18 Auth Worker running' }), {
        headers: { 'Content-Type': 'application/json', ...corsHeaders },
      });
    }

    return new Response('Not found', { status: 404 });
  },
};
ENDOFFILE
echo "✅  OAuth worker created"

# ── Deploy worker with secret ─────────────────────────────────
echo ""
echo "📡 Deploying worker to Cloudflare..."
echo ""

# Login to Cloudflare if needed
wrangler whoami || wrangler login

# Add the client secret as a Worker secret (secure, not in code)
echo "23f798f7b51794b3127aeb3aae3c510f416fb93c" | wrangler secret put GITHUB_CLIENT_SECRET

# Deploy the worker
wrangler deploy

echo ""
echo "✅  Worker deployed!"
echo ""

# ── Update CMS config to use the worker ──────────────────────
cd "/Users/marketingworks/Downloads/tnc-18-project/tnc-18"

cat > public/admin/config.yml << 'ENDOFFILE'
# TNC.18 Decap CMS Config
local_backend: false

backend:
  name: github
  repo: thamswork/tnc-18-project
  branch: main
  base_url: https://tnc-18-auth.workers.dev

media_folder: public/images/uploads
public_folder: /images/uploads

site_url: https://tnc-18-project.pages.dev
display_url: https://tnc-18-project.pages.dev
logo_url: /favicon.svg

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
    sortable_fields: [year, title]
    fields:
      - { label: Title (EN),             name: title,          widget: string }
      - { label: Title (TH),             name: title_th,       widget: string,   required: false }
      - { label: Year,                   name: year,           widget: number,   value_type: int }
      - label: Category (EN)
        name: category
        widget: select
        options: [Residential, Commercial, Interior, Mixed-Use, Hospitality]
      - { label: Category (TH),          name: category_th,    widget: string,   required: false }
      - { label: Cover Image,            name: cover,          widget: image }
      - { label: Short Description (EN), name: description,    widget: text,     required: false }
      - { label: Short Description (TH), name: description_th, widget: text,     required: false }
      - label: Gallery Images
        name: gallery
        widget: list
        required: false
        field: { label: Image, name: image, widget: image }
      - { label: Client,                 name: client,         widget: string,   required: false }
      - { label: Location,               name: location,       widget: string,   required: false }
      - { label: Area (sqm),             name: area,           widget: number,   required: false }
      - { label: Featured on homepage,   name: featured,       widget: boolean,  default: false }
      - { label: Body Content,           name: body,           widget: markdown, required: false }

  - name: services
    label: Services
    label_singular: Service
    folder: src/content/services
    create: true
    delete: true
    slug: "{{slug}}"
    summary: "{{order}}. {{title}}"
    fields:
      - { label: Order,             name: order,          widget: number, value_type: int }
      - { label: Title (EN),        name: title,          widget: string }
      - { label: Title (TH),        name: title_th,       widget: string, required: false }
      - { label: Description (EN),  name: description,    widget: text,   required: false }
      - { label: Description (TH),  name: description_th, widget: text,   required: false }

  - name: news
    label: News & Updates
    label_singular: Article
    folder: src/content/news
    create: true
    delete: true
    slug: "{{year}}-{{month}}-{{slug}}"
    fields:
      - { label: Title (EN),   name: title,      widget: string }
      - { label: Title (TH),   name: title_th,   widget: string,   required: false }
      - { label: Date,         name: date,       widget: datetime, date_format: YYYY-MM-DD, time_format: false }
      - { label: Cover Image,  name: cover,      widget: image,    required: false }
      - { label: Excerpt (EN), name: excerpt,    widget: text,     required: false }
      - { label: Excerpt (TH), name: excerpt_th, widget: text,     required: false }
      - { label: Body,         name: body,       widget: markdown }

  - name: settings
    label: Global Settings
    delete: false
    editor: { preview: false }
    files:

      - name: contact
        label: Contact & Social Links
        file: src/content/settings/contact.json
        fields:
          - { label: Phone,         name: phone,       widget: string }
          - { label: Email,         name: email,       widget: string }
          - { label: Address (EN),  name: address,     widget: text,   required: false }
          - { label: Address (TH),  name: address_th,  widget: text,   required: false }
          - { label: Line OA URL,   name: line,        widget: string, required: false }
          - { label: Instagram URL, name: instagram,   widget: string, required: false }
          - { label: TikTok URL,    name: tiktok,      widget: string, required: false }

      - name: colors
        label: Brand Colors
        file: src/content/settings/colors.json
        fields:
          - { label: Stone (background), name: stone,    widget: color, default: "#F7F4EF" }
          - { label: Charcoal (text),    name: charcoal, widget: color, default: "#1C1A17" }
          - { label: Gold (accent),      name: gold,     widget: color, default: "#A67C4E" }
          - { label: Blue (hover),       name: blue,     widget: color, default: "#1B3F7A" }

      - name: siteinfo
        label: Site Info
        file: src/content/settings/siteinfo.json
        fields:
          - { label: Site Name,        name: site_name, widget: string }
          - { label: Tagline (EN),     name: tagline,   widget: string }
          - { label: Tagline (TH),     name: tagline_th,widget: string, required: false }
          - { label: Meta Description, name: meta_desc, widget: text }
ENDOFFILE
echo "✅  public/admin/config.yml updated"

git add .
git commit -m "feat: GitHub OAuth via custom Cloudflare Worker"
git push origin main

echo ""
echo "════════════════════════════════════════════════════════"
echo "✅  ALL DONE"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Live site:  https://tnc-18-project.pages.dev"
echo "CMS admin:  https://tnc-18-project.pages.dev/admin"
echo ""
echo "To log into CMS:"
echo "  1. Go to https://tnc-18-project.pages.dev/admin"
echo "  2. Click 'Login with GitHub'"
echo "  3. Authorize TNC18 CMS app"
echo "  4. You're in — edit everything from the browser"
echo ""
echo "SECURITY: Go to GitHub Settings → Developer Settings →"
echo "OAuth Apps → TNC18 CMS → regenerate your client secret."
echo "The one used here was shared in chat."
echo ""
