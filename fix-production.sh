#!/bin/bash
# ============================================================
# TNC.18 — Fix Production CSS & Fonts
# Problem: /src/styles/global.css doesn't work on Cloudflare Pages
# Fix: Import CSS properly via Astro + embed critical variables
# ============================================================

set -e
echo ""
echo "🔧 Fixing production CSS and fonts..."
echo ""

# ── Fix Layout.astro — proper CSS import + Google Fonts ──────
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
    <!-- Preconnect for faster font loading -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <!-- Poppins + Merriweather -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500&family=Merriweather:ital,wght@0,300;0,400;1,300;1,400&display=swap" rel="stylesheet" />
    <title>{title} — TNC.18</title>
  </head>
  <body>
    <slot />
    <script>
      const saved = localStorage.getItem('tnc-lang') || 'en';
      document.documentElement.setAttribute('data-lang', saved);
    </script>
  </body>
</html>

<style is:global>
  /* ── TNC.18 Brand Tokens ── */
  :root {
    --stone:       #F7F4EF;
    --stone-mid:   #EAE5DB;
    --stone-dark:  #CFC9BC;
    --charcoal:    #1C1A17;
    --ink:         #3B3830;
    --muted:       #8A8680;
    --warm-white:  #FDFCFA;
    --gold:        #A67C4E;
    --gold-light:  #C49A6C;
    --gold-pale:   #F0E4D0;
    --blue:        #1B3F7A;
    --blue-mid:    #2452A0;
    --blue-pale:   #E8EEF8;
    --font-sans:   'Poppins', system-ui, sans-serif;
    --font-serif:  'Merriweather', Georgia, serif;
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
    background: var(--stone);
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
</style>
ENDOFFILE
echo "✅  src/layouts/Layout.astro — CSS now embedded properly"

# ── Fix global.css — use @import for Tailwind properly ───────
cat > src/styles/global.css << 'ENDOFFILE'
@import "tailwindcss";
ENDOFFILE
echo "✅  src/styles/global.css — simplified"

# ── Fix astro.config.mjs — ensure CSS is processed ───────────
cat > astro.config.mjs << 'ENDOFFILE'
// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://tnc-18-project.pages.dev',
  integrations: [react(), sitemap()],
  vite: {
    plugins: [tailwindcss()],
  },
});
ENDOFFILE
echo "✅  astro.config.mjs — site URL updated"

git add .
git commit -m "fix: move CSS to Layout is:global so fonts + tokens work in production"
git push origin main

echo ""
echo "════════════════════════════════════════════════════"
echo "✅  Pushed — Cloudflare will rebuild in ~1 minute"
echo "════════════════════════════════════════════════════"
echo ""
echo "Live site: https://tnc-18-project.pages.dev"
echo ""
echo "The fix: CSS variables and fonts were in global.css"
echo "which Cloudflare Pages can't serve from /src/."
echo "Now they're in Layout.astro with is:global — Astro"
echo "bundles them into the final HTML at build time."
echo ""
