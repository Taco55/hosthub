/**
 * Generated CMS snapshot fallback.
 *
 * This file is intentionally committed so the website can still serve recent
 * published content when Supabase is unavailable. Update it with:
 *
 *   npm run cms:snapshot
 */

import type { Locale } from "./i18n";
import type {
  CabinContent,
  ContactFormSectionContent,
  LocalizedContent,
  PracticalContent,
} from "./content";

type LocalizedMap<T> = Partial<Record<Locale, T>>;

export type GeneratedSiteConfig = {
  name: string;
  location: string;
  capacity: number;
  bedrooms: number;
  bathrooms: number;
  mapEmbedUrl: string;
  mapLinkUrl: string;
};

export type GeneratedContentSnapshot = {
  siteConfig: LocalizedMap<Partial<GeneratedSiteConfig>>;
  cabin: LocalizedMap<CabinContent>;
  home: LocalizedMap<Partial<LocalizedContent>>;
  practical: LocalizedMap<PracticalContent>;
  area: LocalizedMap<LocalizedContent["area"]>;
  privacy: LocalizedMap<LocalizedContent["privacy"]>;
  contactForm: LocalizedMap<ContactFormSectionContent>;
};

export const generatedContentSnapshot: GeneratedContentSnapshot = {
  siteConfig: {},
  cabin: {},
  home: {},
  practical: {},
  area: {},
  privacy: {},
  contactForm: {},
};
