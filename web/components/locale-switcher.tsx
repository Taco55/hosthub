"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

import { Locale, localeLabels, locales, siteLangPreferenceKey } from "@/lib/i18n";
import { cn } from "@/lib/utils";

type LocaleSwitcherProps = {
  locale: Locale;
  inverted?: boolean;
  className?: string;
};

const preferenceMaxAgeSeconds = 60 * 60 * 24 * 365;

function storeLocalePreference(locale: Locale) {
  if (typeof window === "undefined") {
    return;
  }

  try {
    localStorage.setItem(siteLangPreferenceKey, locale);
  } catch {
    // ignore storage errors
  }

  document.cookie = `${siteLangPreferenceKey}=${locale}; path=/; max-age=${preferenceMaxAgeSeconds}; SameSite=Lax`;
}

export function LocaleSwitcher({ locale, inverted = false, className }: LocaleSwitcherProps) {
  const pathname = usePathname() ?? "/";
  const isPreview = pathname.startsWith("/preview/");
  const prefix = isPreview ? "/preview" : "";
  const localeBase = `${prefix}/${locale}`;
  const restPath = pathname.startsWith(localeBase) ? pathname.slice(localeBase.length) : "";

  return (
    <div
      className={cn(
        "flex items-center rounded-full border p-1 text-[11px] font-semibold uppercase tracking-wide",
        inverted
          ? "border-white/30 bg-white/10 text-white"
          : "border-border/70 bg-background/80 text-muted-foreground",
        className,
      )}
    >
      {locales.map((target) => {
        const href = `${prefix}/${target}${restPath}`;
        const isActive = target === locale;
        return (
          <Link
            key={target}
            href={href}
            className={cn(
              "rounded-full px-2 py-1 transition-colors",
              isActive
                ? inverted
                  ? "bg-white text-slate-900"
                  : "bg-foreground text-background"
                : inverted
                  ? "text-white/70"
                  : "text-muted-foreground",
            )}
            aria-current={isActive ? "page" : undefined}
            onClick={() => {
              storeLocalePreference(target);
            }}
          >
            {localeLabels[target]}
          </Link>
        );
      })}
    </div>
  );
}
