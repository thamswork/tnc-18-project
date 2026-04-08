#!/bin/bash
cd "/Users/marketingworks/Downloads/tnc-18-project/tnc-18"
git pull origin main --rebase

python3 << 'PYEOF'
with open('src/pages/about.astro', 'r') as f:
    src = f.read()

# Add hero bg image to the hero section
src = src.replace(
    '<section class="hero">\n    <div class="inner">',
    '<section class="hero">\n    {photo && <img src={photo} alt="TNC.18 Office" class="hero-bg" loading="eager" />}\n    <div class="hero-overlay"></div>\n    <div class="inner">'
)

# Fix hero CSS to support bg image
src = src.replace(
    '.hero { background:var(--charcoal); padding:9rem 5rem 5rem; min-height:60vh; display:flex; align-items:flex-end; }',
    '.hero { background:var(--charcoal); padding:9rem 5rem 5rem; min-height:60vh; display:flex; align-items:flex-end; position:relative; overflow:hidden; }\n  .hero-bg { position:absolute; inset:0; width:100%; height:100%; object-fit:cover; opacity:0.45; z-index:0; }\n  .hero-overlay { position:absolute; inset:0; background:linear-gradient(to top,rgba(28,26,23,0.88) 0%,rgba(28,26,23,0.3) 100%); z-index:1; }\n  .inner { position:relative; z-index:2; max-width:800px; }'
)

with open('src/pages/about.astro', 'w') as f:
    f.write(src)

print("✅  Hero background image added")
PYEOF

git add .
git commit -m "fix: office photo as hero background on about page"
git push origin main

echo ""
echo "✅  Done — wait 1 min then refresh:"
echo "    https://tnc-18-project.pages.dev/about"
echo ""
