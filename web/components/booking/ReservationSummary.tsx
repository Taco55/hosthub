"use client";

import { useEffect, useMemo, useState } from "react";
import Image from "next/image";

import { BookButton } from "@/components/booking/BookButton";
import { Button } from "@/components/ui/button";
import type { QuoteView } from "@/lib/booking/types";
import { getDictionary, type Locale } from "@/lib/i18n";
import { cn } from "@/lib/utils";
import type { ResponsiveImage } from "@/lib/responsive-images";

// Promo codes stay hidden until Lodgify quote promos are supported.
const promoFeatureFlag = process.env.NEXT_PUBLIC_LODGIFY_PROMO_ENABLED === "true";

function formatCountLabel(count: number, labels: { one: string; other: string }) {
  return `${count} ${count === 1 ? labels.one : labels.other}`;
}

type ReservationSummaryProps = {
  locale: Locale;
  rentalTitle: string;
  rentalImage: ResponsiveImage;
  detailsHref: string;
  availability: { available: boolean } | null;
  availabilityLoading: boolean;
  availabilityError: string | null;
  quote: QuoteView | null;
  quoteLoading: boolean;
  quoteError: string | null;
  promoCode: string;
  onPromoApply: (code: string) => void;
  arrivalLabel: string;
  departureLabel: string;
  nights: number;
  guestsLabel: string;
  checkoutHref: string;
  canBook: boolean;
  hasCheckoutUrl: boolean;
};

