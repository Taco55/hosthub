/**
 * Content provider facade.
 *
 * Tries to load content from Supabase CMS when CMS_ENABLED=true and a
 * site id is configured. The site id can come from:
 * 1) `options.siteId` (runtime override, e.g. resolved from request host)
 * 2) `NEXT_PUBLIC_CMS_SITE_ID` (default/fallback)
 *
 * Falls back to generated snapshot content from `content.generated.ts`, and
 * finally to static `content.ts`, when CMS is unavailable or a document is
 * missing.
 *
 * This means the production website keeps working identically when CMS env
 * vars are not set.
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
import { fetchDocument } from "./supabase/cms";

const CMS_ENABLED = process.env.CMS_ENABLED === "true";
const CMS_SITE_ID = process.env.NEXT_PUBLIC_CMS_SITE_ID ?? "";

export type ContentOptions = {
  /** When true, also fetches draft documents (for preview mode). */
  preview?: boolean;
  /** Optional runtime override for multi-site setups. */
  siteId?: string;
};

function resolveSiteId(options?: ContentOptions) {
  const fromOptions = options?.siteId?.trim();
  if (fromOptions) return fromOptions;
  return CMS_SITE_ID;
}

function cmsActive(siteId: string, options?: ContentOptions) {
  return Boolean((CMS_ENABLED || options?.preview) && siteId);
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
  if (cmsActive(siteId, options)) {
    const doc = await fetchDocument<Partial<SiteConfig>>(
      siteId,
      "site_config",
      "main",
      locale,
      { includeDrafts: options?.preview },
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
  if (cmsActive(siteId, options)) {
    const doc = await fetchDocument<CabinContent>(
      siteId,
      "cabin",
      "main",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return doc;
  }
  const generated = fromGenerated(generatedContentSnapshot.cabin, locale);
  if (generated) return generated;
  return getStaticCabinContent(locale);
}

// ---------------------------------------------------------------------------
// Localized content (home page parts)
// ---------------------------------------------------------------------------

export async function getLocalizedContent(
  locale: Locale,
  options?: ContentOptions,
): Promise<LocalizedContent> {
  const siteId = resolveSiteId(options);
  if (cmsActive(siteId, options)) {
    const doc = await fetchDocument<Partial<LocalizedContent>>(
      siteId,
      "page",
      "home",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return { ...localizedContent[locale], ...doc };
  }
  const generated = fromGenerated(generatedContentSnapshot.home, locale);
  if (generated) return { ...localizedContent[locale], ...generated };
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
  if (cmsActive(siteId, options)) {
    const doc = await fetchDocument<PracticalContent>(
      siteId,
      "page",
      "practical",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return doc;
  }
  const generated = fromGenerated(generatedContentSnapshot.practical, locale);
  if (generated) return generated;
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
  if (cmsActive(siteId, options)) {
    const doc = await fetchDocument<AreaContent>(
      siteId,
      "page",
      "area",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return doc;
  }
  const generated = fromGenerated(generatedContentSnapshot.area, locale);
  if (generated) return generated;
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
  if (cmsActive(siteId, options)) {
    const doc = await fetchDocument<PrivacyContent>(
      siteId,
      "page",
      "privacy",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return doc;
  }
  const generated = fromGenerated(generatedContentSnapshot.privacy, locale);
  if (generated) return generated;
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
  if (cmsActive(siteId, options)) {
    const doc = await fetchDocument<ContactFormSectionContent>(
      siteId,
      "contact_form",
      "main",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return doc;
  }
  const generated = fromGenerated(generatedContentSnapshot.contactForm, locale);
  if (generated) return generated;
  return contactFormSection[locale];
}
