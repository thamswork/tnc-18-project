#!/bin/bash
# ============================================================
# TNC.18 — Final About Page Fix
# Root cause: CMS saves flat JSON but page reads nested keys
# Fix: flatten everything, make CMS + page use same structure
# ============================================================

set -e
cd "/Users/marketingworks/Downloads/tnc-18-project/tnc-18"
git pull origin main --rebase

echo ""
echo "🔧 Final about page fix..."
echo ""

# ── 1. Write flat about.json that matches CMS output exactly ─
cat > src/content/pages/about.json << 'ENDOFFILE'
{
  "hero_headline_en": "Built on craft. Defined by permanence.",
  "hero_headline_th": "สร้างด้วยฝีมือ นิยามด้วยความยั่งยืน",
  "office_photo": "",
  "office_photo_url": "",
  "bio_1_en": "TNC.18 was founded in 2006 with a single conviction — that buildings should outlast the trends of the moment they were built in. Eighteen years later, that conviction remains unchanged.",
  "bio_1_th": "TNC.18 ก่อตั้งขึ้นในปี 2549 ด้วยความเชื่อมั่นเดียว — ว่าอาคารควรคงอยู่ยาวนานกว่ากระแสของยุคสมัยที่สร้างขึ้น",
  "bio_2_en": "We are a Bangkok-based firm of architects, engineers, and builders. Our work spans private residences, commercial towers, interior commissions, and hospitality projects across Thailand.",
  "bio_2_th": "เราเป็นบริษัทที่ตั้งอยู่ในกรุงเทพฯ ประกอบด้วยสถาปนิก วิศวกร และผู้สร้าง",
  "bio_3_en": "Every project begins with the same question: what will this building mean in fifty years? That question shapes every material choice, every structural decision, every detail.",
  "bio_3_th": "ทุกโครงการเริ่มต้นด้วยคำถามเดียวกัน: อาคารนี้จะมีความหมายอะไรในห้าสิบปี?",
  "office_caption_en": "TNC.18 Headquarters, Bangkok",
  "office_caption_th": "สำนักงานใหญ่ TNC.18 กรุงเทพฯ",
  "team_en": "50+ architects, engineers, project managers, and site specialists. Bangkok-based. Regionally experienced.",
  "team_th": "สถาปนิก วิศวกร ผู้จัดการโครงการ และผู้เชี่ยวชาญงานหน้างานมากกว่า 50 คน"
}
ENDOFFILE
echo "✅  about.json — flat structure"

