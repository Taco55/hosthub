import type { Metadata } from "next";
import { notFound } from "next/navigation";

import { Footer } from "@/components/footer";
import { Header } from "@/components/header";
import { localizedContent, primaryHeroImage, site } from "@/lib/content";
import { getDictionary, isLocale, locales, type Locale } from "@/lib/i18n";
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

export function generateStaticParams() {
  return locales.map((locale) => ({ locale }));
}

export async function generateMetadata({ params }: LayoutProps): Promise<Metadata> {
  const { locale } = await params;
  if (!isLocale(locale)) {
    return {};
  }

  const t = getDictionary(locale);
  const description = localizedContent[locale].tagline;
  const baseUrl = getSiteBaseUrl();

  return {
    metadataBase: new URL(baseUrl),
    title: {
      default: `${site.name} | ${t.pages.home}`,
      template: `%s | ${site.name}`,
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
      title: `${site.name} | ${t.pages.home}`,
      description,
      url: `/${locale}`,
      siteName: site.name,
      locale: localeMetadataMap[locale],
      type: "website",
      images: [
        {
          url: `${baseUrl}${primaryHeroImage}`,
          width: 1600,
          height: 1000,
          alt: site.name,
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title: `${site.name} | ${t.pages.home}`,
      description,
      images: [`${baseUrl}${primaryHeroImage}`],
    },
  };
}

export default async function LocaleLayout({ children, params }: LayoutProps) {
  const { locale } = await params;
  if (!isLocale(locale)) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col">
      <Header locale={locale} />
      <main className="flex-1">{children}</main>
      <Footer locale={locale} />
    </div>
  );
}
