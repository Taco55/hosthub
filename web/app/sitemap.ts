import type { MetadataRoute } from "next";

import { locales } from "@/lib/i18n";
import { getSiteBaseUrl } from "@/lib/site-url";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = getSiteBaseUrl();
  const now = new Date();
  const paths = ["", "/gallery", "/practical", "/area", "/privacy"];

  return locales.flatMap((locale) =>
    paths.map((path) => ({
      url: `${baseUrl}/${locale}${path}`,
      lastModified: now,
    })),
  );
}