# ── 2. Update CMS config — flat fields, no nested objects ────
cat > public/admin/config.yml << 'ENDOFFILE'
backend:
  name: github
  repo: thamswork/tnc-18-project
  branch: main
  base_url: https://tnc-18-auth.tyme-sak.workers.dev

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

      - name: about
        label: "About Page"
        file: src/content/pages/about.json
        fields:
          - { label: "Hero Headline (EN)", name: hero_headline_en, widget: string }
          - { label: "Hero Headline (TH)", name: hero_headline_th, widget: string }
          - label: "Office Photo (upload)"
            name: office_photo
            widget: image
            required: false
            hint: "Upload a photo — it appears on the left side of the About page"
          - label: "Office Photo (paste URL from Cloudinary etc.)"
            name: office_photo_url
            widget: string
            required: false
            hint: "Alternative: paste a direct image URL if not uploading"
          - { label: "Bio Paragraph 1 (EN)", name: bio_1_en, widget: text }
          - { label: "Bio Paragraph 1 (TH)", name: bio_1_th, widget: text }
          - { label: "Bio Paragraph 2 (EN)", name: bio_2_en, widget: text }
          - { label: "Bio Paragraph 2 (TH)", name: bio_2_th, widget: text }
          - { label: "Bio Paragraph 3 (EN)", name: bio_3_en, widget: text }
          - { label: "Bio Paragraph 3 (TH)", name: bio_3_th, widget: text }
          - { label: "Photo Caption (EN)",   name: office_caption_en, widget: string }
          - { label: "Photo Caption (TH)",   name: office_caption_th, widget: string }
          - { label: "Team Statement (EN)",  name: team_en, widget: text }
          - { label: "Team Statement (TH)",  name: team_th, widget: text }

      - name: homepage
        label: "Homepage"
        file: src/content/pages/homepage.json
        fields:
          - { label: "Hero Line 1 (EN)", name: hero_line1_en, widget: string }
          - { label: "Hero Line 1 (TH)", name: hero_line1_th, widget: string }
          - { label: "Hero Line 2 (EN)", name: hero_line2_en, widget: string }
          - { label: "Hero Line 2 (TH)", name: hero_line2_th, widget: string }
          - { label: "Statement Quote (EN)", name: statement_en, widget: text }
          - { label: "Statement Quote (TH)", name: statement_th, widget: text }
          - { label: "About Headline (EN)", name: about_headline_en, widget: string }
          - { label: "About Headline (TH)", name: about_headline_th, widget: string }
          - { label: "About Body (EN)", name: about_body_en, widget: text }
          - { label: "About Body (TH)", name: about_body_th, widget: text }
          - { label: "Years stat", name: stats_years, widget: string }
          - { label: "Projects stat", name: stats_projects, widget: string }
          - { label: "Specialists stat", name: stats_specialists, widget: string }
          - { label: "Contact Headline (EN)", name: contact_headline_en, widget: string }
          - { label: "Contact Headline (TH)", name: contact_headline_th, widget: string }
          - { label: "Contact Body (EN)", name: contact_body_en, widget: text }
          - { label: "Contact Body (TH)", name: contact_body_th, widget: text }

  - name: settings
    label: "Global Settings"
    delete: false
    editor: { preview: false }
    files:
      - name: contact
        label: "Contact & Social"
        file: src/content/settings/contact.json
        fields:
          - { label: Phone,          name: phone,      widget: string }
          - { label: Email,          name: email,      widget: string }
          - { label: "Address (EN)", name: address,    widget: text,   required: false }
          - { label: "Address (TH)", name: address_th, widget: text,   required: false }
          - { label: "Line OA URL",  name: line,       widget: string, required: false }
          - { label: Instagram,      name: instagram,  widget: string, required: false }
          - { label: TikTok,         name: tiktok,     widget: string, required: false }
      - name: siteinfo
        label: "Site Info"
        file: src/content/settings/siteinfo.json
        fields:
          - { label: "Site Name",        name: site_name, widget: string }
          - { label: "Tagline (EN)",     name: tagline,   widget: string }
          - { label: "Meta Description", name: meta_desc, widget: text }
ENDOFFILE
echo "✅  config.yml — flat fields, no nested objects"

# ── 3. Rewrite about.astro to read flat JSON keys ────────────
cat > src/pages/about.astro << 'ENDOFFILE'
---
import Layout from '../layouts/Layout.astro';
import Navbar from '../components/Navbar.astro';
import d from '../content/pages/about.json';

