#!/bin/bash
# ============================================================
# TNC.18 — Add hero video + image to CMS
# ============================================================

set -e
cd "/Users/marketingworks/Downloads/tnc-18-project/tnc-18"

echo ""
echo "🎬 Adding hero media to CMS..."
echo ""

# Pull first to avoid conflicts
git pull origin main --rebase

# ── 1. Update homepage.json to include media fields ──────────
cat > src/content/pages/homepage.json << 'ENDOFFILE'
{
  "hero_video": "",
  "hero_image": "",
  "hero_location_en": "Bangkok · Thailand",
  "hero_location_th": "กรุงเทพมหานคร · ประเทศไทย",
  "hero_line1_en": "We Build",
  "hero_line1_th": "เราสร้าง",
  "hero_line2_en": "What Lasts.",
  "hero_line2_th": "สิ่งที่ยั่งยืน",
  "hero_cta_en": "View Our Work",
  "hero_cta_th": "ดูผลงานของเรา",
  "statement_en": "Every structure we build carries a single promise — that it will outlast the moment it was made for.",
  "statement_th": "ทุกสิ่งที่เราสร้างมีคำสัญญาเดียว — ว่ามันจะคงอยู่ยาวนานกว่าช่วงเวลาที่มันถูกสร้างขึ้น",
  "about_headline_en": "Eighteen years of precision, craft, and permanence.",
  "about_headline_th": "สิบแปดปีแห่งความแม่นยำ ฝีมือ และความยั่งยืน",
  "about_body_en": "TNC.18 is a Bangkok-based architecture and construction firm. We work across residential, commercial, and interior disciplines — always with the same commitment to materials, structure, and lasting design.",
  "about_body_th": "TNC.18 เป็นบริษัทสถาปัตยกรรมและก่อสร้างในกรุงเทพฯ",
  "contact_headline_en": "Have a project in mind?",
  "contact_headline_th": "มีโครงการในใจอยู่หรือเปล่า?",
  "contact_body_en": "We work with clients who value precision and permanence. Let's talk about what you're building.",
  "contact_body_th": "เราทำงานกับลูกค้าที่ให้ความสำคัญกับความแม่นยำและความยั่งยืน",
  "stats_years": "18",
  "stats_projects": "200",
  "stats_specialists": "50"
}
ENDOFFILE
echo "✅  homepage.json — hero_video + hero_image fields added"

# ── 2. Update CMS config — add video + image to homepage ─────
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
              - label: "Hero Video (MP4)"
                name: hero_video
                widget: file
                required: false
                hint: "Upload an MP4 video for the hero background. Max recommended: 20MB."
                media_library:
                  config:
                    multiple: false
              - label: "Hero Fallback Image"
                name: hero_image
                widget: image
                required: false
                hint: "Shown if video fails to load, or on mobile. Recommended: 1920×1080px."
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
              - { label: "CTA Button (EN)", name: hero_cta_en,    widget: string }
              - { label: "CTA Button (TH)", name: hero_cta_th,    widget: string }
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
              - { label: "Headline (EN)",  name: about_headline_en,   widget: string }
              - { label: "Headline (TH)",  name: about_headline_th,   widget: string }
              - { label: "Body text (EN)", name: about_body_en,       widget: text }
              - { label: "Body text (TH)", name: about_body_th,       widget: text }
              - { label: "Years stat",       name: stats_years,       widget: string }
              - { label: "Projects stat",    name: stats_projects,    widget: string }
              - { label: "Specialists stat", name: stats_specialists, widget: string }
          - label: "Contact Band"
            name: contact_band
            widget: object
            fields:
              - { label: "Headline (EN)",  name: contact_headline_en, widget: string }
              - { label: "Headline (TH)",  name: contact_headline_th, widget: string }
              - { label: "Body text (EN)", name: contact_body_en,     widget: text }
              - { label: "Body text (TH)", name: contact_body_th,     widget: text }

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
              - label: "Hero Image"
                name: hero_image
                widget: image
                required: false
                hint: "Office or team photo shown on the About page"
          - label: "Biography"
            name: bio
            widget: object
            fields:
              - { label: "Paragraph 1 (EN)", name: bio_1_en, widget: text }
              - { label: "Paragraph 1 (TH)", name: bio_1_th, widget: text }
              - { label: "Paragraph 2 (EN)", name: bio_2_en, widget: text }
              - { label: "Paragraph 2 (TH)", name: bio_2_th, widget: text }
              - { label: "Paragraph 3 (EN)", name: bio_3_en, widget: text }
              - { label: "Paragraph 3 (TH)", name: bio_3_th, widget: text }
          - label: "Office Photo Caption"
            name: office
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
echo "✅  config.yml — hero video + image fields added"

