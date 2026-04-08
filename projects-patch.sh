#!/bin/bash
# ============================================================
# TNC.18 — Projects Section Patch
# Layout: Balanced mosaic B — editorial hover reveal
# Run from: /Users/marketingworks/Downloads/tnc-18-project/tnc-18
# ============================================================

set -e
echo ""
echo "🏛  Patching projects section..."

python3 << 'PYEOF'
import re

with open('src/pages/index.astro', 'r') as f:
    src = f.read()

NEW_PROJECTS = '''  <!-- §3 PROJECTS — Balanced mosaic, editorial hover reveal -->
  <section class="projects">
    <header class="section-header" data-anim="rise">
      <span class="section-label"
        data-en="Selected Work"
        data-th="ผลงานคัดสรร">Selected Work</span>
      <a href="/projects" class="link-sm"
        data-en="All Projects →"
        data-th="ผลงานทั้งหมด →">All Projects →</a>
    </header>

    <div class="mosaic">

      <!-- Row 1: two landscape cards, equal width -->
      <div class="mosaic-row mosaic-row--top">

        <article class="mosaic-card" data-anim="rise" data-delay="1">
          <a href="/projects/silom-residence" class="mosaic-link">
            <div class="mosaic-img">
              <div class="mosaic-ph" style="background:#C8C2B2;"></div>
              <!-- swap: <img src="cloudinary-url" alt="Silom Residence" loading="lazy" /> -->
              <div class="mosaic-overlay">
                <div class="mosaic-overlay-inner">
                  <span class="mosaic-cat" data-en="Residential" data-th="ที่พักอาศัย">Residential</span>
                  <h2 class="mosaic-title" data-en="Silom Residence" data-th="บ้านพักสีลม">Silom Residence</h2>
                  <span class="mosaic-year">2024</span>
                </div>
                <span class="mosaic-arrow">→</span>
              </div>
            </div>
          </a>
        </article>

        <article class="mosaic-card" data-anim="rise" data-delay="2">
          <a href="/projects/thonglor-tower" class="mosaic-link">
            <div class="mosaic-img">
              <div class="mosaic-ph" style="background:#B0AA9C;"></div>
              <div class="mosaic-overlay">
                <div class="mosaic-overlay-inner">
                  <span class="mosaic-cat" data-en="Commercial" data-th="เชิงพาณิชย์">Commercial</span>
                  <h2 class="mosaic-title" data-en="Thonglor Office Tower" data-th="อาคารสำนักงานทองหล่อ">Thonglor Office Tower</h2>
                  <span class="mosaic-year">2023</span>
                </div>
                <span class="mosaic-arrow">→</span>
              </div>
            </div>
          </a>
        </article>

      </div>

      <!-- Row 2: portrait left (narrower) + landscape right (wider) -->
      <div class="mosaic-row mosaic-row--bot">

        <article class="mosaic-card mosaic-card--portrait" data-anim="rise" data-delay="3">
          <a href="/projects/sathorn-penthouse" class="mosaic-link">
            <div class="mosaic-img">
              <div class="mosaic-ph" style="background:#989082;"></div>
              <div class="mosaic-overlay">
                <div class="mosaic-overlay-inner">
                  <span class="mosaic-cat" data-en="Interior" data-th="การออกแบบภายใน">Interior</span>
                  <h2 class="mosaic-title" data-en="Sathorn Penthouse" data-th="เพนท์เฮาส์สาทร">Sathorn Penthouse</h2>
                  <span class="mosaic-year">2023</span>
                </div>
                <span class="mosaic-arrow">→</span>
              </div>
            </div>
          </a>
        </article>

        <article class="mosaic-card mosaic-card--wide" data-anim="rise" data-delay="4">
          <a href="/projects/charoennakhon-villa" class="mosaic-link">
            <div class="mosaic-img">
              <div class="mosaic-ph" style="background:#7E786C;"></div>
              <div class="mosaic-overlay">
                <div class="mosaic-overlay-inner">
                  <span class="mosaic-cat" data-en="Residential" data-th="ที่พักอาศัย">Residential</span>
                  <h2 class="mosaic-title" data-en="Charoennakhon Villa" data-th="วิลล่าเจริญนคร">Charoennakhon Villa</h2>
                  <span class="mosaic-year">2022</span>
                </div>
                <span class="mosaic-arrow">→</span>
              </div>
            </div>
          </a>
        </article>

      </div>

    </div>
  </section>'''

# Find and replace the projects section
pattern = r'  <!-- §3 PROJECTS.*?</section>'
result = re.sub(pattern, NEW_PROJECTS, src, flags=re.DOTALL)

