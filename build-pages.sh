#!/bin/bash
# ============================================================
# TNC.18 — Full Site Pages Build
# Builds: About, Services, Projects, Contact, News
# Wires: Homepage projects from CMS content files
# ============================================================

set -e
echo ""
echo "🏛  TNC.18 — Building all pages..."
echo ""

mkdir -p src/pages/projects
mkdir -p src/content/projects
mkdir -p src/content/news

# ══════════════════════════════════════════════════════════════
# 1. src/content/config.ts — Astro content collections schema
# ══════════════════════════════════════════════════════════════
cat > src/content/config.ts << 'ENDOFFILE'
import { defineCollection, z } from 'astro:content';

const projects = defineCollection({
  type: 'content',
  schema: z.object({
    title:          z.string(),
    title_th:       z.string().optional(),
    year:           z.number(),
    category:       z.string(),
    category_th:    z.string().optional(),
    cover:          z.string(),
    description:    z.string().optional(),
    description_th: z.string().optional(),
    gallery:        z.array(z.string()).optional(),
    client:         z.string().optional(),
    location:       z.string().optional(),
    area:           z.number().optional(),
    featured:       z.boolean().default(false),
  }),
});

const services = defineCollection({
  type: 'content',
  schema: z.object({
    order:          z.number(),
    title:          z.string(),
    title_th:       z.string().optional(),
    description:    z.string().optional(),
    description_th: z.string().optional(),
  }),
});

const news = defineCollection({
  type: 'content',
  schema: z.object({
    title:     z.string(),
    title_th:  z.string().optional(),
    date:      z.string(),
    cover:     z.string().optional(),
    excerpt:   z.string().optional(),
    excerpt_th:z.string().optional(),
  }),
});

export const collections = { projects, services, news };
ENDOFFILE
echo "✅  src/content/config.ts"

# ══════════════════════════════════════════════════════════════
# 2. UPDATED src/pages/index.astro — CMS-wired homepage
# ══════════════════════════════════════════════════════════════
cat > src/pages/index.astro << 'ENDOFFILE'
---
import Layout from '../layouts/Layout.astro';
import Navbar from '../components/Navbar.astro';
import { getCollection } from 'astro:content';

// Pull featured projects from CMS, sorted by year desc, max 4
const allProjects = await getCollection('projects');
const featured = allProjects
  .filter(p => p.data.featured)
  .sort((a, b) => b.data.year - a.data.year)
  .slice(0, 4);

// Fallback if no featured projects yet
const projects = featured.length > 0 ? featured : allProjects
  .sort((a, b) => b.data.year - a.data.year)
  .slice(0, 4);

// Pull services sorted by order
const allServices = await getCollection('services');
const services = allServices.sort((a, b) => a.data.order - b.data.order);
---

<Layout title="Architecture & Construction Excellence">
  <Navbar />

  <!-- HERO -->
  <section class="hero">
    <div class="hero-media">
      <video autoplay muted loop playsinline>
        <source src="/hero.mp4" type="video/mp4" />
      </video>
      <div class="hero-fallback"></div>
      <div class="hero-vignette"></div>
    </div>
    <div class="hero-body">
      <p class="hero-location" data-en="Bangkok · Thailand" data-th="กรุงเทพมหานคร · ประเทศไทย">Bangkok · Thailand</p>
      <h1 class="hero-headline">
        <span class="hero-line" data-split data-en="We Build" data-th="เราสร้าง">We Build</span>
        <span class="hero-line hero-italic" data-split data-en="What Lasts." data-th="สิ่งที่ยั่งยืน">What Lasts.</span>
      </h1>
      <div class="hero-rule"></div>
    </div>
    <div class="hero-foot">
      <a href="/projects" class="hero-cta" data-en="View Our Work" data-th="ดูผลงานของเรา">
        View Our Work <span class="hero-arrow">→</span>
      </a>
      <p class="hero-tag" data-en="Architecture · Engineering · Construction" data-th="สถาปัตยกรรม · วิศวกรรม · การก่อสร้าง">
        Architecture · Engineering · Construction
      </p>
    </div>
  </section>

  <!-- STATEMENT -->
  <section class="statement">
    <div class="statement-inner">
      <div class="statement-side">
        <span class="tag-label" data-anim="rise">TNC.18</span>
        <div class="gold-line" data-anim="line"></div>
      </div>
      <blockquote class="statement-quote" data-split data-delay="1"
        data-en="Every structure we build carries a single promise — that it will outlast the moment it was made for."
        data-th="ทุกสิ่งที่เราสร้างมีคำสัญญาเดียว — ว่ามันจะคงอยู่ยาวนานกว่าช่วงเวลาที่มันถูกสร้างขึ้น">
        Every structure we build carries a single promise — that it will outlast the moment it was made for.
      </blockquote>
    </div>
  </section>

  <!-- PROJECTS — from CMS -->
  <section class="projects">
    <header class="section-header" data-anim="rise">
      <span class="section-label" data-en="Selected Work" data-th="ผลงานคัดสรร">Selected Work</span>
      <a href="/projects" class="link-sm" data-en="All Projects →" data-th="ผลงานทั้งหมด →">All Projects →</a>
    </header>

    <div class="mosaic">
      <div class="mosaic-row mosaic-row--top">
        {projects.slice(0, 2).map((p, i) => (
          <article class="mosaic-card" data-anim="rise" data-delay={String(i + 1)}>
            <a href={`/projects/${p.slug}`} class="mosaic-link">
              <div class="mosaic-img">
                {p.data.cover && p.data.cover !== '/images/uploads/silom-residence.jpg'
                  ? <img src={p.data.cover} alt={p.data.title} loading="lazy" />
                  : <div class="mosaic-ph" style={`background:${['#C8C2B2','#B0AA9C','#989082','#7E786C'][i]};`}></div>
                }
                <div class="mosaic-overlay">
                  <div class="mosaic-overlay-inner">
                    <span class="mosaic-cat" data-en={p.data.category} data-th={p.data.category_th || p.data.category}>{p.data.category}</span>
                    <h2 class="mosaic-title" data-en={p.data.title} data-th={p.data.title_th || p.data.title}>{p.data.title}</h2>
                    <span class="mosaic-year">{p.data.year}</span>
                  </div>
                  <span class="mosaic-arrow">→</span>
                </div>
              </div>
            </a>
          </article>
        ))}
      </div>

      <div class="mosaic-row mosaic-row--bot">
        {projects.slice(2, 4).map((p, i) => (
          <article class={`mosaic-card ${i === 0 ? 'mosaic-card--portrait' : 'mosaic-card--wide'}`} data-anim="rise" data-delay={String(i + 3)}>
            <a href={`/projects/${p.slug}`} class="mosaic-link">
              <div class="mosaic-img">
                {p.data.cover && p.data.cover !== '/images/uploads/silom-residence.jpg'
                  ? <img src={p.data.cover} alt={p.data.title} loading="lazy" />
                  : <div class="mosaic-ph" style={`background:${['#989082','#7E786C'][i]};`}></div>
                }
                <div class="mosaic-overlay">
                  <div class="mosaic-overlay-inner">
                    <span class="mosaic-cat" data-en={p.data.category} data-th={p.data.category_th || p.data.category}>{p.data.category}</span>
                    <h2 class="mosaic-title" data-en={p.data.title} data-th={p.data.title_th || p.data.title}>{p.data.title}</h2>
                    <span class="mosaic-year">{p.data.year}</span>
                  </div>
                  <span class="mosaic-arrow">→</span>
                </div>
              </div>
            </a>
          </article>
        ))}
      </div>
    </div>
  </section>

  <!-- ABOUT -->
  <section class="about">
    <div class="about-inner">
      <div class="about-text">
        <span class="section-label" data-anim="rise" data-en="About the Firm" data-th="เกี่ยวกับบริษัท">About the Firm</span>
        <h2 data-split data-delay="1" data-en="Eighteen years of precision, craft, and permanence." data-th="สิบแปดปีแห่งความแม่นยำ ฝีมือ และความยั่งยืน">
          Eighteen years of precision, craft, and permanence.
        </h2>
        <p data-anim="rise" data-delay="2"
          data-en="TNC.18 is a Bangkok-based architecture and construction firm. We work across residential, commercial, and interior disciplines — always with the same commitment to materials, structure, and lasting design."
          data-th="TNC.18 เป็นบริษัทสถาปัตยกรรมและก่อสร้างในกรุงเทพฯ เราทำงานทั้งในด้านที่พักอาศัย เชิงพาณิชย์ และการออกแบบภายใน">
          TNC.18 is a Bangkok-based architecture and construction firm. We work across residential, commercial, and interior disciplines — always with the same commitment to materials, structure, and lasting design.
        </p>
        <a href="/about" class="link-underline" data-anim="rise" data-delay="3" data-en="Our Story" data-th="เรื่องราวของเรา">Our Story</a>
      </div>
      <div class="about-stats">
        {[
          { n: 18,  suf: '',  en: 'Years',       th: 'ปี' },
          { n: 200, suf: '+', en: 'Projects',    th: 'โครงการ' },
          { n: 50,  suf: '+', en: 'Specialists', th: 'ผู้เชี่ยวชาญ' },
        ].map((s, i) => (
          <div class="stat" data-anim="rise" data-delay={String(i + 1)}>
            <div class="stat-line" data-anim="line"></div>
            <span class="stat-num"><span data-counter={String(s.n)} data-suffix={s.suf}>0</span></span>
            <span class="stat-lbl" data-en={s.en} data-th={s.th}>{s.en}</span>
          </div>
        ))}
      </div>
    </div>
  </section>

  <!-- SERVICES — from CMS -->
  <section class="services">
    <div class="services-inner">
      <span class="section-label" data-anim="rise" data-en="What We Do" data-th="สิ่งที่เราทำ">What We Do</span>
      <div class="svc-list">
        {services.map((s, i) => (
          <a href="/services" class="svc-row" data-anim="rise" data-delay={String((i % 3) + 1)}>
            <span class="svc-n">0{s.data.order}</span>
            <span class="svc-name" data-en={s.data.title} data-th={s.data.title_th || s.data.title}>{s.data.title}</span>
            <span class="svc-arr">→</span>
          </a>
        ))}
      </div>
    </div>
  </section>

  <!-- CONTACT -->
  <section class="contact">
    <h2 data-split data-en="Have a project in mind?" data-th="มีโครงการในใจอยู่หรือเปล่า?">Have a project in mind?</h2>
    <p data-anim="rise" data-delay="2"
      data-en="We work with clients who value precision and permanence. Let's talk about what you're building."
      data-th="เราทำงานกับลูกค้าที่ให้ความสำคัญกับความแม่นยำและความยั่งยืน">
      We work with clients who value precision and permanence.<br/>Let's talk about what you're building.
    </p>
    <a href="/contact" class="contact-btn" data-anim="rise" data-delay="3" data-en="Start a Conversation" data-th="เริ่มบทสนทนา">Start a Conversation</a>
  </section>

  <!-- FOOTER -->
  <footer class="footer">
    <div class="footer-inner">
      <div>
        <span class="footer-logo">TNC<em>.</em>18</span>
        <p class="footer-sub" data-en="Architecture & Construction, Bangkok" data-th="สถาปัตยกรรมและการก่อสร้าง กรุงเทพฯ">Architecture & Construction, Bangkok</p>
      </div>
      <nav class="footer-nav">
        <a href="tel:+66000000000" data-en="Call" data-th="โทร">Call</a>
        <a href="https://line.me" target="_blank" rel="noopener">Line OA</a>
        <a href="https://instagram.com" target="_blank" rel="noopener">Instagram</a>
        <a href="https://tiktok.com" target="_blank" rel="noopener">TikTok</a>
      </nav>
      <p class="footer-copy">© 2024 TNC.18</p>
    </div>
  </footer>
