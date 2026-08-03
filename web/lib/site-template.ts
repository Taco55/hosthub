/**
 * Which website template a site is built from.
 *
 * The console already works this way: its pages, cards, field paths, media
 * routing and labels come from a `WebsiteTemplate` instance, and `sites.
 * template_id` records which one a site uses. This side read the same site and
 * ignored that column — every document set was a module-level literal, so a
 * second template's site would have been described by the chalet's document
 * list.
 *
 * What lives here is only what a template *identifies*: its id and the
 * documents it renders. The section order and the components themselves are
 * still the chalet's; making those data-driven is real work and belongs with an
 * actual second template rather than with an abstraction invented ahead of one.
 */

export type CmsDocumentRef = { contentType: string; slug: string };

export type SiteTemplate = {
  /** Matches `WebsiteTemplate.id` in the console and `sites.template_id`. */
  id: string;
  /** Every document this template's pages read, as `contentType/slug`. */
  documents: CmsDocumentRef[];
};

/** The one template today: the chalet site this codebase renders. */
export const chaletTemplate: SiteTemplate = {
  id: "chalet-v1",
  documents: [
    { contentType: "site_config", slug: "main" },
    { contentType: "cabin", slug: "main" },
    { contentType: "page", slug: "home" },
    { contentType: "page", slug: "practical" },
    { contentType: "page", slug: "area" },
    { contentType: "page", slug: "privacy" },
    { contentType: "contact_form", slug: "main" },
  ],
};

export const siteTemplates: Record<string, SiteTemplate> = {
  [chaletTemplate.id]: chaletTemplate,
};

export const defaultSiteTemplate = chaletTemplate;

/**
 * The template with this id, or the default when the id is unknown or absent.
 *
 * Falls back rather than failing, matching `templateFor` in the console: a site
 * whose template was renamed should still render — imperfectly — instead of
 * serving an error to its visitors.
 */
export function siteTemplateFor(id?: string | null): SiteTemplate {
  if (!id) return defaultSiteTemplate;
  return siteTemplates[id] ?? defaultSiteTemplate;
}

/** `contentType/slug` keys of a template's documents. */
export function documentKeysOf(template: SiteTemplate): string[] {
  return template.documents.map((d) => `${d.contentType}/${d.slug}`);
}
