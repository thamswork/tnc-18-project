#!/bin/bash
# ============================================================
# TNC.18 — Premium Scroll + Text Animation Edition
# Scroll: CSS scroll-snap between sections (native, smooth)
# Text:   Word-by-word reveal, line wipe, counter animation
# Blue:   Hidden surprise on hover only
# ============================================================

set -e
echo ""
echo "🏛  TNC.18 — Scroll & Animation Edition..."
echo ""

# ── 1. astro.config.mjs ──────────────────────────────────────
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

# ── 2. src/styles/global.css ─────────────────────────────────
mkdir -p src/styles
cat > src/styles/global.css << 'ENDOFFILE'
@import "tailwindcss";

:root {
  --stone:      #F7F4EF;
  --stone-mid:  #EAE5DB;
  --stone-dark: #CFC9BC;
  --charcoal:   #1C1A17;
  --ink:        #3B3830;
  --muted:      #8A8680;
  --warm-white: #FDFCFA;
  --gold:       #A67C4E;
  --gold-light: #C49A6C;
  --gold-pale:  #F0E4D0;
  --blue:       #1B3F7A;
  --blue-mid:   #2452A0;
  --blue-pale:  #E8EEF8;
  --font-sans:  'Poppins', system-ui, sans-serif;
  --font-serif: 'Merriweather', Georgia, serif;
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

html {
  background: var(--stone);
  color: var(--charcoal);
}

body {
  font-family: var(--font-sans);
  font-weight: 300;
  -webkit-font-smoothing: antialiased;
  overflow-x: hidden;
}

h1, h2, h3 {
  font-family: var(--font-serif);
  font-weight: 300;
  line-height: 1.1;
}

p { line-height: 1.8; color: var(--ink); }
img, video { display: block; width: 100%; }
::selection { background: var(--blue); color: var(--warm-white); }
::-webkit-scrollbar { width: 2px; }
::-webkit-scrollbar-track { background: var(--stone); }
::-webkit-scrollbar-thumb { background: var(--gold); }

/* ════════════════════════════════════════
   SCROLL SNAP — section by section
   ════════════════════════════════════════ */
.snap-container {
  height: 100vh;
  overflow-y: scroll;
  scroll-snap-type: y mandatory;
  scroll-behavior: smooth;
  /* Webkit smooth momentum */
  -webkit-overflow-scrolling: touch;
}

.snap-section {
  scroll-snap-align: start;
  scroll-snap-stop: always; /* never skip a section */
}

/* Tall sections (about, services) don't snap-force — they scroll freely inside */
.snap-section--free {
  scroll-snap-align: start;
  scroll-snap-stop: normal;
}

/* ════════════════════════════════════════
   TEXT ANIMATION SYSTEM
   ════════════════════════════════════════ */

/* 1. Fade + rise — paragraphs, labels */
[data-anim="rise"] {
  opacity: 0;
  transform: translateY(22px);
  transition: opacity 0.85s cubic-bezier(0.16,1,0.3,1),
              transform 0.85s cubic-bezier(0.16,1,0.3,1);
}
[data-anim="rise"].anim-in { opacity: 1; transform: translateY(0); }

/* 2. Word split — headlines split into spans per word */
.word-wrap {
  overflow: hidden;
  display: inline-block;
}
.word {
  display: inline-block;
  transform: translateY(105%);
  opacity: 0;
  transition: transform 0.8s cubic-bezier(0.16,1,0.3,1),
              opacity 0.6s ease;
}
.word.word-in {
  transform: translateY(0);
  opacity: 1;
}

/* 3. Line wipe — horizontal rule grows left to right */
[data-anim="line"] {
  transform: scaleX(0);
  transform-origin: left;
  transition: transform 1s cubic-bezier(0.4,0,0.2,1);
}
[data-anim="line"].anim-in { transform: scaleX(1); }

/* 4. Counter — numbers count up (handled in JS) */
[data-counter] {
  display: inline-block;
}

/* Stagger via CSS custom property */
[data-delay="1"] { transition-delay: 0.08s !important; }
[data-delay="2"] { transition-delay: 0.18s !important; }
[data-delay="3"] { transition-delay: 0.30s !important; }
[data-delay="4"] { transition-delay: 0.44s !important; }
[data-delay="5"] { transition-delay: 0.60s !important; }
ENDOFFILE
echo "✅  src/styles/global.css"

# ── 3. src/layouts/Layout.astro ──────────────────────────────
mkdir -p src/layouts
cat > src/layouts/Layout.astro << 'ENDOFFILE'
---
export interface Props {
  title: string;
  description?: string;
}
const { title, description = 'TNC.18 — Architecture & Construction Excellence, Thailand' } = Astro.props;
---
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content={description} />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500&family=Merriweather:ital,wght@0,300;0,400;1,300;1,400&display=swap" rel="stylesheet" />
    <title>{title} — TNC.18</title>
    <link rel="stylesheet" href="/src/styles/global.css" />
  </head>
  <body>
    <slot />

    <script>
      // ════════════════════════════════════════
      // WORD SPLIT — wrap each word in a span
      // ════════════════════════════════════════
      function splitWords(el) {
        const text = el.textContent || '';
        el.innerHTML = text.trim().split(' ').map((word, i) =>
          `<span class="word-wrap"><span class="word" style="transition-delay:${0.06 * i}s">${word}</span></span>`
        ).join(' ');
      }

      document.querySelectorAll('[data-split]').forEach(el => splitWords(el));

      // ════════════════════════════════════════
      // INTERSECTION OBSERVER — triggers all anims
      // ════════════════════════════════════════
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (!entry.isIntersecting) return;
          const el = entry.target;

          // Rise animation
          if (el.hasAttribute('data-anim')) {
            el.classList.add('anim-in');
          }

          // Word split animation
          el.querySelectorAll('.word').forEach(w => w.classList.add('word-in'));
          if (el.classList.contains('word')) el.classList.add('word-in');

          // Counter animation
          el.querySelectorAll('[data-counter]').forEach(counter => {
            const target = parseInt(counter.getAttribute('data-counter') || '0', 10);
            const duration = 1800;
            const start = performance.now();
            const suffix = counter.getAttribute('data-suffix') || '';

            function tick(now) {
              const progress = Math.min((now - start) / duration, 1);
              // Ease out quart
              const eased = 1 - Math.pow(1 - progress, 4);
              counter.textContent = Math.floor(eased * target) + suffix;
              if (progress < 1) requestAnimationFrame(tick);
            }
            requestAnimationFrame(tick);
          });

          observer.unobserve(el);
        });
      }, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });

      // Observe everything animated
      document.querySelectorAll('[data-anim], [data-split]').forEach(el => observer.observe(el));
      // Also observe stat blocks that contain counters
      document.querySelectorAll('.stat-block').forEach(el => observer.observe(el));

      // ════════════════════════════════════════
      // LANGUAGE TOGGLE
      // ════════════════════════════════════════
      function applyLang(lang) {
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

      const saved = localStorage.getItem('tnc-lang') || 'en';
      applyLang(saved);

      document.getElementById('lang-toggle')?.addEventListener('click', () => {
        const cur = document.documentElement.getAttribute('data-lang') || 'en';
        applyLang(cur === 'en' ? 'th' : 'en');
      });
    </script>
  </body>
</html>
ENDOFFILE
echo "✅  src/layouts/Layout.astro"

# ── 4. src/components/Navbar.astro ───────────────────────────
mkdir -p src/components
cat > src/components/Navbar.astro << 'ENDOFFILE'
---
const links = [
  { href: '/about',    en: 'About',    th: 'เกี่ยวกับ' },
  { href: '/services', en: 'Services', th: 'บริการ' },
  { href: '/projects', en: 'Projects', th: 'ผลงาน' },
  { href: '/contact',  en: 'Contact',  th: 'ติดต่อ' },
];
const path = Astro.url.pathname;
---

<header id="site-header">
  <a href="/" class="logo" aria-label="TNC.18 Home">
    <svg width="32" height="32" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" class="logo-svg">
      <polygon class="svg-top-t"  points="4,16 16,10 28,16 28,20 16,14 4,20"  fill="#1C1A17"/>
      <polygon points="4,16 4,20 10,23 10,19"              fill="#8A8680"/>
      <polygon points="28,16 28,20 22,23 22,19"            fill="#8A8680"/>
      <polygon points="10,19 10,32 16,35 16,22 22,19 22,32 16,35" fill="#CFC9BC"/>
      <polygon class="svg-top-n"  points="20,30 32,24 44,30 44,34 32,28 20,34" fill="#1C1A17"/>
      <polygon points="20,30 20,34 26,37 26,33"            fill="#8A8680"/>
      <polygon points="44,30 44,34 38,37 38,33"            fill="#8A8680"/>
      <polygon points="26,33 26,44 32,47 32,36 38,33 38,44 32,47" fill="#CFC9BC"/>
    </svg>
    <span class="logo-type">TNC<em>.</em>18</span>
  </a>

  <nav class="nav-links" aria-label="Primary">
    {links.map(link => (
      <a
        href={link.href}
        class={`nav-link ${path.startsWith(link.href) ? 'active' : ''}`}
        data-en={link.en}
        data-th={link.th}
      >{link.en}</a>
    ))}
  </nav>

  <div class="nav-right">
    <button id="lang-toggle" class="lang-btn" aria-label="Switch language">
      <span id="lang-en" class="lang-opt active">EN</span>
      <span class="lang-div">/</span>
      <span id="lang-th" class="lang-opt">TH</span>
    </button>
    <a href="/contact" class="nav-cta" data-en="Enquire" data-th="สอบถาม">
      <span>Enquire</span>
    </a>
    <button id="hamburger" class="hamburger" aria-label="Menu">
      <span></span><span></span>
    </button>
  </div>
</header>

<div id="mobile-menu" class="mobile-menu">
  {links.map(link => (
    <a href={link.href} class="mobile-link" data-en={link.en} data-th={link.th}>
      {link.en}
    </a>
  ))}
  <a href="/contact" class="mobile-cta" data-en="Enquire" data-th="สอบถาม">Enquire</a>
</div>

<style>
  #site-header {
    position: fixed; top:0; left:0; right:0; z-index:200;
    height:68px; padding:0 4rem;
    display:flex; align-items:center;
    background:rgba(247,244,239,0.88);
    backdrop-filter:blur(20px);
    -webkit-backdrop-filter:blur(20px);
    border-bottom:1px solid var(--stone-mid);
    transition:background 0.5s, border-color 0.5s;
  }
  #site-header.scrolled {
    background:rgba(247,244,239,0.97);
    border-bottom-color:var(--stone-dark);
  }

  .logo { display:flex; align-items:center; gap:0.65rem; text-decoration:none; margin-right:auto; }

  .svg-top-t, .svg-top-n { transition:fill 0.4s ease; }
  .logo:hover .svg-top-t,
  .logo:hover .svg-top-n { fill:var(--blue); }

  .logo-type { font-family:var(--font-sans); font-size:1rem; font-weight:500; letter-spacing:0.14em; text-transform:uppercase; color:var(--charcoal); }
  .logo-type em { font-style:normal; color:var(--gold); }

  .nav-links { display:flex; gap:2.5rem; }
  .nav-link {
    font-family:var(--font-sans); font-size:0.7rem; font-weight:400;
    letter-spacing:0.14em; text-transform:uppercase;
    color:var(--muted); text-decoration:none;
    position:relative; padding-bottom:3px; transition:color 0.3s;
  }
  .nav-link::after {
    content:''; position:absolute; bottom:0; left:0; right:0;
    height:1px; background:var(--gold);
    transform:scaleX(0); transform-origin:left;
    transition:transform 0.35s cubic-bezier(0.4,0,0.2,1), background 0.3s;
  }
  .nav-link:hover { color:var(--charcoal); }
  .nav-link:hover::after { transform:scaleX(1); background:var(--blue); }
  .nav-link.active { color:var(--charcoal); }
  .nav-link.active::after { transform:scaleX(1); background:var(--gold); }

  .nav-right { display:flex; align-items:center; gap:2rem; margin-left:3rem; }

  .lang-btn { background:none; border:none; cursor:pointer; display:flex; align-items:center; gap:3px; padding:0; }
  .lang-opt { font-size:0.66rem; font-weight:500; letter-spacing:0.12em; color:var(--muted); transition:color 0.3s; }
  .lang-opt.active { color:var(--charcoal); }
  .lang-div { font-size:0.66rem; color:var(--stone-dark); }

  .nav-cta {
    font-size:0.68rem; font-weight:500; letter-spacing:0.14em; text-transform:uppercase;
    color:var(--warm-white); background:var(--charcoal);
    text-decoration:none; padding:0.58rem 1.35rem;
    position:relative; overflow:hidden;
    transition:color 0.4s;
  }
  .nav-cta::before {
    content:''; position:absolute; inset:0;
    background:var(--blue);
    transform:translateX(-101%);
    transition:transform 0.4s cubic-bezier(0.4,0,0.2,1);
  }
  .nav-cta:hover::before { transform:translateX(0); }
  .nav-cta span { position:relative; z-index:1; }

  .hamburger { display:none; flex-direction:column; gap:6px; background:none; border:none; cursor:pointer; padding:2px; }
  .hamburger span { display:block; width:20px; height:1px; background:var(--charcoal); transition:0.3s; }

  .mobile-menu {
    display:none; position:fixed; top:68px; left:0; right:0; bottom:0;
    background:var(--warm-white); z-index:190;
    flex-direction:column; padding:3rem 2.5rem; gap:0; overflow-y:auto;
  }
  .mobile-menu.open { display:flex; }
  .mobile-link {
    font-family:var(--font-serif); font-size:2rem; font-weight:300;
    color:var(--charcoal); text-decoration:none;
    padding:0.9rem 0; border-bottom:1px solid var(--stone-mid);
    transition:color 0.3s, padding-left 0.3s;
  }
  .mobile-link:hover { color:var(--blue); padding-left:0.5rem; }
  .mobile-cta {
    margin-top:2rem; font-size:0.75rem; letter-spacing:0.16em;
    text-transform:uppercase; color:var(--muted); text-decoration:none;
  }

  @media (max-width:960px) {
    #site-header { padding:0 1.5rem; }
    .nav-links, .nav-cta { display:none; }
    .hamburger { display:flex; }
  }
