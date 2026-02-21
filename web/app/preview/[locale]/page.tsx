import { notFound } from "next/navigation";
import { Eye, Flame, MountainSnow, Users } from "lucide-react";

import { GalleryPreview } from "@/components/gallery-preview";
import { HighlightsGrid } from "@/components/highlights-grid";
import { ContactFormSection } from "@/components/home/ContactFormSection";
import { SectionHeading } from "@/components/section-heading";
import { AmenitiesGrouped } from "@/components/site/AmenitiesGrouped";
import { Container } from "@/components/site/Container";
import { Description } from "@/components/site/Description";
import { Hero } from "@/components/site/Hero";
import { KeyFactsGrid } from "@/components/site/KeyFactsGrid";
import { LocationBlock } from "@/components/site/LocationBlock";
import { primaryHeroImage } from "@/lib/content";
import { getCabinContent, getLocalizedContent, getSiteConfig } from "@/lib/content-provider";
import { getGalleryImages } from "@/lib/gallery";
import { getDictionary, isLocale } from "@/lib/i18n";
import { getSiteBaseUrl } from "@/lib/site-url";
import {
  buildResponsiveImage,
  highlightImageSizes,
  highlightImageWidths,
} from "@/lib/responsive-images";

type PageProps = {
  params: Promise<{ locale: string }>;
};

export default async function PreviewHomePage({ params }: PageProps) {
  const { locale } = await params;
  if (!isLocale(locale)) {
    notFound();
  }

  const preview = true;
  const opts = { preview };
  const content = await getCabinContent(locale, opts);
  const localized = await getLocalizedContent(locale, opts);
  const site = await getSiteConfig(locale, opts);
  const t = getDictionary(locale);
  const images = getGalleryImages(locale, "preview");
  const highlightImages = localized.highlightImages?.map((image) => ({
    ...buildResponsiveImage(image.src, {
      widths: highlightImageWidths,
      sizes: highlightImageSizes,
      defaultWidth: 1280,
    }),
    alt: image.alt,
  }));
  const bookingUrl =
    process.env.NEXT_PUBLIC_LODGIFY_CHECKOUT_URL ?? process.env.LODGIFY_BOOKING_URL ?? "";
  const bookingPageHref = `/preview/${locale}/book`;
  const bookingCtaHref = bookingUrl || bookingPageHref;
  const baseUrl = getSiteBaseUrl();
  const heroImage = images[0];
  const heroImageSrc = heroImage?.src ?? primaryHeroImage;
  const heroImageAlt = content.meta.name;

  const amenityItems = content.amenities.groups.flatMap((group) => group.items);
  const amenityFeature = Array.from(new Set(amenityItems));
  const locationDistanceKeywords = [
    "ski lift",
    "skilift",
    "lift",
    "heis",
    "lodge",
    "skistar",
    "transport",
    "trail",
    "trails",
    "loipe",
    "langlauf",
    "langrenn",
    "hiking",
    "mountain bike",
    "bikeroute",
    "bikeroutes",
    "wandel",
    "stier",
    "route",
    "routes",
    "terrengsykkel",
    "sykkel",
  ];
  const filteredDistances = content.location.distances.filter((distance) => {
    const normalized = distance.label
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "");
    return locationDistanceKeywords.some((keyword) => normalized.includes(keyword));
  });
  const locationHighlights = filteredDistances.length
    ? filteredDistances
    : content.location.distances;
  const highlightIcons = [MountainSnow, Users, Eye, Flame];

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "LodgingBusiness",
    name: site.name,
    alternateName: content.meta.name,
    description: content.hero.subtitle,
    image: [`${baseUrl}${heroImageSrc}`],
    url: `${baseUrl}/${locale}`,
      address: {
        "@type": "PostalAddress",
        addressLocality: "Trysil",
        addressCountry: "NO",
        streetAddress: "Fageråsen 701",
      },
      geo: {
        "@type": "GeoCoordinates",
        latitude: 61.332251,
        longitude: 12.165275,
      },
    amenityFeature: amenityFeature.map((amenity) => ({
      "@type": "LocationFeatureSpecification",
      name: amenity,
      value: true,
    })),
    numberOfRooms: site.bedrooms,
    occupancy: {
      "@type": "QuantitativeValue",
      value: site.capacity,
      unitText: "guests",
    },
    sameAs: bookingUrl ? [bookingUrl] : undefined,
  };

  return (
    <div className="space-y-10 pb-16 lg:space-y-14">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <Hero
        locale={locale}
        title={content.hero.title}
        locationShort={content.meta.locationShort}
        imageSrc={heroImageSrc}
        imageAlt={heroImageAlt}
        primaryCtaHref={bookingCtaHref}
        secondaryCtaHref="#gallery"
      />
      <KeyFactsGrid items={localized.keyFacts} />
      <Container className="space-y-10 text-center lg:space-y-14">
        <div className="space-y-10 lg:space-y-12">
          <Description title={t.sections.description} paragraphs={content.description} />
          <GalleryPreview
            id="gallery"
            title={t.sections.gallery}
            ctaLabel={t.cta.viewGallery}
            href={`/preview/${locale}/gallery`}
            images={images}
          />
          <AmenitiesGrouped title={content.amenities.title} locale={locale} />
          <LocationBlock
            title={content.location.title}
            locationShort={content.meta.locationShort}
            distances={locationHighlights}
            mapQuery={content.location.mapQuery}
            mapEmbedUrl={site.mapEmbedUrl}
            mapLinkUrl={site.mapLinkUrl}
            ctaLabel={t.misc.openMap}
          />
          <section className="space-y-6">
            <SectionHeading
              title={t.sections.highlights}
              subtitle={t.sections.highlightsSubtitle}
              align="center"
            />
            <HighlightsGrid
              highlights={localized.highlights}
              icons={highlightIcons}
              images={highlightImages}
            />
          </section>
        </div>
      </Container>
      <ContactFormSection locale={locale} />
    </div>
  );
}
