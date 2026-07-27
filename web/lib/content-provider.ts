/**
 * Content provider facade.
 *
 * Reads the site's content from the Supabase CMS. The site is whichever one the
 * request's host resolves to (see `runtime-site-context`) — there is no env
 * default and no on/off switch, so the site being edited and the site being
 * rendered cannot drift apart.
 *
 * Falls back to generated snapshot content from `content.generated.ts`, and
 * finally to static `content.ts`, when a document is missing or unreadable.
 *
 * This means the website keeps rendering when the CMS is unreachable or a
 * locale has no documents yet. The fallback is deliberate for the public site
 * and a trap
 * for the preview: a preview that quietly renders snapshot content tells the
 * owner their CMS copy is live when it is not. So every fallback is reported —
 * to the server log, and through [getPreviewContentStatus] to the preview
 * banner, which states what is actually on screen.
 */

import type { Locale } from "./i18n";
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
  /** Optional runtime override for multi-site setups. */
  siteId?: string;
};

/**
 * The site comes from the request's host (see runtime-site-context): with a
 * site there is CMS content to read, without one the fallback is all there is.
 */
function resolveSiteId(options?: ContentOptions) {
  return options?.siteId?.trim() ?? "";
}

function cmsActive(siteId: string) {
  return siteId.length > 0;
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
  return {
    ...site,
    ...override,
    imagePaths: {
      ...site.imagePaths,
      ...(override.imagePaths ?? {}),
    },
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
