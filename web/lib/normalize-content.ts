/**
 * Normalizes CMS documents to the shapes the components render.
 *
 * The stable-row-id migration turned every repeatable list into objects with
 * an `id` ([{ id, text }]) and folded the highlight images into their
 * highlight rows. These normalizers accept documents from before and after
 * that migration — and the static/snapshot fallbacks — and always hand the
 * components one shape. Applied at the provider boundary so no component
 * needs to know which era its data came from.
 */

import type {
  CabinContent,
  ContactFormSectionContent,
  HighlightItem,
  LocalizedContent,
  PracticalContent,
} from "./content";
import { rowTexts, textRows } from "./cms-rows";
import { mediaPublicUrl } from "./media-url";

type AnyRecord = Record<string, unknown>;

function isRecord(value: unknown): value is AnyRecord {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** Replaces `key` (a text list) with plain strings, in place on the copy. */
function normalizeTextList(target: AnyRecord, key: string) {
  if (key in target) target[key] = rowTexts(target[key]);
}

export function normalizeCabinContent(doc: CabinContent): CabinContent {
  const cabin = { ...doc } as unknown as AnyRecord;
  // Paragraphs keep their rows: the renderer binds each paragraph to its
  // row's CMS address so the live preview can patch it.
  if ("description" in cabin) cabin.description = textRows(cabin.description);
  normalizeTextList(cabin, "experience");
  if (isRecord(cabin.houseRules)) {
    const houseRules = { ...cabin.houseRules };
    normalizeTextList(houseRules, "bullets");
    cabin.houseRules = houseRules;
  }
  if (isRecord(cabin.amenities) && Array.isArray(cabin.amenities.groups)) {
    cabin.amenities = {
      ...cabin.amenities,
      groups: cabin.amenities.groups.map((group) => {
        if (!isRecord(group)) return group;
        const normalized = { ...group };
        normalizeTextList(normalized, "items");
        return normalized;
      }),
    };
  }
  return cabin as unknown as CabinContent;
}

export function normalizeHomeContent(
  doc: Partial<LocalizedContent>,
): Partial<LocalizedContent> {
  const home = { ...doc } as AnyRecord;
  if (Array.isArray(home.highlights)) {
    const highlights = home.highlights.filter(isRecord) as Array<
      HighlightItem & { image?: string; alt?: string }
    >;
    home.highlights = highlights;
    // Post-migration rows carry their image; keep the legacy parallel array
    // shape alive for the render path until the media phase replaces it.
    if (!home.highlightImages && highlights.some((row) => row.image)) {
      home.highlightImages = highlights
        .filter((row) => typeof row.image === "string")
        // A row's image is a storage path once the owner picked it in the
        // console; resolving here keeps the page ignorant of where it came from.
        .map((row) => ({
          src: mediaPublicUrl(row.image as string),
          alt: row.alt ?? "",
        }));
    }
  }
  normalizeTextList(home, "amenities");
  return home as Partial<LocalizedContent>;
}

export function normalizePracticalContent(
  doc: PracticalContent,
): PracticalContent {
  const practical = { ...doc } as unknown as AnyRecord;
  for (const key of [
    "arrivalAccess",
    "parkingCharging",
    "goodToKnow",
    "contactHelp",
  ]) {
    if (isRecord(practical[key])) {
      const section = { ...(practical[key] as AnyRecord) };
      normalizeTextList(section, "bullets");
      practical[key] = section;
    }
  }
  // Grouped lists: the group holds its own text list under its own key.
  // `agreementsAndPayment` is here because the console can now edit it, and an
  // edited list arrives as [{ id, text }] rows — handing those to React is the
  // "Objects are not valid as a React child" crash.
  const groupedLists: [string, string, string][] = [
    ["layoutFacilities", "sections", "bullets"],
    ["transport", "columns", "bullets"],
    ["agreementsAndPayment", "blocks", "items"],
  ];
  for (const [key, groupsKey, itemsKey] of groupedLists) {
    const block = practical[key];
    if (!isRecord(block)) continue;
    const groups = block[groupsKey];
    if (!Array.isArray(groups)) continue;
    practical[key] = {
      ...block,
      [groupsKey]: groups.map((group) => {
        if (!isRecord(group)) return group;
        const normalized = { ...group };
        normalizeTextList(normalized, itemsKey);
        return normalized;
      }),
    };
  }
  return practical as unknown as PracticalContent;
}

type AreaContent = LocalizedContent["area"];

export function normalizeAreaContent(doc: AreaContent): AreaContent {
  const area = { ...doc } as unknown as AnyRecord;
  if (Array.isArray(area.sections)) {
    area.sections = area.sections.map((section) => {
      if (!isRecord(section)) return section;
      const normalized = { ...section };
      normalizeTextList(normalized, "bullets");
      return normalized;
    });
  }
  return area as unknown as AreaContent;
}

type PrivacyContent = LocalizedContent["privacy"];

export function normalizePrivacyContent(doc: PrivacyContent): PrivacyContent {
  const privacy = { ...doc } as unknown as AnyRecord;
  normalizeTextList(privacy, "bullets");
  return privacy as unknown as PrivacyContent;
}

export function normalizeContactFormContent(
  doc: ContactFormSectionContent,
): ContactFormSectionContent {
  // The contact form's fields are fixed objects keyed by name — no
  // repeatable lists, nothing to normalize. Exists so the provider treats
  // every document uniformly.
  return doc;
}