</style>

<script>
  // Scroll header effect — listens on the snap container
  const container = document.getElementById('snap-container');
  const header = document.getElementById('site-header');
  (container || window).addEventListener('scroll', () => {
    const scrollY = container ? container.scrollTop : window.scrollY;
    header?.classList.toggle('scrolled', scrollY > 30);
  }, { passive: true });

  document.getElementById('hamburger')?.addEventListener('click', () => {
    document.getElementById('mobile-menu')?.classList.toggle('open');
  });
</script>
ENDOFFILE
echo "✅  src/components/Navbar.astro"

# ── 5. src/pages/index.astro ─────────────────────────────────
cat > src/pages/index.astro << 'ENDOFFILE'
---
import Layout from '../layouts/Layout.astro';
import Navbar from '../components/Navbar.astro';
---

<Layout title="Architecture & Construction Excellence">
  <Navbar />

  <!--
    SNAP CONTAINER wraps all sections.
    Each .snap-section snaps into place on scroll.
    Tall sections use snap-section--free so they don't cut off.
  -->
  <div id="snap-container" class="snap-container">

    <!-- ══════════════════════════════
         §1  HERO
         ══════════════════════════════ -->
    <section class="snap-section hero">
      <div class="hero-media">
        <video autoplay muted loop playsinline class="hero-video">
          <source src="/hero.mp4" type="video/mp4" />
        </video>
        <div class="hero-fallback"></div>
        <div class="hero-vignette"></div>
      </div>

      <div class="hero-content">
        <p class="hero-location"
          data-en="Bangkok · Thailand"
          data-th="กรุงเทพมหานคร · ประเทศไทย">
          Bangkok · Thailand
        </p>

        <!-- data-split triggers JS word-by-word animation -->
        <h1 class="hero-headline">
          <span class="hero-line" data-split
            data-en="We Build"
            data-th="เราสร้าง">We Build</span>
          <span class="hero-line hero-line--italic" data-split
            data-en="What Lasts."
            data-th="สิ่งที่ยั่งยืน">What Lasts.</span>
        </h1>

        <div class="hero-rule" data-anim="line"></div>
      </div>

      <div class="hero-footer">
        <a href="/projects" class="hero-cta"
          data-en="View Our Work"
          data-th="ดูผลงานของเรา">
          View Our Work <span class="hero-arrow">→</span>
        </a>
        <p class="hero-tagline"
          data-en="Architecture · Engineering · Construction"
          data-th="สถาปัตยกรรม · วิศวกรรม · การก่อสร้าง">
          Architecture · Engineering · Construction
        </p>
      </div>

      <!-- Section indicator dots -->
      <nav class="section-dots" aria-label="Scroll sections">
        <button class="dot dot--active" data-target="0" aria-label="Hero"></button>
        <button class="dot" data-target="1" aria-label="Statement"></button>
        <button class="dot" data-target="2" aria-label="Projects"></button>
        <button class="dot" data-target="3" aria-label="About"></button>
        <button class="dot" data-target="4" aria-label="Services"></button>
        <button class="dot" data-target="5" aria-label="Contact"></button>
      </nav>
    </section>

    <!-- ══════════════════════════════
         §2  STATEMENT
         ══════════════════════════════ -->
    <section class="snap-section statement" id="section-1">
      <div class="statement-inner">
        <div class="statement-left">
          <span class="statement-tag" data-anim="rise">TNC.18</span>
          <div class="statement-line" data-anim="line"></div>
        </div>
        <blockquote class="statement-quote">
          <span class="statement-text" data-split data-delay="1"
            data-en="Every structure we build carries a single promise — that it will outlast the moment it was made for."
            data-th="ทุกสิ่งที่เราสร้างมีคำสัญญาเดียว — ว่ามันจะคงอยู่ยาวนานกว่าช่วงเวลาที่มันถูกสร้างขึ้น">
            Every structure we build carries a single promise — that it will outlast the moment it was made for.
          </span>
        </blockquote>
      </div>
    </section>

    <!-- ══════════════════════════════
         §3  PROJECTS
         ══════════════════════════════ -->
    <section class="snap-section--free projects" id="section-2">
      <header class="projects-header" data-anim="rise">
        <span class="section-label"
          data-en="Selected Work"
          data-th="ผลงานคัดสรร">Selected Work</span>
        <a href="/projects" class="link-plain"
          data-en="View All →"
          data-th="ดูทั้งหมด →">View All →</a>
      </header>

      <div class="projects-grid">
        <article class="proj proj--a" data-anim="rise" data-delay="1">
          <a href="/projects/silom-residence" class="proj-link">
            <div class="proj-img">
              <div class="proj-ph" style="background:#CDC7BA;"></div>
            </div>
            <div class="proj-meta">
              <div class="proj-top">
                <span class="proj-year">2024</span>
                <span class="proj-cat" data-en="Residential" data-th="ที่พักอาศัย">Residential</span>
              </div>
              <h2 class="proj-title" data-en="Silom Residence" data-th="บ้านพักสีลม">Silom Residence</h2>
            </div>
          </a>
        </article>

        <div class="proj-col">
          <article class="proj proj--b" data-anim="rise" data-delay="2">
            <a href="/projects/thonglor-tower" class="proj-link">
              <div class="proj-img">
                <div class="proj-ph" style="background:#B8B2A5;"></div>
              </div>
              <div class="proj-meta">
                <div class="proj-top">
                  <span class="proj-year">2023</span>
                  <span class="proj-cat" data-en="Commercial" data-th="เชิงพาณิชย์">Commercial</span>
                </div>
                <h2 class="proj-title" data-en="Thonglor Office Tower" data-th="อาคารสำนักงานทองหล่อ">Thonglor Office Tower</h2>
              </div>
            </a>
          </article>

          <article class="proj proj--c" data-anim="rise" data-delay="3">
            <a href="/projects/sathorn-penthouse" class="proj-link">
              <div class="proj-img">
                <div class="proj-ph" style="background:#A8A298;"></div>
              </div>
              <div class="proj-meta">
                <div class="proj-top">
                  <span class="proj-year">2023</span>
                  <span class="proj-cat" data-en="Interior" data-th="การออกแบบภายใน">Interior</span>
                </div>
                <h2 class="proj-title" data-en="Sathorn Penthouse" data-th="เพนท์เฮาส์สาทร">Sathorn Penthouse</h2>
              </div>
            </a>
          </article>
        </div>
      </div>
    </section>

    <!-- ══════════════════════════════
         §4  ABOUT
         ══════════════════════════════ -->
    <section class="snap-section--free about" id="section-3">
      <div class="about-inner">
        <div class="about-text">
          <span class="section-label" data-anim="rise"
            data-en="About the Firm"
            data-th="เกี่ยวกับบริษัท">About the Firm</span>
          <h2 data-split data-delay="1"
            data-en="Eighteen years of precision, craft, and permanence."
            data-th="สิบแปดปีแห่งความแม่นยำ ฝีมือ และความยั่งยืน">
            Eighteen years of precision, craft, and permanence.
          </h2>
          <p data-anim="rise" data-delay="2"
            data-en="TNC.18 is a Bangkok-based architecture and construction firm. We work across residential, commercial, and interior disciplines — always with the same commitment to materials, structure, and lasting design."
            data-th="TNC.18 เป็นบริษัทสถาปัตยกรรมและก่อสร้างในกรุงเทพฯ เราทำงานทั้งในด้านที่พักอาศัย เชิงพาณิชย์ และการออกแบบภายใน ด้วยความมุ่งมั่นในวัสดุ โครงสร้าง และการออกแบบที่ยั่งยืนเสมอ">
            TNC.18 is a Bangkok-based architecture and construction firm. We work across residential, commercial, and interior disciplines — always with the same commitment to materials, structure, and lasting design.
          </p>
          <a href="/about" class="link-under" data-anim="rise" data-delay="3"
            data-en="Our Story" data-th="เรื่องราวของเรา">Our Story</a>
        </div>

        <div class="about-stats">
          <div class="stat-block" data-anim="rise" data-delay="1">
            <div class="stat-rule" data-anim="line"></div>
            <span class="stat-num">
              <span data-counter="18" data-suffix="">0</span>
            </span>
            <span class="stat-label" data-en="Years" data-th="ปี">Years</span>
          </div>
          <div class="stat-block" data-anim="rise" data-delay="2">
            <div class="stat-rule" data-anim="line"></div>
            <span class="stat-num">
              <span data-counter="200" data-suffix="+">0</span>
            </span>
            <span class="stat-label" data-en="Projects" data-th="โครงการ">Projects</span>
          </div>
          <div class="stat-block" data-anim="rise" data-delay="3">
            <div class="stat-rule" data-anim="line"></div>
            <span class="stat-num">
              <span data-counter="50" data-suffix="+">0</span>
            </span>
            <span class="stat-label" data-en="Specialists" data-th="ผู้เชี่ยวชาญ">Specialists</span>
          </div>
        </div>
      </div>
    </section>

    <!-- ══════════════════════════════
         §5  SERVICES
         ══════════════════════════════ -->
    <section class="snap-section--free services" id="section-4">
      <div class="services-inner">
        <span class="section-label" data-anim="rise"
          data-en="What We Do"
          data-th="สิ่งที่เราทำ">What We Do</span>

        <div class="services-list">
          {[
            { n:'01', en:'Architecture & Design',   th:'สถาปัตยกรรมและการออกแบบ' },
            { n:'02', en:'Structural Engineering',   th:'วิศวกรรมโครงสร้าง' },
            { n:'03', en:'Interior Architecture',    th:'สถาปัตยกรรมภายใน' },
            { n:'04', en:'Construction Management',  th:'การบริหารการก่อสร้าง' },
            { n:'05', en:'Site Supervision',         th:'การควบคุมงานหน้างาน' },
          ].map((s, i) => (
            <a href="/services" class="svc-row" data-anim="rise" data-delay={String((i % 3) + 1)}>
              <span class="svc-n">{s.n}</span>
              <span class="svc-name" data-en={s.en} data-th={s.th}>{s.en}</span>
              <span class="svc-arrow" aria-hidden="true">→</span>
            </a>
          ))}
        </div>
      </div>
    </section>

    <!-- ══════════════════════════════
         §6  CONTACT BAND + FOOTER
         ══════════════════════════════ -->
    <section class="snap-section contact-band" id="section-5">
      <div class="contact-inner">
        <h2 data-split
          data-en="Have a project in mind?"
          data-th="มีโครงการในใจอยู่หรือเปล่า?">
          Have a project in mind?
        </h2>
        <p data-anim="rise" data-delay="2"
          data-en="We work with clients who value precision and permanence. Let's talk about what you're building."
          data-th="เราทำงานกับลูกค้าที่ให้ความสำคัญกับความแม่นยำและความยั่งยืน">
          We work with clients who value precision and permanence. Let's talk about what you're building.
        </p>
        <a href="/contact" class="contact-cta" data-anim="rise" data-delay="3"
          data-en="Start a Conversation"
          data-th="เริ่มบทสนทนา">
          Start a Conversation
        </a>
      </div>

      <footer class="site-footer">
        <div class="footer-inner">
          <div>
            <span class="footer-logo">TNC<em>.</em>18</span>
            <p class="footer-tag"
              data-en="Architecture & Construction, Bangkok"
              data-th="สถาปัตยกรรมและการก่อสร้าง กรุงเทพฯ">
              Architecture & Construction, Bangkok
            </p>
          </div>
          <div class="footer-links">
            <a href="tel:+66000000000" data-en="Call" data-th="โทร">Call</a>
            <a href="https://line.me" target="_blank" rel="noopener">Line OA</a>
            <a href="https://instagram.com" target="_blank" rel="noopener">Instagram</a>
            <a href="https://tiktok.com" target="_blank" rel="noopener">TikTok</a>
          </div>
          <p class="footer-copy">© 2024 TNC.18</p>
        </div>
      </footer>
    </section>

  </div><!-- /snap-container -->