</Layout>

<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  .hero { position:relative; height:100vh; min-height:600px; display:flex; flex-direction:column; justify-content:flex-end; overflow:hidden; background:var(--charcoal); }
  .hero-media { position:absolute; inset:0; z-index:0; }
  .hero-media video { width:100%; height:100%; object-fit:cover; opacity:0.46; }
  .hero-fallback { position:absolute; inset:0; background:linear-gradient(155deg,#2C2820 0%,#1A1612 60%,#0F0D0A 100%); z-index:-1; }
  .hero-vignette { position:absolute; inset:0; background:linear-gradient(to top,rgba(28,26,23,0.92) 0%,transparent 55%),linear-gradient(to right,rgba(28,26,23,0.3) 0%,transparent 50%); }
  .hero-body { position:relative; z-index:2; padding:0 5rem 2.5rem; }
  .hero-location { font-size:0.64rem; letter-spacing:0.24em; text-transform:uppercase; color:rgba(247,244,239,0.32); margin-bottom:1.25rem; animation:fadeUp 1s 0.3s both; }
  .hero-headline { font-family:var(--font-serif); font-size:clamp(3.5rem,8vw,7.5rem); font-weight:300; line-height:1.0; color:var(--stone); overflow:hidden; margin-bottom:1.75rem; }
  .hero-line { display:block; animation:slideUp 1.1s cubic-bezier(0.16,1,0.3,1) both; }
  .hero-line:nth-child(2) { animation-delay:0.12s; }
  .hero-italic { font-style:italic; color:rgba(247,244,239,0.5); padding-left:1.5rem; }
  @keyframes slideUp { from{transform:translateY(110%);opacity:0} to{transform:translateY(0);opacity:1} }
  @keyframes fadeUp { from{opacity:0;transform:translateY(6px)} to{opacity:1;transform:translateY(0)} }
  .hero-rule { width:44px; height:1px; background:var(--gold); transform:scaleX(0); transform-origin:left; animation:lineIn 0.7s 0.9s cubic-bezier(0.4,0,0.2,1) forwards; }
  @keyframes lineIn { to{transform:scaleX(1)} }
  .hero-foot { position:relative; z-index:2; display:flex; align-items:center; justify-content:space-between; padding:1.25rem 5rem; border-top:1px solid rgba(247,244,239,0.07); animation:fadeUp 0.8s 1s both; }
  .hero-cta { display:flex; align-items:center; gap:0.6rem; font-size:0.68rem; letter-spacing:0.18em; text-transform:uppercase; color:var(--stone); text-decoration:none; }
  .hero-arrow { color:var(--gold); transition:transform 0.3s,color 0.3s; }
  .hero-cta:hover .hero-arrow { transform:translateX(5px); color:var(--blue-mid); }
  .hero-tag { font-size:0.58rem; letter-spacing:0.18em; text-transform:uppercase; color:rgba(247,244,239,0.18); }

  .statement { background:var(--stone); border-bottom:1px solid var(--stone-mid); padding:5rem; }
  .statement-inner { display:grid; grid-template-columns:72px 1fr; gap:2.5rem; max-width:860px; margin:0 auto; align-items:start; }
  .statement-side { display:flex; flex-direction:column; gap:0.85rem; padding-top:0.3rem; }
  .tag-label { font-size:0.58rem; font-weight:500; letter-spacing:0.22em; text-transform:uppercase; color:var(--gold); }
  .gold-line { width:100%; height:1px; background:var(--stone-dark); }
  .statement-quote { font-family:var(--font-serif); font-size:clamp(1.25rem,2.2vw,1.75rem); font-weight:300; font-style:italic; color:var(--ink); line-height:1.65; }

  .projects { background:var(--warm-white); border-top:1px solid var(--stone-mid); padding:4rem 5rem; }
  .section-header { display:flex; justify-content:space-between; align-items:baseline; border-bottom:1px solid var(--stone-dark); padding-bottom:1rem; margin-bottom:2rem; }
  .section-label { font-family:var(--font-sans); font-size:0.62rem; font-weight:500; letter-spacing:0.22em; text-transform:uppercase; color:var(--muted); }
  .link-sm { font-size:0.66rem; letter-spacing:0.1em; color:var(--ink); text-decoration:none; transition:color 0.3s; }
  .link-sm:hover { color:var(--blue); }
  .mosaic { display:flex; flex-direction:column; gap:0.6rem; }
  .mosaic-row { display:grid; gap:0.6rem; }
  .mosaic-row--top { grid-template-columns:1fr 1fr; }
  .mosaic-row--bot { grid-template-columns:1fr 1.6fr; }
  .mosaic-card { position:relative; overflow:hidden; }
  .mosaic-link { display:block; text-decoration:none; color:inherit; }
  .mosaic-img { position:relative; overflow:hidden; background:var(--stone-dark); }
  .mosaic-img img { width:100%; height:100%; object-fit:cover; transition:transform 1s cubic-bezier(0.4,0,0.2,1); }
  .mosaic-row--top .mosaic-img { aspect-ratio:16/10; }
  .mosaic-card--portrait .mosaic-img { aspect-ratio:3/4; }
  .mosaic-card--wide .mosaic-img { aspect-ratio:16/10; }
  .mosaic-ph { width:100%; height:100%; transition:transform 1s cubic-bezier(0.4,0,0.2,1); }
  .mosaic-link:hover .mosaic-ph, .mosaic-link:hover .mosaic-img img { transform:scale(1.06); }
  .mosaic-overlay { position:absolute; inset:0; background:linear-gradient(to top,rgba(20,18,15,0.82) 0%,rgba(20,18,15,0.3) 45%,transparent 70%); display:flex; align-items:flex-end; justify-content:space-between; padding:1.5rem 1.75rem; opacity:0; transition:opacity 0.5s cubic-bezier(0.4,0,0.2,1); }
  .mosaic-link:hover .mosaic-overlay { opacity:1; }
  .mosaic-overlay-inner { display:flex; flex-direction:column; gap:0.2rem; transform:translateY(8px); transition:transform 0.5s cubic-bezier(0.16,1,0.3,1); }
  .mosaic-link:hover .mosaic-overlay-inner { transform:translateY(0); }
  .mosaic-cat { font-family:var(--font-sans); font-size:0.58rem; font-weight:500; letter-spacing:0.2em; text-transform:uppercase; color:var(--gold-light); }
  .mosaic-title { font-family:var(--font-serif); font-size:clamp(1rem,1.6vw,1.35rem); font-weight:300; color:var(--warm-white); line-height:1.15; }
  .mosaic-year { font-size:0.58rem; color:rgba(247,244,239,0.35); letter-spacing:0.1em; margin-top:0.15rem; }
  .mosaic-arrow { font-size:1.1rem; color:var(--gold); align-self:flex-end; transform:translate(-6px,6px); opacity:0; transition:transform 0.5s cubic-bezier(0.16,1,0.3,1),opacity 0.4s ease; }
  .mosaic-link:hover .mosaic-arrow { transform:translate(0,0); opacity:1; }
  .mosaic-img::after { content:''; position:absolute; inset:0; border:1px solid rgba(166,124,78,0); transition:border-color 0.4s; pointer-events:none; z-index:2; }
  .mosaic-link:hover .mosaic-img::after { border-color:rgba(166,124,78,0.35); }

  .about { background:var(--stone-mid); border-top:1px solid var(--stone-dark); border-bottom:1px solid var(--stone-dark); padding:5rem; }
  .about-inner { display:grid; grid-template-columns:1fr 220px; gap:5rem; align-items:center; max-width:1000px; margin:0 auto; }
  .about-text .section-label { display:block; margin-bottom:1rem; }
  .about-text h2 { font-size:clamp(1.5rem,2.5vw,2rem); font-weight:300; color:var(--charcoal); margin-bottom:1.25rem; line-height:1.25; }
  .about-text p { font-size:0.85rem; color:var(--ink); line-height:1.85; margin-bottom:1.75rem; max-width:400px; font-weight:300; }
  .link-underline { font-size:0.64rem; font-weight:500; letter-spacing:0.16em; text-transform:uppercase; color:var(--charcoal); text-decoration:none; border-bottom:1px solid var(--stone-dark); padding-bottom:2px; transition:color 0.3s,border-color 0.3s; }
  .link-underline:hover { color:var(--blue); border-color:var(--blue); }
  .about-stats { display:flex; flex-direction:column; gap:1.75rem; }
  .stat { display:flex; flex-direction:column; gap:0.15rem; }
  .stat-line { width:26px; height:1px; background:var(--gold); margin-bottom:0.5rem; }
  .stat-num { font-family:var(--font-serif); font-size:2.75rem; font-weight:300; color:var(--charcoal); line-height:1; }
  .stat-lbl { font-size:0.58rem; font-weight:500; letter-spacing:0.2em; text-transform:uppercase; color:var(--muted); }

  .services { background:var(--stone); padding:4rem 5rem; }
  .services-inner { max-width:960px; margin:0 auto; }
  .services .section-label { display:block; margin-bottom:1.5rem; }
  .svc-list { border-top:1px solid var(--stone-dark); }
  .svc-row { display:flex; align-items:center; padding:1.1rem 0; border-bottom:1px solid var(--stone-mid); text-decoration:none; color:inherit; position:relative; overflow:hidden; transition:padding-left 0.35s cubic-bezier(0.4,0,0.2,1),background 0.35s; }
  .svc-row::before { content:''; position:absolute; left:0; top:0; bottom:0; width:2px; background:var(--blue); transform:scaleY(0); transition:transform 0.35s cubic-bezier(0.4,0,0.2,1); }
  .svc-row:hover { padding-left:1rem; background:rgba(234,229,219,0.5); }
  .svc-row:hover::before { transform:scaleY(1); }
  .svc-n { font-size:0.58rem; color:var(--muted); width:3rem; flex-shrink:0; letter-spacing:0.1em; }
  .svc-name { font-family:var(--font-serif); font-size:clamp(1rem,1.6vw,1.35rem); font-weight:300; color:var(--charcoal); flex:1; transition:color 0.3s; }
  .svc-row:hover .svc-name { color:var(--blue); }
  .svc-arr { font-size:0.8rem; color:var(--gold); transition:transform 0.3s,color 0.3s; }
  .svc-row:hover .svc-arr { transform:translateX(5px); color:var(--blue); }

  .contact { background:var(--charcoal); padding:6rem 5rem; text-align:center; display:flex; flex-direction:column; align-items:center; gap:1.5rem; }
  .contact h2 { font-family:var(--font-serif); font-size:clamp(1.75rem,3.5vw,2.75rem); font-weight:300; font-style:italic; color:var(--stone); line-height:1.2; max-width:600px; }
  .contact p { font-size:0.85rem; color:rgba(247,244,239,0.38); font-weight:300; line-height:1.85; max-width:420px; }
  .contact-btn { display:inline-block; margin-top:0.75rem; font-size:0.66rem; font-weight:500; letter-spacing:0.18em; text-transform:uppercase; color:var(--stone); text-decoration:none; border:1px solid rgba(247,244,239,0.2); padding:0.85rem 2.25rem; position:relative; overflow:hidden; transition:border-color 0.4s; z-index:1; }
  .contact-btn::before { content:''; position:absolute; inset:0; background:var(--blue); transform:translateY(101%); transition:transform 0.4s cubic-bezier(0.4,0,0.2,1); z-index:-1; }
  .contact-btn:hover::before { transform:translateY(0); }
  .contact-btn:hover { border-color:var(--blue); }

  .footer { background:#0F0E0C; border-top:1px solid rgba(247,244,239,0.05); padding:1.75rem 5rem; }
  .footer-inner { display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:1rem; }
  .footer-logo { font-family:var(--font-sans); font-size:0.85rem; font-weight:500; letter-spacing:0.1em; color:rgba(247,244,239,0.4); }
  .footer-logo em { font-style:normal; color:var(--gold); }
  .footer-sub { font-size:0.56rem; letter-spacing:0.1em; color:rgba(247,244,239,0.15); margin-top:0.2rem; }
  .footer-nav { display:flex; gap:1.75rem; }
  .footer-nav a { font-size:0.58rem; letter-spacing:0.1em; text-transform:uppercase; color:rgba(247,244,239,0.2); text-decoration:none; transition:color 0.3s; }
  .footer-nav a:hover { color:rgba(247,244,239,0.65); }
  .footer-copy { font-size:0.55rem; color:rgba(247,244,239,0.12); letter-spacing:0.08em; }

  @media (max-width:900px) {
    .hero-body,.hero-foot { padding-left:1.75rem; padding-right:1.75rem; }
    .statement,.projects,.about,.services,.contact { padding-left:1.75rem; padding-right:1.75rem; }
    .statement-inner { grid-template-columns:1fr; gap:1rem; }
    .mosaic-row--top,.mosaic-row--bot { grid-template-columns:1fr; }
    .mosaic-card--portrait .mosaic-img { aspect-ratio:16/9; }
    .about-inner { grid-template-columns:1fr; gap:2.5rem; }
    .about-stats { flex-direction:row; flex-wrap:wrap; gap:1.5rem; }
    .footer { padding:1.5rem 1.75rem; }
    .footer-inner { flex-direction:column; align-items:flex-start; gap:0.75rem; }
  }
</style>

<script>
  document.querySelectorAll('[data-split]').forEach(el => {
    const text = el.textContent?.trim() || '';
    el.innerHTML = text.split(' ').map((w, i) =>
      `<span style="display:inline-block;overflow:hidden"><span class="word" style="display:inline-block;transform:translateY(105%);opacity:0;transition:transform 0.75s cubic-bezier(0.16,1,0.3,1) ${i*0.055}s,opacity 0.5s ease ${i*0.055}s">${w}</span></span>`
    ).join(' ');
  });

  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const el = entry.target;
      if (el.dataset.anim === 'rise') { el.style.opacity='1'; el.style.transform='translateY(0)'; }
      if (el.dataset.anim === 'line') { el.style.transform='scaleX(1)'; }
      el.querySelectorAll('.word').forEach((w:any) => { w.style.transform='translateY(0)'; w.style.opacity='1'; });
      el.querySelectorAll('[data-counter]').forEach((counter:any) => {
        const target = parseInt(counter.getAttribute('data-counter') || '0');
        const suffix = counter.getAttribute('data-suffix') || '';
        const dur = 1600; const start = performance.now();
        const tick = (now:number) => {
          const p = Math.min((now-start)/dur,1); const e = 1-Math.pow(1-p,4);
          counter.textContent = Math.floor(e*target)+suffix;
          if (p < 1) requestAnimationFrame(tick);
        };
        requestAnimationFrame(tick);
      });
      io.unobserve(el);
    });
  }, { threshold:0.12, rootMargin:'0px 0px -32px 0px' });

  document.querySelectorAll('[data-anim="rise"]').forEach((el:any) => {
    el.style.opacity='0'; el.style.transform='translateY(20px)';
    el.style.transition=`opacity 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s,transform 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s`;
    io.observe(el);
  });
  document.querySelectorAll('[data-anim="line"]').forEach((el:any) => {
    el.style.transform='scaleX(0)'; el.style.transformOrigin='left'; el.style.transition='transform 1s cubic-bezier(0.4,0,0.2,1) 0.2s';
    io.observe(el);
  });
  document.querySelectorAll('[data-split]').forEach(el => io.observe(el));
  document.querySelectorAll('.stat').forEach(el => io.observe(el));

  function applyLang(lang:string) {
    localStorage.setItem('tnc-lang',lang);
    document.documentElement.setAttribute('data-lang',lang);
    document.getElementById('lang-en')?.classList.toggle('active',lang==='en');
    document.getElementById('lang-th')?.classList.toggle('active',lang==='th');
    document.querySelectorAll('[data-en][data-th]').forEach(el => {
      el.textContent = lang==='th' ? el.getAttribute('data-th')||'' : el.getAttribute('data-en')||'';
    });
  }
  applyLang(localStorage.getItem('tnc-lang')||'en');
  document.getElementById('lang-toggle')?.addEventListener('click',()=>{
    applyLang((document.documentElement.getAttribute('data-lang')||'en')==='en'?'th':'en');
  });