export function ReservationSummary({
  locale,
  rentalTitle,
  rentalImage,
  detailsHref,
  availability,
  availabilityLoading,
  availabilityError,
  quote,
  quoteLoading,
  quoteError,
  promoCode,
  onPromoApply,
  arrivalLabel,
  departureLabel,
  nights,
  guestsLabel,
  checkoutHref,
  canBook,
  hasCheckoutUrl,
}: ReservationSummaryProps) {
  const t = getDictionary(locale);
  const [promoOpen, setPromoOpen] = useState(false);
  const [promoDraft, setPromoDraft] = useState(promoCode);

  useEffect(() => {
    setPromoDraft(promoCode);
  }, [promoCode]);

  const statusMessage = useMemo(() => {
    if (availabilityError) {
      return availabilityError;
    }
    if (quoteError) {
      return quoteError;
    }
    if (availability && !availability.available) {
      return t.booking.unavailable;
    }
    return "";
  }, [availability, availabilityError, quoteError, t.booking.unavailable]);

  const showBreakdown = Boolean(quote && quote.sections.length);
  const showPlaceholder =
    !quote && !statusMessage && !availabilityLoading && !quoteLoading;
  const paymentLabel = quote?.payments?.length
    ? `(${formatCountLabel(quote.payments.length, t.booking.paymentsLabel)})`
    : "";
  const nightsLabel = nights > 0 ? `${nights} ${t.booking.nights}` : t.booking.selectDates;
  const arrivalValue = arrivalLabel || t.booking.selectDate;
  const departureValue = departureLabel || t.booking.selectDate;

  return (
    <div className="space-y-6 rounded-3xl border border-border/60 bg-white/95 p-6 shadow-sm">
      <div className="space-y-2">
        <h2 className="text-lg font-semibold text-foreground">
          {t.booking.reservationSummary}
        </h2>
        {availabilityLoading || quoteLoading ? (
          <p className="text-xs text-muted-foreground">{t.booking.summaryLoading}</p>
        ) : null}
        {statusMessage ? (
          <p className="text-sm text-rose-600">{statusMessage}</p>
        ) : null}
      </div>

      <div className="flex items-center gap-4 rounded-2xl border border-border/60 bg-background/80 p-4">
          <div className="relative h-16 w-20 overflow-hidden rounded-xl">
            <Image
              src={rentalImage.src}
              sizes="80px"
              alt={rentalTitle}
              fill
              className="object-cover"
            />
          </div>
        <div className="space-y-1">
          <div className="text-sm font-semibold text-foreground">{rentalTitle}</div>
          <a
            href={detailsHref}
            className="text-xs font-semibold text-primary hover:underline"
          >
            {t.booking.moreDetails}
          </a>
        </div>
      </div>

      <div className="rounded-2xl border border-border/60 bg-background/80 p-4">
        <div className="grid gap-3 text-sm">
          {[
            { label: t.booking.checkInDate, value: arrivalValue },
            { label: t.booking.checkOutDate, value: departureValue },
            { label: t.booking.nights, value: nightsLabel },
            { label: t.booking.numberOfGuests, value: guestsLabel },
          ].map((item) => (
            <div key={item.label} className="flex items-center justify-between">
              <span className="text-muted-foreground">{item.label}</span>
              <span className="font-semibold text-foreground">{item.value}</span>
            </div>
          ))}
        </div>
      </div>

      {promoFeatureFlag ? (
        <div className="rounded-2xl border border-dashed border-border/70 p-4">
          {promoOpen ? (
            <div className="space-y-3">
              <div className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                {t.booking.addPromoCode}
              </div>
              <div className="flex flex-col gap-2 sm:flex-row">
                <input
                  type="text"
                  value={promoDraft}
                  onChange={(event) => setPromoDraft(event.target.value)}
                  className="w-full rounded-full border border-border/60 bg-background px-4 py-2 text-sm text-foreground"
                  placeholder="PROMO"
                />
                <Button
                  type="button"
                  onClick={() => onPromoApply(promoDraft.trim())}
                  className="w-full sm:w-auto"
                >
                  {t.booking.applyPromo}
                </Button>
              </div>
            </div>
          ) : (
            <button
              type="button"
              onClick={() => setPromoOpen(true)}
              className="text-sm font-semibold text-foreground hover:text-primary"
            >
              {t.booking.addPromoCode}
            </button>
          )}
        </div>
      ) : null}

      <div className="space-y-4">
        {showBreakdown ? (
          quote?.sections.map((section) => (
            <div key={section.title} className="space-y-2">
              <div className="text-sm font-semibold text-foreground">
                {section.title}
              </div>
              <div className="space-y-2">
                {section.lines.map((line, index) => (
                  <div
                    key={`${line.label}-${index}`}
                    className="flex items-start justify-between gap-4"
                  >
                    <div>
                      <div className="text-sm text-foreground">{line.label}</div>
                      {line.meta ? (
                        <div className="text-xs text-muted-foreground">{line.meta}</div>
                      ) : null}
                    </div>
                    <div
                      className={cn(
                        "text-sm",
                        line.amount.amount < 0 ? "text-rose-600" : "text-foreground",
                      )}
                    >
                      {line.amount.formatted}
                    </div>
                  </div>
                ))}
                {section.subtotal && section.lines.length > 1 ? (
                  <div className="flex items-center justify-between border-t border-border/40 pt-2 text-sm font-semibold text-foreground">
                    <span>{t.booking.total}</span>
                    <span>{section.subtotal.formatted}</span>
                  </div>
                ) : null}
              </div>
            </div>
          ))
        ) : showPlaceholder ? (
          <div className="rounded-2xl border border-border/60 bg-background/70 p-4 text-sm text-muted-foreground">
            {t.booking.priceHint}
          </div>
        ) : null}

        {quote ? (
          <div className="space-y-2 border-t border-border/50 pt-4">
            <div className="flex items-center justify-between text-base font-semibold text-foreground">
              <span>{t.booking.total}</span>
              <span>{quote.total.formatted}</span>
            </div>
            {quote.taxesIncluded ? (
              <div className="text-xs text-muted-foreground">{t.booking.taxesIncluded}</div>
            ) : null}
          </div>
        ) : null}
      </div>

      {quote?.payments?.length ? (
        <div className="space-y-3">
          <div className="flex items-center justify-between text-sm font-semibold text-foreground">
            <span>{t.booking.paymentSchedule}</span>
            <span className="text-xs text-muted-foreground">{paymentLabel}</span>
          </div>
          <div className="space-y-2">
            {quote.payments.map((payment) => (
              <div
                key={`${payment.label}-${payment.amount.amount}-${payment.dueDate ?? payment.dueLabel}`}
                className="flex items-start justify-between"
              >
                <div>
                  <div className="text-sm text-foreground">{payment.label}</div>
                  <div className="text-xs text-muted-foreground">{payment.dueLabel}</div>
                </div>
                <div className="text-sm font-semibold text-foreground">
                  {payment.amount.formatted}
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : null}

      <div className="space-y-3 border-t border-border/50 pt-4">
        {!hasCheckoutUrl ? (
          <div className="rounded-xl border border-border/60 bg-accent/40 px-3 py-3 text-sm text-foreground">
            {t.booking.missingCheckout}
          </div>
        ) : null}
        <BookButton href={checkoutHref || "#"} disabled={!canBook} label={t.cta.bookNow} />
        <p className="text-center text-xs text-muted-foreground">{t.booking.note}</p>
      </div>
    </div>
  );
}
