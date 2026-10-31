import fs from "node:fs";
import { getCollection } from "astro:content";
import worksOrder from "../data/works-order.json";

// Same rule the portfolio pages use for their URLs.
export function projectSlug(t: string): string {
  return t.toLowerCase().replace(/[\u2018\u2019'']/g, "").replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}
export const projectUrl = (p: any) => `/portfolio/${projectSlug(String(p.data.title))}`;

const isDraft = (e: any) => !!e.filePath && /^draft:\s*true/m.test(fs.readFileSync(e.filePath, "utf-8"));
const readOrder = (e: any): number => {
  if (!e.filePath) return 999;
  const m = fs.readFileSync(e.filePath, "utf-8").match(/^order:\s*(\d+)/m);
  return m ? Number(m[1]) : 999;
};

// Visible projects, in the CMS "Works — Project Order", then order field, then newest year.
export async function getProjects(): Promise<any[]> {
  const list: string[] = ((worksOrder as any).projects ?? []).map((t: any) => String(typeof t === "string" ? t : t?.project ?? "").trim());
  const pos = (p: any) => { const i = list.indexOf(String(p.data.title ?? "").trim()); return i === -1 ? 9999 : i; };
  const all = (await getCollection("projects")).filter((p: any) => !isDraft(p));
  return all.sort((a: any, b: any) => (pos(a) - pos(b)) || (readOrder(a) - readOrder(b)) || (b.data.year - a.data.year));
}

// "Nefelogne — Siam Paragon Pop-Up Kiosk" -> "Nefelogne"
export const projectName = (p: any) => String(p.data.title).split(/\s+[—–-]\s+/)[0].trim();
export const projectPlace = (p: any) => {
  const loc = String(p.data.location ?? "").split(",")[0].trim();
  return loc || (String(p.data.title).split(/\s+[—–-]\s+/)[1] ?? "").trim();
};
export const projectMeta = (p: any) => [projectPlace(p), p.data.category, p.data.year].filter(Boolean).join(" · ");

// Bangkok malls we recognise in a project's location or title.
const MALLS = [
  "Siam Paragon", "ICONSIAM", "CentralWorld", "One Bangkok", "Gaysorn Village", "EmQuartier", "Emporium", "EmSphere",
  "Central Chidlom", "Central Embassy", "Central Park", "Central Ladprao", "Central Rama 3", "Central Rama 9",
  "Central Westgate", "Central Eastville", "Fashion Island", "Mega Bangna", "Samyan Mitrtown", "Siam Center",
  "Siam Discovery", "Terminal 21", "Seacon Square", "Paradise Park",
];
const squash = (s: string) => s.toLowerCase().replace(/[^a-z0-9]/g, "");
export function mallOf(p: any): string | undefined {
  const hay = squash(`${p.data.location ?? ""} ${p.data.title ?? ""}`);
  return MALLS.find((m) => hay.includes(squash(m)));
}
export function mallsOf(projects: any[]): { name: string; count: number }[] {
  const c = new Map<string, number>();
  for (const p of projects) { const m = mallOf(p); if (m) c.set(m, (c.get(m) ?? 0) + 1); }
  return [...c.entries()].sort((a, b) => b[1] - a[1]).map(([name, count]) => ({ name, count }));
}
