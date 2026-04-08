#!/bin/bash
# ============================================================
# TNC.18 — Fix About Page + Photo Upload
# ============================================================

set -e
cd "/Users/marketingworks/Downloads/tnc-18-project/tnc-18"
git pull origin main --rebase

echo ""
echo "🔧 Fixing About page..."
echo ""

# ── Rewrite about.astro cleanly ──────────────────────────────
cat > src/pages/about.astro << 'ENDOFFILE'
---
import Layout from '../layouts/Layout.astro';
import Navbar from '../components/Navbar.astro';
import aboutData from '../content/pages/about.json';
---
<Layout title="About — Eighteen Years of Craft">
  <Navbar />

  <!-- HERO -->
  <section class="about-hero">
    <div class="about-hero-inner">
      <span class="page-label" data-anim="rise"
        data-en="About TNC.18"
        data-th="เกี่ยวกับ TNC.18">About TNC.18</span>
      <h1 data-split
        data-en={aboutData.hero_headline_en}
        data-th={aboutData.hero_headline_th}>
        {aboutData.hero_headline_en}
      </h1>
    </div>
  </section>

  <!-- SPLIT: image left, text right -->
  <section class="about-split">
    <div class="about-split-inner">

      <div class="about-img-col">
        {aboutData.hero_image
          ? <img src={aboutData.hero_image} alt="TNC.18 Office" class="about-img" loading="lazy" />
          : <div class="about-img-ph"></div>
        }
        <p class="about-img-caption"
          data-en={aboutData.office_image_caption_en}
          data-th={aboutData.office_image_caption_th}>
          {aboutData.office_image_caption_en}
        </p>
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

  <!-- VALUES -->
  <section class="values">
    <div class="values-inner">
      <span class="section-label" data-anim="rise"
        data-en="Our Values"
        data-th="ค่านิยมของเรา">Our Values</span>
      <div class="values-grid">
        {[
          { n:'01', en:'Permanence', th:'ความยั่งยืน',  desc_en:'We build for decades, not for the moment. Every material, joint, and detail is chosen to last.', desc_th:'เราสร้างเพื่อทศวรรษ ไม่ใช่เพื่อช่วงเวลา' },
          { n:'02', en:'Precision',  th:'ความแม่นยำ',   desc_en:'Architecture is a discipline of exactness. We hold ourselves to tolerances that most firms consider unnecessary.', desc_th:'สถาปัตยกรรมคือวินัยแห่งความถูกต้อง' },
          { n:'03', en:'Craft',      th:'ฝีมือ',        desc_en:'We believe in the intelligence of the hand. Details are designed, not defaulted. Materiality is deliberate.', desc_th:'เราเชื่อในสติปัญญาของมือ' },
          { n:'04', en:'Clarity',    th:'ความชัดเจน',   desc_en:'Clear thinking produces clear buildings. We strip away everything that does not serve the project.', desc_th:'การคิดที่ชัดเจนสร้างอาคารที่ชัดเจน' },
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

  <!-- TEAM BAND -->
  <section class="team-band">
    <div class="team-inner">
      <span class="section-label" data-anim="rise"
        data-en="The Team"
        data-th="ทีมงาน">The Team</span>
      <p class="team-copy" data-anim="rise" data-delay="1"
        data-en={aboutData.team_statement_en}
        data-th={aboutData.team_statement_th}>
        {aboutData.team_statement_en}
      </p>
      <a href="/contact" class="cta-link" data-anim="rise" data-delay="2"
        data-en="Work with us →"
        data-th="ร่วมงานกับเรา →">Work with us →</a>
    </div>
  </section>

  <!-- FOOTER -->
  <footer class="footer">
    <div class="footer-inner">
      <div>
        <span class="footer-logo">TNC<em>.</em>18</span>
        <p class="footer-sub"
          data-en="Architecture & Construction, Bangkok"
          data-th="สถาปัตยกรรมและการก่อสร้าง กรุงเทพฯ">
          Architecture & Construction, Bangkok
        </p>
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
  /* ── HERO ── */
  .about-hero {
    background: var(--charcoal);
    padding: 68px 5rem 5rem; /* 68px = navbar height */
    min-height: 60vh;
    display: flex;
    align-items: flex-end;
  }

  .about-hero-inner { max-width: 800px; }

  .page-label {
    font-size: 0.62rem;
    font-weight: 500;
    letter-spacing: 0.22em;
    text-transform: uppercase;
    color: var(--gold);
    display: block;
    margin-bottom: 1.5rem;
  }

  .about-hero h1 {
    font-family: var(--font-serif);
    font-size: clamp(2.5rem, 6vw, 5rem);
    font-weight: 300;
    color: var(--stone);
    line-height: 1.1;
  }

  /* ── SPLIT ── */
  .about-split {
    background: var(--stone);
    padding: 6rem 5rem;
    border-bottom: 1px solid var(--stone-mid);
  }

  .about-split-inner {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 5rem;
    align-items: start;
    max-width: 1100px;
    margin: 0 auto;
  }

  .about-img-col { display: flex; flex-direction: column; gap: 0.75rem; }

  .about-img {
    width: 100%;
    aspect-ratio: 3/4;
    object-fit: cover;
    display: block;
  }

  .about-img-ph {
    aspect-ratio: 3/4;
    background: var(--stone-dark);
    width: 100%;
  }

  .about-img-caption {
    font-size: 0.6rem;
    letter-spacing: 0.12em;
    color: var(--muted);
    margin: 0;
  }

  .about-copy { padding-top: 1rem; }

  .about-copy p {
    font-size: 0.9rem;
    color: var(--ink);
    line-height: 1.9;
    font-weight: 300;
    margin-bottom: 1.5rem;
  }

  /* ── VALUES ── */
  .values {
    background: var(--stone-mid);
    padding: 6rem 5rem;
    border-top: 1px solid var(--stone-dark);
  }

  .values-inner { max-width: 1000px; margin: 0 auto; }

  .section-label {
    font-family: var(--font-sans);
    font-size: 0.62rem;
    font-weight: 500;
    letter-spacing: 0.22em;
    text-transform: uppercase;
    color: var(--muted);
    display: block;
    margin-bottom: 2.5rem;
  }

  .values-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 3rem 4rem;
  }

  .value-item {
    border-top: 1px solid var(--stone-dark);
    padding-top: 1.5rem;
  }

  .value-n {
    font-size: 0.6rem;
    color: var(--gold);
    letter-spacing: 0.12em;
    display: block;
    margin-bottom: 0.75rem;
  }

  .value-title {
    font-family: var(--font-serif);
    font-size: 1.5rem;
    font-weight: 300;
    color: var(--charcoal);
    margin-bottom: 0.75rem;
  }

  .value-desc {
    font-size: 0.84rem;
    color: var(--ink);
    line-height: 1.8;
    font-weight: 300;
  }

  /* ── TEAM BAND ── */
  .team-band {
    background: var(--charcoal);
    padding: 6rem 5rem;
    text-align: center;
  }

  .team-inner { max-width: 600px; margin: 0 auto; }

  .team-inner .section-label {
    color: rgba(247,244,239,0.3);
    margin-bottom: 1.5rem;
  }

  .team-copy {
    font-family: var(--font-serif);
    font-size: clamp(1.25rem, 2vw, 1.6rem);
    font-weight: 300;
    font-style: italic;
    color: var(--stone);
    line-height: 1.6;
    margin-bottom: 2.5rem;
  }

  .cta-link {
    font-size: 0.7rem;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    color: var(--gold);
    text-decoration: none;
    border-bottom: 1px solid rgba(166,124,78,0.4);
    padding-bottom: 2px;
    transition: color 0.3s, border-color 0.3s;
  }

  .cta-link:hover { color: var(--warm-white); border-color: rgba(247,244,239,0.4); }

  /* ── FOOTER ── */
  .footer { background: #0F0E0C; padding: 1.75rem 5rem; border-top: 1px solid rgba(247,244,239,0.05); }
  .footer-inner { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1rem; }
  .footer-logo { font-family: var(--font-sans); font-size: 0.85rem; font-weight: 500; letter-spacing: 0.1em; color: rgba(247,244,239,0.4); }
  .footer-logo em { font-style: normal; color: var(--gold); }
  .footer-sub { font-size: 0.56rem; letter-spacing: 0.1em; color: rgba(247,244,239,0.15); margin-top: 0.2rem; }
  .footer-nav { display: flex; gap: 2rem; }
  .footer-nav a { font-size: 0.58rem; letter-spacing: 0.1em; text-transform: uppercase; color: rgba(247,244,239,0.2); text-decoration: none; transition: color 0.3s; }
  .footer-nav a:hover { color: rgba(247,244,239,0.65); }
  .footer-copy { font-size: 0.55rem; color: rgba(247,244,239,0.12); }

  /* ── RESPONSIVE ── */
  @media (max-width: 900px) {
    .about-hero { padding: 68px 1.75rem 3rem; }
    .about-split, .values, .team-band, .footer { padding-left: 1.75rem; padding-right: 1.75rem; }
    .about-split-inner { grid-template-columns: 1fr; gap: 2.5rem; }
    .values-grid { grid-template-columns: 1fr; gap: 2rem; }
    .footer-inner { flex-direction: column; align-items: flex-start; }
  }
</style>

<script>
  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const el = entry.target as HTMLElement;
      if (el.dataset.anim === 'rise') {
        el.style.opacity = '1';
        el.style.transform = 'translateY(0)';
      }
      el.querySelectorAll('.word').forEach((w: any) => {
        w.style.transform = 'translateY(0)';
        w.style.opacity = '1';
      });
      io.unobserve(el);
    });
  }, { threshold: 0.12 });

  document.querySelectorAll('[data-anim="rise"]').forEach((el: any) => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = `opacity 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s, transform 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s`;
    io.observe(el);
  });

  document.querySelectorAll('[data-split]').forEach(el => {
    const text = el.textContent?.trim() || '';
    el.innerHTML = text.split(' ').map((w, i) =>
      `<span style="display:inline-block;overflow:hidden"><span class="word" style="display:inline-block;transform:translateY(105%);opacity:0;transition:transform 0.75s cubic-bezier(0.16,1,0.3,1) ${i*0.055}s,opacity 0.5s ease ${i*0.055}s">${w}</span></span>`
    ).join(' ');
    io.observe(el);
  });

  function applyLang(lang: string) {
    localStorage.setItem('tnc-lang', lang);
    document.documentElement.setAttribute('data-lang', lang);
    document.getElementById('lang-en')?.classList.toggle('active', lang === 'en');
    document.getElementById('lang-th')?.classList.toggle('active', lang === 'th');
    document.querySelectorAll('[data-en][data-th]').forEach(el => {
      el.textContent = lang === 'th'
        ? el.getAttribute('data-th') || ''
        : el.getAttribute('data-en') || '';
    });
  }
  applyLang(localStorage.getItem('tnc-lang') || 'en');
  document.getElementById('lang-toggle')?.addEventListener('click', () => {
    applyLang((document.documentElement.getAttribute('data-lang') || 'en') === 'en' ? 'th' : 'en');
  });
</script>
ENDOFFILE
echo "✅  src/pages/about.astro — fully rewritten"

git add .
git commit -m "fix: about page hero padding + office image display from CMS"
git push origin main

echo ""
echo "════════════════════════════════════════════════════"
echo "✅  Done — wait 1 min then refresh:"
echo "    https://tnc-18-project.pages.dev/about"
echo ""
echo "To upload your office photo:"
echo "  CMS → Page Content → About Page"
echo "  → Hero Image → Choose image → upload your photo"
echo "  → Publish"
echo "════════════════════════════════════════════════════"
echo ""
