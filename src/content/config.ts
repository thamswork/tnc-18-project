import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));

const projects = defineCollection({
  loader: glob({ pattern: '*.md', base: join(__dirname, 'projects') }),
  schema: z.object({
    title:          z.string(),
    title_th:       z.string().optional(),
    year:           z.number(),
    category:       z.string(),
    category_th:    z.string().optional(),
    cover:          z.string().optional(),
    video_url:      z.string().optional(),
    description:    z.string().optional(),
    description_th: z.string().optional(),
    gallery:        z.array(z.string()).optional(),
    client:         z.string().optional(),
    location:       z.string().optional(),
    size:           z.string().optional(),
    area:           z.number().optional(),
    featured:       z.boolean().optional().default(false),
    draft:          z.boolean().default(false),
    order:          z.number().optional(),
  }),
});

const services = defineCollection({
  loader: glob({ pattern: '*.md', base: join(__dirname, 'services') }),
  schema: z.object({
    order:       z.number(),
    title:       z.string(),
    title_th:    z.string().optional(),
    description: z.string().optional(),
    icon:        z.string().optional(),
  }),
});

const news = defineCollection({
  loader: glob({ pattern: '*.md', base: join(__dirname, 'news') }),
  schema: z.object({
    title:    z.string(),
    title_th: z.string().optional(),
    date:     z.string(),
    cover:    z.string().optional(),
    excerpt:  z.string().optional(),
  }),
});

const specbook = defineCollection({
  loader: glob({ pattern: '*.md', base: join(__dirname, 'specbook') }),
  schema: z.object({
    title:           z.string(),
    date:            z.string(),
    category:        z.string().optional(),
    tags:            z.array(z.string()).optional(),
    cover:           z.string().optional(),
    excerpt:         z.string().optional(),
    featured:        z.boolean().optional(),
    draft:           z.boolean().optional().default(false),
    author:          z.string().optional(),
    lang:            z.string().optional().default('en'),
    seo_title:       z.string().optional(),
    seo_description: z.string().optional(),
    blocks:          z.array(z.any()).optional(),
  }),
});

const trusted_by = defineCollection({
  loader: glob({ pattern: '*.json', base: join(__dirname, 'trusted-by') }),
  schema: z.object({
    name:    z.string(),
    logo:    z.string(),
    url:     z.string().optional(),
    order:   z.number().optional(),
  }),
});
export const collections = { projects, services, news, specbook, trusted_by };