</script>
ENDOFFILE
echo "✅  src/pages/index.astro (CMS-wired)"

# ══════════════════════════════════════════════════════════════
# 3. ABOUT PAGE
# ══════════════════════════════════════════════════════════════
cat > src/pages/about.astro << 'ENDOFFILE'
---
import Layout from '../layouts/Layout.astro';
import Navbar from '../components/Navbar.astro';
---
<Layout title="About — Eighteen Years of Craft">
  <Navbar />

  <section class="about-hero">
    <div class="about-hero-inner">
      <span class="page-label" data-anim="rise" data-en="About TNC.18" data-th="เกี่ยวกับ TNC.18">About TNC.18</span>
      <h1 data-split data-en="Built on craft. Defined by permanence." data-th="สร้างด้วยฝีมือ นิยามด้วยความยั่งยืน">
        Built on craft.<br/>Defined by permanence.
      </h1>
    </div>
  </section>

  <section class="about-split">
    <div class="about-split-inner">
      <div class="about-img-col">
        <div class="about-img-ph"></div>
        <div class="about-img-caption" data-anim="rise">
          <span data-en="TNC.18 Headquarters, Bangkok" data-th="สำนักงานใหญ่ TNC.18 กรุงเทพฯ">TNC.18 Headquarters, Bangkok</span>
        </div>
      </div>
      <div class="about-copy">
        <p data-anim="rise" data-delay="1"
          data-en="TNC.18 was founded in 2006 with a single conviction — that buildings should outlast the trends of the moment they were built in. Eighteen years later, that conviction remains unchanged."
          data-th="TNC.18 ก่อตั้งขึ้นในปี 2549 ด้วยความเชื่อมั่นเดียว — ว่าอาคารควรคงอยู่ยาวนานกว่ากระแสของยุคสมัยที่สร้างขึ้น สิบแปดปีต่อมา ความเชื่อมั่นนั้นยังคงไม่เปลี่ยนแปลง">
          TNC.18 was founded in 2006 with a single conviction — that buildings should outlast the trends of the moment they were built in. Eighteen years later, that conviction remains unchanged.
        </p>
        <p data-anim="rise" data-delay="2"
          data-en="We are a Bangkok-based firm of architects, engineers, and builders. Our work spans private residences, commercial towers, interior commissions, and hospitality projects across Thailand."
          data-th="เราเป็นบริษัทที่ตั้งอยู่ในกรุงเทพฯ ประกอบด้วยสถาปนิก วิศวกร และผู้สร้าง ผลงานของเราครอบคลุมทั้งที่พักอาศัยส่วนตัว อาคารพาณิชย์ งานออกแบบภายใน และโครงการการบริการทั่วประเทศไทย">
          We are a Bangkok-based firm of architects, engineers, and builders. Our work spans private residences, commercial towers, interior commissions, and hospitality projects across Thailand.
        </p>
        <p data-anim="rise" data-delay="3"
          data-en="Every project begins with the same question: what will this building mean in fifty years? That question shapes every material choice, every structural decision, every detail."
          data-th="ทุกโครงการเริ่มต้นด้วยคำถามเดียวกัน: อาคารนี้จะมีความหมายอะไรในห้าสิบปี? คำถามนั้นกำหนดทุกการเลือกวัสดุ ทุกการตัดสินใจด้านโครงสร้าง ทุกรายละเอียด">
          Every project begins with the same question: what will this building mean in fifty years? That question shapes every material choice, every structural decision, every detail.
        </p>
      </div>
    </div>
  </section>

  <section class="values">
    <div class="values-inner">
      <span class="section-label" data-anim="rise" data-en="Our Values" data-th="ค่านิยมของเรา">Our Values</span>
      <div class="values-grid">
        {[
          { n:'01', en:'Permanence', th:'ความยั่งยืน', desc_en:'We build for decades, not for the moment. Every material, joint, and detail is chosen to last.', desc_th:'เราสร้างเพื่อทศวรรษ ไม่ใช่เพื่อช่วงเวลา ทุกวัสดุ ข้อต่อ และรายละเอียดถูกเลือกเพื่อความคงทน' },
          { n:'02', en:'Precision',  th:'ความแม่นยำ',  desc_en:'Architecture is a discipline of exactness. We hold ourselves to tolerances that most firms consider unnecessary.', desc_th:'สถาปัตยกรรมคือวินัยแห่งความถูกต้อง เราถือมาตรฐานที่บริษัทส่วนใหญ่มองว่าไม่จำเป็น' },
          { n:'03', en:'Craft',      th:'ฝีมือ',       desc_en:'We believe in the intelligence of the hand. Details are designed, not defaulted. Materiality is deliberate.', desc_th:'เราเชื่อในสติปัญญาของมือ รายละเอียดถูกออกแบบ ไม่ใช่ถูกกำหนดโดยค่าเริ่มต้น วัสดุถูกเลือกอย่างตั้งใจ' },
          { n:'04', en:'Clarity',    th:'ความชัดเจน',  desc_en:'Clear thinking produces clear buildings. We strip away everything that does not serve the project.', desc_th:'การคิดที่ชัดเจนสร้างอาคารที่ชัดเจน เราตัดทิ้งทุกสิ่งที่ไม่รับใช้โครงการ' },
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
        data-en="50+ architects, engineers, project managers, and site specialists. Bangkok-based. Regionally experienced."
        data-th="สถาปนิก วิศวกร ผู้จัดการโครงการ และผู้เชี่ยวชาญงานหน้างานมากกว่า 50 คน ตั้งอยู่ในกรุงเทพฯ มีประสบการณ์ในภูมิภาค">
        50+ architects, engineers, project managers, and site specialists.<br/>Bangkok-based. Regionally experienced.
      </p>
      <a href="/contact" class="cta-link" data-anim="rise" data-delay="2" data-en="Work with us →" data-th="ร่วมงานกับเรา →">Work with us →</a>
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
  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const el = entry.target as HTMLElement;
      if (el.dataset.anim==='rise'){el.style.opacity='1';el.style.transform='translateY(0)';}
      el.querySelectorAll('.word').forEach((w:any)=>{w.style.transform='translateY(0)';w.style.opacity='1';});
      io.unobserve(el);
    });
  },{threshold:0.12});
  document.querySelectorAll('[data-anim="rise"]').forEach((el:any)=>{
    el.style.opacity='0';el.style.transform='translateY(20px)';
    el.style.transition=`opacity 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s,transform 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s`;
    io.observe(el);
  });
  document.querySelectorAll('[data-split]').forEach(el=>{
    const text=el.textContent?.trim()||'';
    el.innerHTML=text.split(' ').map((w,i)=>`<span style="display:inline-block;overflow:hidden"><span class="word" style="display:inline-block;transform:translateY(105%);opacity:0;transition:transform 0.75s cubic-bezier(0.16,1,0.3,1) ${i*0.055}s,opacity 0.5s ease ${i*0.055}s">${w}</span></span>`).join(' ');
    io.observe(el);
  });
  function applyLang(lang:string){localStorage.setItem('tnc-lang',lang);document.querySelectorAll('[data-en][data-th]').forEach(el=>{el.textContent=lang==='th'?el.getAttribute('data-th')||'':el.getAttribute('data-en')||'';});}
  applyLang(localStorage.getItem('tnc-lang')||'en');
  document.getElementById('lang-toggle')?.addEventListener('click',()=>{applyLang((document.documentElement.getAttribute('data-lang')||'en')==='en'?'th':'en');});
