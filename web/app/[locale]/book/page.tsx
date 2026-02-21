import type { Metadata } from "next";
import { notFound } from "next/navigation";

import { BookingPage as BookingPageContent } from "@/components/booking/BookingPage";
import { Container } from "@/components/site/Container";
import { primaryHeroImage } from "@/lib/content";
import { resolveBookingUrl } from "@/lib/booking-url";
import { getCabinContent, getSiteConfig } from "@/lib/content-provider";
import { getDictionary, isLocale } from "@/lib/i18n";
import { getHeroImages } from "@/lib/heroImages";
import {
  resolveRuntimeSiteContext,
  toSiteContentOptions,
} from "@/lib/runtime-site-context";
import { buildResponsiveImage, heroImageSizes, heroImageWidths } from "@/lib/responsive-images";

type PageProps = {
  params: Promise<{ locale: string }>;
};

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) {
    return {};
  }

  const runtimeSite = await resolveRuntimeSiteContext();
  const t = getDictionary(locale);
  const content = await getCabinContent(
    locale,
    toSiteContentOptions(runtimeSite),
  );
  return {
    title: t.pages.booking,
    description: content.hero.subtitle,
  };
}

export default async function BookingPage({ params }: PageProps) {
  const { locale } = await params;
  if (!isLocale(locale)) {
    notFound();
  }

  const runtimeSite = await resolveRuntimeSiteContext();
  const contentOptions = toSiteContentOptions(runtimeSite);
  const [content, siteConfig] = await Promise.all([
    getCabinContent(locale, contentOptions),
    getSiteConfig(locale, contentOptions),
  ]);
  const currency = process.env.NEXT_PUBLIC_LODGIFY_CURRENCY ?? "NOK";
  const checkoutUrl = resolveBookingUrl(siteConfig);
  const heroImages = getHeroImages(siteConfig);
  const heroImage = heroImages[0] ?? buildResponsiveImage(primaryHeroImage, {
    widths: heroImageWidths,
    sizes: heroImageSizes,
    defaultWidth: 1920,
  });
  const detailsHref = `/${locale}`;

  return (
    <Container className="py-10 lg:py-14">
      <BookingPageContent
        locale={locale}
        rentalTitle={content.meta.name}
        rentalImage={heroImage}
        detailsHref={detailsHref}
        currencyFallback={currency}
        checkoutUrl={checkoutUrl}
      />
    </Container>
  );
}
