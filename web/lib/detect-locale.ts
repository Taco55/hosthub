import { cookies, headers } from "next/headers";

import {
  detectionFallbackLocale,
  localeAliases,
  locales,
  siteLangPreferenceKey,
  type Locale,
} from "./i18n";

/**
 * Which language to send a visitor who did not ask for one.
 *
 * This used to live in `proxy.ts`. Next 16 renamed middleware to Proxy and
 * pinned it to the Node.js runtime, which the Cloudflare adapter refuses to
 * build — so the site could not be deployed at all while the redirect lived
 * there. Reading the same cookie and header from a server component costs one
 * redirect instead of an edge hop, and keeps the site deployable.
 */

const supportedSet = new Set<string>(locales);

export function normalizeLocale(value?: string | null): Locale | undefined {
  if (!value) return undefined;
  const lower = value.toLowerCase();
  const candidate = localeAliases[lower] ?? lower;
  return supportedSet.has(candidate) ? (candidate as Locale) : undefined;
}

type AcceptLanguageEntry = { lang: string; quality: number };

export function parseAcceptLanguage(header: string | null): Locale | undefined {
  if (!header) return undefined;

  const entries: AcceptLanguageEntry[] = header
    .split(",")
    .map((chunk) => {
      const trimmed = chunk.trim();
      if (!trimmed) return null;
      const [range, qValue] = trimmed.split(";q=");
      const quality = qValue ? Number.parseFloat(qValue) : 1;
      return {
        lang: range.split("-")[0].toLowerCase(),
        quality: Number.isNaN(quality) ? 1 : quality,
      };
    })
    .filter((entry): entry is AcceptLanguageEntry => Boolean(entry))
    .sort((a, b) => b.quality - a.quality);

  for (const entry of entries) {
    const normalized = normalizeLocale(entry.lang);
    if (normalized) return normalized;
  }
  return undefined;
}

/** The visitor's own choice first, then what their browser asks for. */
export async function detectLocale(): Promise<Locale> {
  const [cookieStore, headerList] = await Promise.all([cookies(), headers()]);
  return (
    normalizeLocale(cookieStore.get(siteLangPreferenceKey)?.value) ??
    parseAcceptLanguage(headerList.get("accept-language")) ??
    detectionFallbackLocale
  );
}
