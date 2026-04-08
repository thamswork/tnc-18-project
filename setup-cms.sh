#!/bin/bash
# ============================================================
# TNC.18 — Phase 4: Decap CMS Setup
# Repo: thamswork/tnc-18-project
# Collections: Projects, Services, Contact, Global Settings, News
# Local backend: true (no OAuth needed locally)
# ============================================================

set -e
echo ""
echo "📋  TNC.18 — Setting up Decap CMS..."
echo ""

# ── Install Decap CMS proxy server ───────────────────────────
npm install --save-dev decap-server
echo "✅  decap-server installed"

# ── Create public/admin/ directory ───────────────────────────
mkdir -p public/admin
mkdir -p public/admin/previews

# ── 1. public/admin/index.html ───────────────────────────────
cat > public/admin/index.html << 'ENDOFFILE'
<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>TNC.18 — Content Manager</title>
  <style>
    body { margin: 0; font-family: 'Poppins', sans-serif; background: #F7F4EF; }
  </style>
</head>
<body>
  <script src="https://unpkg.com/decap-cms@^3.0.0/dist/decap-cms.js"></script>
</body>
</html>
ENDOFFILE
echo "✅  public/admin/index.html"

# ── 2. public/admin/config.yml ───────────────────────────────
cat > public/admin/config.yml << 'ENDOFFILE'
# ─────────────────────────────────────────────────────────────
# TNC.18 — Decap CMS Config
# local_backend: true = edit locally without OAuth
# Switch to github backend for production
# ─────────────────────────────────────────────────────────────

local_backend: true

backend:
  name: github
  repo: thamswork/tnc-18-project
  branch: main
  base_url: https://sveltia-cms-auth.pages.dev  # free OAuth proxy

media_folder: public/images/uploads
public_folder: /images/uploads

site_url: https://tnc18.com
display_url: https://tnc18.com
logo_url: /favicon.svg

# ─────────────────────────────────────────────────────────────
# COLLECTIONS
# ─────────────────────────────────────────────────────────────
collections:

  # ── PROJECTS ──────────────────────────────────────────────
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
      - { label: Title (EN),        name: title,       widget: string }
      - { label: Title (TH),        name: title_th,    widget: string, required: false }
      - { label: Year,              name: year,        widget: number, value_type: int }
      - label: Category (EN)
        name: category
        widget: select
        options: [Residential, Commercial, Interior, Mixed-Use, Hospitality]
      - label: Category (TH)
        name: category_th
        widget: select
        required: false
        options: [ที่พักอาศัย, เชิงพาณิชย์, การออกแบบภายใน, อาคารรวม, การบริการ]
      - { label: Cover Image,       name: cover,       widget: image }
      - { label: Short Description (EN), name: description, widget: text, required: false }
      - { label: Short Description (TH), name: description_th, widget: text, required: false }
      - label: Gallery Images
        name: gallery
        widget: list
        required: false
        field: { label: Image, name: image, widget: image }
      - { label: Client,            name: client,      widget: string, required: false }
      - { label: Location,          name: location,    widget: string, required: false }
      - { label: Area (sqm),        name: area,        widget: number, required: false }
      - { label: Featured,          name: featured,    widget: boolean, default: false }
      - { label: Body Content,      name: body,        widget: markdown, required: false }

  # ── SERVICES ──────────────────────────────────────────────
  - name: services
    label: Services
    label_singular: Service
    folder: src/content/services
    create: true
    delete: true
    slug: "{{slug}}"
    summary: "{{order}}. {{title}}"
    sortable_fields: [order]
    fields:
      - { label: Order,             name: order,       widget: number, value_type: int }
      - { label: Title (EN),        name: title,       widget: string }
      - { label: Title (TH),        name: title_th,    widget: string, required: false }
      - { label: Description (EN),  name: description, widget: text,   required: false }
      - { label: Description (TH),  name: description_th, widget: text, required: false }
      - { label: Icon (optional),   name: icon,        widget: string, required: false }

  # ── NEWS / UPDATES ─────────────────────────────────────────
  - name: news
    label: News & Updates
    label_singular: Article
    folder: src/content/news
    create: true
    delete: true
    slug: "{{year}}-{{month}}-{{slug}}"
    summary: "{{title}} ({{date}})"
    sortable_fields: [date, title]
    fields:
      - { label: Title (EN),        name: title,       widget: string }
      - { label: Title (TH),        name: title_th,    widget: string, required: false }
      - { label: Date,              name: date,        widget: datetime, date_format: YYYY-MM-DD, time_format: false }
      - { label: Cover Image,       name: cover,       widget: image,   required: false }
      - { label: Excerpt (EN),      name: excerpt,     widget: text,    required: false }
      - { label: Excerpt (TH),      name: excerpt_th,  widget: text,    required: false }
      - { label: Body,              name: body,        widget: markdown }

  # ── GLOBAL SETTINGS ────────────────────────────────────────
  - name: settings
    label: Global Settings
    delete: false
    editor: { preview: false }
    files:

      # Contact & Social
      - name: contact
        label: Contact & Social Links
        file: src/content/settings/contact.json
        fields:
          - { label: Phone,             name: phone,       widget: string, hint: "e.g. +66 2 000 0000" }
          - { label: Email,             name: email,       widget: string }
          - { label: Address (EN),      name: address,     widget: text,   required: false }
          - { label: Address (TH),      name: address_th,  widget: text,   required: false }
          - { label: Line OA URL,       name: line,        widget: string, required: false }
          - { label: Instagram URL,     name: instagram,   widget: string, required: false }
          - { label: TikTok URL,        name: tiktok,      widget: string, required: false }
          - { label: Facebook URL,      name: facebook,    widget: string, required: false }

      # Brand Colors
      - name: colors
        label: Brand Colors
        file: src/content/settings/colors.json
        fields:
          - { label: Stone (background),  name: stone,       widget: color, default: "#F7F4EF" }
          - { label: Charcoal (text),     name: charcoal,    widget: color, default: "#1C1A17" }
          - { label: Gold (accent),       name: gold,        widget: color, default: "#A67C4E" }
          - { label: Blue (surprise),     name: blue,        widget: color, default: "#1B3F7A" }
          - { label: Muted (secondary),   name: muted,       widget: color, default: "#8A8680" }

      # Typography
      - name: typography
        label: Typography
        file: src/content/settings/typography.json
        fields:
          - label: Heading Font
            name: heading_font
            widget: select
            options:
              - { label: "Merriweather (current)", value: "Merriweather" }
              - { label: "Cormorant Garamond",     value: "Cormorant Garamond" }
              - { label: "Playfair Display",       value: "Playfair Display" }
              - { label: "Lora",                   value: "Lora" }
          - label: Body Font
            name: body_font
            widget: select
            options:
              - { label: "Poppins (current)", value: "Poppins" }
              - { label: "DM Sans",           value: "DM Sans" }
              - { label: "Inter",             value: "Inter" }
              - { label: "Nunito Sans",       value: "Nunito Sans" }
          - { label: Custom Google Font URL, name: custom_font_url, widget: string, required: false, hint: "Paste a Google Fonts embed URL to override the above" }

      # Site Info
      - name: siteinfo
        label: Site Info
        file: src/content/settings/siteinfo.json
        fields:
          - { label: Site Name,           name: site_name,    widget: string, default: "TNC.18" }
          - { label: Tagline (EN),        name: tagline,      widget: string }
          - { label: Tagline (TH),        name: tagline_th,   widget: string, required: false }
          - { label: Meta Description,    name: meta_desc,    widget: text }
          - { label: Google Analytics ID, name: ga_id,        widget: string, required: false }
ENDOFFILE
echo "✅  public/admin/config.yml"

# ── 3. Create content folder structure ───────────────────────
mkdir -p src/content/projects
mkdir -p src/content/services
mkdir -p src/content/news
mkdir -p src/content/settings
mkdir -p public/images/uploads

# ── 4. Seed default settings files ───────────────────────────
cat > src/content/settings/contact.json << 'ENDOFFILE'
{
  "phone": "+66 2 000 0000",
  "email": "hello@tnc18.com",
  "address": "Bangkok, Thailand",
  "address_th": "กรุงเทพมหานคร ประเทศไทย",
  "line": "https://line.me",
  "instagram": "https://instagram.com/tnc18",
  "tiktok": "https://tiktok.com/@tnc18",
  "facebook": ""
}
ENDOFFILE
echo "✅  src/content/settings/contact.json"

cat > src/content/settings/colors.json << 'ENDOFFILE'
{
  "stone": "#F7F4EF",
  "charcoal": "#1C1A17",
  "gold": "#A67C4E",
  "blue": "#1B3F7A",
  "muted": "#8A8680"
}
ENDOFFILE
echo "✅  src/content/settings/colors.json"

cat > src/content/settings/typography.json << 'ENDOFFILE'
{
  "heading_font": "Merriweather",
  "body_font": "Poppins",
  "custom_font_url": ""
}
ENDOFFILE
echo "✅  src/content/settings/typography.json"

cat > src/content/settings/siteinfo.json << 'ENDOFFILE'
{
  "site_name": "TNC.18",
  "tagline": "Architecture & Construction Excellence",
  "tagline_th": "ความเป็นเลิศด้านสถาปัตยกรรมและการก่อสร้าง",
  "meta_desc": "TNC.18 — Bangkok-based architecture and construction firm with 18 years of precision, craft, and permanence.",
  "ga_id": ""
}
ENDOFFILE
echo "✅  src/content/settings/siteinfo.json"

# ── 5. Seed one sample project ───────────────────────────────
cat > src/content/projects/silom-residence.md << 'ENDOFFILE'
---
title: Silom Residence
title_th: บ้านพักสีลม
year: 2024
category: Residential
category_th: ที่พักอาศัย
cover: /images/uploads/silom-residence.jpg
description: A refined private residence in the heart of Silom, designed around natural light and material permanence.
description_th: ที่พักอาศัยส่วนตัวในย่านสีลม ออกแบบโดยคำนึงถึงแสงธรรมชาติและความคงทนของวัสดุ
client: Private
location: Silom, Bangkok
area: 420
featured: true
---

Full project description goes here.
ENDOFFILE
echo "✅  src/content/projects/silom-residence.md (sample)"

# ── 6. Seed sample services ──────────────────────────────────
cat > src/content/services/01-architecture.md << 'ENDOFFILE'
---
order: 1
title: Architecture & Design
title_th: สถาปัตยกรรมและการออกแบบ
description: Full architectural services from concept through construction documentation.
description_th: บริการสถาปัตยกรรมครบวงจรตั้งแต่แนวคิดจนถึงเอกสารการก่อสร้าง
---
ENDOFFILE

cat > src/content/services/02-structural.md << 'ENDOFFILE'
---
order: 2
title: Structural Engineering
title_th: วิศวกรรมโครงสร้าง
description: Structural analysis, design, and documentation for all building types.
description_th: การวิเคราะห์โครงสร้าง การออกแบบ และเอกสารสำหรับอาคารทุกประเภท
---
ENDOFFILE

cat > src/content/services/03-interior.md << 'ENDOFFILE'
---
order: 3
title: Interior Architecture
title_th: สถาปัตยกรรมภายใน
description: Interior spatial design grounded in material craft and livability.
description_th: การออกแบบพื้นที่ภายในที่ยึดหลักฝีมือและความน่าอยู่
---
ENDOFFILE

cat > src/content/services/04-management.md << 'ENDOFFILE'
---
order: 4
title: Construction Management
title_th: การบริหารการก่อสร้าง
description: End-to-end project management from procurement through handover.
description_th: การบริหารโครงการครบวงจรตั้งแต่การจัดซื้อจนถึงการส่งมอบ
---
ENDOFFILE

cat > src/content/services/05-supervision.md << 'ENDOFFILE'
---
order: 5
title: Site Supervision
title_th: การควบคุมงานหน้างาน
description: On-site quality control and contractor coordination throughout construction.
description_th: การควบคุมคุณภาพและประสานงานผู้รับเหมาตลอดการก่อสร้าง
---
ENDOFFILE
echo "✅  src/content/services/ (5 seeded)"

# ── 7. astro.config.mjs — add content collections ────────────
cat > astro.config.mjs << 'ENDOFFILE'
// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://tnc18.com',
  integrations: [react(), sitemap()],
  vite: { plugins: [tailwindcss()] },
});
ENDOFFILE
echo "✅  astro.config.mjs"

