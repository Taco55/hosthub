"use client";

import Script from "next/script";

import { getDictionary, type Locale } from "@/lib/i18n";

type LodgifySearchBarProps = {
  locale: Locale;
  websiteId: string;
  checkoutUrl: string;
};

const languageCodeMap: Record<Locale, string> = {
  nl: "nl",
  en: "en",
  no: "no",
};

export function LodgifySearchBar({ locale, websiteId, checkoutUrl }: LodgifySearchBarProps) {
  const t = getDictionary(locale);
  const languageCode = languageCodeMap[locale];

  return (
    <>
      <div
        id="lodgify-search-bar"
        data-website-id={websiteId}
        data-language-code={languageCode}
        data-checkout-page-url={checkoutUrl}
        data-dates-check-in-label={t.lodgify.checkInLabel}
        data-dates-check-out-label={t.lodgify.checkOutLabel}
        data-guests-counter-label={t.lodgify.guestsLabel}
        data-guests-input-singular-label={t.lodgify.guestsSingular}
        data-guests-input-plural-label={t.lodgify.guestsPlural}
        data-location-input-label={t.lodgify.locationLabel}
        data-search-button-label={t.lodgify.searchLabel}
        data-dates-input-min-stay-tooltip-text={JSON.stringify(t.lodgify.minStayTooltip)}
        data-guests-breakdown-label={t.lodgify.guestsBreakdownLabel}
        data-adults-label={JSON.stringify(t.lodgify.adultsLabel)}
        data-adults-description={t.lodgify.adultsDescription}
        data-children-label={JSON.stringify(t.lodgify.childrenLabel)}
        data-children-description={t.lodgify.childrenDescription}
        data-children-not-allowed-label={t.lodgify.childrenNotAllowedLabel}
        data-infants-label={JSON.stringify(t.lodgify.infantsLabel)}
        data-infants-description={t.lodgify.infantsDescription}
        data-infants-not-allowed-label={t.lodgify.infantsNotAllowedLabel}
        data-pets-label={JSON.stringify(t.lodgify.petsLabel)}
        data-pets-not-allowed-label={t.lodgify.petsNotAllowedLabel}
        data-done-label={t.lodgify.doneLabel}
        data-new-tab="true"
        data-version="stable"
        data-has-guests-breakdown="true"
      />
      <Script
        src="https://app.lodgify.com/portable-search-bar/stable/renderPortableSearchBar.js"
        strategy="afterInteractive"
      />
    </>
  );
}
