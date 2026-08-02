/**
 * Content provider facade.
 *
 * Reads the site's content from the Supabase CMS. The site is whichever one the
 * request's host resolves to (see `runtime-site-context`) — there is no env
 * default and no on/off switch, so the site being edited and the site being
 * rendered cannot drift apart.
 *
 * Falls back to generated snapshot content from `content.generated.ts`, and
 * finally to static `content.ts`, when a document is missing or unreadable —
 * but only for the site those bundles belong to (`CMS_SNAPSHOT_SITE_ID`). One
 * worker serves every customer domain and carries exactly one site's copy, so
 * for any other site the fallback would be another customer's content and the
 * read fails closed instead.
 *
 * For the site that does own the bundle, the website keeps rendering when the
 * CMS is unreachable or a locale has no documents yet. That fallback is
 * deliberate for the public site and a trap for the preview: a preview that
 * quietly renders snapshot content tells the owner their CMS copy is live when
 * it is not. So every fallback is reported — to the server log, and through
 * [getPreviewContentStatus] to the preview banner, which states what is
 * actually on screen.
 */

import { locales, type Locale } from "./i18n";
import type {
  CabinContent,
  ContactFormSectionContent,
  LocalizedContent,
  PracticalContent,
  SiteConfig,
} from "./content";
import {
  getCabinContent as getStaticCabinContent,
  localizedContent,
  contactFormSection,
  site,
} from "./content";
import { generatedContentSnapshot } from "./content.generated";
import {
  fetchDocument,
  fetchDocumentIndex,
  type DocumentOutcome,
  type DocumentUnavailableReason,
} from "./supabase/cms";
import { mediaPublicUrls } from "./media-url";
import {
  normalizeAreaContent,
  normalizeCabinContent,
  normalizeContactFormContent,
  normalizeHomeContent,
  normalizePracticalContent,
  normalizePrivacyContent,
} from "./normalize-content";

/** Every document the site renders, as `contentType/slug`. */
const SITE_DOCUMENTS: { contentType: string; slug: string }[] = [
  { contentType: "site_config", slug: "main" },
  { contentType: "cabin", slug: "main" },
  { contentType: "page", slug: "home" },
  { contentType: "page", slug: "practical" },
  { contentType: "page", slug: "area" },
  { contentType: "page", slug: "privacy" },
  { contentType: "contact_form", slug: "main" },
];

export type ContentOptions = {
  /** When true, also fetches draft documents (for preview mode). */
  preview?: boolean;
  /** Which site to read. Comes from the request host; see runtime-site-context. */
  siteId?: string;
};

/**
 * The site comes from the request's host (see runtime-site-context).
 * `toSiteContentOptions` refuses to build options without one, so an empty value
 * here means a caller bypassed that guard.
 */
function resolveSiteId(options?: ContentOptions) {
  return options?.siteId?.trim() ?? "";
}

function cmsActive(siteId: string) {
  return siteId.length > 0;
}

/**
 * The site the bundled snapshot was generated from
 * (`scripts/generate-cms-snapshot.mjs` prints the line to set).
 *
 * One worker serves every customer domain but carries one snapshot, so the
 * snapshot is only ever a valid fallback for the site it came from. Unset means
 * no site claims it, and then it is not used at all — an outage that shows a
 * neutral error is recoverable, one that shows a competitor's prices under your
 * own domain is not.
 */
const SNAPSHOT_SITE_ID = process.env.CMS_SNAPSHOT_SITE_ID?.trim() ?? "";

function snapshotServes(siteId: string) {
  return SNAPSHOT_SITE_ID.length > 0 && siteId === SNAPSHOT_SITE_ID;
}

/**
 * No readable document, and no bundled fallback this site may use.
 *
 * Surfacing an error is the correct outcome: the alternative is rendering the
 * one site whose copy happens to be compiled into the worker.
 */
