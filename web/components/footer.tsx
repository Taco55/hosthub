import Link from "next/link";

import { Locale, getDictionary } from "@/lib/i18n";
import { Button } from "@/components/ui/button";

type FooterProps = {
  locale: Locale;
  siteName: string;
  siteLocation: string;
  bookingHref: string;
  pathPrefix?: string;
};

export function Footer({
  locale,
  siteName,
  siteLocation,
  bookingHref,
  pathPrefix = "",
}: FooterProps) {
  const t = getDictionary(locale);
  const base = `${pathPrefix}/${locale}`;
  const showBookingCta = Boolean(bookingHref);

  return (
    <footer className="border-t border-border/60 bg-background/80">
      <div className="mx-auto flex w-full max-w-7xl flex-col gap-8 px-6 py-10 sm:px-8 lg:px-10 md:flex-row md:items-center md:justify-between">
        <div className="space-y-2">
          <div className="font-sans text-lg font-semibold">{siteName}</div>
          <p className="text-sm text-muted-foreground">{siteLocation}</p>
        </div>
        <nav className="flex flex-wrap items-center gap-4 text-sm font-medium">
          <Link href={base}>{t.nav.home}</Link>
          <Link href={`${base}/gallery`}>{t.nav.gallery}</Link>
          <Link href={`${base}/practical`}>{t.nav.practical}</Link>
          <Link href={`${base}/area`}>{t.nav.area}</Link>
          <Link href={`${base}/privacy`}>{t.nav.privacy}</Link>
        </nav>
        {showBookingCta ? (
          <Button asChild>
            <a href={bookingHref}>{t.cta.bookNow}</a>
          </Button>
        ) : null}
      </div>
    </footer>
  );
}