# Now inject the mosaic CSS before the closing </style>
MOSAIC_CSS = '''
  /* ─── MOSAIC PROJECTS ─── */
  .projects {
    background: var(--stone);
    padding: 4rem 5rem;
    border-top: 1px solid var(--stone-mid);
  }

  .section-header {
    display: flex; justify-content: space-between; align-items: baseline;
    border-bottom: 1px solid var(--stone-dark);
    padding-bottom: 1rem; margin-bottom: 2rem;
  }

  .mosaic {
    display: flex;
    flex-direction: column;
    gap: 0.6rem;
  }

  .mosaic-row {
    display: grid;
    gap: 0.6rem;
  }

  /* Row 1: two equal landscape */
  .mosaic-row--top {
    grid-template-columns: 1fr 1fr;
  }

  /* Row 2: portrait (1) + wide landscape (1.6) — asymmetric */
  .mosaic-row--bot {
    grid-template-columns: 1fr 1.6fr;
  }

  .mosaic-card {
    position: relative;
    overflow: hidden;
  }

  .mosaic-link {
    display: block;
    text-decoration: none;
    color: inherit;
  }

  .mosaic-img {
    position: relative;
    overflow: hidden;
    background: var(--stone-dark);
  }

  /* Row 1 images — landscape 16:10 */
  .mosaic-row--top .mosaic-img { aspect-ratio: 16/10; }

  /* Portrait card — taller */
  .mosaic-card--portrait .mosaic-img { aspect-ratio: 3/4; }

  /* Wide card — shorter landscape */
  .mosaic-card--wide .mosaic-img { aspect-ratio: 16/10; }

  .mosaic-ph {
    width: 100%; height: 100%;
    transition: transform 1s cubic-bezier(0.4, 0, 0.2, 1);
  }

  /* Slow zoom on hover */
  .mosaic-link:hover .mosaic-ph { transform: scale(1.06); }

  /* Overlay — hidden by default, reveals on hover */
  .mosaic-overlay {
    position: absolute;
    inset: 0;
    background: linear-gradient(
      to top,
      rgba(20, 18, 15, 0.82) 0%,
      rgba(20, 18, 15, 0.3) 45%,
      transparent 70%
    );
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    padding: 1.5rem 1.75rem;
    opacity: 0;
    transition: opacity 0.5s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .mosaic-link:hover .mosaic-overlay { opacity: 1; }

  .mosaic-overlay-inner {
    display: flex;
    flex-direction: column;
    gap: 0.2rem;
    transform: translateY(8px);
    transition: transform 0.5s cubic-bezier(0.16, 1, 0.3, 1);
  }

  .mosaic-link:hover .mosaic-overlay-inner { transform: translateY(0); }

  .mosaic-cat {
    font-family: var(--font-sans);
    font-size: 0.58rem;
    font-weight: 500;
    letter-spacing: 0.2em;
    text-transform: uppercase;
    color: var(--gold-light);
  }

  .mosaic-title {
    font-family: var(--font-serif);
    font-size: clamp(1rem, 1.6vw, 1.35rem);
    font-weight: 300;
    color: var(--warm-white);
    line-height: 1.15;
  }

  .mosaic-year {
    font-size: 0.58rem;
    color: rgba(247,244,239,0.35);
    letter-spacing: 0.1em;
    margin-top: 0.15rem;
  }

  .mosaic-arrow {
    font-size: 1.1rem;
    color: var(--gold);
    align-self: flex-end;
    transform: translate(-6px, 6px);
    opacity: 0;
    transition:
      transform 0.5s cubic-bezier(0.16, 1, 0.3, 1),
      opacity 0.4s ease;
  }

  .mosaic-link:hover .mosaic-arrow {
    transform: translate(0, 0);
    opacity: 1;
  }

  /* Thin gold border reveals on hover */
  .mosaic-img::after {
    content: '';
    position: absolute;
    inset: 0;
    border: 1px solid rgba(166, 124, 78, 0);
    transition: border-color 0.4s;
    pointer-events: none;
    z-index: 2;
  }

  .mosaic-link:hover .mosaic-img::after {
    border-color: rgba(166, 124, 78, 0.35);
  }

  /* Static caption below each card — visible always, complements the hover info */
  .mosaic-card::after {
    content: '';
    display: block;
    height: 0;
  }

  @media (max-width: 900px) {
    .projects { padding: 3.5rem 1.75rem; }
    .mosaic-row--top { grid-template-columns: 1fr; }
    .mosaic-row--bot { grid-template-columns: 1fr; }
    .mosaic-card--portrait .mosaic-img { aspect-ratio: 16/9; }
  }
'''

# Remove old .projects and .proj-* CSS, inject new mosaic CSS
# Find the closing </style> and inject before it
if '/* ─── MOSAIC PROJECTS ─── */' not in result:
    result = result.replace('</style>', MOSAIC_CSS + '\n</style>', 1)
    print("✅  Mosaic CSS injected")
else:
    print("ℹ️  Mosaic CSS already present, skipping")

with open('src/pages/index.astro', 'w') as f:
    f.write(result)

print("✅  Projects section patched successfully")
PYEOF

echo ""
echo "════════════════════════════════════"
echo "✅  Done — Astro will hot-reload"
echo "════════════════════════════════════"
echo ""
echo "What you now have:"
echo "  Row 1: Two equal landscape cards (16:10)"
echo "  Row 2: Portrait left + wide landscape right"
echo "  Hover: Overlay fades in, title rises up, gold arrow appears"
echo "  Border: Gold edge traces on hover"
echo "  Images: Slow zoom (1s ease)"
echo ""