export class SiteContentUnavailableError extends Error {
  constructor(siteId: string, document: string, locale: Locale) {
    super(
      `No content for ${document} (${locale}) on site ${
        siteId || "(unresolved)"
      }, and the bundled snapshot does not belong to this site`,
    );
    this.name = "SiteContentUnavailableError";
  }
}

/** Guards the bundled fallbacks. Call before reading either of them. */
function requireBundledFallback(
  siteId: string,
  document: string,
  locale: Locale,
) {
  if (!snapshotServes(siteId)) {
    throw new SiteContentUnavailableError(siteId, document, locale);
  }
}

/**
 * Unwraps a document read, leaving a trail for anything that is not a hit.
 * Returns null when the caller should use its fallback content — the callers
 * below all do, because a website that stops rendering when the CMS hiccups is
 * worse than one showing its last known copy.
 */
function unwrap<T>(
  outcome: DocumentOutcome<T>,
  document: string,
  locale: Locale,
  options?: ContentOptions,
): T | null {
  if (outcome.status === "ok") return outcome.content;

  const where = `${document} (${locale})`;
  if (outcome.status === "unavailable") {
    // Not the same as "there is no content": we do not know what the CMS holds.
    console.warn(
      `[cms] ${where}: read failed (${outcome.reason})${
        outcome.detail ? ` — ${outcome.detail}` : ""
      }; rendering fallback content`,
    );
  } else if (options?.preview) {
    // The public site has no document for this locale yet, which is normal
    // while a site is being set up. In the preview it is worth saying, because
    // what renders is not what the owner is editing.
    console.warn(
      `[cms] ${where}: no document; the preview is rendering fallback content`,
    );
  }
  return null;
}

function fromGenerated<T>(record: Partial<Record<Locale, T>>, locale: Locale): T | null {
  return record[locale] ?? null;
}

function mergeSiteConfig(override: Partial<SiteConfig>): SiteConfig {
  const merged: SiteConfig = {
    ...site,
    ...override,
    imagePaths: {
      ...site.imagePaths,
      ...(override.imagePaths ?? {}),
    },
  };
  return applyMediaSlots(merged, override);
}

/** A caption for a photo the repo does not describe: present, and empty. */
function emptyAlt(): Record<Locale, string> {
  return Object.fromEntries(locales.map((l) => [l, ""])) as Record<
    Locale,
    string
  >;
}

/**
 * Photo slots the console writes (`images.heroPhotos`, `images.homeGallery`,
 * `images.galleryAll`) win over the repo's own file lists.
 *
 * Resolved to public bucket URLs here, at the provider boundary, so no page or
 * resolver has to know whether a photo came from the CMS or from `public/`.
 * A slot the owner has not filled yet keeps the repo's list: half-migrated is
 * a state this site is allowed to be in.
 */
function applyMediaSlots(
  config: SiteConfig,
  override: Partial<SiteConfig>,
): SiteConfig {
  const images = (override as { images?: Record<string, unknown> }).images;
  if (!images) return config;

  const hero = mediaPublicUrls(images.heroPhotos);
  const homeGallery = mediaPublicUrls(images.homeGallery);
  const galleryAll = mediaPublicUrls(images.galleryAll);

  return {
    ...config,
    heroImages: hero.length > 0 ? hero : config.heroImages,
    // The homepage selection is a subset of the library, not its own upload
    // (README par. A.5): same URLs, fewer of them.
    //
    // Alt text is matched by src, never by position. The repo's list carries
    // an alt per photo; a CMS selection is a different set in a different
    // order, so pairing the two by index captioned whichever photo happened
    // to land in that slot — a wrong description read out loud is worse than
    // none. A photo the repo does not know keeps an empty alt until it has
    // its own, which is the honest answer.
    gallery:
      homeGallery.length > 0
        ? homeGallery.map((src) => {
            const known = config.gallery.find((image) => image.src === src);
            return { src, alt: known?.alt ?? emptyAlt() };
          })
        : config.gallery,
    galleryAllFilenames:
      galleryAll.length > 0 ? galleryAll : config.galleryAllFilenames,
  };
}