# ── 8. package.json — add cms proxy script ───────────────────
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts = pkg.scripts || {};
pkg.scripts['cms'] = 'npx decap-server';
pkg.scripts['dev:cms'] = 'concurrently \"npm run dev\" \"npm run cms\"';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
console.log('package.json updated');
"

npm install --save-dev concurrently
echo "✅  package.json — cms + dev:cms scripts added"

# ── 9. Commit everything ──────────────────────────────────────
git add .
git commit -m "feat: Phase 4 — Decap CMS setup with all collections"
git push origin main
echo "✅  Committed and pushed to GitHub"

echo ""
echo "════════════════════════════════════════════════════"
echo "✅  PHASE 4 COMPLETE — Decap CMS ready"
echo "════════════════════════════════════════════════════"
echo ""
echo "TO RUN LOCALLY:"
echo "  npm run dev:cms"
echo ""
echo "  → Site:  http://localhost:4321"
echo "  → Admin: http://localhost:4321/admin"
echo ""
echo "Collections available in admin:"
echo "  · Projects     — add/edit/delete with images"
echo "  · Services     — reorder and edit descriptions"
echo "  · News         — publish articles in EN + TH"
echo "  · Contact      — phone, email, Line, IG, TikTok"
echo "  · Colors       — brand hex codes with color picker"
echo "  · Typography   — switch heading/body fonts"
echo "  · Site Info    — tagline, meta description, GA"
echo ""
echo "IMPORTANT: Regenerate your GitHub token."
echo "The one shared in chat should be deleted now."
echo ""
