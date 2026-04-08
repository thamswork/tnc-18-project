#!/bin/bash
# ============================================================
# TNC.18 — Add all pages to CMS
# Makes About, Homepage, Contact fully editable from admin
# ============================================================

set -e
cd "/Users/marketingworks/Downloads/tnc-18-project/tnc-18"

echo ""
echo "📋 Adding all pages to CMS..."
echo ""

# ── 1. Create content files for page content ─────────────────
mkdir -p src/content/pages

cat > src/content/pages/about.json << 'ENDOFFILE'
{
  "hero_headline_en": "Built on craft. Defined by permanence.",
  "hero_headline_th": "สร้างด้วยฝีมือ นิยามด้วยความยั่งยืน",
  "hero_image": "",
  "bio_1_en": "TNC.18 was founded in 2006 with a single conviction — that buildings should outlast the trends of the moment they were built in. Eighteen years later, that conviction remains unchanged.",
  "bio_1_th": "TNC.18 ก่อตั้งขึ้นในปี 2549 ด้วยความเชื่อมั่นเดียว — ว่าอาคารควรคงอยู่ยาวนานกว่ากระแสของยุคสมัยที่สร้างขึ้น สิบแปดปีต่อมา ความเชื่อมั่นนั้นยังคงไม่เปลี่ยนแปลง",
  "bio_2_en": "We are a Bangkok-based firm of architects, engineers, and builders. Our work spans private residences, commercial towers, interior commissions, and hospitality projects across Thailand.",
  "bio_2_th": "เราเป็นบริษัทที่ตั้งอยู่ในกรุงเทพฯ ประกอบด้วยสถาปนิก วิศวกร และผู้สร้าง ผลงานของเราครอบคลุมทั้งที่พักอาศัยส่วนตัว อาคารพาณิชย์ งานออกแบบภายใน และโครงการการบริการทั่วประเทศไทย",
  "bio_3_en": "Every project begins with the same question: what will this building mean in fifty years? That question shapes every material choice, every structural decision, every detail.",
  "bio_3_th": "ทุกโครงการเริ่มต้นด้วยคำถามเดียวกัน: อาคารนี้จะมีความหมายอะไรในห้าสิบปี? คำถามนั้นกำหนดทุกการเลือกวัสดุ ทุกการตัดสินใจด้านโครงสร้าง ทุกรายละเอียด",
  "office_image_caption_en": "TNC.18 Headquarters, Bangkok",
  "office_image_caption_th": "สำนักงานใหญ่ TNC.18 กรุงเทพฯ",
  "team_statement_en": "50+ architects, engineers, project managers, and site specialists. Bangkok-based. Regionally experienced.",
  "team_statement_th": "สถาปนิก วิศวกร ผู้จัดการโครงการ และผู้เชี่ยวชาญงานหน้างานมากกว่า 50 คน"
}
ENDOFFILE
echo "✅  src/content/pages/about.json"

