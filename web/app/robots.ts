import type { MetadataRoute } from "next";

import { getSiteBaseUrl } from "@/lib/site-url";
import { localeAliases, locales } from "@/lib/i18n";

const disallowPaths = Array.from(
  new Set([
    "/homemanual",
    ...locales.map((locale) => `/${locale}/homemanual`),
    ...Object.keys(localeAliases).map((alias) => `/${alias}/homemanual`),
  ]),
);

export default function robots(): MetadataRoute.Robots {
  const baseUrl = getSiteBaseUrl();

  return {
    rules: [
      {
        userAgent: "*",
        allow: "/",
        disallow: disallowPaths,
      },
    ],
    sitemap: `${baseUrl}/sitemap.xml`,
  };
}
