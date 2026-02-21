import type { MetadataRoute } from "next";

import { locales } from "@/lib/i18n";
import { resolveRuntimeSiteContext } from "@/lib/runtime-site-context";
import { getSiteBaseUrl } from "@/lib/site-url";

export const dynamic = "force-dynamic";

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const runtimeSite = await resolveRuntimeSiteContext();
  const baseUrl = getSiteBaseUrl(runtimeSite.baseUrl);
  const now = new Date();
  const paths = ["", "/gallery", "/practical", "/area", "/privacy"];

  return locales.flatMap((locale) =>
    paths.map((path) => ({
      url: `${baseUrl}/${locale}${path}`,
      lastModified: now,
    })),
  );
}
