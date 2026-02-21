import type { Metadata } from "next";
import { notFound } from "next/navigation";

import { GalleryGrid } from "@/components/gallery-grid";
import { SectionHeading } from "@/components/section-heading";
import { Container } from "@/components/site/Container";
import { localizedContent } from "@/lib/content";
import { getGalleryImages } from "@/lib/gallery";
import { getDictionary, isLocale } from "@/lib/i18n";

type PageProps = {
  params: Promise<{ locale: string }>;
};

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) {
    return {};
  }

  const t = getDictionary(locale);
  return {
    title: t.pages.gallery,
    description: localizedContent[locale].tagline,
  };
}

export default async function GalleryPage({ params }: PageProps) {
  const { locale } = await params;
  if (!isLocale(locale)) {
    notFound();
  }

  const t = getDictionary(locale);
  const content = localizedContent[locale];
  const images = getGalleryImages(locale);

  return (
    <Container className="py-10 lg:py-14">
      <div className="space-y-8">
        <SectionHeading title={t.pages.gallery} subtitle={content.tagline} />
        <GalleryGrid images={images} allLabel={t.misc.all} />
      </div>
    </Container>
  );
}
