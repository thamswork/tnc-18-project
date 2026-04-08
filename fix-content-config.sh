#!/bin/bash
# ============================================================
# TNC.18 — Fix Astro 6 Content Collections Config
# Astro 6 requires: src/content.config.ts (not src/content/config.ts)
# and requires explicit loaders
# ============================================================

set -e
echo ""
echo "🔧 Fixing Astro 6 content config..."
echo ""

# Remove old config location
rm -f src/content/config.ts
echo "✅  Removed src/content/config.ts"

# Create new config at correct location with Astro 6 loader syntax
cat > src/content.config.ts << 'ENDOFFILE'
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const projects = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/projects' }),
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
  loader: glob({ pattern: '**/*.md', base: './src/content/services' }),
  schema: z.object({
    order:          z.number(),
    title:          z.string(),
    title_th:       z.string().optional(),
    description:    z.string().optional(),
    description_th: z.string().optional(),
  }),
});

const news = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/news' }),
  schema: z.object({
    title:      z.string(),
    title_th:   z.string().optional(),
    date:       z.string(),
    cover:      z.string().optional(),
    excerpt:    z.string().optional(),
    excerpt_th: z.string().optional(),
  }),
});

export const collections = { projects, services, news };
ENDOFFILE
echo "✅  src/content.config.ts (Astro 6 format)"

# Commit and push
git add .
git commit -m "fix: move content config to Astro 6 location with glob loaders"
git push origin main

echo ""
echo "════════════════════════════════════════"
echo "✅  Fixed — run: npm run dev:cms"
echo "════════════════════════════════════════"
echo ""
