import type { MetadataRoute } from "next";

import { getSiteBaseUrl } from "@/lib/site-url";
import { localeAliases, locales } from "@/lib/i18n";
import { resolveRuntimeSiteContext } from "@/lib/runtime-site-context";

const disallowPaths = Array.from(
  new Set([
    "/homemanual",
    ...locales.map((locale) => `/${locale}/homemanual`),
    ...Object.keys(localeAliases).map((alias) => `/${alias}/homemanual`),
  ]),
);

export const dynamic = "force-dynamic";

export default async function robots(): Promise<MetadataRoute.Robots> {
  const runtimeSite = await resolveRuntimeSiteContext();
  const baseUrl = getSiteBaseUrl(runtimeSite.baseUrl);

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
