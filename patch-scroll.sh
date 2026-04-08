#!/bin/bash
# ============================================================
# TNC.18 — Scroll & Spacing Patch
# Fixes: sections too tall/blank, snap too aggressive
# Run from: /Users/marketingworks/Downloads/tnc-18-project/tnc-18
# ============================================================

set -e
echo ""
echo "🔧 TNC.18 — Patching scroll & spacing..."
echo ""

# ── Patch global.css — fix snap type and section heights ──
python3 - << 'PYEOF'
import re

with open('src/styles/global.css', 'r') as f:
    css = f.read()

# Fix 1: scroll-snap-type mandatory → proximity
css = css.replace(
    'scroll-snap-type: y mandatory;',
    'scroll-snap-type: y proximity;'
)

# Fix 2: snap-section — remove forced height:100vh
old = '''.snap-section {
  scroll-snap-align: start;
  scroll-snap-stop: always;
  height: 100vh;
  min-height: 600px;
}'''
new = '''.snap-section {
  scroll-snap-align: start;
  scroll-snap-stop: always;
  height: auto;
  min-height: 0;
}'''
css = css.replace(old, new)

# Fix 3: snap-section--free — no forced min-height
old2 = '''.snap-section--free {
  scroll-snap-align: start;
  min-height: 100vh;
}'''
new2 = '''.snap-section--free {
  scroll-snap-align: start;
  min-height: 0;
}'''
css = css.replace(old2, new2)

with open('src/styles/global.css', 'w') as f:
    f.write(css)

print("✅  global.css patched")
PYEOF

# ── Patch index.astro — tighten all section paddings ──
python3 - << 'PYEOF'
with open('src/pages/index.astro', 'r') as f:
    src = f.read()

patches = [
    # Statement — remove forced flex centering, add sensible padding
    (
        'display:flex; align-items:center; justify-content:center;\n  background:var(--stone);\n  border-bottom:1px solid var(--stone-mid);\n  padding:0 5rem;',
        'background:var(--stone);\n  border-bottom:1px solid var(--stone-mid);\n  padding:5rem 5rem 4.5rem;'
    ),
    # Projects padding
    (
        'background:var(--warm-white);\n  border-top:1px solid var(--stone-mid);\n  padding:6rem 5rem;',
        'background:var(--warm-white);\n  border-top:1px solid var(--stone-mid);\n  padding:4.5rem 5rem;'
    ),
    # About padding
    (
        'background:var(--stone-mid);\n  border-top:1px solid var(--stone-dark);\n  border-bottom:1px solid var(--stone-dark);\n  padding:7rem 5rem;',
        'background:var(--stone-mid);\n  border-top:1px solid var(--stone-dark);\n  border-bottom:1px solid var(--stone-dark);\n  padding:5rem 5rem;'
    ),
    # Services padding
    (
        'background:var(--stone);\n  padding:6rem 5rem;',
        'background:var(--stone);\n  padding:4rem 5rem;'
    ),
    # Contact band — remove forced flex stretch
    (
        'background:var(--charcoal);\n  display:flex; flex-direction:column;\n  justify-content:center;',
        'background:var(--charcoal);'
    ),
    # Contact inner — tighten padding
    (
        'flex:1; display:flex; flex-direction:column;\n  align-items:center; justify-content:center;\n  text-align:center; padding:5rem;',
        'display:flex; flex-direction:column;\n  align-items:center; justify-content:center;\n  text-align:center; padding:5rem 5rem 4rem;'
    ),
    # Hero — remove height:100vh so it fits content
    (
        'height: 100vh;\n  overflow-y: scroll;\n  scroll-snap-type: y mandatory;',
        'height: 100vh;\n  overflow-y: scroll;\n  scroll-snap-type: y proximity;'
    ),
    # Statement section — also fix the snap-section class on it
    # Hero snap section — keep min-height but not force fullscreen blank
    (
        '  height: 100vh;\n    overflow-y: scroll;\n    scroll-snap-type: y mandatory;\n    scroll-behavior: smooth;\n    -webkit-overflow-scrolling: touch;',
        '  height: 100vh;\n    overflow-y: scroll;\n    scroll-snap-type: y proximity;\n    scroll-behavior: smooth;\n    -webkit-overflow-scrolling: touch;'
    ),
]

for old, new in patches:
    if old in src:
        src = src.replace(old, new)
        print(f"✅  Patched: {old[:50].strip()!r}...")
    else:
        print(f"⚠️  Not found (may already be patched): {old[:50].strip()!r}...")

# Also fix the inline snap-container style block
src = src.replace(
    'scroll-snap-type: y mandatory;',
    'scroll-snap-type: y proximity;'
)

with open('src/pages/index.astro', 'w') as f:
    f.write(src)

print("✅  index.astro patched")
PYEOF

echo ""
echo "════════════════════════════════════"
echo "✅  Patch complete — changes applied"
echo "════════════════════════════════════"
echo ""
echo "Dev server will hot-reload automatically."
echo "If not running: npm run dev"
echo ""
