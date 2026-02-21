import type { Metadata } from "next";
import { notFound } from "next/navigation";

import { GalleryGrid } from "@/components/gallery-grid";
import { SectionHeading } from "@/components/section-heading";
import { Container } from "@/components/site/Container";
import { getLocalizedContent, getSiteConfig } from "@/lib/content-provider";
import { getGalleryImages } from "@/lib/gallery";
import { getDictionary, isLocale } from "@/lib/i18n";
import {
  resolveRuntimeSiteContext,
  toSiteContentOptions,
} from "@/lib/runtime-site-context";

type PageProps = {
  params: Promise<{ locale: string }>;
};

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) {
    return {};
  }

  const runtimeSite = await resolveRuntimeSiteContext();
  const localized = await getLocalizedContent(
    locale,
    toSiteContentOptions(runtimeSite),
  );
  const t = getDictionary(locale);
  return {
    title: t.pages.gallery,
    description: localized.tagline,
  };
}

export default async function GalleryPage({ params }: PageProps) {
  const { locale } = await params;
  if (!isLocale(locale)) {
    notFound();
  }

  const runtimeSite = await resolveRuntimeSiteContext();
  const t = getDictionary(locale);
  const contentOptions = toSiteContentOptions(runtimeSite);
  const [content, siteConfig] = await Promise.all([
    getLocalizedContent(locale, contentOptions),
    getSiteConfig(locale, contentOptions),
  ]);
  const images = getGalleryImages(siteConfig, locale);

  return (
    <Container className="py-10 lg:py-14">
      <div className="space-y-8">
        <SectionHeading title={t.pages.gallery} subtitle={content.tagline} />
        <GalleryGrid images={images} allLabel={t.misc.all} />
      </div>
    </Container>
  );
}
