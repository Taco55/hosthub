import { notFound } from "next/navigation";

import { Footer } from "@/components/footer";
import { Header } from "@/components/header";
import { PreviewBanner } from "@/components/preview-banner";
import { PreviewDraftBridge } from "@/components/preview/PreviewDraftBridge";
import { resolveBookingUrl } from "@/lib/booking-url";
import { getPreviewContentStatus, getSiteConfig } from "@/lib/content-provider";
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
  const contentOptions = toSiteContentOptions(runtimeSite, true);
  const [siteConfig, contentStatus] = await Promise.all([
    getSiteConfig(locale, contentOptions),
    // What the pages below are really rendering — the banner says so out loud.
    getPreviewContentStatus(locale, contentOptions),
  ]);
  const bookingHref = resolveBookingUrl(siteConfig);

  return (
    <div className="flex min-h-screen flex-col">
      <PreviewBanner locale={locale} status={contentStatus} />
      {/* Applies the editor's unsaved draft to what is on screen. */}
      <PreviewDraftBridge locale={locale} />
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