# ── 3. Update index.astro hero to read from CMS ──────────────
python3 << 'PYEOF'
with open('src/pages/index.astro', 'r') as f:
    src = f.read()

# Replace the static hero media block with CMS-driven one
old = """import Layout from '../layouts/Layout.astro';
import Navbar from '../components/Navbar.astro';
import { getCollection } from 'astro:content';"""

new = """import Layout from '../layouts/Layout.astro';
import Navbar from '../components/Navbar.astro';
import { getCollection } from 'astro:content';
import homepageData from '../content/pages/homepage.json';"""

src = src.replace(old, new)

# Replace hero media section
old_media = """    <div class="hero-media">
      <video autoplay muted loop playsinline>
        <source src="/hero.mp4" type="video/mp4" />
      </video>
      <div class="hero-fallback"></div>
      <div class="hero-vignette"></div>
    </div>"""

new_media = """    <div class="hero-media">
      {homepageData.hero_video && (
        <video autoplay muted loop playsinline class="hero-video">
          <source src={homepageData.hero_video} type="video/mp4" />
        </video>
      )}
      {!homepageData.hero_video && (
        <video autoplay muted loop playsinline class="hero-video">
          <source src="/hero.mp4" type="video/mp4" />
        </video>
      )}
      {homepageData.hero_image
        ? <img src={homepageData.hero_image} alt="TNC.18" class="hero-img-fallback" />
        : <div class="hero-fallback"></div>
      }
      <div class="hero-vignette"></div>
    </div>"""

src = src.replace(old_media, new_media)

with open('src/pages/index.astro', 'w') as f:
    f.write(src)

print("✅  index.astro hero now reads video + image from CMS")
PYEOF

# ── 4. Add hero-img-fallback CSS ─────────────────────────────
python3 << 'PYEOF'
with open('src/pages/index.astro', 'r') as f:
    src = f.read()

old_css = "  .hero-fallback { position:absolute; inset:0; background:linear-gradient(155deg,#2C2820 0%,#1A1612 60%,#0F0D0A 100%); z-index:-1; }"
new_css = """  .hero-fallback { position:absolute; inset:0; background:linear-gradient(155deg,#2C2820 0%,#1A1612 60%,#0F0D0A 100%); z-index:-1; }
  .hero-img-fallback { position:absolute; inset:0; width:100%; height:100%; object-fit:cover; opacity:0.5; z-index:-1; }"""

src = src.replace(old_css, new_css)

with open('src/pages/index.astro', 'w') as f:
    f.write(src)

print("✅  hero-img-fallback CSS added")
PYEOF

git add .
git commit -m "feat: hero video + image upload from CMS"
git push origin main

echo ""
echo "════════════════════════════════════════════════════"
echo "✅  Done — wait 1 min then:"
echo ""
echo "Go to CMS → Page Content → Homepage"
echo "→ Hero Media section:"
echo "  · Upload your MP4 video"
echo "  · Upload a fallback image (shown on mobile)"
echo "→ Click Publish"
echo "→ Hero updates on the live site"
echo "════════════════════════════════════════════════════"
echo ""
