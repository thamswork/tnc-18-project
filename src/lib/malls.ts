import { projectSlug, projectName } from "./projects";

// Malls we've built in: matched from each project's location and title.
export const MALLS: { name: string; re: RegExp }[] = [
  { name: "Siam Paragon", re: /siam\s*paragon/i },
  { name: "ICONSIAM", re: /icon\s*siam/i },
  { name: "EmQuartier", re: /em\s*quartier/i },
  { name: "One Bangkok", re: /one\s*bangkok/i },
  { name: "Gaysorn Village", re: /gaysorn/i },
  { name: "CentralWorld", re: /central\s*world/i },
  { name: "Central Chidlom", re: /chidlom/i },
  { name: "Central Westgate", re: /westgate/i },
  { name: "Central Rama 3", re: /rama\s*3/i },
  { name: "Central Park", re: /central\s*park/i },
  { name: "Central Ladprao", re: /lad\s*prao/i },
  { name: "Fashion Island", re: /fashion\s*island/i },
  { name: "Mega Bangna", re: /mega\s*bang\s*na/i },
];

export function mallsFrom(projects: any[]) {
  const out = MALLS.map((m) => ({ name: m.name, projects: [] as { name: string; url: string }[] }));
  for (const p of projects) {
    const text = `${p.data.location ?? ""} ${p.data.title ?? ""}`;
    if (/centara/i.test(text)) continue; // hotel venue, not a mall
    MALLS.forEach((m, i) => {
      if (m.re.test(text)) out[i].projects.push({ name: projectName(p), url: `/portfolio/${projectSlug(String(p.data.title))}/` });
    });
  }
  return out.filter((m) => m.projects.length).sort((a, b) => b.projects.length - a.projects.length || a.name.localeCompare(b.name));
}
