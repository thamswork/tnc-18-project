#!/bin/bash
# ============================================================
# TNC.18 — Project Detail Page (Magazine Style)
# Layout: Full-bleed hero → specs strip → editorial story →
#         photo mosaic → related projects → next project
# ============================================================

set -e
echo ""
echo "🏛  Building magazine-style project detail page..."
echo ""

mkdir -p src/pages/projects

# ══════════════════════════════════════════════════════════════
# [slug].astro — Magazine layout project detail
# ══════════════════════════════════════════════════════════════
cat > 'src/pages/projects/[slug].astro' << 'ENDOFFILE'
---
import Layout from '../../layouts/Layout.astro';
import Navbar from '../../components/Navbar.astro';
import { getCollection } from 'astro:content';

export async function getStaticPaths() {
  const projects = await getCollection('projects');
  return projects.map(p => ({
    params: { slug: p.id },
    props: { project: p },
  }));
}

const { project } = Astro.props;
const { Content } = await project.render();

// Get other projects for "More Work" section
const allProjects = await getCollection('projects');
const others = allProjects
  .filter(p => p.id !== project.id)
  .sort((a, b) => b.data.year - a.data.year)
  .slice(0, 2);

// Placeholder colors for demo (replaced by real images)
const placeholderColors = [
  '#CDC7BA','#B8B2A5','#A8A298','#928C82',
  '#7E786C','#6A6458','#C4BEB0','#BAB4A6',
];
---