// Use uploaded photo first, then URL fallback, then placeholder
const photo = d.office_photo || d.office_photo_url || '';
---
<Layout title="About — TNC.18">
  <Navbar />

  <section class="hero">
    <div class="inner">
      <span class="label" data-en="About TNC.18" data-th="เกี่ยวกับ TNC.18">About TNC.18</span>
      <h1 data-en={d.hero_headline_en} data-th={d.hero_headline_th}>{d.hero_headline_en}</h1>
    </div>
  </section>

  <section class="split">
    <div class="split-inner">
      <div class="img-col">
        {photo
          ? <img src={photo} alt="TNC.18 Office" class="office-img" loading="lazy" />
          : <div class="img-ph"></div>
        }
        <p class="caption"
          data-en={d.office_caption_en}
          data-th={d.office_caption_th}>
          {d.office_caption_en}
        </p>
      </div>
      <div class="copy">
        <p data-en={d.bio_1_en} data-th={d.bio_1_th}>{d.bio_1_en}</p>
        <p data-en={d.bio_2_en} data-th={d.bio_2_th}>{d.bio_2_en}</p>
        <p data-en={d.bio_3_en} data-th={d.bio_3_th}>{d.bio_3_en}</p>
      </div>
    </div>
  </section>

  <section class="values">
    <div class="values-inner">
      <span class="section-label" data-en="Our Values" data-th="ค่านิยมของเรา">Our Values</span>
      <div class="values-grid">
        {[
          { n:'01', en:'Permanence', th:'ความยั่งยืน',  d_en:'We build for decades, not for the moment. Every material, joint, and detail is chosen to last.', d_th:'เราสร้างเพื่อทศวรรษ' },
          { n:'02', en:'Precision',  th:'ความแม่นยำ',   d_en:'Architecture is a discipline of exactness. We hold ourselves to tolerances that most firms consider unnecessary.', d_th:'สถาปัตยกรรมคือวินัยแห่งความถูกต้อง' },
          { n:'03', en:'Craft',      th:'ฝีมือ',        d_en:'We believe in the intelligence of the hand. Details are designed, not defaulted.', d_th:'เราเชื่อในสติปัญญาของมือ' },
          { n:'04', en:'Clarity',    th:'ความชัดเจน',   d_en:'Clear thinking produces clear buildings. We strip away everything that does not serve the project.', d_th:'การคิดที่ชัดเจนสร้างอาคารที่ชัดเจน' },
        ].map((v,i) => (
          <div class="value-item">
            <span class="vn">{v.n}</span>
            <h3 data-en={v.en} data-th={v.th}>{v.en}</h3>
            <p data-en={v.d_en} data-th={v.d_th}>{v.d_en}</p>
          </div>
        ))}
      </div>
    </div>
  </section>

  <section class="team">
    <div class="team-inner">
      <span class="section-label" style="color:rgba(247,244,239,0.3)" data-en="The Team" data-th="ทีมงาน">The Team</span>
      <p class="team-copy" data-en={d.team_en} data-th={d.team_th}>{d.team_en}</p>
      <a href="/contact" class="cta" data-en="Work with us →" data-th="ร่วมงานกับเรา →">Work with us →</a>
    </div>
  </section>

  <footer class="footer">
    <div class="footer-inner">
      <div>
        <span class="footer-logo">TNC<em>.</em>18</span>
        <p class="footer-sub" data-en="Architecture & Construction, Bangkok" data-th="สถาปัตยกรรมและการก่อสร้าง กรุงเทพฯ">Architecture & Construction, Bangkok</p>
      </div>
      <nav class="footer-nav">
        <a href="/projects" data-en="Projects" data-th="ผลงาน">Projects</a>
        <a href="/services" data-en="Services" data-th="บริการ">Services</a>
        <a href="/contact"  data-en="Contact"  data-th="ติดต่อ">Contact</a>
      </nav>
      <p class="footer-copy">© 2024 TNC.18</p>
    </div>
  </footer>
</Layout>

