import { getProjects, projectSlug } from "../lib/projects";
import { cld } from "../lib/cld";

// Image sitemap: every project photo listed under its project page (Google Images).
export async function GET() {
  const esc = (v: string) => v.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
  const key = (u: string) => u.split("/").pop() || u;
  const projects = await getProjects();
  const urls = projects.map((p: any) => {
    const d = p.data;
    const seen = new Set<string>();
    const imgs = [d.cover, ...(d.gallery ?? [])].map((u: any) => String(u ?? "").trim()).filter((u: string) => {
      if (!u || seen.has(key(u))) return false;
      seen.add(key(u));
      return true;
    });
    const loc = `https://tncbuildstudio.com/portfolio/${projectSlug(String(d.title))}/`;
    return `<url><loc>${esc(loc)}</loc>${imgs.map((u: string) => `<image:image><image:loc>${esc(cld(u, { w: 1600 }))}</image:loc></image:image>`).join("")}</url>`;
  });
  const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">${urls.join("")}</urlset>`;
  return new Response(xml, { headers: { "Content-Type": "application/xml; charset=utf-8" } });
}