</Layout>

<style>
  /* ══════ SNAP CONTAINER ══════ */
  .snap-container {
    height: 100vh;
    overflow-y: scroll;
    scroll-snap-type: y mandatory;
    scroll-behavior: smooth;
    -webkit-overflow-scrolling: touch;
  }

  /* Fixed sections = exactly 100vh */
  .snap-section {
    scroll-snap-align: start;
    scroll-snap-stop: always;
    height: 100vh;
    min-height: 600px;
  }

  /* Tall sections — at least 100vh but can be taller */
  .snap-section--free {
    scroll-snap-align: start;
    min-height: 100vh;
  }

  /* ══════ HERO ══════ */
  .hero {
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    overflow: hidden;
    background: var(--charcoal);
  }

  .hero-media { position: absolute; inset: 0; z-index: 0; }
  .hero-video { width:100%; height:100%; object-fit:cover; opacity:0.48; }
  .hero-fallback {
    position:absolute; inset:0;
    background:linear-gradient(155deg,#2C2820 0%,#1A1612 60%,#0F0D0A 100%);
    z-index:-1;
  }
  .hero-vignette {
    position:absolute; inset:0;
    background:
      linear-gradient(to top, rgba(28,26,23,0.88) 0%, transparent 55%),
      linear-gradient(to right, rgba(28,26,23,0.35) 0%, transparent 55%);
  }

  .hero-content {
    position:relative; z-index:2;
    padding:0 5rem 3rem;
    margin-top:auto;
  }

  .hero-location {
    font-size:0.66rem; font-weight:400; letter-spacing:0.24em;
    text-transform:uppercase; color:rgba(247,244,239,0.35);
    margin-bottom:1.75rem;
    animation:fadeUp 1s 0.3s both;
  }

  .hero-headline {
    font-family:var(--font-serif);
    font-size:clamp(3.25rem,8vw,7.5rem);
    font-weight:300; line-height:1.0;
    color:var(--stone); overflow:hidden;
    margin-bottom:2rem;
  }

  .hero-line {
    display:block;
    animation:heroSlide 1.1s cubic-bezier(0.16,1,0.3,1) both;
  }
  .hero-line:nth-child(2) { animation-delay:0.14s; }
  .hero-line--italic {
    font-style:italic;
    color:rgba(247,244,239,0.52);
    padding-left:2.5rem;
  }

  @keyframes heroSlide {
    from { transform:translateY(110%); opacity:0; }
    to   { transform:translateY(0); opacity:1; }
  }
  @keyframes fadeUp {
    from { opacity:0; transform:translateY(8px); }
    to   { opacity:1; transform:translateY(0); }
  }

  .hero-rule {
    width:56px; height:1px;
    background:var(--gold);
    animation:ruleIn 0.7s 1s cubic-bezier(0.4,0,0.2,1) forwards;
    transform:scaleX(0); transform-origin:left;
  }
  @keyframes ruleIn { to { transform:scaleX(1); } }

  .hero-footer {
    position:relative; z-index:2;
    display:flex; align-items:center; justify-content:space-between;
    padding:1.75rem 5rem;
    border-top:1px solid rgba(247,244,239,0.08);
    animation:fadeUp 0.9s 1.1s both;
  }

  .hero-cta {
    display:flex; align-items:center; gap:0.7rem;
    font-size:0.7rem; font-weight:400; letter-spacing:0.18em;
    text-transform:uppercase; color:var(--stone);
    text-decoration:none;
  }
  .hero-arrow {
    color:var(--gold);
    transition:transform 0.35s cubic-bezier(0.4,0,0.2,1), color 0.3s;
  }
  .hero-cta:hover .hero-arrow { transform:translateX(6px); color:var(--blue-mid); }

  .hero-tagline {
    font-size:0.62rem; letter-spacing:0.18em;
    text-transform:uppercase; color:rgba(247,244,239,0.22);
  }

  /* Section navigation dots */
  .section-dots {
    position:absolute; right:2.5rem; top:50%; transform:translateY(-50%);
    display:flex; flex-direction:column; gap:10px; z-index:10;
  }
  .dot {
    width:5px; height:5px; border-radius:50%;
    background:rgba(247,244,239,0.25);
    border:none; cursor:pointer;
    transition:background 0.3s, transform 0.3s;
    padding:0;
  }
  .dot--active, .dot:hover { background:var(--gold); transform:scale(1.3); }

  /* ══════ STATEMENT ══════ */
  .statement {
    display:flex; align-items:center; justify-content:center;
    background:var(--stone);
    border-bottom:1px solid var(--stone-mid);
    padding:0 5rem;
  }

  .statement-inner {
    display:grid; grid-template-columns:100px 1fr;
    gap:3rem; max-width:960px; width:100%;
    align-items:start;
  }

  .statement-left { display:flex; flex-direction:column; gap:1.25rem; padding-top:0.5rem; }

  .statement-tag {
    font-family:var(--font-sans); font-size:0.62rem; font-weight:500;
    letter-spacing:0.22em; text-transform:uppercase; color:var(--gold);
  }

  .statement-line {
    width:100%; height:1px; background:var(--stone-dark); display:block;
  }

  .statement-quote {
    font-family:var(--font-serif);
    font-size:clamp(1.35rem,2.6vw,2rem);
    font-weight:300; font-style:italic;
    color:var(--ink); line-height:1.65;
  }

  /* ══════ PROJECTS ══════ */
  .projects {
    background:var(--warm-white);
    border-top:1px solid var(--stone-mid);
    padding:6rem 5rem;
  }

  .projects-header {
    display:flex; justify-content:space-between; align-items:baseline;
    padding-bottom:1.75rem; margin-bottom:2.75rem;
    border-bottom:1px solid var(--stone-dark);
  }

  .section-label {
    font-family:var(--font-sans); font-size:0.66rem; font-weight:500;
    letter-spacing:0.22em; text-transform:uppercase; color:var(--muted);
  }

  .link-plain {
    font-size:0.7rem; letter-spacing:0.1em;
    color:var(--ink); text-decoration:none; transition:color 0.3s;
  }
  .link-plain:hover { color:var(--blue); }

  .projects-grid {
    display:grid; grid-template-columns:1.1fr 0.9fr;
    gap:2rem; align-items:start;
  }

  .proj-col { display:flex; flex-direction:column; gap:2rem; padding-top:3rem; }

  .proj-link { display:block; text-decoration:none; color:inherit; }
  .proj-img { overflow:hidden; background:var(--stone-mid); margin-bottom:1rem; }
  .proj--a .proj-img { aspect-ratio:3/4; }
  .proj--b .proj-img { aspect-ratio:16/10; }
  .proj--c .proj-img { aspect-ratio:4/3; }

  .proj-ph {
    width:100%; height:100%;
    transition:transform 0.9s cubic-bezier(0.4,0,0.2,1);
  }
  .proj-link:hover .proj-ph { transform:scale(1.04); }

  .proj-top {
    display:flex; justify-content:space-between;
    align-items:center; margin-bottom:0.4rem;
  }
  .proj-year { font-size:0.62rem; letter-spacing:0.1em; color:var(--muted); }
  .proj-cat {
    font-size:0.62rem; font-weight:500; letter-spacing:0.14em;
    text-transform:uppercase; color:var(--muted);
  }
  .proj-title {
    font-family:var(--font-serif); font-size:clamp(1rem,1.6vw,1.35rem);
    font-weight:300; color:var(--charcoal);
    transition:color 0.35s; line-height:1.2;
  }
  .proj-link:hover .proj-title { color:var(--blue); }

  /* ══════ ABOUT ══════ */
  .about {
    background:var(--stone-mid);
    border-top:1px solid var(--stone-dark);
    border-bottom:1px solid var(--stone-dark);
    padding:7rem 5rem;
  }

  .about-inner {
    display:grid; grid-template-columns:1fr 280px;
    gap:7rem; align-items:center;
    max-width:1100px; margin:0 auto;
  }

  .about-text h2 {
    font-size:clamp(1.65rem,3vw,2.4rem); font-weight:300;
    color:var(--charcoal); margin:1.25rem 0 1.75rem; line-height:1.25;
  }
  .about-text p {
    font-size:0.88rem; color:var(--ink); line-height:1.9;
    margin-bottom:2.25rem; max-width:440px; font-weight:300;
  }

  .link-under {
    font-size:0.7rem; font-weight:500; letter-spacing:0.16em;
    text-transform:uppercase; color:var(--charcoal); text-decoration:none;
    border-bottom:1px solid var(--stone-dark); padding-bottom:3px;
    transition:color 0.3s, border-color 0.3s;
  }
  .link-under:hover { color:var(--blue); border-color:var(--blue); }

  .about-stats { display:flex; flex-direction:column; gap:2.75rem; }
  .stat-block { display:flex; flex-direction:column; gap:0.3rem; }
  .stat-rule { width:36px; height:1px; background:var(--gold); margin-bottom:0.65rem; display:block; }
  .stat-num {
    font-family:var(--font-serif); font-size:3.5rem;
    font-weight:300; color:var(--charcoal); line-height:1;
  }
  .stat-label {
    font-family:var(--font-sans); font-size:0.64rem; font-weight:500;
    letter-spacing:0.2em; text-transform:uppercase; color:var(--muted);
  }

  /* ══════ SERVICES ══════ */
  .services {
    background:var(--stone);
    padding:6rem 5rem;
  }

  .services-inner { max-width:1050px; margin:0 auto; }

  .services-list {
    margin-top:2.5rem;
    border-top:1px solid var(--stone-dark);
  }

  .svc-row {
    display:flex; align-items:center;
    padding:1.5rem 0; border-bottom:1px solid var(--stone-mid);
    text-decoration:none; color:inherit;
    transition:padding-left 0.4s cubic-bezier(0.4,0,0.2,1),
               background 0.4s;
    position:relative; overflow:hidden;
  }
  .svc-row::before {
    content:''; position:absolute; left:0; top:0; bottom:0;
    width:2px; background:var(--blue);
    transform:scaleY(0); transition:transform 0.4s cubic-bezier(0.4,0,0.2,1);
  }
  .svc-row:hover { padding-left:1.25rem; background:rgba(234,229,219,0.5); }
  .svc-row:hover::before { transform:scaleY(1); }

  .svc-n {
    font-size:0.62rem; letter-spacing:0.1em; color:var(--muted);
    width:3.25rem; flex-shrink:0;
  }
  .svc-name {
    font-family:var(--font-serif); font-size:clamp(1.1rem,2vw,1.55rem);
    font-weight:300; color:var(--charcoal); flex:1; transition:color 0.3s;
  }
  .svc-row:hover .svc-name { color:var(--blue); }
  .svc-arrow {
    font-size:0.9rem; color:var(--gold);
    transition:transform 0.35s cubic-bezier(0.4,0,0.2,1), color 0.3s;
  }
  .svc-row:hover .svc-arrow { transform:translateX(6px); color:var(--blue); }

  /* ══════ CONTACT BAND ══════ */
  .contact-band {
    background:var(--charcoal);
    display:flex; flex-direction:column;
    justify-content:center;
  }

  .contact-inner {
    flex:1; display:flex; flex-direction:column;
    align-items:center; justify-content:center;
    text-align:center; padding:5rem;
  }

  .contact-inner h2 {
    font-family:var(--font-serif);
    font-size:clamp(1.85rem,4vw,3rem);
    font-weight:300; font-style:italic;
    color:var(--stone); margin-bottom:1.5rem; line-height:1.25;
  }
  .contact-inner p {
    font-size:0.87rem; color:rgba(247,244,239,0.42);
    font-weight:300; line-height:1.85;
    margin-bottom:3rem; max-width:460px;
  }

  .contact-cta {
    display:inline-block; font-size:0.7rem; font-weight:500;
    letter-spacing:0.18em; text-transform:uppercase;
    color:var(--stone); text-decoration:none;
    border:1px solid rgba(247,244,239,0.22);
    padding:1rem 2.75rem;
    position:relative; overflow:hidden;
    transition:border-color 0.4s;
  }
  .contact-cta::before {
    content:''; position:absolute; inset:0;
    background:var(--blue);
    transform:translateY(101%);
    transition:transform 0.45s cubic-bezier(0.4,0,0.2,1);
  }
  .contact-cta:hover::before { transform:translateY(0); }
  .contact-cta:hover { border-color:var(--blue); }
  .contact-cta { position:relative; z-index:1; }

  /* ══════ FOOTER ══════ */
  .site-footer {
    padding:2rem 5rem;
    background:#0F0E0C;
    border-top:1px solid rgba(247,244,239,0.04);
  }
  .footer-inner {
    display:flex; align-items:center; justify-content:space-between;
    flex-wrap:wrap; gap:1.25rem;
  }
  .footer-logo {
    font-family:var(--font-sans); font-size:0.85rem; font-weight:500;
    letter-spacing:0.1em; color:rgba(247,244,239,0.45);
  }
  .footer-logo em { font-style:normal; color:var(--gold); }
  .footer-tag {
    font-size:0.6rem; letter-spacing:0.1em;
    color:rgba(247,244,239,0.18); margin-top:0.2rem;
  }
  .footer-links { display:flex; gap:2rem; }
  .footer-links a {
    font-size:0.62rem; letter-spacing:0.1em; text-transform:uppercase;
    color:rgba(247,244,239,0.22); text-decoration:none; transition:color 0.3s;
  }
  .footer-links a:hover { color:rgba(247,244,239,0.7); }
  .footer-copy { font-size:0.6rem; color:rgba(247,244,239,0.14); letter-spacing:0.08em; }

  /* ══════ RESPONSIVE ══════ */
  @media (max-width:960px) {
    .snap-container { scroll-snap-type: none; }
    .snap-section { height:auto; min-height:100svh; }
    .hero-content,.hero-footer { padding-left:1.75rem; padding-right:1.75rem; }
    .statement { padding:5rem 1.75rem; }
    .statement-inner { grid-template-columns:1fr; gap:1.5rem; }
    .projects { padding:5rem 1.75rem; }
    .projects-grid { grid-template-columns:1fr; }
    .proj-col { padding-top:0; }
    .about { padding:5rem 1.75rem; }
    .about-inner { grid-template-columns:1fr; gap:3rem; }
    .about-stats { flex-direction:row; flex-wrap:wrap; gap:2rem; }
    .services { padding:5rem 1.75rem; }
    .contact-inner { padding:4rem 1.75rem; }
    .site-footer { padding:2rem 1.75rem; }
    .footer-inner { flex-direction:column; align-items:flex-start; }
    .section-dots { display:none; }
  }
</style>

<script>
  // ══════════════════════════════════════════
  // Section dot navigation
  // ══════════════════════════════════════════
  const container = document.getElementById('snap-container');
  const dots = document.querySelectorAll('.dot');
  const sections = [
    document.querySelector('.hero'),
    document.getElementById('section-1'),
    document.getElementById('section-2'),
    document.getElementById('section-3'),
    document.getElementById('section-4'),
    document.getElementById('section-5'),
  ];

  dots.forEach((dot, i) => {
    dot.addEventListener('click', () => {
      sections[i]?.scrollIntoView({ behavior: 'smooth' });
    });
  });

  // Highlight active dot on scroll
  container?.addEventListener('scroll', () => {
    const scrollMid = (container.scrollTop || 0) + window.innerHeight / 2;
    sections.forEach((sec, i) => {
      if (!sec) return;
      const top = (sec as HTMLElement).offsetTop;
      const bottom = top + (sec as HTMLElement).offsetHeight;
      dots[i]?.classList.toggle('dot--active', scrollMid >= top && scrollMid < bottom);
    });
  }, { passive: true });
</script>
ENDOFFILE
echo "✅  src/pages/index.astro"

# ── 6. VS Code workspace ──────────────────────────────────────
cat > tnc-18.code-workspace << 'ENDOFFILE'
{
  "folders": [{ "name": "TNC.18", "path": "." }],
  "settings": {
    "editor.formatOnSave": true,
    "editor.tabSize": 2,
    "files.associations": { "*.astro": "astro" },
    "emmet.includeLanguages": { "astro": "html" },
    "tailwindCSS.includeLanguages": { "astro": "html" },
    "workbench.colorCustomizations": {
      "titleBar.activeBackground": "#1C1A17",
      "titleBar.activeForeground": "#F7F4EF",
      "activityBar.background": "#0F0E0C",
      "statusBar.background": "#A67C4E",
      "statusBar.foreground": "#F7F4EF"
    }
  },
  "extensions": {
    "recommendations": [
      "astro-build.astro-vscode",
      "bradlc.vscode-tailwindcss",
      "esbenp.prettier-vscode"
    ]
  }
}
ENDOFFILE
echo "✅  tnc-18.code-workspace"

echo ""
echo "════════════════════════════════════════════════"
echo "✅  TNC.18 — Scroll + Animation Edition ready"
echo "════════════════════════════════════════════════"
echo ""
echo "  npm run dev  →  http://localhost:4321"
echo "  open tnc-18.code-workspace"
echo ""
echo "Scroll behaviour:"
echo "  · CSS scroll-snap — one section at a time"
echo "  · scroll-snap-stop: always — never skips"
echo "  · Tall sections (projects/about/services) scroll freely inside"
echo "  · Gold dot nav on right side — jump to any section"
echo ""
echo "Text animations:"
echo "  · Hero headline — word by word slide up"
echo "  · Statement quote — word by word, staggered"
echo "  · About headline — word by word"
echo "  · Paragraphs — fade + rise on scroll"
echo "  · Stats — count up from 0 when visible"
echo "  · Gold rule lines — grow left to right"
echo "  · Section labels — fade + rise"
echo ""
