/**
 * Content provider facade.
 *
 * Tries to load content from Supabase CMS when CMS_ENABLED=true and a
 * NEXT_PUBLIC_CMS_SITE_ID is configured. Falls back to the static content
 * from `content.ts` when CMS is not available or a document is missing.
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
} from "./content";
import {
  getCabinContent as getStaticCabinContent,
  localizedContent,
  contactFormSection,
  site,
} from "./content";
import { fetchDocument } from "./supabase/cms";

const CMS_ENABLED = process.env.CMS_ENABLED === "true";
const CMS_SITE_ID = process.env.NEXT_PUBLIC_CMS_SITE_ID ?? "";

function cmsActive(options?: { preview?: boolean }) {
  return (CMS_ENABLED || options?.preview) && CMS_SITE_ID;
}

type ContentOptions = {
  /** When true, also fetches draft documents (for preview mode). */
  preview?: boolean;
};

// ---------------------------------------------------------------------------
// Site config
// ---------------------------------------------------------------------------

type SiteConfig = typeof site;

export async function getSiteConfig(
  locale: Locale,
  options?: ContentOptions,
): Promise<SiteConfig> {
  if (cmsActive(options)) {
    const doc = await fetchDocument<Partial<SiteConfig>>(
      CMS_SITE_ID,
      "site_config",
      "main",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return { ...site, ...doc };
  }
  return site;
}

// ---------------------------------------------------------------------------
// Cabin content
// ---------------------------------------------------------------------------

export async function getCabinContent(
  locale: Locale,
  options?: ContentOptions,
): Promise<CabinContent> {
  if (cmsActive(options)) {
    const doc = await fetchDocument<CabinContent>(
      CMS_SITE_ID,
      "cabin",
      "main",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return doc;
  }
  return getStaticCabinContent(locale);
}

// ---------------------------------------------------------------------------
// Localized content (home page parts)
// ---------------------------------------------------------------------------

export async function getLocalizedContent(
  locale: Locale,
  options?: ContentOptions,
): Promise<LocalizedContent> {
  if (cmsActive(options)) {
    const doc = await fetchDocument<Partial<LocalizedContent>>(
      CMS_SITE_ID,
      "page",
      "home",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return { ...localizedContent[locale], ...doc };
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
  if (cmsActive(options)) {
    const doc = await fetchDocument<PracticalContent>(
      CMS_SITE_ID,
      "page",
      "practical",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return doc;
  }
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
  if (cmsActive(options)) {
    const doc = await fetchDocument<AreaContent>(
      CMS_SITE_ID,
      "page",
      "area",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return doc;
  }
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
  if (cmsActive(options)) {
    const doc = await fetchDocument<PrivacyContent>(
      CMS_SITE_ID,
      "page",
      "privacy",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return doc;
  }
  return localizedContent[locale].privacy;
}

// ---------------------------------------------------------------------------
// Contact form
// ---------------------------------------------------------------------------

export async function getContactFormContent(
  locale: Locale,
  options?: ContentOptions,
): Promise<ContactFormSectionContent> {
  if (cmsActive(options)) {
    const doc = await fetchDocument<ContactFormSectionContent>(
      CMS_SITE_ID,
      "contact_form",
      "main",
      locale,
      { includeDrafts: options?.preview },
    );
    if (doc) return doc;
  }
  return contactFormSection[locale];
}
