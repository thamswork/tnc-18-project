// Cloudinary helper: returns the same photo at the size a layout needs.
// Works with URLs that already carry transformations (e.g. c_limit,w_2000).
const RE = /^(https:\/\/res\.cloudinary\.com\/[^/]+\/image\/upload\/)(.+)$/;

export function cld(url: string | undefined, opts: { w?: number; h?: number; crop?: "fill" | "limit" } = {}): string {
  if (!url) return "";
  const m = url.match(RE);
  if (!m) return url;
  const parts = m[2].split("/");
  while (parts.length > 1 && !/^v\d+$/.test(parts[0]) && /^[a-z]{1,3}_/.test(parts[0])) parts.shift();
  const crop = opts.crop ?? (opts.h ? "fill" : "limit");
  const t = [`c_${crop}`, crop === "fill" ? "g_auto" : "", opts.w ? `w_${opts.w}` : "", opts.h ? `h_${opts.h}` : "", "f_auto", "q_auto"]
    .filter(Boolean)
    .join(",");
  return `${m[1]}${t}/${parts.join("/")}`;
}

// srcset for one photo at several widths, keeping an aspect ratio (w/h) when given.
export function cldSet(url: string | undefined, widths: number[], ratio?: number): string {
  if (!url) return "";
  return widths
    .map((w) => `${cld(url, ratio ? { w, h: Math.round(w / ratio) } : { w })} ${w}w`)
    .join(", ");
}
