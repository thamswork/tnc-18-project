import { defineCollection, z } from 'astro:content';

const projects = defineCollection({
  type: 'content',
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
  }),
});

const services = defineCollection({
  type: 'content',
  schema: z.object({
    order:       z.number(),
    title:       z.string(),
    title_th:    z.string().optional(),
    description: z.string().optional(),
    icon:        z.string().optional(),
  }),
});

const news = defineCollection({
  type: 'content',
  schema: z.object({
    title:    z.string(),
    title_th: z.string().optional(),
    date:     z.string(),
    cover:    z.string().optional(),
    excerpt:  z.string().optional(),
  }),
});

// ── SPECBOOK ──────────────────────────────────────────────────────
const blockSchema = z.discriminatedUnion('type', [
  z.object({
    type:    z.literal('text'),
    heading: z.string().optional(),
    body:    z.string(),
    align:   z.enum(['left', 'center', 'right']).optional().default('left'),
  }),
  z.object({
    type:         z.literal('full-image'),
    src:          z.string(),
    alt:          z.string().optional().default(''),
    layout_style: z.enum(['portrait', 'landscape', 'full-bleed']).optional().default('full-bleed'),
    caption:      z.string().optional(),
  }),
  z.object({
    type:         z.literal('split-gallery'),
    images: z.array(z.object({
      src:          z.string(),
      alt:          z.string().optional().default(''),
      layout_style: z.enum(['portrait', 'landscape', 'square']).optional().default('landscape'),
    })),
    caption: z.string().optional(),
  }),
  z.object({
    type:       z.literal('quote'),
    text:       z.string(),
    author:     z.string().optional(),
    highlight:  z.boolean().optional().default(false),
  }),
]);

const specbook = defineCollection({
  type: 'content',
  schema: z.object({
    title:           z.string(),
    slug_label:      z.string().optional(),
    date:            z.string(),
    category:        z.string().optional(),
    tags:            z.array(z.string()).optional().default([]),
    cover:           z.string().optional(),
    excerpt:         z.string().optional(),
    seo_title:       z.string().optional(),
    seo_description: z.string().optional(),
    canonical:       z.string().optional(),
    featured:        z.boolean().optional().default(false),
    blocks:          z.array(blockSchema).optional().default([]),
  }),
});

export const collections = { projects, services, news, specbook };
