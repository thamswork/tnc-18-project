// Site-wide contact details. Everything comes from the CMS file
// src/content/settings/contact.json ("Site Settings > Contact & Social Links").
// The values after || are fallbacks, used if a CMS field is left empty.
import contact from "../content/settings/contact.json";

const c = contact as Record<string, unknown>;
const txt = (k: string) => (typeof c[k] === "string" ? (c[k] as string).trim() : "");
const digits = (v: string) => v.replace(/\D/g, "");

// "0800064465" -> "080 006 4465"
const show = (raw: string, fallback: string) => {
  const d = digits(raw);
  if (d.length === 10) return `${d.slice(0, 3)} ${d.slice(3, 6)} ${d.slice(6)}`;
  if (d.length === 9) return `${d.slice(0, 2)} ${d.slice(2, 5)} ${d.slice(5)}`;
  return raw || fallback;
};
// "0800064465" -> "tel:+66800064465"
const tel = (raw: string, fallback: string) => {
  const d = digits(raw);
  if (!d) return fallback;
  return d.startsWith("0") ? `tel:+66${d.slice(1)}` : `tel:+${d}`;
};

const studioLines = txt("studio_address").split(/\r?\n/).map((l) => l.trim()).filter(Boolean);

export const site = {
  lineUrl: txt("line") || "https://lin.ee/RdpRHTR",
  lineId: txt("line_id") || "@tncbuildstudio",
  phoneDisplay: show(txt("phone"), "080 006 4465"),
  phoneHref: tel(txt("phone"), "tel:+66800064465"),
  email: txt("email") || "info@tncbuildstudio.com",
  hours: txt("hours") || "Mon–Sat, 09:00–18:00",
  city: txt("address") || "Bangkok, Thailand",
  address: {
    name: "TNC Build Studio",
    lines: studioLines.length
      ? studioLines
      : ["ห้อง 431 ตึก Udomsuk Hub", "55 ซอยสุขุมวิท 101/2 แขวงบางนาเหนือ", "เขตบางนา กรุงเทพมหานคร 10260"],
  },
  officeDisplay: show(txt("office_phone"), "061 356 1422"),
  officeHref: tel(txt("office_phone"), "tel:+66613561422"),
  socials: [
    { label: "Instagram", href: txt("instagram") },
    { label: "TikTok", href: txt("tiktok") },
    { label: "Facebook", href: txt("facebook") },
  ],
};