export async function getSiteConfig(
  locale: Locale,
  options?: ContentOptions,
): Promise<SiteConfig> {
  const siteId = resolveSiteId(options);
  if (cmsActive(siteId)) {
    const doc = unwrap(
      await fetchDocument<Partial<SiteConfig>>(
        siteId,
        "site_config",
        "main",
        locale,
        { includeDrafts: options?.preview },
      ),
      "site_config/main",
      locale,
      options,
    );
    if (doc) return mergeSiteConfig(doc);
  }
  requireBundledFallback(siteId, "site_config/main", locale);
  const generated = fromGenerated(generatedContentSnapshot.siteConfig, locale);
  if (generated) return mergeSiteConfig(generated);
  return site;
}

// ---------------------------------------------------------------------------
// Cabin content
// ---------------------------------------------------------------------------

export async function getCabinContent(
  locale: Locale,
  options?: ContentOptions,
): Promise<CabinContent> {
  const siteId = resolveSiteId(options);
  if (cmsActive(siteId)) {
    const doc = unwrap(
      await fetchDocument<CabinContent>(siteId, "cabin", "main", locale, {
        includeDrafts: options?.preview,
      }),
      "cabin/main",
      locale,
      options,
    );
    if (doc) return normalizeCabinContent(doc);
  }
  requireBundledFallback(siteId, "cabin/main", locale);
  const generated = fromGenerated(generatedContentSnapshot.cabin, locale);
  if (generated) return normalizeCabinContent(generated);
  return normalizeCabinContent(getStaticCabinContent(locale));
}

// ---------------------------------------------------------------------------
// Localized content (home page parts)
// ---------------------------------------------------------------------------

export async function getLocalizedContent(
  locale: Locale,
  options?: ContentOptions,
): Promise<LocalizedContent> {
  const siteId = resolveSiteId(options);
  if (cmsActive(siteId)) {
    const doc = unwrap(
      await fetchDocument<Partial<LocalizedContent>>(
        siteId,
        "page",
        "home",
        locale,
        { includeDrafts: options?.preview },
      ),
      "page/home",
      locale,
      options,
    );
    if (doc) {
      return {
        ...localizedContent[locale],
        ...normalizeHomeContent(doc),
      };
    }
  }
  requireBundledFallback(siteId, "page/home", locale);
  const generated = fromGenerated(generatedContentSnapshot.home, locale);
  if (generated) {
    return { ...localizedContent[locale], ...normalizeHomeContent(generated) };
  }
  return localizedContent[locale];
}

// ---------------------------------------------------------------------------
// Practical page
// ---------------------------------------------------------------------------

export async function getPracticalContent(
  locale: Locale,
  options?: ContentOptions,
): Promise<PracticalContent> {
  const siteId = resolveSiteId(options);
  if (cmsActive(siteId)) {
    const doc = unwrap(
      await fetchDocument<PracticalContent>(
        siteId,
        "page",
        "practical",
        locale,
        { includeDrafts: options?.preview },
      ),
      "page/practical",
      locale,
      options,
    );
    if (doc) return normalizePracticalContent(doc);
  }
  requireBundledFallback(siteId, "page/practical", locale);
  const generated = fromGenerated(generatedContentSnapshot.practical, locale);
  if (generated) return normalizePracticalContent(generated);
  return localizedContent[locale].practical;
}

// ---------------------------------------------------------------------------
// Area page
// ---------------------------------------------------------------------------

type AreaContent = LocalizedContent["area"];

export async function getAreaContent(
  locale: Locale,
  options?: ContentOptions,
): Promise<AreaContent> {
  const siteId = resolveSiteId(options);
  if (cmsActive(siteId)) {
    const doc = unwrap(
      await fetchDocument<AreaContent>(siteId, "page", "area", locale, {
        includeDrafts: options?.preview,
      }),
      "page/area",
      locale,
      options,
    );
    if (doc) return normalizeAreaContent(doc);
  }
  requireBundledFallback(siteId, "page/area", locale);
  const generated = fromGenerated(generatedContentSnapshot.area, locale);
  if (generated) return normalizeAreaContent(generated);
  return localizedContent[locale].area;
}

