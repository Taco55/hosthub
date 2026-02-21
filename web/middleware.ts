import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

import {
  detectionFallbackLocale,
  localeAliases,
  locales,
  siteLangPreferenceKey,
  type Locale,
} from "./lib/i18n";

const supportedSet = new Set(locales);
const excludedPaths = ["/robots.txt", "/sitemap.xml", "/favicon.ico"];

function shouldSkipPath(pathname: string) {
  if (pathname.startsWith("/_next") || pathname.startsWith("/api") || pathname.startsWith("/preview")) {
    return true;
  }

  if (pathname.startsWith("/.well-known") || excludedPaths.includes(pathname)) {
    return true;
  }

  return pathname.includes(".") && pathname !== "/";
}

function normalizeLocale(value?: string | null): Locale | undefined {
  if (!value) {
    return undefined;
  }

  const lower = value.toLowerCase();
  const alias = localeAliases[lower];
  const candidate = alias ?? lower;
  return supportedSet.has(candidate) ? (candidate as Locale) : undefined;
}

type AcceptLanguageEntry = { lang: string; quality: number };

function parseAcceptLanguage(header: string | null): Locale | undefined {
  if (!header) {
    return undefined;
  }

  const entries: AcceptLanguageEntry[] = header
    .split(",")
    .map((chunk) => {
      const trimmed = chunk.trim();
      if (!trimmed) {
        return null;
      }

      const [range, qValue] = trimmed.split(";q=");
      const quality = qValue ? Number.parseFloat(qValue) : 1;
      const safeQuality = Number.isNaN(quality) ? 1 : quality;
      const base = range.split("-")[0];
      return { lang: base.toLowerCase(), quality: safeQuality };
    })
    .filter((entry): entry is AcceptLanguageEntry => Boolean(entry))
    .sort((a, b) => b.quality - a.quality);

  for (const entry of entries) {
    const normalized = normalizeLocale(entry.lang);
    if (normalized) {
      return normalized;
    }
  }

  return undefined;
}

export const runtime = "experimental-edge";

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  if (shouldSkipPath(pathname)) {
    return NextResponse.next();
  }

  const segments = pathname.split("/").filter(Boolean);
  const firstSegment = normalizeLocale(segments[0]);
  if (firstSegment) {
    return NextResponse.next();
  }

  const cookieLocale = normalizeLocale(request.cookies.get(siteLangPreferenceKey)?.value);
  const fromHeader = parseAcceptLanguage(request.headers.get("accept-language"));
  const targetLocale = cookieLocale ?? fromHeader ?? detectionFallbackLocale;

  const destination = request.nextUrl.clone();
  destination.pathname = pathname === "/" ? `/${targetLocale}` : `/${targetLocale}${pathname}`;
  return NextResponse.redirect(destination);
}
