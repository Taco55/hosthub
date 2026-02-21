import { notFound } from "next/navigation";

import { Footer } from "@/components/footer";
import { Header } from "@/components/header";
import { PreviewBanner } from "@/components/preview-banner";
import { resolveBookingUrl } from "@/lib/booking-url";
import { getSiteConfig } from "@/lib/content-provider";
import { isLocale } from "@/lib/i18n";
import {
  resolveRuntimeSiteContext,
  toSiteContentOptions,
} from "@/lib/runtime-site-context";

type LayoutProps = {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
};

export default async function PreviewLocaleLayout({ children, params }: LayoutProps) {
  const { locale } = await params;
  if (!isLocale(locale)) {
    notFound();
  }

  const runtimeSite = await resolveRuntimeSiteContext();
  const siteConfig = await getSiteConfig(
    locale,
    toSiteContentOptions(runtimeSite, true),
  );
  const bookingHref = resolveBookingUrl(siteConfig);

  return (
    <div className="flex min-h-screen flex-col">
      <PreviewBanner locale={locale} />
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
        pathPrefix="/preview"
      />
    </div>
  );
}
