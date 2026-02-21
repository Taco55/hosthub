"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";

import { Locale, getDictionary } from "@/lib/i18n";
import { site } from "@/lib/content";
import { Button } from "@/components/ui/button";
import { LocaleSwitcher } from "@/components/locale-switcher";
import { cn } from "@/lib/utils";
import { Menu, X } from "lucide-react";

type HeaderProps = {
  locale: Locale;
};

export function Header({ locale }: HeaderProps) {
  const t = getDictionary(locale);
  const pathname = usePathname() ?? "/";
  const isPreview = pathname.startsWith("/preview/");
  const base = isPreview ? `/preview/${locale}` : `/${locale}`;
  const isHome = pathname === base;
  const [hasScrolledHalfhero, setHasScrolledHalfHero] = useState(false);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const isSolid = !isHome || hasScrolledHalfhero;
  const bookingHref =
    process.env.NEXT_PUBLIC_LODGIFY_CHECKOUT_URL ??
    "https://checkout.lodgify.com/fagerasen701/706211/reservation?currency=NOK&adults=1";
  const navLinks = [
    { href: base, label: t.nav.home },
    { href: `${base}/gallery`, label: t.nav.gallery },
    { href: `${base}/practical`, label: t.nav.practical },
    { href: `${base}/area`, label: t.nav.area },
    { href: `${base}/privacy`, label: t.nav.privacy },
  ];
  useEffect(() => {
    if (!isHome) {
      setHasScrolledHalfHero(false);
      return;
    }

    const heroSelector = "[data-hero-section]";
    const onScroll = () => {
      const hero = document.querySelector<HTMLElement>(heroSelector);
      if (!hero) {
        return;
      }

      const heroBottom = hero.getBoundingClientRect().bottom;
      const heroHalf = hero.offsetHeight / 2;
      setHasScrolledHalfHero(heroBottom <= heroHalf);
    };

    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", onScroll);
    return () => {
      window.removeEventListener("scroll", onScroll);
      window.removeEventListener("resize", onScroll);
    };
  }, [isHome]);

  useEffect(() => {
    document.body.style.overflow = isMenuOpen ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [isMenuOpen]);

  useEffect(() => {
    if (!isMenuOpen) {
      return;
    }

    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        setIsMenuOpen(false);
      }
    };

    window.addEventListener("keydown", onKeyDown);
    return () => {
      window.removeEventListener("keydown", onKeyDown);
    };
  }, [isMenuOpen]);

  return (
    <>
      <header
        className={cn(
          "sticky top-0 z-40 transition-colors duration-300",
          !isSolid
            ? "border-transparent bg-transparent text-white"
            : "border-b border-border/80 bg-[hsl(var(--background)/0.6)] text-foreground backdrop-blur-md",
        )}
      >
        <div className="mx-auto flex h-16 w-full max-w-7xl items-center justify-between px-6 sm:h-20 sm:px-8 lg:px-10">
          <div className="flex items-center gap-3">
            <button
              type="button"
              aria-label={t.nav.openMenu}
              aria-controls="mobile-nav-panel"
              aria-expanded={isMenuOpen}
              className={cn(
                "md:hidden rounded-full border p-2 text-white transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background",
                !isSolid ? "border-white/40" : "border-border/80 text-foreground",
              )}
              onClick={() => setIsMenuOpen(true)}
            >
              <Menu className="h-5 w-5" />
            </button>
            <Link href={base} className="font-sans text-xl font-semibold tracking-tight">
              {site.name}
            </Link>
          </div>
          <nav className="hidden items-center gap-6 text-sm font-medium md:flex">
            {navLinks.map((link) => (
              <Link key={link.href} href={link.href}>
                {link.label}
              </Link>
            ))}
          </nav>
          <div className="flex items-center gap-3">
            <LocaleSwitcher locale={locale} inverted={!isSolid} />
            <Button
              asChild
              size="sm"
              className={cn("hidden sm:inline-flex", !isSolid ? "shadow-sm" : undefined)}
            >
              <a href={bookingHref}>{t.cta.bookNow}</a>
            </Button>
          </div>
        </div>
      </header>
      {isMenuOpen && (
        <div className="fixed inset-0 z-50 flex md:hidden">
          <div
            className="absolute inset-0 bg-foreground/40 backdrop-blur-sm"
            onClick={() => setIsMenuOpen(false)}
            aria-hidden="true"
          />
          <section
            id="mobile-nav-panel"
            role="dialog"
            aria-modal="true"
            aria-label={t.nav.openMenu}
            className="relative flex h-full w-full max-w-xs flex-col gap-6 border-r border-border/70 bg-[hsl(var(--background)/0.6)] px-6 py-8 shadow-2xl backdrop-blur-2xl"
          >
            <div className="flex items-center justify-between">
              <span className="font-sans text-lg font-semibold tracking-tight text-foreground">
                {site.name}
              </span>
              <button
                type="button"
                aria-label={t.nav.closeMenu}
                className="rounded-full p-1 text-muted-foreground transition hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background"
                onClick={() => setIsMenuOpen(false)}
              >
                <X className="h-5 w-5" />
              </button>
            </div>
            <nav className="flex flex-col gap-3 text-base font-semibold text-foreground" aria-label={t.nav.openMenu}>
              {navLinks.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => setIsMenuOpen(false)}
                  className="rounded-2xl px-4 py-2 transition hover:bg-foreground/5 hover:text-foreground"
                >
                  {link.label}
                </Link>
              ))}
            </nav>
            <Button
              asChild
              size="sm"
              variant="default"
              className="w-full rounded-2xl border border-border/70 bg-[hsl(var(--background)/0.92)] text-foreground shadow-sm shadow-foreground/10"
            >
              <Link
                href={bookingHref}
                onClick={() => setIsMenuOpen(false)}
                className="block w-full text-center"
              >
                {t.cta.bookNow}
              </Link>
            </Button>
          </section>
        </div>
      )}
    </>
  );
}