<Layout title={`${project.data.title} — TNC.18`}>
  <Navbar />

  <!-- ══════════════════════════════
       HERO — Full bleed, title overlaid
       ══════════════════════════════ -->
  <section class="hero">
    <div class="hero-media">
      {project.data.cover && !project.data.cover.includes('silom-residence')
        ? <img src={project.data.cover} alt={project.data.title} class="hero-img" />
        : <div class="hero-ph" style="background:#C8C2B2;"></div>
      }
      <div class="hero-vignette"></div>
    </div>

    <div class="hero-content">
      <div class="hero-top">
        <a href="/projects" class="back-link">
          <span class="back-arrow">←</span>
          <span data-en="All Projects" data-th="ผลงานทั้งหมด">All Projects</span>
        </a>
        <span class="hero-year">{project.data.year}</span>
      </div>
      <div class="hero-bottom">
        <span class="hero-cat" data-en={project.data.category} data-th={project.data.category_th || project.data.category}>
          {project.data.category}
        </span>
        <h1 class="hero-title" data-en={project.data.title} data-th={project.data.title_th || project.data.title}>
          {project.data.title}
        </h1>
        {project.data.location && (
          <p class="hero-location">{project.data.location}</p>
        )}
      </div>
    </div>
  </section>

  <!-- ══════════════════════════════
       SPECS STRIP
       ══════════════════════════════ -->
  <section class="specs">
    <div class="specs-inner">
      {project.data.client && (
        <div class="spec-item" data-anim="rise" data-delay="1">
          <span class="spec-label" data-en="Client" data-th="ลูกค้า">Client</span>
          <span class="spec-value">{project.data.client}</span>
        </div>
      )}
      {project.data.location && (
        <div class="spec-item" data-anim="rise" data-delay="2">
          <span class="spec-label" data-en="Location" data-th="สถานที่">Location</span>
          <span class="spec-value">{project.data.location}</span>
        </div>
      )}
      {project.data.area && (
        <div class="spec-item" data-anim="rise" data-delay="3">
          <span class="spec-label" data-en="Area" data-th="พื้นที่">Area</span>
          <span class="spec-value">{project.data.area} m²</span>
        </div>
      )}
      <div class="spec-item" data-anim="rise" data-delay="4">
        <span class="spec-label" data-en="Year" data-th="ปี">Year</span>
        <span class="spec-value">{project.data.year}</span>
      </div>
      <div class="spec-item" data-anim="rise" data-delay="5">
        <span class="spec-label" data-en="Type" data-th="ประเภท">Type</span>
        <span class="spec-value" data-en={project.data.category} data-th={project.data.category_th || project.data.category}>
          {project.data.category}
        </span>
      </div>
    </div>
  </section>

  <!-- ══════════════════════════════
       EDITORIAL INTRO
       ══════════════════════════════ -->
  {(project.data.description || project.data.description_th) && (
    <section class="editorial">
      <div class="editorial-inner">
        <div class="editorial-label">
          <span class="section-tag" data-anim="rise">Project Overview</span>
          <div class="tag-line" data-anim="line"></div>
        </div>
        <div class="editorial-text">
          <p class="editorial-lead" data-anim="rise" data-delay="1"
            data-en={project.data.description || ''}
            data-th={project.data.description_th || project.data.description || ''}>
            {project.data.description}
          </p>
          <div class="editorial-body" data-anim="rise" data-delay="2">
            <Content />
          </div>
        </div>
      </div>
    </section>
  )}

  <!-- ══════════════════════════════
       PHOTO MOSAIC — editorial grid
       Uses gallery images from CMS.
       Falls back to placeholder blocks.
       ══════════════════════════════ -->
  <section class="mosaic-section">

    {project.data.gallery && project.data.gallery.length > 0 ? (
      <!-- Real gallery from CMS -->
      <div class="photo-mosaic">
        {project.data.gallery.map((img, i) => {
          // Alternate between wide, tall, and square for visual rhythm
          const layouts = ['wide','tall','square','wide','square','tall','wide','square'];
          const layout = layouts[i % layouts.length];
          return (
            <div class={`photo-tile photo-tile--${layout}`} data-anim="rise" data-delay={String((i%3)+1)}>
              <img src={img} alt={`${project.data.title} — view ${i+1}`} loading="lazy" />
            </div>
          );
        })}
      </div>
    ) : (
      <!-- Placeholder mosaic (replace by adding gallery images in CMS) -->
      <div class="photo-mosaic">
        <!-- Row 1: wide + square -->
        <div class="photo-tile photo-tile--wide" data-anim="rise" data-delay="1">
          <div class="ph-block" style={`background:${placeholderColors[0]};`}></div>
        </div>
        <div class="photo-tile photo-tile--square" data-anim="rise" data-delay="2">
          <div class="ph-block" style={`background:${placeholderColors[1]};`}></div>
        </div>

        <!-- Row 2: three equal -->
        <div class="photo-tile photo-tile--third" data-anim="rise" data-delay="1">
          <div class="ph-block" style={`background:${placeholderColors[2]};`}></div>
        </div>
        <div class="photo-tile photo-tile--third" data-anim="rise" data-delay="2">
          <div class="ph-block" style={`background:${placeholderColors[3]};`}></div>
        </div>
        <div class="photo-tile photo-tile--third" data-anim="rise" data-delay="3">
          <div class="ph-block" style={`background:${placeholderColors[4]};`}></div>
        </div>

        <!-- Row 3: tall + wide -->
        <div class="photo-tile photo-tile--tall" data-anim="rise" data-delay="1">
          <div class="ph-block" style={`background:${placeholderColors[5]};`}></div>
        </div>
        <div class="photo-tile photo-tile--wide" data-anim="rise" data-delay="2">
          <div class="ph-block" style={`background:${placeholderColors[6]};`}></div>
        </div>

        <!-- CMS hint overlay on first tile -->
        <div class="cms-hint">
          <p data-en="Add gallery images via CMS Admin → Projects → Gallery" data-th="เพิ่มรูปภาพผ่าน CMS Admin → โครงการ → แกลเลอรี่">
            Add gallery images via CMS Admin → Projects → Gallery
          </p>
          <a href="/admin" class="cms-hint-link">Open CMS →</a>
        </div>
      </div>
    )}

  </section>

  <!-- ══════════════════════════════
       PULL QUOTE — if body content exists
       ══════════════════════════════ -->
  <section class="pull-quote">
    <div class="pull-quote-inner" data-anim="rise">
      <span class="pq-rule" data-anim="line"></span>
      <blockquote class="pq-text"
        data-en={`${project.data.title} — ${project.data.year}. ${project.data.location || 'Bangkok, Thailand'}.`}
        data-th={`${project.data.title_th || project.data.title} — ${project.data.year}. ${project.data.location || 'กรุงเทพมหานคร ประเทศไทย'}.`}>
        {project.data.title} — {project.data.year}. {project.data.location || 'Bangkok, Thailand'}.
      </blockquote>
    </div>
  </section>

  <!-- ══════════════════════════════
       MORE WORK — 2 related projects
       ══════════════════════════════ -->
  {others.length > 0 && (
    <section class="more-work">
      <div class="more-work-header" data-anim="rise">
        <span class="section-label" data-en="More Work" data-th="ผลงานอื่น">More Work</span>
        <a href="/projects" class="link-sm" data-en="All Projects →" data-th="ผลงานทั้งหมด →">All Projects →</a>
      </div>
      <div class="more-work-grid">
        {others.map((p, i) => (
          <article class="mw-card" data-anim="rise" data-delay={String(i + 1)}>
            <a href={`/projects/${p.id}`} class="mw-link">
              <div class="mw-img">
                {p.data.cover && !p.data.cover.includes('silom-residence')
                  ? <img src={p.data.cover} alt={p.data.title} loading="lazy" />
                  : <div class="mw-ph" style={`background:${placeholderColors[i+1]};`}></div>
                }
                <div class="mw-overlay">
                  <span class="mw-cat" data-en={p.data.category} data-th={p.data.category_th || p.data.category}>{p.data.category}</span>
                  <span class="mw-arr">→</span>
                </div>
              </div>
              <div class="mw-info">
                <span class="mw-year">{p.data.year}</span>
                <h2 class="mw-title" data-en={p.data.title} data-th={p.data.title_th || p.data.title}>{p.data.title}</h2>
              </div>
            </a>
          </article>
        ))}
      </div>
    </section>
  )}

  <!-- ══════════════════════════════
       NEXT / ENQUIRE BAND
       ══════════════════════════════ -->
  <section class="enquire-band">
    <div class="enquire-inner">
      <p class="enquire-text" data-anim="rise"
        data-en="Interested in a similar project?"
        data-th="สนใจโครงการที่คล้ายกันหรือไม่?">
        Interested in a similar project?
      </p>
      <a href="/contact" class="enquire-btn" data-anim="rise" data-delay="1"
        data-en="Start a conversation →"
        data-th="เริ่มบทสนทนา →">
        Start a conversation →
      </a>
    </div>
  </section>

  <!-- FOOTER -->
  <footer class="footer">
    <div class="footer-inner">
      <div>
        <span class="footer-logo">TNC<em>.</em>18</span>
        <p class="footer-sub" data-en="Architecture & Construction, Bangkok" data-th="สถาปัตยกรรมและการก่อสร้าง กรุงเทพฯ">Architecture & Construction, Bangkok</p>
      </div>
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
  /* ── HERO ── */
  .hero {
    position: relative;
    height: 100vh;
    min-height: 640px;
    overflow: hidden;
    background: var(--charcoal);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }

  .hero-media { position: absolute; inset: 0; z-index: 0; }
  .hero-img { width: 100%; height: 100%; object-fit: cover; opacity: 0.6; }
  .hero-ph { width: 100%; height: 100%; }
  .hero-vignette {
    position: absolute; inset: 0;
    background:
      linear-gradient(to top, rgba(20,18,15,0.92) 0%, rgba(20,18,15,0.4) 40%, transparent 70%),
      linear-gradient(to bottom, rgba(20,18,15,0.5) 0%, transparent 25%);
  }

  .hero-content {
    position: relative; z-index: 2;
    display: flex; flex-direction: column;
    justify-content: space-between;
    height: 100%;
    padding: 2rem 5rem;
  }

  .hero-top {
    display: flex; justify-content: space-between; align-items: center;
    padding-top: 72px; /* below navbar */
  }

  .back-link {
    display: flex; align-items: center; gap: 0.6rem;
    font-size: 0.66rem; letter-spacing: 0.14em; text-transform: uppercase;
    color: rgba(247,244,239,0.5); text-decoration: none;
    transition: color 0.3s;
  }
  .back-link:hover { color: var(--stone); }
  .back-arrow { transition: transform 0.3s; }
  .back-link:hover .back-arrow { transform: translateX(-4px); }

  .hero-year {
    font-size: 0.62rem; letter-spacing: 0.16em;
    color: rgba(247,244,239,0.35);
  }

  .hero-bottom { padding-bottom: 3rem; }

  .hero-cat {
    display: block; font-size: 0.62rem; font-weight: 500;
    letter-spacing: 0.22em; text-transform: uppercase;
    color: var(--gold); margin-bottom: 1rem;
    animation: fadeUp 0.8s 0.3s both;
  }

  .hero-title {
    font-family: var(--font-serif);
    font-size: clamp(3rem, 8vw, 7rem);
    font-weight: 300; line-height: 1.0;
    color: var(--stone);
    animation: slideUp 1.1s cubic-bezier(0.16,1,0.3,1) both;
    margin-bottom: 1rem;
  }

  .hero-location {
    font-size: 0.72rem; letter-spacing: 0.12em;
    color: rgba(247,244,239,0.35);
    animation: fadeUp 0.8s 0.5s both;
  }

  @keyframes slideUp { from{transform:translateY(60px);opacity:0} to{transform:translateY(0);opacity:1} }
  @keyframes fadeUp  { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }

  /* ── SPECS STRIP ── */
  .specs {
    background: var(--charcoal);
    border-top: 1px solid rgba(247,244,239,0.08);
    border-bottom: 1px solid rgba(247,244,239,0.08);
    padding: 2rem 5rem;
  }

  .specs-inner {
    display: flex; gap: 0; flex-wrap: wrap;
    max-width: 1100px; margin: 0 auto;
  }

  .spec-item {
    display: flex; flex-direction: column; gap: 0.3rem;
    padding: 0 3rem 0 0;
    border-right: 1px solid rgba(247,244,239,0.08);
    margin-right: 3rem;
  }

  .spec-item:last-child { border-right: none; margin-right: 0; padding-right: 0; }

  .spec-label {
    font-size: 0.56rem; font-weight: 500; letter-spacing: 0.2em;
    text-transform: uppercase; color: rgba(247,244,239,0.3);
  }

  .spec-value {
    font-family: var(--font-serif); font-size: 1rem;
    font-weight: 300; color: var(--stone);
  }

  /* ── EDITORIAL INTRO ── */
  .editorial {
    background: var(--stone);
    padding: 6rem 5rem;
    border-bottom: 1px solid var(--stone-mid);
  }

  .editorial-inner {
    display: grid; grid-template-columns: 120px 1fr;
    gap: 3rem; max-width: 1000px; margin: 0 auto;
    align-items: start;
  }

  .editorial-label {
    display: flex; flex-direction: column; gap: 1rem; padding-top: 0.4rem;
  }

  .section-tag {
    font-size: 0.58rem; font-weight: 500; letter-spacing: 0.22em;
    text-transform: uppercase; color: var(--gold);
  }

  .tag-line { width: 100%; height: 1px; background: var(--stone-dark); }

  .editorial-lead {
    font-family: var(--font-serif);
    font-size: clamp(1.15rem, 2vw, 1.5rem);
    font-weight: 300; font-style: italic;
    color: var(--ink); line-height: 1.7;
    margin-bottom: 2rem;
  }

  .editorial-body {
    font-size: 0.88rem; color: var(--ink);
    line-height: 1.9; font-weight: 300;
  }
  .editorial-body p { margin-bottom: 1.25rem; }
  .editorial-body h2, .editorial-body h3 {
    font-family: var(--font-serif); font-weight: 300;
    color: var(--charcoal); margin: 2rem 0 0.75rem; font-size: 1.25rem;
  }

  /* ── PHOTO MOSAIC ── */
  .mosaic-section {
    background: var(--warm-white);
    padding: 0;
    position: relative;
  }

  .photo-mosaic {
    display: grid;
    grid-template-columns: repeat(12, 1fr);
    grid-auto-rows: 260px;
    gap: 4px;
    padding: 4px;
  }

  /* Wide = 8 cols */
  .photo-tile--wide { grid-column: span 8; }
  /* Square = 4 cols */
  .photo-tile--square { grid-column: span 4; }
  /* Third = 4 cols each */
  .photo-tile--third { grid-column: span 4; }
  /* Tall = 4 cols, 2 rows */
  .photo-tile--tall { grid-column: span 4; grid-row: span 2; }

  .photo-tile img,
  .ph-block {
    width: 100%; height: 100%;
    object-fit: cover;
    display: block;
    transition: transform 0.9s cubic-bezier(0.4,0,0.2,1);
  }

  .photo-tile { overflow: hidden; }
  .photo-tile:hover img,
  .photo-tile:hover .ph-block { transform: scale(1.04); }

  /* CMS hint — only shows when no gallery images */
  .cms-hint {
    position: absolute;
    top: 50%; left: 50%;
    transform: translate(-50%, -50%);
    background: rgba(28,26,23,0.85);
    backdrop-filter: blur(8px);
    padding: 1.5rem 2rem;
    text-align: center;
    pointer-events: none;
    z-index: 10;
  }

  .cms-hint p {
    font-size: 0.72rem; letter-spacing: 0.1em;
    color: rgba(247,244,239,0.6);
    margin-bottom: 0.75rem;
  }

  .cms-hint-link {
    font-size: 0.66rem; letter-spacing: 0.14em; text-transform: uppercase;
    color: var(--gold); text-decoration: none;
    pointer-events: all;
  }

  /* ── PULL QUOTE ── */
  .pull-quote {
    background: var(--stone-mid);
    padding: 5rem;
    border-top: 1px solid var(--stone-dark);
    border-bottom: 1px solid var(--stone-dark);
  }

  .pull-quote-inner {
    max-width: 800px; margin: 0 auto;
    display: flex; flex-direction: column; gap: 1.5rem;
  }

  .pq-rule {
    display: block; width: 48px; height: 1px;
    background: var(--gold);
  }

  .pq-text {
    font-family: var(--font-serif);
    font-size: clamp(1.25rem, 2.2vw, 1.75rem);
    font-weight: 300; font-style: italic;
    color: var(--ink); line-height: 1.6;
  }

  /* ── MORE WORK ── */
  .more-work {
    background: var(--stone);
    padding: 5rem;
    border-top: 1px solid var(--stone-mid);
  }

  .more-work-header {
    display: flex; justify-content: space-between; align-items: baseline;
    border-bottom: 1px solid var(--stone-dark);
    padding-bottom: 1rem; margin-bottom: 2rem;
  }

  .section-label {
    font-family: var(--font-sans); font-size: 0.62rem; font-weight: 500;
    letter-spacing: 0.22em; text-transform: uppercase; color: var(--muted);
  }

  .link-sm {
    font-size: 0.66rem; letter-spacing: 0.1em;
    color: var(--ink); text-decoration: none; transition: color 0.3s;
  }
  .link-sm:hover { color: var(--blue); }

  .more-work-grid {
    display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;
  }

  .mw-link { display: block; text-decoration: none; color: inherit; }
  .mw-img { aspect-ratio: 16/10; overflow: hidden; background: var(--stone-dark); position: relative; margin-bottom: 0.85rem; }
  .mw-img img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.85s cubic-bezier(0.4,0,0.2,1); }
  .mw-ph { width: 100%; height: 100%; transition: transform 0.85s cubic-bezier(0.4,0,0.2,1); }
  .mw-link:hover .mw-ph, .mw-link:hover .mw-img img { transform: scale(1.04); }

  .mw-overlay {
    position: absolute; inset: 0;
    background: linear-gradient(to top, rgba(20,18,15,0.65) 0%, transparent 55%);
    display: flex; align-items: flex-end; justify-content: space-between;
    padding: 1rem 1.25rem; opacity: 0; transition: opacity 0.4s;
  }
  .mw-link:hover .mw-overlay { opacity: 1; }

  .mw-cat {
    font-size: 0.56rem; font-weight: 500; letter-spacing: 0.18em;
    text-transform: uppercase; color: var(--gold-light);
  }
  .mw-arr { color: var(--gold); font-size: 0.85rem; }

  .mw-year { font-size: 0.58rem; color: var(--muted); display: block; margin-bottom: 0.25rem; }
  .mw-title {
    font-family: var(--font-serif); font-size: clamp(1rem, 1.5vw, 1.25rem);
    font-weight: 300; color: var(--charcoal); transition: color 0.3s; line-height: 1.2;
  }
  .mw-link:hover .mw-title { color: var(--blue); }

  /* ── ENQUIRE BAND ── */
  .enquire-band {
    background: var(--charcoal);
    padding: 4rem 5rem;
    border-top: 1px solid rgba(247,244,239,0.06);
  }

  .enquire-inner {
    display: flex; align-items: center; justify-content: space-between;
    max-width: 1000px; margin: 0 auto;
  }

  .enquire-text {
    font-family: var(--font-serif);
    font-size: clamp(1.25rem, 2.5vw, 1.75rem);
    font-weight: 300; font-style: italic;
    color: var(--stone);
  }

  .enquire-btn {
    font-size: 0.68rem; font-weight: 500; letter-spacing: 0.16em;
    text-transform: uppercase; color: var(--gold);
    text-decoration: none; border-bottom: 1px solid rgba(166,124,78,0.4);
    padding-bottom: 2px; transition: color 0.3s, border-color 0.3s;
    white-space: nowrap; margin-left: 3rem;
  }
  .enquire-btn:hover { color: var(--warm-white); border-color: rgba(247,244,239,0.4); }

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
    .hero-content { padding: 1.5rem 1.75rem; }
    .specs { padding: 1.75rem; }
    .specs-inner { gap: 1.5rem; }
    .spec-item { padding-right: 1.5rem; margin-right: 1.5rem; }
    .editorial { padding: 4rem 1.75rem; }
    .editorial-inner { grid-template-columns: 1fr; gap: 1.25rem; }
    .photo-mosaic { grid-template-columns: repeat(6, 1fr); grid-auto-rows: 200px; }
    .photo-tile--wide { grid-column: span 6; }
    .photo-tile--square, .photo-tile--third { grid-column: span 3; }
    .photo-tile--tall { grid-column: span 3; }
    .pull-quote { padding: 4rem 1.75rem; }
    .more-work { padding: 4rem 1.75rem; }
    .more-work-grid { grid-template-columns: 1fr; }
    .enquire-band { padding: 3rem 1.75rem; }
    .enquire-inner { flex-direction: column; align-items: flex-start; gap: 1.5rem; }
    .enquire-btn { margin-left: 0; }
    .footer { padding: 1.5rem 1.75rem; }
    .footer-inner { flex-direction: column; align-items: flex-start; gap: 0.75rem; }
  }