</script>
ENDOFFILE
echo "✅  src/pages/about.astro"

# ══════════════════════════════════════════════════════════════
# 4. SERVICES PAGE
# ══════════════════════════════════════════════════════════════
cat > src/pages/services.astro << 'ENDOFFILE'
---
import Layout from '../layouts/Layout.astro';
import Navbar from '../components/Navbar.astro';
import { getCollection } from 'astro:content';

const allServices = await getCollection('services');
const services = allServices.sort((a,b) => a.data.order - b.data.order);
---
<Layout title="Services — What We Do">
  <Navbar />

  <section class="svc-hero">
    <div class="svc-hero-inner">
      <span class="page-label" data-anim="rise" data-en="Our Services" data-th="บริการของเรา">Our Services</span>
      <h1 data-split data-en="What we do, and how we do it." data-th="สิ่งที่เราทำ และวิธีที่เราทำ">
        What we do,<br/>and how we do it.
      </h1>
    </div>
  </section>

  <section class="svc-list-section">
    <div class="svc-list-inner">
      {services.map((s, i) => (
        <div class="svc-block" data-anim="rise" data-delay={String((i%3)+1)}>
          <div class="svc-block-header">
            <span class="svc-block-n">0{s.data.order}</span>
            <h2 class="svc-block-title" data-en={s.data.title} data-th={s.data.title_th||s.data.title}>{s.data.title}</h2>
          </div>
          {s.data.description && (
            <p class="svc-block-desc" data-en={s.data.description} data-th={s.data.description_th||s.data.description}>
              {s.data.description}
            </p>
          )}
          <div class="svc-block-line"></div>
        </div>
      ))}
    </div>
  </section>

  <section class="svc-cta">
    <h2 data-split data-en="Every project is different. Every project gets the same attention." data-th="ทุกโครงการแตกต่างกัน ทุกโครงการได้รับความสนใจเท่ากัน">
      Every project is different.<br/>Every project gets the same attention.
    </h2>
    <a href="/contact" class="cta-link" data-anim="rise" data-delay="2" data-en="Discuss your project →" data-th="พูดคุยเกี่ยวกับโครงการของคุณ →">Discuss your project →</a>
  </section>

  <footer class="footer">
    <div class="footer-inner">
      <div><span class="footer-logo">TNC<em>.</em>18</span></div>
      <nav class="footer-nav">
        <a href="/projects" data-en="Projects" data-th="ผลงาน">Projects</a>
        <a href="/about" data-en="About" data-th="เกี่ยวกับ">About</a>
        <a href="/contact" data-en="Contact" data-th="ติดต่อ">Contact</a>
      </nav>
      <p class="footer-copy">© 2024 TNC.18</p>
    </div>
  </footer>
</Layout>