cat > src/content/pages/homepage.json << 'ENDOFFILE'
{
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
echo "✅  src/content/pages/homepage.json"

# ── 2. Update CMS config to include page editors ─────────────
cat > public/admin/config.yml << 'ENDOFFILE'
backend:
  name: github
  repo: thamswork/tnc-18-project
  branch: main
  base_url: https://tnc-18-auth.tyme-sak.workers.dev

media_folder: public/images/uploads
public_folder: /images/uploads

collections:

  # ── PROJECTS ────────────────────────────────────────────────
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

  # ── SERVICES ────────────────────────────────────────────────
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

  # ── NEWS ────────────────────────────────────────────────────
  - name: news
    label: "News & Updates"
    folder: src/content/news
    create: true
    delete: true
    slug: "{{year}}-{{month}}-{{slug}}"
    fields:
      - { label: "Title (EN)", name: title,  widget: string }
      - { label: "Title (TH)", name: title_th, widget: string, required: false }
      - { label: "Date",       name: date,   widget: datetime, date_format: YYYY-MM-DD, time_format: false }
      - { label: "Cover",      name: cover,  widget: image,    required: false }
      - { label: "Excerpt (EN)", name: excerpt, widget: text,  required: false }
      - { label: "Body",       name: body,   widget: markdown }

  # ── PAGE CONTENT ────────────────────────────────────────────
  - name: pages
    label: "Page Content"
    delete: false
    editor: { preview: false }
    files:

      - name: homepage
        label: "Homepage Text"
        file: src/content/pages/homepage.json
        fields:
          - label: "Hero Section"
            name: hero
            widget: object
            fields:
              - { label: "Location text (EN)", name: hero_location_en, widget: string }
              - { label: "Location text (TH)", name: hero_location_th, widget: string }
              - { label: "Line 1 (EN)",         name: hero_line1_en,   widget: string }
              - { label: "Line 1 (TH)",         name: hero_line1_th,   widget: string }
              - { label: "Line 2 (EN)",         name: hero_line2_en,   widget: string }
              - { label: "Line 2 (TH)",         name: hero_line2_th,   widget: string }
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
              - { label: "Headline (EN)", name: about_headline_en, widget: string }
              - { label: "Headline (TH)", name: about_headline_th, widget: string }
              - { label: "Body text (EN)", name: about_body_en, widget: text }
              - { label: "Body text (TH)", name: about_body_th, widget: text }
              - { label: "Years stat",       name: stats_years,       widget: string }
              - { label: "Projects stat",    name: stats_projects,    widget: string }
              - { label: "Specialists stat", name: stats_specialists, widget: string }
          - label: "Contact Band"
            name: contact_band
            widget: object
            fields:
              - { label: "Headline (EN)", name: contact_headline_en, widget: string }
              - { label: "Headline (TH)", name: contact_headline_th, widget: string }
              - { label: "Body text (EN)", name: contact_body_en, widget: text }
              - { label: "Body text (TH)", name: contact_body_th, widget: text }

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
              - { label: "Hero Image",    name: hero_image,        widget: image, required: false }
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
          - label: "Office"
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

  # ── GLOBAL SETTINGS ─────────────────────────────────────────
  - name: settings
    label: "Global Settings"
    delete: false
    editor: { preview: false }
    files:

      - name: contact
        label: "Contact & Social"
        file: src/content/settings/contact.json
        fields:
          - { label: Phone,           name: phone,     widget: string }
          - { label: Email,           name: email,     widget: string }
          - { label: "Address (EN)",  name: address,   widget: text,   required: false }
          - { label: "Address (TH)",  name: address_th,widget: text,   required: false }
          - { label: "Line OA URL",   name: line,      widget: string, required: false }
          - { label: Instagram,       name: instagram, widget: string, required: false }
          - { label: TikTok,          name: tiktok,    widget: string, required: false }

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
echo "✅  public/admin/config.yml — Page Content collection added"

# ── 3. Update about.astro to read from CMS ───────────────────
cat > src/pages/about.astro << 'ENDOFFILE'
---
import Layout from '../layouts/Layout.astro';
import Navbar from '../components/Navbar.astro';
import aboutData from '../content/pages/about.json';
---
<Layout title="About — Eighteen Years of Craft">
  <Navbar />

  <section class="about-hero">
    <div class="about-hero-inner">
      <span class="page-label" data-anim="rise" data-en="About TNC.18" data-th="เกี่ยวกับ TNC.18">About TNC.18</span>
      <h1 data-split
        data-en={aboutData.hero_headline_en}
        data-th={aboutData.hero_headline_th}>
        {aboutData.hero_headline_en}
      </h1>
    </div>
  </section>

  <section class="about-split">
    <div class="about-split-inner">
      <div class="about-img-col">
        {aboutData.hero_image
          ? <img src={aboutData.hero_image} alt="TNC.18 Office" class="about-img" />
          : <div class="about-img-ph"></div>
        }
        <div class="about-img-caption" data-anim="rise"
          data-en={aboutData.office_image_caption_en}
          data-th={aboutData.office_image_caption_th}>
          {aboutData.office_image_caption_en}
        </div>
      </div>
      <div class="about-copy">
        <p data-anim="rise" data-delay="1"
          data-en={aboutData.bio_1_en}
          data-th={aboutData.bio_1_th}>
          {aboutData.bio_1_en}
        </p>
        <p data-anim="rise" data-delay="2"
          data-en={aboutData.bio_2_en}
          data-th={aboutData.bio_2_th}>
          {aboutData.bio_2_en}
        </p>
        <p data-anim="rise" data-delay="3"
          data-en={aboutData.bio_3_en}
          data-th={aboutData.bio_3_th}>
          {aboutData.bio_3_en}
        </p>
      </div>
    </div>
  </section>

  <section class="values">
    <div class="values-inner">
      <span class="section-label" data-anim="rise" data-en="Our Values" data-th="ค่านิยมของเรา">Our Values</span>
      <div class="values-grid">
        {[
          { n:'01', en:'Permanence', th:'ความยั่งยืน', desc_en:'We build for decades, not for the moment. Every material, joint, and detail is chosen to last.', desc_th:'เราสร้างเพื่อทศวรรษ ไม่ใช่เพื่อช่วงเวลา' },
          { n:'02', en:'Precision',  th:'ความแม่นยำ',  desc_en:'Architecture is a discipline of exactness. We hold ourselves to tolerances that most firms consider unnecessary.', desc_th:'สถาปัตยกรรมคือวินัยแห่งความถูกต้อง' },
          { n:'03', en:'Craft',      th:'ฝีมือ',       desc_en:'We believe in the intelligence of the hand. Details are designed, not defaulted. Materiality is deliberate.', desc_th:'เราเชื่อในสติปัญญาของมือ รายละเอียดถูกออกแบบ ไม่ใช่ถูกกำหนดโดยค่าเริ่มต้น' },
          { n:'04', en:'Clarity',    th:'ความชัดเจน',  desc_en:'Clear thinking produces clear buildings. We strip away everything that does not serve the project.', desc_th:'การคิดที่ชัดเจนสร้างอาคารที่ชัดเจน' },
        ].map((v, i) => (
          <div class="value-item" data-anim="rise" data-delay={String((i%2)+1)}>
            <span class="value-n">{v.n}</span>
            <h3 class="value-title" data-en={v.en} data-th={v.th}>{v.en}</h3>
            <p class="value-desc" data-en={v.desc_en} data-th={v.desc_th}>{v.desc_en}</p>
          </div>
        ))}
      </div>
    </div>
  </section>

  <section class="team-band">
    <div class="team-inner">
      <span class="section-label" data-anim="rise" data-en="The Team" data-th="ทีมงาน">The Team</span>
      <p class="team-copy" data-anim="rise" data-delay="1"
        data-en={aboutData.team_statement_en}
        data-th={aboutData.team_statement_th}>
        {aboutData.team_statement_en}
      </p>
      <a href="/contact" class="cta-link" data-anim="rise" data-delay="2"
        data-en="Work with us →" data-th="ร่วมงานกับเรา →">Work with us →</a>
    </div>
  </section>

  <footer class="footer">
    <div class="footer-inner">
      <div><span class="footer-logo">TNC<em>.</em>18</span></div>
      <nav class="footer-nav">
        <a href="/projects" data-en="Projects" data-th="ผลงาน">Projects</a>
        <a href="/services" data-en="Services" data-th="บริการ">Services</a>
        <a href="/contact" data-en="Contact" data-th="ติดต่อ">Contact</a>
      </nav>
      <p class="footer-copy">© 2024 TNC.18</p>
    </div>
  </footer>
</Layout>

<style>
  .about-hero { background:var(--charcoal); padding:10rem 5rem 5rem; min-height:55vh; display:flex; align-items:flex-end; }
  .about-hero-inner { max-width:800px; }
  .page-label { font-size:0.62rem; font-weight:500; letter-spacing:0.22em; text-transform:uppercase; color:var(--gold); display:block; margin-bottom:1.5rem; }
  .about-hero h1 { font-family:var(--font-serif); font-size:clamp(2.5rem,6vw,5rem); font-weight:300; color:var(--stone); line-height:1.1; }

  .about-split { background:var(--stone); padding:6rem 5rem; border-bottom:1px solid var(--stone-mid); }
  .about-split-inner { display:grid; grid-template-columns:1fr 1fr; gap:5rem; align-items:start; max-width:1100px; margin:0 auto; }
  .about-img { width:100%; aspect-ratio:3/4; object-fit:cover; }
  .about-img-ph { aspect-ratio:3/4; background:var(--stone-dark); }
  .about-img-caption { margin-top:0.75rem; font-size:0.6rem; letter-spacing:0.12em; color:var(--muted); }
  .about-copy p { font-size:0.9rem; color:var(--ink); line-height:1.9; font-weight:300; margin-bottom:1.5rem; }

  .values { background:var(--stone-mid); padding:6rem 5rem; border-top:1px solid var(--stone-dark); }
  .values-inner { max-width:1000px; margin:0 auto; }
  .section-label { font-family:var(--font-sans); font-size:0.62rem; font-weight:500; letter-spacing:0.22em; text-transform:uppercase; color:var(--muted); display:block; margin-bottom:2.5rem; }
  .values-grid { display:grid; grid-template-columns:1fr 1fr; gap:3rem 4rem; }
  .value-item { border-top:1px solid var(--stone-dark); padding-top:1.5rem; }
  .value-n { font-size:0.6rem; color:var(--gold); letter-spacing:0.12em; display:block; margin-bottom:0.75rem; }
  .value-title { font-family:var(--font-serif); font-size:1.5rem; font-weight:300; color:var(--charcoal); margin-bottom:0.75rem; }
  .value-desc { font-size:0.84rem; color:var(--ink); line-height:1.8; font-weight:300; }

  .team-band { background:var(--charcoal); padding:6rem 5rem; text-align:center; }
  .team-inner { max-width:600px; margin:0 auto; }
  .team-inner .section-label { color:rgba(247,244,239,0.3); margin-bottom:1.5rem; }
  .team-copy { font-family:var(--font-serif); font-size:clamp(1.25rem,2vw,1.6rem); font-weight:300; font-style:italic; color:var(--stone); line-height:1.6; margin-bottom:2.5rem; }
  .cta-link { font-size:0.7rem; letter-spacing:0.16em; text-transform:uppercase; color:var(--gold); text-decoration:none; border-bottom:1px solid rgba(166,124,78,0.4); padding-bottom:2px; transition:color 0.3s,border-color 0.3s; }
  .cta-link:hover { color:var(--warm-white); border-color:rgba(247,244,239,0.4); }

  .footer { background:#0F0E0C; padding:1.75rem 5rem; border-top:1px solid rgba(247,244,239,0.05); }
  .footer-inner { display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:1rem; }
  .footer-logo { font-family:var(--font-sans); font-size:0.85rem; font-weight:500; letter-spacing:0.1em; color:rgba(247,244,239,0.4); }
  .footer-logo em { font-style:normal; color:var(--gold); }
  .footer-nav { display:flex; gap:2rem; }
  .footer-nav a { font-size:0.58rem; letter-spacing:0.1em; text-transform:uppercase; color:rgba(247,244,239,0.2); text-decoration:none; transition:color 0.3s; }
  .footer-nav a:hover { color:rgba(247,244,239,0.65); }
  .footer-copy { font-size:0.55rem; color:rgba(247,244,239,0.12); }

  @media (max-width:900px) {
    .about-hero,.about-split,.values,.team-band,.footer { padding-left:1.75rem; padding-right:1.75rem; }
    .about-split-inner { grid-template-columns:1fr; gap:2.5rem; }
    .values-grid { grid-template-columns:1fr; gap:2rem; }
    .footer-inner { flex-direction:column; align-items:flex-start; }
  }
</style>
<script>
  const io=new IntersectionObserver((entries)=>{entries.forEach(entry=>{if(!entry.isIntersecting)return;const el=entry.target as HTMLElement;if(el.dataset.anim==='rise'){el.style.opacity='1';el.style.transform='translateY(0)';}el.querySelectorAll('.word').forEach((w:any)=>{w.style.transform='translateY(0)';w.style.opacity='1';});io.unobserve(el);});},{threshold:0.12});
  document.querySelectorAll('[data-anim="rise"]').forEach((el:any)=>{el.style.opacity='0';el.style.transform='translateY(20px)';el.style.transition=`opacity 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s,transform 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s`;io.observe(el);});
  document.querySelectorAll('[data-split]').forEach(el=>{const text=el.textContent?.trim()||'';el.innerHTML=text.split(' ').map((w,i)=>`<span style="display:inline-block;overflow:hidden"><span class="word" style="display:inline-block;transform:translateY(105%);opacity:0;transition:transform 0.75s cubic-bezier(0.16,1,0.3,1) ${i*0.055}s,opacity 0.5s ease ${i*0.055}s">${w}</span></span>`).join(' ');io.observe(el);});
  function applyLang(lang:string){localStorage.setItem('tnc-lang',lang);document.documentElement.setAttribute('data-lang',lang);document.getElementById('lang-en')?.classList.toggle('active',lang==='en');document.getElementById('lang-th')?.classList.toggle('active',lang==='th');document.querySelectorAll('[data-en][data-th]').forEach(el=>{el.textContent=lang==='th'?el.getAttribute('data-th')||'':el.getAttribute('data-en')||'';});}
  applyLang(localStorage.getItem('tnc-lang')||'en');
  document.getElementById('lang-toggle')?.addEventListener('click',()=>{applyLang((document.documentElement.getAttribute('data-lang')||'en')==='en'?'th':'en');});
</script>
ENDOFFILE
echo "✅  src/pages/about.astro — now reads from CMS"

git add .
git commit -m "feat: all pages editable from CMS — About, Homepage, Contact, Services, News"
git push origin main

echo ""
echo "════════════════════════════════════════════════════════"
echo "✅  Done — wait 1 min then refresh admin"
echo "════════════════════════════════════════════════════════"
echo ""
echo "In CMS admin you can now edit:"
echo "  📄 Page Content → Homepage Text"
echo "  📄 Page Content → About Page"
echo "  📋 Projects, Services, News"
echo "  ⚙️  Global Settings → Contact, Colors, Site Info"
echo ""
