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
  const [availabilityStatus, setAvailabilityStatus] = useState<AvailabilityStatus>("idle");
  const [quoteStatus, setQuoteStatus] = useState<QuoteStatus>("idle");
  const [quote, setQuote] = useState<QuoteResponse | null>(null);
  const [calendarError, setCalendarError] = useState(false);

  const start = range?.from ? format(range.from, "yyyy-MM-dd") : "";
  const end = range?.to ? format(range.to, "yyyy-MM-dd") : "";
  const rangeKey = start && end ? `${start}|${end}` : "";
  const hasSelection = Boolean(start && end);

  const checkoutHref =
    checkoutUrl ??
    process.env.NEXT_PUBLIC_LODGIFY_CHECKOUT_URL ??
    "https://checkout.lodgify.com/fagerasen701/706211/reservation?currency=NOK&adults=1";
  const currencyFallback =
    currency ?? process.env.NEXT_PUBLIC_LODGIFY_CURRENCY ?? "NOK";

  useEffect(() => {
    if (!rangeKey) {
      setAvailabilityStatus("idle");
      setQuoteStatus("idle");
      setQuote(null);
      return;
    }

    const controller = new AbortController();
    let active = true;

    setAvailabilityStatus("loading");
    setQuoteStatus("idle");
    setQuote(null);

    fetchAvailability({ start, end }, { signal: controller.signal })
      .then((data) => {
        if (!active) {
          return;
        }
        const isAvailable = data.available;
        setAvailabilityStatus(isAvailable ? "available" : "unavailable");
        if (!isAvailable) {
          setQuoteStatus("idle");
          setQuote(null);
        }
      })
      .catch(() => {
        if (!active || controller.signal.aborted) {
          return;
        }
        setAvailabilityStatus("error");
        setQuoteStatus("error");
        setQuote(null);
      });

    return () => {
      active = false;
      controller.abort();
    };
  }, [end, rangeKey, start]);

  useEffect(() => {
    if (!rangeKey) {
      return;
    }
    if (availabilityStatus !== "available") {
      if (availabilityStatus !== "loading") {
        setQuoteStatus("idle");
        setQuote(null);
      }
      return;
    }

    const controller = new AbortController();
    let active = true;

    setQuoteStatus("loading");
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
        setQuote(data);
        setQuoteStatus("ready");
      })
      .catch(() => {
        if (!active || controller.signal.aborted) {
          return;
        }
        setQuoteStatus("error");
        setQuote(null);
      });

    return () => {
      active = false;
      controller.abort();
    };
  }, [
    availabilityStatus,
    end,
    guests.adults,
    guests.children,
    guests.pets,
    rangeKey,
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