// ---------------------------------------------------------------------------
// Privacy page
// ---------------------------------------------------------------------------

type PrivacyContent = LocalizedContent["privacy"];

export async function getPrivacyContent(
  locale: Locale,
  options?: ContentOptions,
): Promise<PrivacyContent> {
  const siteId = resolveSiteId(options);
  if (cmsActive(siteId)) {
    const doc = unwrap(
      await fetchDocument<PrivacyContent>(siteId, "page", "privacy", locale, {
        includeDrafts: options?.preview,
      }),
      "page/privacy",
      locale,
      options,
    );
    if (doc) return normalizePrivacyContent(doc);
  }
  requireBundledFallback(siteId, "page/privacy", locale);
  const generated = fromGenerated(generatedContentSnapshot.privacy, locale);
  if (generated) return normalizePrivacyContent(generated);
  return localizedContent[locale].privacy;
}

// ---------------------------------------------------------------------------
// Contact form
// ---------------------------------------------------------------------------

export async function getContactFormContent(
  locale: Locale,
  options?: ContentOptions,
): Promise<ContactFormSectionContent> {
  const siteId = resolveSiteId(options);
  if (cmsActive(siteId)) {
    const doc = unwrap(
      await fetchDocument<ContactFormSectionContent>(
        siteId,
        "contact_form",
        "main",
        locale,
        { includeDrafts: options?.preview },
      ),
      "contact_form/main",
      locale,
      options,
    );
    if (doc) return normalizeContactFormContent(doc);
  }
  requireBundledFallback(siteId, "contact_form/main", locale);
  const generated = fromGenerated(generatedContentSnapshot.contactForm, locale);
  if (generated) return normalizeContactFormContent(generated);
  return contactFormSection[locale];
}

// ---------------------------------------------------------------------------
// Preview status
// ---------------------------------------------------------------------------

/**
 * What the preview is really showing, for the banner to state plainly.
 *
 * Derived from the same client and the same RLS path as the content reads, so
 * it cannot claim CMS content while the pages render a fallback.
 */
export type PreviewContentStatus =
  | { kind: "no_site" }
  | { kind: "unavailable"; reason: DocumentUnavailableReason; detail?: string }
  | {
      kind: "documents";
      /** `contentType/slug` of documents whose unpublished draft is on screen. */
      draft: string[];
      /** `contentType/slug` of documents rendering their published content. */
      published: string[];
      /** Documents that do not exist for this locale — fallback content. */
      missing: string[];
    };

export async function getPreviewContentStatus(
  locale: Locale,
  options?: ContentOptions,
): Promise<PreviewContentStatus> {
  const siteId = resolveSiteId(options);
  if (!siteId) return { kind: "no_site" };

  const index = await fetchDocumentIndex(siteId, locale, {
    includeDrafts: options?.preview,
  });
  if (index.status === "unavailable") {
    console.warn(
      `[cms] document index (${locale}): read failed (${index.reason})${
        index.detail ? ` — ${index.detail}` : ""
      }`,
    );
    return { kind: "unavailable", reason: index.reason, detail: index.detail };
  }

  const byKey = new Map(
    index.entries.map((entry) => [`${entry.contentType}/${entry.slug}`, entry]),
  );
  const draft: string[] = [];
  const published: string[] = [];
  const missing: string[] = [];
  for (const document of SITE_DOCUMENTS) {
    const key = `${document.contentType}/${document.slug}`;
    const entry = byKey.get(key);
    if (!entry) {
      missing.push(key);
    } else if (options?.preview && entry.hasDraft) {
      draft.push(key);
    } else {
      published.push(key);
    }
  }
  return { kind: "documents", draft, published, missing };
}
