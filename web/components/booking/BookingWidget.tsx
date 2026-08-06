"use client";

import { useEffect, useMemo, useState } from "react";
import type { DateRange } from "react-day-picker";
import { format } from "date-fns";

import { BookButton } from "@/components/booking/BookButton";
import { LodgifyErrorBanner } from "@/components/booking/LodgifyErrorBanner";
import { DateRangePicker } from "@/components/booking/DateRangePicker";
import { GuestSelector } from "@/components/booking/GuestSelector";
import { PriceSummary } from "@/components/booking/PriceSummary";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { fetchAvailability, fetchQuote, type QuoteResponse } from "@/lib/lodgify/api";
import { getDictionary, type Locale } from "@/lib/i18n";
import { cn } from "@/lib/utils";

type BookingWidgetProps = {
  locale: Locale;
  checkoutUrl?: string;
  currency?: string;
  className?: string;
};

type AvailabilityStatus = "idle" | "loading" | "available" | "unavailable" | "error";

type QuoteStatus = "idle" | "loading" | "ready" | "error";

type GuestCounts = {
  adults: number;
  children: number;
  pets: number;
};

const defaultGuests: GuestCounts = {
  adults: 2,
  children: 0,
  pets: 0,
};

export function BookingWidget({ locale, checkoutUrl, currency, className }: BookingWidgetProps) {
  const t = getDictionary(locale);
  const [range, setRange] = useState<DateRange | undefined>();
  const [guests, setGuests] = useState<GuestCounts>(defaultGuests);
  // Each answer is stamped with the selection it answers for, so "loading" is
  // "asked, nothing back for *this* selection yet" — a thing to look up rather
  // than a flag to raise on the way out and lower on the way back. The flags
  // were what let a price for one set of dates sit under another.
  const [availabilityAnswer, setAvailabilityAnswer] = useState<{
    key: string;
    status: Exclude<AvailabilityStatus, "idle" | "loading">;
  } | null>(null);
  const [quoteAnswer, setQuoteAnswer] = useState<{
    key: string;
    quote: QuoteResponse | null;
    status: Exclude<QuoteStatus, "idle" | "loading">;
  } | null>(null);
  const [calendarError, setCalendarError] = useState(false);

  const start = range?.from ? format(range.from, "yyyy-MM-dd") : "";
  const end = range?.to ? format(range.to, "yyyy-MM-dd") : "";
  const rangeKey = start && end ? `${start}|${end}` : "";
  const hasSelection = Boolean(start && end);

  const checkoutHref =
    checkoutUrl ??
    process.env.NEXT_PUBLIC_LODGIFY_CHECKOUT_URL ??
    "";
  const currencyFallback =
    currency ?? process.env.NEXT_PUBLIC_LODGIFY_CURRENCY ?? "NOK";

  const availabilityStatus: AvailabilityStatus = !rangeKey
    ? "idle"
    : availabilityAnswer?.key === rangeKey
      ? availabilityAnswer.status
      : "loading";

  // Guests change the price for the same dates, so they are part of the
  // question the quote answers.
  const quoteKey =
    rangeKey && availabilityStatus === "available"
      ? `${rangeKey}|${guests.adults}|${guests.children}|${guests.pets}`
      : "";
  const quoteStatus: QuoteStatus = !quoteKey
    ? availabilityStatus === "error"
      ? "error"
      : "idle"
    : quoteAnswer?.key === quoteKey
      ? quoteAnswer.status
      : "loading";
  const quote = quoteAnswer?.key === quoteKey ? quoteAnswer.quote : null;

  useEffect(() => {
    // Nothing to ask without a selection, and nothing to clear: the answers
    // below carry the selection they belong to.
    if (!rangeKey) return;

    const controller = new AbortController();
    let active = true;
    const key = rangeKey;

    fetchAvailability({ start, end }, { signal: controller.signal })
      .then((data) => {
        if (!active) {
          return;
        }
        setAvailabilityAnswer({
          key,
          status: data.available ? "available" : "unavailable",
        });
      })
      .catch(() => {
        if (!active || controller.signal.aborted) {
          return;
        }
        setAvailabilityAnswer({ key, status: "error" });
      });

    return () => {
      active = false;
      controller.abort();
    };
  }, [end, rangeKey, start]);

  useEffect(() => {
    // `quoteKey` is empty unless the dates are known to be available, so this
    // covers both early returns the effect used to make — without writing the
    // state that says so.
    if (!quoteKey) {
      return;
    }

    const controller = new AbortController();
    let active = true;
    const key = quoteKey;

    fetchQuote(
      {
        arrival: start,
        departure: end,
        adults: guests.adults,
        children: guests.children,
        pets: guests.pets,
      },
      { signal: controller.signal },
    )
      .then((data) => {
        if (!active) {
          return;
        }
        setQuoteAnswer({ key, quote: data, status: "ready" });
      })
      .catch(() => {
        if (!active || controller.signal.aborted) {
          return;
        }
        setQuoteAnswer({ key, quote: null, status: "error" });
      });

    return () => {
      active = false;
      controller.abort();
    };
  }, [
    end,
    guests.adults,
    guests.children,
    guests.pets,
    quoteKey,
    start,
  ]);

  const hasBookingUrl = Boolean(checkoutHref);
  const hasLodgifyError =
    availabilityStatus === "error" || quoteStatus === "error" || calendarError;
  const canBook =
    hasBookingUrl &&
    availabilityStatus === "available" &&
    hasSelection &&
    guests.adults >= 1 &&
    !hasLodgifyError;

  const helperText = useMemo(() => {
    if (availabilityStatus === "loading") {
      return t.booking.directBookingHint;
    }
    if (availabilityStatus === "unavailable") {
      return t.booking.unavailable;
    }
    return t.booking.note;
  }, [
    availabilityStatus,
    t.booking.directBookingHint,
    t.booking.note,
    t.booking.unavailable,
  ]);
  const showDirectBookingLink = availabilityStatus === "loading" && hasBookingUrl;

  return (
    <>
      <LodgifyErrorBanner
        message={hasLodgifyError ? t.booking.connectionError : null}
      />
      <Card id="booking" className={cn("bg-white/95", className)}>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg">{t.booking.title}</CardTitle>
          <CardDescription>{t.booking.subtitle}</CardDescription>
        </CardHeader>
        <CardContent className="space-y-5">
          <GuestSelector locale={locale} value={guests} onChange={setGuests} />
          <DateRangePicker
            locale={locale}
            value={range}
            onChange={setRange}
            onErrorChange={setCalendarError}
          />
          <PriceSummary
            locale={locale}
            hasSelection={hasSelection}
            availabilityStatus={availabilityStatus}
            quoteStatus={quoteStatus}
            quote={quote}
            currencyFallback={currencyFallback}
          />
          {!hasBookingUrl ? (
            <div className="rounded-xl border border-border/60 bg-accent/40 px-3 py-3 text-sm text-foreground">
              {t.booking.missingCheckout}
            </div>
          ) : null}
        </CardContent>
        <CardFooter className="flex flex-col items-stretch gap-3">
          <BookButton href={checkoutHref || "#"} disabled={!canBook} label={t.cta.bookNow} />
          <p
            className={cn(
              "text-center text-xs",
              availabilityStatus === "unavailable" ? "text-rose-600" : "text-muted-foreground",
            )}
          >
            {helperText}
          </p>
          {showDirectBookingLink ? (
            <div className="text-center text-xs text-muted-foreground">
              <a
                href={checkoutHref}
                target="_blank"
                rel="noreferrer"
                className="font-semibold text-primary underline"
              >
                {t.booking.directBookingLinkLabel}
              </a>
            </div>
          ) : null}
        </CardFooter>
      </Card>
    </>
  );
}