<style>
  .svc-hero { background:var(--charcoal); padding:10rem 5rem 5rem; min-height:50vh; display:flex; align-items:flex-end; }
  .svc-hero-inner { max-width:700px; }
  .page-label { font-size:0.62rem; font-weight:500; letter-spacing:0.22em; text-transform:uppercase; color:var(--gold); display:block; margin-bottom:1.5rem; }
  .svc-hero h1 { font-family:var(--font-serif); font-size:clamp(2.5rem,6vw,5rem); font-weight:300; color:var(--stone); line-height:1.1; }

  .svc-list-section { background:var(--stone); padding:5rem; }
  .svc-list-inner { max-width:900px; margin:0 auto; display:grid; grid-template-columns:1fr 1fr; gap:0; }
  .svc-block { padding:2.5rem 0; border-bottom:1px solid var(--stone-mid); }
  .svc-block:nth-child(odd) { padding-right:3rem; border-right:1px solid var(--stone-mid); }
  .svc-block:nth-child(even) { padding-left:3rem; }
  .svc-block-header { display:flex; align-items:baseline; gap:1rem; margin-bottom:1rem; }
  .svc-block-n { font-size:0.6rem; color:var(--gold); letter-spacing:0.12em; }
  .svc-block-title { font-family:var(--font-serif); font-size:clamp(1.25rem,2vw,1.6rem); font-weight:300; color:var(--charcoal); }
  .svc-block-desc { font-size:0.84rem; color:var(--ink); line-height:1.8; font-weight:300; }
  .svc-block-line { width:24px; height:1px; background:var(--gold); margin-top:1.5rem; }

  .svc-cta { background:var(--stone-mid); padding:6rem 5rem; text-align:center; border-top:1px solid var(--stone-dark); }
  .svc-cta h2 { font-family:var(--font-serif); font-size:clamp(1.5rem,3vw,2.5rem); font-weight:300; font-style:italic; color:var(--charcoal); line-height:1.3; margin-bottom:2.5rem; }
  .cta-link { font-size:0.7rem; letter-spacing:0.16em; text-transform:uppercase; color:var(--gold); text-decoration:none; border-bottom:1px solid rgba(166,124,78,0.4); padding-bottom:2px; transition:color 0.3s; }
  .cta-link:hover { color:var(--blue); border-color:var(--blue); }

  .footer { background:#0F0E0C; padding:1.75rem 5rem; border-top:1px solid rgba(247,244,239,0.05); }
  .footer-inner { display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:1rem; }
  .footer-logo { font-family:var(--font-sans); font-size:0.85rem; font-weight:500; letter-spacing:0.1em; color:rgba(247,244,239,0.4); }
  .footer-logo em { font-style:normal; color:var(--gold); }
  .footer-nav { display:flex; gap:2rem; }
  .footer-nav a { font-size:0.58rem; letter-spacing:0.1em; text-transform:uppercase; color:rgba(247,244,239,0.2); text-decoration:none; transition:color 0.3s; }
  .footer-nav a:hover { color:rgba(247,244,239,0.65); }
  .footer-copy { font-size:0.55rem; color:rgba(247,244,239,0.12); }

  @media (max-width:900px) {
    .svc-hero,.svc-list-section,.svc-cta,.footer { padding-left:1.75rem; padding-right:1.75rem; }
    .svc-list-inner { grid-template-columns:1fr; }
    .svc-block:nth-child(odd) { padding-right:0; border-right:none; }
    .svc-block:nth-child(even) { padding-left:0; }
    .footer-inner { flex-direction:column; align-items:flex-start; }
  }
</style>
<script>
  const io=new IntersectionObserver((entries)=>{entries.forEach(entry=>{if(!entry.isIntersecting)return;const el=entry.target as HTMLElement;if(el.dataset.anim==='rise'){el.style.opacity='1';el.style.transform='translateY(0)';}el.querySelectorAll('.word').forEach((w:any)=>{w.style.transform='translateY(0)';w.style.opacity='1';});io.unobserve(el);});},{threshold:0.12});
  document.querySelectorAll('[data-anim="rise"]').forEach((el:any)=>{el.style.opacity='0';el.style.transform='translateY(20px)';el.style.transition=`opacity 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s,transform 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s`;io.observe(el);});
  document.querySelectorAll('[data-split]').forEach(el=>{const text=el.textContent?.trim()||'';el.innerHTML=text.split(' ').map((w,i)=>`<span style="display:inline-block;overflow:hidden"><span class="word" style="display:inline-block;transform:translateY(105%);opacity:0;transition:transform 0.75s cubic-bezier(0.16,1,0.3,1) ${i*0.055}s,opacity 0.5s ease ${i*0.055}s">${w}</span></span>`).join(' ');io.observe(el);});
  function applyLang(lang:string){localStorage.setItem('tnc-lang',lang);document.querySelectorAll('[data-en][data-th]').forEach(el=>{el.textContent=lang==='th'?el.getAttribute('data-th')||'':el.getAttribute('data-en')||'';});}
  applyLang(localStorage.getItem('tnc-lang')||'en');
  document.getElementById('lang-toggle')?.addEventListener('click',()=>{applyLang((document.documentElement.getAttribute('data-lang')||'en')==='en'?'th':'en');});
</script>
ENDOFFILE
echo "✅  src/pages/services.astro"

# ══════════════════════════════════════════════════════════════
# 5. PROJECTS INDEX PAGE
# ══════════════════════════════════════════════════════════════
cat > src/pages/projects/index.astro << 'ENDOFFILE'
---
import Layout from '../../layouts/Layout.astro';
import Navbar from '../../components/Navbar.astro';
import { getCollection } from 'astro:content';

const allProjects = await getCollection('projects');
const projects = allProjects.sort((a,b) => b.data.year - a.data.year);
const categories = ['All', ...new Set(allProjects.map(p => p.data.category))];
---
<Layout title="Projects — Selected Work">
  <Navbar />

  <section class="proj-hero">
    <div class="proj-hero-inner">
      <span class="page-label" data-anim="rise" data-en="Selected Work" data-th="ผลงานคัดสรร">Selected Work</span>
      <h1 data-split data-en="Every project is a permanent mark." data-th="ทุกโครงการคือรอยประทับถาวร">Every project is a permanent mark.</h1>
    </div>
  </section>

  <section class="proj-grid-section">
    <div class="proj-filter" data-anim="rise">
      {categories.map(cat => (
        <button class={`filter-btn ${cat==='All'?'active':''}`} data-cat={cat}
          data-en={cat} data-th={cat}>{cat}</button>
      ))}
    </div>

    <div class="proj-grid" id="proj-grid">
      {projects.map((p, i) => (
        <article class="proj-card" data-cat={p.data.category} data-anim="rise" data-delay={String((i%3)+1)}>
          <a href={`/projects/${p.slug}`} class="proj-card-link">
            <div class="proj-card-img">
              {p.data.cover && !p.data.cover.includes('silom-residence')
                ? <img src={p.data.cover} alt={p.data.title} loading="lazy" />
                : <div class="proj-card-ph" style={`background:hsl(${40+i*8},${15+i*2}%,${70-i*4}%);`}></div>
              }
              <div class="proj-card-overlay">
                <span class="proj-card-cat" data-en={p.data.category} data-th={p.data.category_th||p.data.category}>{p.data.category}</span>
                <span class="proj-card-arr">→</span>
              </div>
            </div>
            <div class="proj-card-info">
              <span class="proj-card-year">{p.data.year}</span>
              <h2 class="proj-card-title" data-en={p.data.title} data-th={p.data.title_th||p.data.title}>{p.data.title}</h2>
            </div>
          </a>
        </article>
      ))}
    </div>
  </section>

  <footer class="footer">
    <div class="footer-inner">
      <div><span class="footer-logo">TNC<em>.</em>18</span></div>
      <nav class="footer-nav">
        <a href="/services" data-en="Services" data-th="บริการ">Services</a>
        <a href="/about" data-en="About" data-th="เกี่ยวกับ">About</a>
        <a href="/contact" data-en="Contact" data-th="ติดต่อ">Contact</a>
      </nav>
      <p class="footer-copy">© 2024 TNC.18</p>
    </div>
  </footer>
</Layout>

<style>
  .proj-hero { background:var(--charcoal); padding:10rem 5rem 5rem; min-height:50vh; display:flex; align-items:flex-end; }
  .proj-hero-inner { max-width:700px; }
  .page-label { font-size:0.62rem; font-weight:500; letter-spacing:0.22em; text-transform:uppercase; color:var(--gold); display:block; margin-bottom:1.5rem; }
  .proj-hero h1 { font-family:var(--font-serif); font-size:clamp(2.5rem,6vw,5rem); font-weight:300; color:var(--stone); line-height:1.1; }

  .proj-grid-section { background:var(--warm-white); padding:4rem 5rem; }

  .proj-filter { display:flex; gap:1rem; flex-wrap:wrap; margin-bottom:2.5rem; padding-bottom:1.5rem; border-bottom:1px solid var(--stone-dark); }
  .filter-btn { background:none; border:1px solid var(--stone-dark); padding:0.4rem 1rem; font-size:0.62rem; font-weight:500; letter-spacing:0.12em; text-transform:uppercase; color:var(--muted); cursor:pointer; transition:all 0.25s; font-family:var(--font-sans); }
  .filter-btn:hover,.filter-btn.active { background:var(--charcoal); color:var(--stone); border-color:var(--charcoal); }

  .proj-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:2rem 1.75rem; }
  .proj-card-link { display:block; text-decoration:none; color:inherit; }
  .proj-card-img { aspect-ratio:4/3; overflow:hidden; background:var(--stone-mid); position:relative; margin-bottom:0.85rem; }
  .proj-card-img img { width:100%; height:100%; object-fit:cover; transition:transform 0.85s cubic-bezier(0.4,0,0.2,1); }
  .proj-card-ph { width:100%; height:100%; transition:transform 0.85s cubic-bezier(0.4,0,0.2,1); }
  .proj-card-link:hover .proj-card-ph,.proj-card-link:hover img { transform:scale(1.05); }
  .proj-card-overlay { position:absolute; inset:0; background:linear-gradient(to top,rgba(20,18,15,0.7) 0%,transparent 60%); display:flex; align-items:flex-end; justify-content:space-between; padding:1rem 1.25rem; opacity:0; transition:opacity 0.4s; }
  .proj-card-link:hover .proj-card-overlay { opacity:1; }
  .proj-card-cat { font-size:0.58rem; font-weight:500; letter-spacing:0.16em; text-transform:uppercase; color:var(--gold-light); }
  .proj-card-arr { color:var(--gold); font-size:0.9rem; }
  .proj-card-info { display:flex; flex-direction:column; gap:0.2rem; }
  .proj-card-year { font-size:0.58rem; color:var(--muted); letter-spacing:0.1em; }
  .proj-card-title { font-family:var(--font-serif); font-size:clamp(0.95rem,1.4vw,1.15rem); font-weight:300; color:var(--charcoal); transition:color 0.3s; line-height:1.2; }
  .proj-card-link:hover .proj-card-title { color:var(--blue); }

  .proj-card.hidden { display:none; }

  .footer { background:#0F0E0C; padding:1.75rem 5rem; border-top:1px solid rgba(247,244,239,0.05); }
  .footer-inner { display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:1rem; }
  .footer-logo { font-family:var(--font-sans); font-size:0.85rem; font-weight:500; letter-spacing:0.1em; color:rgba(247,244,239,0.4); }
  .footer-logo em { font-style:normal; color:var(--gold); }
  .footer-nav { display:flex; gap:2rem; }
  .footer-nav a { font-size:0.58rem; letter-spacing:0.1em; text-transform:uppercase; color:rgba(247,244,239,0.2); text-decoration:none; transition:color 0.3s; }
  .footer-nav a:hover { color:rgba(247,244,239,0.65); }
  .footer-copy { font-size:0.55rem; color:rgba(247,244,239,0.12); }

  @media (max-width:900px) {
    .proj-hero,.proj-grid-section,.footer { padding-left:1.75rem; padding-right:1.75rem; }
    .proj-grid { grid-template-columns:1fr 1fr; }
    .footer-inner { flex-direction:column; align-items:flex-start; }
  }
  @media (max-width:600px) { .proj-grid { grid-template-columns:1fr; } }
</style>
<script>
  // Filter
  document.querySelectorAll('.filter-btn').forEach(btn=>{
    btn.addEventListener('click',()=>{
      document.querySelectorAll('.filter-btn').forEach(b=>b.classList.remove('active'));
      btn.classList.add('active');
      const cat=btn.getAttribute('data-cat')||'All';
      document.querySelectorAll('.proj-card').forEach((card:any)=>{
        card.classList.toggle('hidden', cat!=='All' && card.dataset.cat!==cat);
      });
    });
  });
  // Animations
  const io=new IntersectionObserver((entries)=>{entries.forEach(entry=>{if(!entry.isIntersecting)return;const el=entry.target as HTMLElement;if(el.dataset.anim==='rise'){el.style.opacity='1';el.style.transform='translateY(0)';}el.querySelectorAll('.word').forEach((w:any)=>{w.style.transform='translateY(0)';w.style.opacity='1';});io.unobserve(el);});},{threshold:0.1});
  document.querySelectorAll('[data-anim="rise"]').forEach((el:any)=>{el.style.opacity='0';el.style.transform='translateY(20px)';el.style.transition=`opacity 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s,transform 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s`;io.observe(el);});
  document.querySelectorAll('[data-split]').forEach(el=>{const text=el.textContent?.trim()||'';el.innerHTML=text.split(' ').map((w,i)=>`<span style="display:inline-block;overflow:hidden"><span class="word" style="display:inline-block;transform:translateY(105%);opacity:0;transition:transform 0.75s cubic-bezier(0.16,1,0.3,1) ${i*0.055}s,opacity 0.5s ease ${i*0.055}s">${w}</span></span>`).join(' ');io.observe(el);});
  function applyLang(lang:string){localStorage.setItem('tnc-lang',lang);document.querySelectorAll('[data-en][data-th]').forEach(el=>{el.textContent=lang==='th'?el.getAttribute('data-th')||'':el.getAttribute('data-en')||'';});}
  applyLang(localStorage.getItem('tnc-lang')||'en');
  document.getElementById('lang-toggle')?.addEventListener('click',()=>{applyLang((document.documentElement.getAttribute('data-lang')||'en')==='en'?'th':'en');});
</script>
ENDOFFILE
echo "✅  src/pages/projects/index.astro"

# ══════════════════════════════════════════════════════════════
# 6. PROJECT DETAIL PAGE [slug].astro
# ══════════════════════════════════════════════════════════════
cat > 'src/pages/projects/[slug].astro' << 'ENDOFFILE'
---
import Layout from '../../layouts/Layout.astro';
import Navbar from '../../components/Navbar.astro';
import { getCollection, getEntry } from 'astro:content';

export async function getStaticPaths() {
  const projects = await getCollection('projects');
  return projects.map(p => ({ params: { slug: p.slug } }));
}

const { slug } = Astro.params;
const project = await getEntry('projects', slug);
if (!project) return Astro.redirect('/projects');
const { Content } = await project.render();
---
<Layout title={project.data.title}>
  <Navbar />

  <section class="detail-hero">
    <div class="detail-hero-img">
      {project.data.cover && !project.data.cover.includes('silom-residence')
        ? <img src={project.data.cover} alt={project.data.title} />
        : <div class="detail-ph"></div>
      }
      <div class="detail-hero-overlay"></div>
    </div>
    <div class="detail-hero-info">
      <span class="detail-cat">{project.data.category}</span>
      <h1 class="detail-title">{project.data.title}</h1>
      <div class="detail-meta">
        <span>{project.data.year}</span>
        {project.data.location && <span>{project.data.location}</span>}
        {project.data.client && <span>{project.data.client}</span>}
        {project.data.area && <span>{project.data.area} m²</span>}
      </div>
    </div>
  </section>

  <section class="detail-body">
    <div class="detail-inner">
      {project.data.description && (
        <p class="detail-desc">{project.data.description}</p>
      )}
      <div class="detail-content">
        <Content />
      </div>
    </div>
  </section>

  {project.data.gallery && project.data.gallery.length > 0 && (
    <section class="detail-gallery">
      <div class="gallery-grid">
        {project.data.gallery.map((img, i) => (
          <div class={`gallery-item gallery-item--${i%3===0?'wide':'std'}`}>
            <img src={img} alt={`${project.data.title} — ${i+1}`} loading="lazy" />
          </div>
        ))}
      </div>
    </section>
  )}

  <section class="detail-next">
    <a href="/projects" class="back-link" data-en="← All Projects" data-th="← ผลงานทั้งหมด">← All Projects</a>
    <a href="/contact" class="contact-link" data-en="Discuss a similar project →" data-th="พูดคุยเกี่ยวกับโครงการที่คล้ายกัน →">Discuss a similar project →</a>
  </section>

  <footer class="footer">
    <div class="footer-inner">
      <div><span class="footer-logo">TNC<em>.</em>18</span></div>
      <nav class="footer-nav">
        <a href="/projects" data-en="Projects" data-th="ผลงาน">Projects</a>
        <a href="/contact" data-en="Contact" data-th="ติดต่อ">Contact</a>
      </nav>
      <p class="footer-copy">© 2024 TNC.18</p>
    </div>
  </footer>
</Layout>

<style>
  .detail-hero { position:relative; height:85vh; min-height:500px; overflow:hidden; background:var(--charcoal); }
  .detail-hero-img { position:absolute; inset:0; }
  .detail-hero-img img,.detail-ph { width:100%; height:100%; object-fit:cover; }
  .detail-ph { background:var(--stone-dark); }
  .detail-hero-overlay { position:absolute; inset:0; background:linear-gradient(to top,rgba(20,18,15,0.85) 0%,rgba(20,18,15,0.2) 60%,transparent 100%); }
  .detail-hero-info { position:absolute; bottom:0; left:0; right:0; padding:3rem 5rem; z-index:2; }
  .detail-cat { font-size:0.6rem; font-weight:500; letter-spacing:0.2em; text-transform:uppercase; color:var(--gold); display:block; margin-bottom:0.75rem; }
  .detail-title { font-family:var(--font-serif); font-size:clamp(2.5rem,6vw,5rem); font-weight:300; color:var(--stone); line-height:1.05; margin-bottom:1rem; }
  .detail-meta { display:flex; gap:2rem; flex-wrap:wrap; }
  .detail-meta span { font-size:0.64rem; color:rgba(247,244,239,0.45); letter-spacing:0.12em; }

  .detail-body { background:var(--stone); padding:5rem; border-bottom:1px solid var(--stone-mid); }
  .detail-inner { max-width:680px; margin:0 auto; }
  .detail-desc { font-family:var(--font-serif); font-size:1.15rem; font-weight:300; font-style:italic; color:var(--ink); line-height:1.7; margin-bottom:2.5rem; }
  .detail-content { font-size:0.88rem; color:var(--ink); line-height:1.9; font-weight:300; }
  .detail-content p { margin-bottom:1.25rem; }
  .detail-content h2,.detail-content h3 { font-family:var(--font-serif); font-weight:300; color:var(--charcoal); margin:2rem 0 0.75rem; }

  .detail-gallery { background:var(--warm-white); padding:4rem 5rem; }
  .gallery-grid { display:grid; grid-template-columns:1fr 1fr 1fr; gap:0.75rem; }
  .gallery-item img { width:100%; height:100%; object-fit:cover; display:block; aspect-ratio:4/3; }
  .gallery-item--wide { grid-column:span 2; }
  .gallery-item--wide img { aspect-ratio:16/9; }

  .detail-next { background:var(--stone-mid); padding:2.5rem 5rem; display:flex; justify-content:space-between; align-items:center; border-top:1px solid var(--stone-dark); }
  .back-link,.contact-link { font-size:0.68rem; letter-spacing:0.14em; text-transform:uppercase; color:var(--ink); text-decoration:none; transition:color 0.3s; }
  .back-link:hover { color:var(--blue); }
  .contact-link { color:var(--gold); }
  .contact-link:hover { color:var(--blue); }

  .footer { background:#0F0E0C; padding:1.75rem 5rem; border-top:1px solid rgba(247,244,239,0.05); }
  .footer-inner { display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:1rem; }
  .footer-logo { font-family:var(--font-sans); font-size:0.85rem; font-weight:500; letter-spacing:0.1em; color:rgba(247,244,239,0.4); }
  .footer-logo em { font-style:normal; color:var(--gold); }
  .footer-nav { display:flex; gap:2rem; }
  .footer-nav a { font-size:0.58rem; letter-spacing:0.1em; text-transform:uppercase; color:rgba(247,244,239,0.2); text-decoration:none; transition:color 0.3s; }
  .footer-nav a:hover { color:rgba(247,244,239,0.65); }
  .footer-copy { font-size:0.55rem; color:rgba(247,244,239,0.12); }

  @media (max-width:900px) {
    .detail-hero-info,.detail-body,.detail-gallery,.detail-next,.footer { padding-left:1.75rem; padding-right:1.75rem; }
    .gallery-grid { grid-template-columns:1fr 1fr; }
    .gallery-item--wide { grid-column:span 2; }
    .detail-next { flex-direction:column; gap:1rem; align-items:flex-start; }
    .footer-inner { flex-direction:column; align-items:flex-start; }
  }
</style>
<script>
  function applyLang(lang:string){localStorage.setItem('tnc-lang',lang);document.querySelectorAll('[data-en][data-th]').forEach(el=>{el.textContent=lang==='th'?el.getAttribute('data-th')||'':el.getAttribute('data-en')||'';});}
  applyLang(localStorage.getItem('tnc-lang')||'en');
  document.getElementById('lang-toggle')?.addEventListener('click',()=>{applyLang((document.documentElement.getAttribute('data-lang')||'en')==='en'?'th':'en');});
</script>
ENDOFFILE
echo "✅  src/pages/projects/[slug].astro"

# ══════════════════════════════════════════════════════════════
# 7. CONTACT PAGE
# ══════════════════════════════════════════════════════════════
cat > src/pages/contact.astro << 'ENDOFFILE'
---
import Layout from '../layouts/Layout.astro';
import Navbar from '../components/Navbar.astro';
import contact from '../content/settings/contact.json';
---
<Layout title="Contact — Start a Conversation">
  <Navbar />

  <section class="contact-hero">
    <div class="contact-hero-inner">
      <span class="page-label" data-anim="rise" data-en="Get in Touch" data-th="ติดต่อเรา">Get in Touch</span>
      <h1 data-split data-en="Let's talk about what you're building." data-th="มาพูดคุยเกี่ยวกับสิ่งที่คุณกำลังสร้าง">
        Let's talk about<br/>what you're building.
      </h1>
    </div>
  </section>

  <section class="contact-body">
    <div class="contact-grid">

      <div class="contact-form-col">
        <form class="contact-form" id="contact-form">
          <div class="form-group">
            <label data-en="Your Name" data-th="ชื่อของคุณ">Your Name</label>
            <input type="text" name="name" required placeholder="—" />
          </div>
          <div class="form-group">
            <label data-en="Email Address" data-th="ที่อยู่อีเมล">Email Address</label>
            <input type="email" name="email" required placeholder="—" />
          </div>
          <div class="form-group">
            <label data-en="Project Type" data-th="ประเภทโครงการ">Project Type</label>
            <select name="type">
              <option value="" data-en="Select one" data-th="เลือกหนึ่ง">Select one</option>
              <option value="residential" data-en="Residential" data-th="ที่พักอาศัย">Residential</option>
              <option value="commercial" data-en="Commercial" data-th="เชิงพาณิชย์">Commercial</option>
              <option value="interior" data-en="Interior" data-th="การออกแบบภายใน">Interior</option>
              <option value="other" data-en="Other" data-th="อื่นๆ">Other</option>
            </select>
          </div>
          <div class="form-group">
            <label data-en="Tell us about your project" data-th="เล่าให้เราฟังเกี่ยวกับโครงการของคุณ">Tell us about your project</label>
            <textarea name="message" rows="5" placeholder="—"></textarea>
          </div>
          <button type="submit" class="form-submit" data-en="Send Message" data-th="ส่งข้อความ">Send Message</button>
        </form>
      </div>

      <div class="contact-info-col">
        <div class="contact-info-block" data-anim="rise">
          <span class="info-label" data-en="Direct Contact" data-th="ติดต่อโดยตรง">Direct Contact</span>
          <a href={`tel:${contact.phone}`} class="info-link">{contact.phone}</a>
          <a href={`mailto:${contact.email}`} class="info-link">{contact.email}</a>
        </div>

        <div class="contact-info-block" data-anim="rise" data-delay="1">
          <span class="info-label" data-en="Social & Messaging" data-th="โซเชียลและการส่งข้อความ">Social & Messaging</span>
          {contact.line && <a href={contact.line} target="_blank" rel="noopener" class="info-link">Line OA</a>}
          {contact.instagram && <a href={contact.instagram} target="_blank" rel="noopener" class="info-link">Instagram</a>}
          {contact.tiktok && <a href={contact.tiktok} target="_blank" rel="noopener" class="info-link">TikTok</a>}
        </div>

        <div class="contact-info-block" data-anim="rise" data-delay="2">
          <span class="info-label" data-en="Location" data-th="ที่ตั้ง">Location</span>
          <p class="info-addr" data-en={contact.address} data-th={contact.address_th}>{contact.address}</p>
        </div>
      </div>

    </div>
  </section>

  <footer class="footer">
    <div class="footer-inner">
      <div><span class="footer-logo">TNC<em>.</em>18</span></div>
      <nav class="footer-nav">
        <a href="/projects" data-en="Projects" data-th="ผลงาน">Projects</a>
        <a href="/about" data-en="About" data-th="เกี่ยวกับ">About</a>
        <a href="/services" data-en="Services" data-th="บริการ">Services</a>
      </nav>
      <p class="footer-copy">© 2024 TNC.18</p>
    </div>
  </footer>
</Layout>

<style>
  .contact-hero { background:var(--charcoal); padding:10rem 5rem 5rem; min-height:50vh; display:flex; align-items:flex-end; }
  .contact-hero-inner { max-width:700px; }
  .page-label { font-size:0.62rem; font-weight:500; letter-spacing:0.22em; text-transform:uppercase; color:var(--gold); display:block; margin-bottom:1.5rem; }
  .contact-hero h1 { font-family:var(--font-serif); font-size:clamp(2.5rem,6vw,5rem); font-weight:300; color:var(--stone); line-height:1.1; }

  .contact-body { background:var(--stone); padding:5rem; border-bottom:1px solid var(--stone-mid); }
  .contact-grid { display:grid; grid-template-columns:1fr 320px; gap:6rem; max-width:1050px; margin:0 auto; align-items:start; }

  .form-group { display:flex; flex-direction:column; gap:0.5rem; margin-bottom:1.75rem; }
  .form-group label { font-size:0.62rem; font-weight:500; letter-spacing:0.16em; text-transform:uppercase; color:var(--muted); }
  .form-group input,.form-group select,.form-group textarea { background:none; border:none; border-bottom:1px solid var(--stone-dark); padding:0.75rem 0; font-family:var(--font-sans); font-size:0.88rem; font-weight:300; color:var(--charcoal); outline:none; transition:border-color 0.3s; width:100%; }
  .form-group input:focus,.form-group select:focus,.form-group textarea:focus { border-bottom-color:var(--charcoal); }
  .form-group textarea { resize:none; }
  .form-submit { background:var(--charcoal); color:var(--stone); border:none; padding:0.9rem 2.5rem; font-family:var(--font-sans); font-size:0.68rem; font-weight:500; letter-spacing:0.18em; text-transform:uppercase; cursor:pointer; position:relative; overflow:hidden; transition:background 0.3s; margin-top:0.5rem; }
  .form-submit::before { content:''; position:absolute; inset:0; background:var(--blue); transform:translateX(-101%); transition:transform 0.4s cubic-bezier(0.4,0,0.2,1); }
  .form-submit:hover::before { transform:translateX(0); }
  .form-submit span,.form-submit { position:relative; z-index:1; }

  .contact-info-col { display:flex; flex-direction:column; gap:2.5rem; padding-top:0.5rem; }
  .contact-info-block { display:flex; flex-direction:column; gap:0.5rem; border-top:1px solid var(--stone-dark); padding-top:1.25rem; }
  .info-label { font-size:0.58rem; font-weight:500; letter-spacing:0.2em; text-transform:uppercase; color:var(--muted); margin-bottom:0.25rem; }
  .info-link { font-size:0.88rem; color:var(--charcoal); text-decoration:none; font-weight:300; transition:color 0.3s; }
  .info-link:hover { color:var(--blue); }
  .info-addr { font-size:0.85rem; color:var(--ink); font-weight:300; line-height:1.6; }

  .footer { background:#0F0E0C; padding:1.75rem 5rem; border-top:1px solid rgba(247,244,239,0.05); }
  .footer-inner { display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:1rem; }
  .footer-logo { font-family:var(--font-sans); font-size:0.85rem; font-weight:500; letter-spacing:0.1em; color:rgba(247,244,239,0.4); }
  .footer-logo em { font-style:normal; color:var(--gold); }
  .footer-nav { display:flex; gap:2rem; }
  .footer-nav a { font-size:0.58rem; letter-spacing:0.1em; text-transform:uppercase; color:rgba(247,244,239,0.2); text-decoration:none; transition:color 0.3s; }
  .footer-nav a:hover { color:rgba(247,244,239,0.65); }
  .footer-copy { font-size:0.55rem; color:rgba(247,244,239,0.12); }

  @media (max-width:900px) {
    .contact-hero,.contact-body,.footer { padding-left:1.75rem; padding-right:1.75rem; }
    .contact-grid { grid-template-columns:1fr; gap:3rem; }
    .footer-inner { flex-direction:column; align-items:flex-start; }
  }
</style>
<script>
  const io=new IntersectionObserver((entries)=>{entries.forEach(entry=>{if(!entry.isIntersecting)return;const el=entry.target as HTMLElement;if(el.dataset.anim==='rise'){el.style.opacity='1';el.style.transform='translateY(0)';}io.unobserve(el);});},{threshold:0.12});
  document.querySelectorAll('[data-anim="rise"]').forEach((el:any)=>{el.style.opacity='0';el.style.transform='translateY(20px)';el.style.transition=`opacity 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s,transform 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s`;io.observe(el);});
  document.querySelectorAll('[data-split]').forEach(el=>{const text=el.textContent?.trim()||'';el.innerHTML=text.split(' ').map((w,i)=>`<span style="display:inline-block;overflow:hidden"><span class="word" style="display:inline-block;transform:translateY(105%);opacity:0;transition:transform 0.75s cubic-bezier(0.16,1,0.3,1) ${i*0.055}s,opacity 0.5s ease ${i*0.055}s">${w}</span></span>`).join(' ');io.observe(el);});
  function applyLang(lang:string){localStorage.setItem('tnc-lang',lang);document.querySelectorAll('[data-en][data-th]').forEach(el=>{el.textContent=lang==='th'?el.getAttribute('data-th')||'':el.getAttribute('data-en')||'';});}
  applyLang(localStorage.getItem('tnc-lang')||'en');
  document.getElementById('lang-toggle')?.addEventListener('click',()=>{applyLang((document.documentElement.getAttribute('data-lang')||'en')==='en'?'th':'en');});
</script>
ENDOFFILE
echo "✅  src/pages/contact.astro"

# ══════════════════════════════════════════════════════════════
# 8. NEWS INDEX PAGE
# ══════════════════════════════════════════════════════════════
cat > src/pages/news.astro << 'ENDOFFILE'
---
import Layout from '../layouts/Layout.astro';
import Navbar from '../components/Navbar.astro';
import { getCollection } from 'astro:content';

const allNews = await getCollection('news').catch(() => []);
const articles = allNews.sort((a,b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime());
---
<Layout title="News — Updates from TNC.18">
  <Navbar />

  <section class="news-hero">
    <div class="news-hero-inner">
      <span class="page-label" data-anim="rise" data-en="News & Updates" data-th="ข่าวสารและอัปเดต">News & Updates</span>
      <h1 data-split data-en="From the studio." data-th="จากสตูดิโอ">From the studio.</h1>
    </div>
  </section>

  <section class="news-list">
    {articles.length === 0 ? (
      <div class="news-empty">
        <p data-en="No articles yet. Add your first update in the CMS admin." data-th="ยังไม่มีบทความ เพิ่มการอัปเดตแรกของคุณใน CMS admin">
          No articles yet. Add your first update in the CMS admin.
        </p>
        <a href="/admin" class="admin-link">Open CMS Admin →</a>
      </div>
    ) : (
      articles.map((article, i) => (
        <article class="news-item" data-anim="rise" data-delay={String((i%3)+1)}>
          <div class="news-item-inner">
            <div class="news-date">{new Date(article.data.date).toLocaleDateString('en-GB', {day:'numeric',month:'long',year:'numeric'})}</div>
            <div class="news-content">
              <h2 class="news-title" data-en={article.data.title} data-th={article.data.title_th||article.data.title}>{article.data.title}</h2>
              {article.data.excerpt && (
                <p class="news-excerpt" data-en={article.data.excerpt} data-th={article.data.excerpt_th||article.data.excerpt}>{article.data.excerpt}</p>
              )}
              <a href={`/news/${article.slug}`} class="news-read" data-en="Read more →" data-th="อ่านเพิ่มเติม →">Read more →</a>
            </div>
          </div>
        </article>
      ))
    )}
  </section>

  <footer class="footer">
    <div class="footer-inner">
      <div><span class="footer-logo">TNC<em>.</em>18</span></div>
      <nav class="footer-nav">
        <a href="/projects" data-en="Projects" data-th="ผลงาน">Projects</a>
        <a href="/contact" data-en="Contact" data-th="ติดต่อ">Contact</a>
      </nav>
      <p class="footer-copy">© 2024 TNC.18</p>
    </div>
  </footer>
</Layout>

<style>
  .news-hero { background:var(--charcoal); padding:10rem 5rem 5rem; min-height:45vh; display:flex; align-items:flex-end; }
  .news-hero-inner { max-width:600px; }
  .page-label { font-size:0.62rem; font-weight:500; letter-spacing:0.22em; text-transform:uppercase; color:var(--gold); display:block; margin-bottom:1.5rem; }
  .news-hero h1 { font-family:var(--font-serif); font-size:clamp(2.5rem,6vw,5rem); font-weight:300; color:var(--stone); line-height:1.1; }

  .news-list { background:var(--stone); padding:4rem 5rem; max-width:100%; }
  .news-item { border-bottom:1px solid var(--stone-mid); padding:2.5rem 0; }
  .news-item-inner { display:grid; grid-template-columns:160px 1fr; gap:3rem; max-width:900px; margin:0 auto; align-items:start; }
  .news-date { font-size:0.62rem; color:var(--muted); letter-spacing:0.1em; padding-top:0.25rem; }
  .news-title { font-family:var(--font-serif); font-size:clamp(1.1rem,1.8vw,1.5rem); font-weight:300; color:var(--charcoal); margin-bottom:0.75rem; line-height:1.25; }
  .news-excerpt { font-size:0.84rem; color:var(--ink); line-height:1.8; font-weight:300; margin-bottom:1.25rem; max-width:480px; }
  .news-read { font-size:0.64rem; letter-spacing:0.14em; text-transform:uppercase; color:var(--gold); text-decoration:none; transition:color 0.3s; }
  .news-read:hover { color:var(--blue); }
  .news-empty { padding:4rem 0; text-align:center; max-width:500px; margin:0 auto; }
  .news-empty p { font-size:0.9rem; color:var(--muted); line-height:1.7; margin-bottom:1.5rem; }
  .admin-link { font-size:0.68rem; letter-spacing:0.14em; text-transform:uppercase; color:var(--gold); text-decoration:none; }

  .footer { background:#0F0E0C; padding:1.75rem 5rem; border-top:1px solid rgba(247,244,239,0.05); }
  .footer-inner { display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:1rem; }
  .footer-logo { font-family:var(--font-sans); font-size:0.85rem; font-weight:500; letter-spacing:0.1em; color:rgba(247,244,239,0.4); }
  .footer-logo em { font-style:normal; color:var(--gold); }
  .footer-nav { display:flex; gap:2rem; }
  .footer-nav a { font-size:0.58rem; letter-spacing:0.1em; text-transform:uppercase; color:rgba(247,244,239,0.2); text-decoration:none; transition:color 0.3s; }
  .footer-nav a:hover { color:rgba(247,244,239,0.65); }
  .footer-copy { font-size:0.55rem; color:rgba(247,244,239,0.12); }

  @media (max-width:900px) {
    .news-hero,.news-list,.footer { padding-left:1.75rem; padding-right:1.75rem; }
    .news-item-inner { grid-template-columns:1fr; gap:0.75rem; }
    .footer-inner { flex-direction:column; align-items:flex-start; }
  }
</style>
<script>
  const io=new IntersectionObserver((entries)=>{entries.forEach(entry=>{if(!entry.isIntersecting)return;const el=entry.target as HTMLElement;if(el.dataset.anim==='rise'){el.style.opacity='1';el.style.transform='translateY(0)';}io.unobserve(el);});},{threshold:0.1});
  document.querySelectorAll('[data-anim="rise"]').forEach((el:any)=>{el.style.opacity='0';el.style.transform='translateY(20px)';el.style.transition=`opacity 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s,transform 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s`;io.observe(el);});
  document.querySelectorAll('[data-split]').forEach(el=>{const text=el.textContent?.trim()||'';el.innerHTML=text.split(' ').map((w,i)=>`<span style="display:inline-block;overflow:hidden"><span class="word" style="display:inline-block;transform:translateY(105%);opacity:0;transition:transform 0.75s cubic-bezier(0.16,1,0.3,1) ${i*0.055}s,opacity 0.5s ease ${i*0.055}s">${w}</span></span>`).join(' ');io.observe(el);});
  function applyLang(lang:string){localStorage.setItem('tnc-lang',lang);document.querySelectorAll('[data-en][data-th]').forEach(el=>{el.textContent=lang==='th'?el.getAttribute('data-th')||'':el.getAttribute('data-en')||'';});}
  applyLang(localStorage.getItem('tnc-lang')||'en');
  document.getElementById('lang-toggle')?.addEventListener('click',()=>{applyLang((document.documentElement.getAttribute('data-lang')||'en')==='en'?'th':'en');});
</script>
ENDOFFILE
echo "✅  src/pages/news.astro"

# ── Commit everything ─────────────────────────────────────────
git add .
git commit -m "feat: all pages built — About, Services, Projects, Contact, News + CMS-wired homepage"
git push origin main

echo ""
echo "════════════════════════════════════════════════════════"
echo "✅  ALL PAGES BUILT & PUSHED"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Pages live at localhost:4321:"
echo "  /           → Homepage (CMS-wired projects + services)"
echo "  /about      → About page with values + team"
echo "  /services   → Services from CMS"
echo "  /projects   → Filterable project grid"
echo "  /projects/[slug] → Individual project pages"
echo "  /contact    → Contact form + social links from CMS"
echo "  /news       → News/updates listing"
echo "  /admin      → Decap CMS editor"
echo ""
echo "To add real projects: go to localhost:4321/admin → Projects"
echo "To update contact:    go to localhost:4321/admin → Settings → Contact"
echo ""
echo "Run: npm run dev:cms"
echo ""