</style>

<script>
  // Animations
  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const el = entry.target as HTMLElement;
      if (el.dataset.anim === 'rise') {
        el.style.opacity = '1';
        el.style.transform = 'translateY(0)';
      }
      if (el.dataset.anim === 'line') {
        el.style.transform = 'scaleX(1)';
      }
      io.unobserve(el);
    });
  }, { threshold: 0.12 });

  document.querySelectorAll('[data-anim="rise"]').forEach((el: any) => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = `opacity 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s, transform 0.8s cubic-bezier(0.16,1,0.3,1) ${(+(el.dataset.delay||0))*0.12}s`;
    io.observe(el);
  });

  document.querySelectorAll('[data-anim="line"]').forEach((el: any) => {
    el.style.transform = 'scaleX(0)';
    el.style.transformOrigin = 'left';
    el.style.transition = 'transform 1s cubic-bezier(0.4,0,0.2,1) 0.2s';
    io.observe(el);
  });

  // Language
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
echo "✅  src/pages/projects/[slug].astro"

# Commit
git add .
git commit -m "feat: magazine-style project detail page with editorial mosaic"
git push origin main

echo ""
echo "════════════════════════════════════════════════"
echo "✅  Project detail page built & pushed"
echo "════════════════════════════════════════════════"
echo ""
echo "Visit: http://localhost:4321/projects/silom-residence"
echo ""
echo "To add real photos to a project:"
echo "  1. Go to localhost:4321/admin"
echo "  2. Projects → Silom Residence"
echo "  3. Scroll to Gallery Images → Add images"
echo "  4. Save → photos appear in the mosaic instantly"
echo ""
echo "Mosaic layout:"
echo "  Row 1: Wide (8 cols) + Square (4 cols)"
echo "  Row 2: Three equal thirds"
echo "  Row 3: Tall portrait (4 cols, 2 rows) + Wide (8 cols)"
echo ""
