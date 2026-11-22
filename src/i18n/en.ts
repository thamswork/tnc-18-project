// English wording shared across the site. The Thai file (th.ts) will mirror these keys.
export const en = {
  nav: { work: "Work", studio: "Studio", specbook: "Specbook", contact: "Contact" },
  cta: { line: "Chat on LINE", call: "Call", callStudio: "Call the studio" },
  header: { openMenu: "Open menu" },
  footer: {
    title: "Start a project",
    lead: "Tell us what you are building and when it has to open.",
    line: "LINE", phone: "Phone", office: "Office", email: "Email", hours: "Hours", studio: "Studio", follow: "Follow",
  },
  dial: { lineAria: "Chat on LINE OA", call: "Call Us", callAria: "Call TNC Build Studio" },
  notFound: {
    title: "Page not found",
    description: "This page doesn't exist. See TNC Build Studio's work or contact the studio in Bangkok.",
    heading: "This page isn't here.",
    sub: "It may have moved when we rebuilt the site. Try one of these instead.",
    home: "Home",
    work: "Our work",
  },
  work: { malls: "Malls we've built in" },
};
export type Strings = typeof en;
export const t = en;
