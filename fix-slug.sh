#!/bin/bash
# Fix: Astro 6 glob loader uses p.id not p.slug
cd "/Users/marketingworks/Downloads/tnc-18-project/tnc-18"

python3 << 'PYEOF'
import os

files = [
    'src/pages/index.astro',
    'src/pages/projects/index.astro',
    'src/pages/projects/[slug].astro',
]

for path in files:
    if not os.path.exists(path):
        print(f"⚠️  Not found: {path}")
        continue
    with open(path, 'r') as f:
        src = f.read()

    original = src

    # Fix href links — /projects/${p.slug} → /projects/${p.id}
    src = src.replace('/projects/${p.slug}', '/projects/${p.id}')
    src = src.replace("href={`/projects/${p.slug}`}", "href={`/projects/${p.id}`}")

    # Fix getStaticPaths — params: { slug: p.slug } → params: { slug: p.id }
    src = src.replace('params: { slug: p.slug }', 'params: { slug: p.id }')

    # Fix more-work links
    src = src.replace('/projects/${p.id}', '/projects/${p.id}')  # already correct, skip

    if src != original:
        with open(path, 'w') as f:
            f.write(src)
        print(f"✅  Fixed: {path}")
    else:
        print(f"ℹ️   No changes needed: {path}")

PYEOF

git add .
git commit -m "fix: use p.id instead of p.slug for Astro 6 glob loader"
git push origin main

echo ""
echo "✅  Done. Visit: http://localhost:4321/projects/silom-residence"
echo ""
