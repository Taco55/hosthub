import type { Metadata } from "next";
import { notFound } from "next/navigation";

import { Footer } from "@/components/footer";
import { Header } from "@/components/header";
import { primaryHeroImage } from "@/lib/content";
import { resolveBookingUrl } from "@/lib/booking-url";
import { getLocalizedContent, getSiteConfig } from "@/lib/content-provider";
import { getDictionary, isLocale, type Locale } from "@/lib/i18n";
import {
  resolveRuntimeSiteContext,
  toSiteContentOptions,
} from "@/lib/runtime-site-context";
import { getSiteBaseUrl } from "@/lib/site-url";

type LayoutProps = {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
};

const localeMetadataMap: Record<Locale, string> = {
  nl: "nl_NL",
  en: "en_US",
  no: "nb_NO",
};

export const dynamic = "force-dynamic";

export async function generateMetadata({ params }: LayoutProps): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) {
    return {};
  }

  const runtimeSite = await resolveRuntimeSiteContext();
  const contentOptions = toSiteContentOptions(runtimeSite);
  const [siteConfig, localized] = await Promise.all([
    getSiteConfig(locale, contentOptions),
    getLocalizedContent(locale, contentOptions),
  ]);
  const t = getDictionary(locale);
  const description = localized.tagline;
  const baseUrl = getSiteBaseUrl(runtimeSite.baseUrl);
  const metadataHeroImage = siteConfig.heroImages[0] ?? primaryHeroImage;

  return {
    metadataBase: new URL(baseUrl),
    title: {
      default: `${siteConfig.name} | ${t.pages.home}`,
      template: `%s | ${siteConfig.name}`,
    },
    description,
    alternates: {
      canonical: `/${locale}`,
      languages: {
        nl: "/nl",
        en: "/en",
        no: "/no",
      },
    },
    openGraph: {
      title: `${siteConfig.name} | ${t.pages.home}`,
      description,
      url: `/${locale}`,
      siteName: siteConfig.name,
      locale: localeMetadataMap[locale],
      type: "website",
      images: [
        {
          url: `${baseUrl}${metadataHeroImage}`,
          width: 1600,
          height: 1000,
          alt: siteConfig.name,
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title: `${siteConfig.name} | ${t.pages.home}`,
      description,
      images: [`${baseUrl}${metadataHeroImage}`],
    },
  };
}

export default async function LocaleLayout({ children, params }: LayoutProps) {
  const { locale } = await params;
  if (!isLocale(locale)) {
    notFound();
  }

  const runtimeSite = await resolveRuntimeSiteContext();
  const siteConfig = await getSiteConfig(locale, toSiteContentOptions(runtimeSite));
  const bookingHref = resolveBookingUrl(siteConfig);

  return (
    <div className="flex min-h-screen flex-col">
      <Header
        locale={locale}
        siteName={siteConfig.name}
        bookingHref={bookingHref}
      />
      <main className="flex-1">{children}</main>
      <Footer
        locale={locale}
        siteName={siteConfig.name}
        siteLocation={siteConfig.location}
        bookingHref={bookingHref}
      />
    </div>
  );
}