<style>
  .hero { background:var(--charcoal); padding:9rem 5rem 5rem; min-height:60vh; display:flex; align-items:flex-end; }
  .inner { max-width:800px; }
  .label { font-size:0.62rem; font-weight:500; letter-spacing:0.22em; text-transform:uppercase; color:var(--gold); display:block; margin-bottom:1.5rem; }
  .hero h1 { font-family:var(--font-serif); font-size:clamp(2.5rem,6vw,5rem); font-weight:300; color:var(--stone); line-height:1.1; }

  .split { background:var(--stone); padding:6rem 5rem; border-bottom:1px solid var(--stone-mid); }
  .split-inner { display:grid; grid-template-columns:1fr 1fr; gap:5rem; align-items:start; max-width:1100px; margin:0 auto; }
  .img-col { display:flex; flex-direction:column; gap:0.75rem; }
  .office-img { width:100%; aspect-ratio:3/4; object-fit:cover; display:block; }
  .img-ph { aspect-ratio:3/4; background:var(--stone-dark); width:100%; }
  .caption { font-size:0.6rem; letter-spacing:0.12em; color:var(--muted); margin:0; }
  .copy { padding-top:1rem; }
  .copy p { font-size:0.9rem; color:var(--ink); line-height:1.9; font-weight:300; margin-bottom:1.5rem; }

  .values { background:var(--stone-mid); padding:6rem 5rem; border-top:1px solid var(--stone-dark); }
  .values-inner { max-width:1000px; margin:0 auto; }
  .section-label { font-family:var(--font-sans); font-size:0.62rem; font-weight:500; letter-spacing:0.22em; text-transform:uppercase; color:var(--muted); display:block; margin-bottom:2.5rem; }
  .values-grid { display:grid; grid-template-columns:1fr 1fr; gap:3rem 4rem; }
  .value-item { border-top:1px solid var(--stone-dark); padding-top:1.5rem; }
  .vn { font-size:0.6rem; color:var(--gold); letter-spacing:0.12em; display:block; margin-bottom:0.75rem; }
  .value-item h3 { font-family:var(--font-serif); font-size:1.5rem; font-weight:300; color:var(--charcoal); margin-bottom:0.75rem; }
  .value-item p { font-size:0.84rem; color:var(--ink); line-height:1.8; font-weight:300; }

  .team { background:var(--charcoal); padding:6rem 5rem; text-align:center; }
  .team-inner { max-width:600px; margin:0 auto; }
  .team-copy { font-family:var(--font-serif); font-size:clamp(1.25rem,2vw,1.6rem); font-weight:300; font-style:italic; color:var(--stone); line-height:1.6; margin:1.5rem 0 2.5rem; }
  .cta { font-size:0.7rem; letter-spacing:0.16em; text-transform:uppercase; color:var(--gold); text-decoration:none; border-bottom:1px solid rgba(166,124,78,0.4); padding-bottom:2px; }
  .cta:hover { color:var(--warm-white); }

  .footer { background:#0F0E0C; padding:1.75rem 5rem; border-top:1px solid rgba(247,244,239,0.05); }
  .footer-inner { display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:1rem; }
  .footer-logo { font-family:var(--font-sans); font-size:0.85rem; font-weight:500; letter-spacing:0.1em; color:rgba(247,244,239,0.4); }
  .footer-logo em { font-style:normal; color:var(--gold); }
  .footer-sub { font-size:0.56rem; letter-spacing:0.1em; color:rgba(247,244,239,0.15); margin-top:0.2rem; }
  .footer-nav { display:flex; gap:2rem; }
  .footer-nav a { font-size:0.58rem; letter-spacing:0.1em; text-transform:uppercase; color:rgba(247,244,239,0.2); text-decoration:none; transition:color 0.3s; }
  .footer-nav a:hover { color:rgba(247,244,239,0.65); }
  .footer-copy { font-size:0.55rem; color:rgba(247,244,239,0.12); }

  @media (max-width:900px) {
    .hero { padding:9rem 1.75rem 3rem; }
    .split,.values,.team,.footer { padding-left:1.75rem; padding-right:1.75rem; }
    .split-inner { grid-template-columns:1fr; gap:2.5rem; }
    .values-grid { grid-template-columns:1fr; gap:2rem; }
    .footer-inner { flex-direction:column; align-items:flex-start; }
  }
</style>

<script>
  function applyLang(lang: string) {
    localStorage.setItem('tnc-lang', lang);
    document.documentElement.setAttribute('data-lang', lang);
    document.getElementById('lang-en')?.classList.toggle('active', lang === 'en');
    document.getElementById('lang-th')?.classList.toggle('active', lang === 'th');
    document.querySelectorAll('[data-en][data-th]').forEach(el => {
      el.textContent = lang === 'th' ? el.getAttribute('data-th') || '' : el.getAttribute('data-en') || '';
    });
  }
  applyLang(localStorage.getItem('tnc-lang') || 'en');
  document.getElementById('lang-toggle')?.addEventListener('click', () => {
    applyLang((document.documentElement.getAttribute('data-lang') || 'en') === 'en' ? 'th' : 'en');
  });
</script>
ENDOFFILE
echo "✅  about.astro — reads flat JSON keys directly"

git add .
git commit -m "fix: flatten about.json + CMS config + page reads correctly"
git push origin main

echo ""
echo "════════════════════════════════════════════════════"
echo "✅  Done — Cloudflare rebuilds in ~1 min"
echo ""
echo "After rebuild, in CMS → Page Content → About Page:"
echo "  · All fields are now flat — no nested sections"
echo "  · 'Office Photo (upload)' — upload your photo"
echo "  · 'Office Photo (paste URL)' — or paste a URL"
echo "  · All bio paragraphs editable directly"
echo "  · Publish → live site updates within 1 min"
echo "════════════════════════════════════════════════════"
echo ""
