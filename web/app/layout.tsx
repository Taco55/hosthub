import "./globals.css";
import { Cormorant_Garamond, Manrope } from "next/font/google";

import {
  defaultLocale,
  detectionFallbackLocale,
  localeAliases,
  locales,
  siteLangPreferenceKey,
} from "@/lib/i18n";

const manrope = Manrope({
  subsets: ["latin"],
  variable: "--font-sans",
  display: "swap",
});

const cormorant = Cormorant_Garamond({
  subsets: ["latin"],
  weight: ["400", "600", "700"],
  variable: "--font-serif",
  display: "swap",
});

const localeRedirectScript = [
  "(function () {",
  "  // All comments in English are required; no other language in code comments.",
  `  const supported = ${JSON.stringify(locales)};`,
  `  const defaultLang = ${JSON.stringify(detectionFallbackLocale)};`,
  `  const localeAliasMap = ${JSON.stringify(localeAliases)};`,
  `  const preferenceKey = ${JSON.stringify(siteLangPreferenceKey)};`,
  "",
  "  const normalizeLocale = (value) => {",
  "    if (!value) {",
  "      return null;",
  "    }",
  "",
  "    const lower = value.toLowerCase();",
  "    const alias = localeAliasMap[lower];",
  "    const candidate = alias ?? lower;",
  "    return supported.includes(candidate) ? candidate : null;",
  "  };",
  "",
  "  const getCookieValue = (name) => {",
  "    if (!document.cookie) {",
  "      return null;",
  "    }",
  "",
  "    const matches = document.cookie.match(new RegExp('(^|; )' + name + '=([^;]*)'));",
  "    return matches ? decodeURIComponent(matches[2]) : null;",
  "  };",
  "",
  "  const path = window.location.pathname;",
  "  const segments = path.split('/').filter(Boolean);",
  "  const firstSegment = normalizeLocale(segments[0]);",
  "  if (firstSegment || segments[0] === 'preview') {",
  "    return;",
  "  }",
  "",
  "  const storedLocal = (() => {",
  "    try {",
  "      return localStorage.getItem(preferenceKey);",
  "    } catch {",
  "      return null;",
  "    }",
  "  })();",
  "",
  "  const storedCookie = getCookieValue(preferenceKey);",
  "  const storedValue = storedLocal || storedCookie;",
  "  if (storedValue) {",
  "    const normalizedStored = normalizeLocale(storedValue);",
  "    if (normalizedStored) {",
  "      const trailing = `${window.location.search}${window.location.hash}`;",
  "      window.location.replace(`/${normalizedStored}${path}${trailing}`);",
  "      return;",
  "    }",
  "  }",
  "",
  "  const prefs =",
  "    navigator.languages && navigator.languages.length",
  "      ? navigator.languages",
  "      : [navigator.language || defaultLang];",
  "",
  "  const preferredBase = prefs",
  "    .map((lang) => normalizeLocale(lang))",
  "    .find((lang) => Boolean(lang));",
  "",
  "  const lang = preferredBase || defaultLang;",
  "  const trailing = `${window.location.search}${window.location.hash}`;",
  "  window.location.replace(`/${lang}${path}${trailing}`);",
  "})();",
].join("\n");

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang={defaultLocale} suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: localeRedirectScript }} />
      </head>
      <body
        className={`${manrope.variable} ${cormorant.variable} min-h-screen font-sans antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
