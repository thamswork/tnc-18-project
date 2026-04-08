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
