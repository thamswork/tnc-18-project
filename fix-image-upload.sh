#!/bin/bash
# ============================================================
# TNC.18 — Fix Image Upload for Live CMS
# Problem: media_folder path wrong for Cloudflare Pages
# ============================================================

set -e
cd "/Users/marketingworks/Downloads/tnc-18-project/tnc-18"
git pull origin main --rebase

echo ""
echo "🖼  Fixing image upload..."
echo ""

# The issue: Cloudflare Pages serves from /dist
# Images uploaded via CMS need to go into /public/uploads
# and be referenced as /uploads/filename

# Fix 1: Update CMS config with correct media paths
cat > public/admin/config.yml << 'ENDOFFILE'
backend:
  name: github
  repo: thamswork/tnc-18-project
  branch: main
  base_url: https://tnc-18-auth.tyme-sak.workers.dev

# ── Media: upload to public/uploads, serve from /uploads ──
media_folder: "public/uploads"
public_folder: "/uploads"

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
      - { label: "Title (EN)",   name: title,      widget: string }
      - { label: "Title (TH)",   name: title_th,   widget: string,   required: false }
      - { label: "Date",         name: date,       widget: datetime, date_format: YYYY-MM-DD, time_format: false }
      - { label: "Cover Image",  name: cover,      widget: image,    required: false }
      - { label: "Excerpt (EN)", name: excerpt,    widget: text,     required: false }
      - { label: "Body",         name: body,       widget: markdown }

  - name: pages
    label: "Page Content"
    delete: false
    editor: { preview: false }
    files:

      - name: homepage
        label: "Homepage"
        file: src/content/pages/homepage.json
        fields:
          - label: "Hero Media"
            name: hero_media
            widget: object
            fields:
              - { label: "Hero Video (MP4 URL or upload)", name: hero_video, widget: string, required: false, hint: "Paste a video URL or leave blank" }
              - { label: "Hero Fallback Image", name: hero_image, widget: image, required: false }
          - label: "Hero Text"
            name: hero_text
            widget: object
            fields:
              - { label: "Location (EN)", name: hero_location_en, widget: string }
              - { label: "Location (TH)", name: hero_location_th, widget: string }
              - { label: "Line 1 (EN)",   name: hero_line1_en,    widget: string }
              - { label: "Line 1 (TH)",   name: hero_line1_th,    widget: string }
              - { label: "Line 2 (EN)",   name: hero_line2_en,    widget: string }
              - { label: "Line 2 (TH)",   name: hero_line2_th,    widget: string }
          - label: "Statement Quote"
            name: statement
            widget: object
            fields:
              - { label: "Quote (EN)", name: statement_en, widget: text }
              - { label: "Quote (TH)", name: statement_th, widget: text }
          - label: "About Section"
            name: about
            widget: object
            fields:
              - { label: "Headline (EN)",    name: about_headline_en,   widget: string }
              - { label: "Headline (TH)",    name: about_headline_th,   widget: string }
              - { label: "Body text (EN)",   name: about_body_en,       widget: text }
              - { label: "Body text (TH)",   name: about_body_th,       widget: text }
              - { label: "Years stat",       name: stats_years,         widget: string }
              - { label: "Projects stat",    name: stats_projects,      widget: string }
              - { label: "Specialists stat", name: stats_specialists,   widget: string }
          - label: "Contact Band"
            name: contact_band
            widget: object
            fields:
              - { label: "Headline (EN)", name: contact_headline_en, widget: string }
              - { label: "Headline (TH)", name: contact_headline_th, widget: string }
              - { label: "Body (EN)",     name: contact_body_en,     widget: text }
              - { label: "Body (TH)",     name: contact_body_th,     widget: text }

      - name: about
        label: "About Page"
        file: src/content/pages/about.json
        fields:
          - label: "Hero"
            name: hero
            widget: object
            fields:
              - { label: "Headline (EN)", name: hero_headline_en, widget: string }
              - { label: "Headline (TH)", name: hero_headline_th, widget: string }
              - label: "Office / Team Photo"
                name: hero_image
                widget: image
                required: false
                hint: "Upload your office or team photo here. It appears on the left side of the About page."
          - label: "Biography — Paragraph 1"
            name: bio1
            widget: object
            fields:
              - { label: "English", name: bio_1_en, widget: text }
              - { label: "Thai",    name: bio_1_th, widget: text }
          - label: "Biography — Paragraph 2"
            name: bio2
            widget: object
            fields:
              - { label: "English", name: bio_2_en, widget: text }
              - { label: "Thai",    name: bio_2_th, widget: text }
          - label: "Biography — Paragraph 3"
            name: bio3
            widget: object
            fields:
              - { label: "English", name: bio_3_en, widget: text }
              - { label: "Thai",    name: bio_3_th, widget: text }
          - label: "Photo Caption"
            name: caption
            widget: object
            fields:
              - { label: "Caption (EN)", name: office_image_caption_en, widget: string }
              - { label: "Caption (TH)", name: office_image_caption_th, widget: string }
          - label: "Team Statement"
            name: team
            widget: object
            fields:
              - { label: "Statement (EN)", name: team_statement_en, widget: text }
              - { label: "Statement (TH)", name: team_statement_th, widget: text }

  - name: settings
    label: "Global Settings"
    delete: false
    editor: { preview: false }
    files:

      - name: contact
        label: "Contact & Social"
        file: src/content/settings/contact.json
        fields:
          - { label: Phone,           name: phone,      widget: string }
          - { label: Email,           name: email,      widget: string }
          - { label: "Address (EN)",  name: address,    widget: text,   required: false }
          - { label: "Address (TH)",  name: address_th, widget: text,   required: false }
          - { label: "Line OA URL",   name: line,       widget: string, required: false }
          - { label: Instagram,       name: instagram,  widget: string, required: false }
          - { label: TikTok,          name: tiktok,     widget: string, required: false }

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
echo "✅  config.yml — media_folder fixed to public/uploads"

# Fix 2: Create the uploads folder
mkdir -p public/uploads
touch public/uploads/.gitkeep
echo "✅  public/uploads/ folder created"

# Fix 3: Create a sample news article so the tab shows
mkdir -p src/content/news
cat > src/content/news/2024-01-welcome.md << 'ENDOFFILE'
---
title: Welcome to TNC.18
title_th: ยินดีต้อนรับสู่ TNC.18
date: "2024-01-01"
excerpt: TNC.18 — eighteen years of architecture and construction excellence in Bangkok.
excerpt_th: TNC.18 — สิบแปดปีแห่งความเป็นเลิศด้านสถาปัตยกรรมและการก่อสร้างในกรุงเทพฯ
---

Welcome to TNC.18. We are a Bangkok-based architecture and construction firm with eighteen years of experience across residential, commercial, and interior projects.
ENDOFFILE
echo "✅  Sample news article created — News tab will now show"

git add .
git commit -m "fix: media_folder path + uploads folder + sample news article"
git push origin main

echo ""
echo "════════════════════════════════════════════════════"
echo "✅  Done — wait 1 min then:"
echo ""
echo "1. Refresh CMS admin"
echo "2. Page Content → About Page"
echo "   → Click 'Office / Team Photo'"
echo "   → Click 'Choose image'"
echo "   → Upload your photo"
echo "   → Publish"
echo ""
echo "3. News & Updates tab will now show in CMS"
echo "════════════════════════════════════════════════════"
echo ""
