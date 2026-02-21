"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { differenceInCalendarDays, format, isValid, parseISO } from "date-fns";

import { DateRangeModal } from "@/components/booking/DateRangeModal";
import { GuestsField } from "@/components/booking/GuestsField";
import { GuestsModal } from "@/components/booking/GuestsModal";
import { LodgifyErrorBanner } from "@/components/booking/LodgifyErrorBanner";
import { ReservationSummary } from "@/components/booking/ReservationSummary";
import type { DateRange as BookingDateRange, Guests } from "@/lib/booking/types";
import { useBookingState } from "@/lib/booking/useBookingState";
import { getDateFnsLocale, getDictionary, type Locale } from "@/lib/i18n";
import type { ResponsiveImage } from "@/lib/responsive-images";

function formatDateLabel(value: string | null, locale: Locale) {
  if (!value) {
    return "";
  }
  const parsed = parseISO(value);
  if (!isValid(parsed)) {
    return value;
  }
  return format(parsed, "PPP", { locale: getDateFnsLocale(locale) });
}

function formatGuestsLabel(
  count: number,
  labels: { one: string; other: string },
) {
  return `${count} ${count === 1 ? labels.one : labels.other}`;
}

function buildCheckoutUrl(
  baseUrl: string,
  range: BookingDateRange,
  guests: Guests,
  currency: string,
) {
  if (!baseUrl) {
    return "";
  }
  if (!range.arrival || !range.departure) {
    return baseUrl;
  }

  try {
    const url = new URL(baseUrl);
    url.searchParams.set("arrival", range.arrival);
    url.searchParams.set("departure", range.departure);
    url.searchParams.set("adults", String(guests.adults));
    if (guests.children) {
      url.searchParams.set("children", String(guests.children));
    }
    if (guests.pets) {
      url.searchParams.set("pets", String(guests.pets));
    }
    if (currency) {
      url.searchParams.set("currency", currency);
    }
    return url.toString();
  } catch {
    return baseUrl;
  }
}

type BookingPageProps = {
  locale: Locale;
  rentalTitle: string;
  rentalImage: ResponsiveImage;
  detailsHref: string;
  currencyFallback: string;
  checkoutUrl: string;
};

export function BookingPage({
  locale,
  rentalTitle,
  rentalImage,
  detailsHref,
  currencyFallback,
  checkoutUrl,
}: BookingPageProps) {
  const t = getDictionary(locale);
  const [guestsOpen, setGuestsOpen] = useState(false);
  const [calendarError, setCalendarError] = useState(false);
  const guestsRef = useRef<HTMLDivElement | null>(null);

  const {
    range,
    guests,
    promoCode,
    availability,
    quote,
    availabilityLoading,
    quoteLoading,
    availabilityError,
    quoteError,
    quoteErrorReason,
    blockedDates,
    setRange,
    setGuests,
    setPromoCode,
  } = useBookingState({
    locale,
    rentalTitle,
    rentalImage,
    currencyFallback,
  });

  const checkInLabel = useMemo(
    () => formatDateLabel(range.arrival, locale),
    [locale, range.arrival],
  );
  const checkOutLabel = useMemo(
    () => formatDateLabel(range.departure, locale),
    [locale, range.departure],
  );

  const guestsLabel = useMemo(() => {
    const adultsLabel = formatGuestsLabel(guests.adults, t.lodgify.adultsLabel);
    const parts = [adultsLabel];
    if (guests.children > 0) {
      parts.push(formatGuestsLabel(guests.children, t.lodgify.childrenLabel));
    }
    return parts.join(" + ");
  }, [guests.adults, guests.children, t.lodgify.adultsLabel, t.lodgify.childrenLabel]);
  const hasLodgifyError = Boolean(
    availabilityError ||
      calendarError ||
      (quoteError && quoteErrorReason !== "unavailable"),
  );
  const hasSelection = Boolean(range.arrival && range.departure);
  const hasCheckoutUrl = Boolean(checkoutUrl);

  const nights = useMemo(() => {
    if (!range.arrival || !range.departure) {
      return 0;
    }
    const arrivalDate = parseISO(range.arrival);
    const departureDate = parseISO(range.departure);
    if (!isValid(arrivalDate) || !isValid(departureDate)) {
      return 0;
    }
    return Math.max(0, differenceInCalendarDays(departureDate, arrivalDate));
  }, [range.arrival, range.departure]);

  const checkoutHref = useMemo(
    () =>
      buildCheckoutUrl(checkoutUrl, range, guests, currencyFallback),
    [
      checkoutUrl,
      currencyFallback,
      guests.adults,
      guests.children,
      guests.pets,
      range.arrival,
      range.departure,
    ],
  );

  const canBook = Boolean(
    hasCheckoutUrl &&
      hasSelection &&
      availability?.available &&
      !availabilityLoading &&
      !availabilityError &&
      !calendarError &&
      guests.adults >= 1,
  );

  useEffect(() => {
    if (!guestsOpen) {
      return;
    }

    const handleClick = (event: MouseEvent) => {
      const target = event.target as Node | null;
      if (target && guestsRef.current?.contains(target)) {
        return;
      }
      setGuestsOpen(false);
    };

    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, [guestsOpen]);

  return (
    <>
      <LodgifyErrorBanner
        message={hasLodgifyError ? t.booking.connectionError : null}
      />
      <div className="grid gap-10 lg:grid-cols-[1fr_420px]">
        <div className="space-y-6">
          <div className="space-y-2">
            <h1 className="text-2xl font-semibold text-foreground">
              {t.booking.selectYourDates}
            </h1>
            <p className="text-sm text-muted-foreground">
              {t.booking.subtitle}
            </p>
          </div>
          <div className="space-y-5 rounded-3xl border border-border/60 bg-white/95 p-6 shadow-sm w-full max-w-[min(760px,100%)]">
            <div className="grid gap-3 sm:grid-cols-2">
              <div className="rounded-2xl border border-border/60 bg-background/90 p-3">
                <div className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                  {t.booking.checkInDate}
                </div>
                <div className="mt-1 text-sm font-semibold text-foreground">
                  {checkInLabel || t.booking.selectCheckInDate}
                </div>
              </div>
              <div className="rounded-2xl border border-border/60 bg-background/90 p-3">
                <div className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                  {t.booking.checkOutDate}
                </div>
                <div className="mt-1 text-sm font-semibold text-foreground">
                  {checkOutLabel || t.booking.selectCheckOutDate}
                </div>
              </div>
            </div>
            <DateRangeModal
              locale={locale}
              open
              value={range}
              onOpenChange={() => undefined}
              onConfirm={setRange}
              onErrorChange={setCalendarError}
              blockedDates={blockedDates}
              variant="inline"
            />
            <div ref={guestsRef} className="relative">
              <GuestsField
                label={t.booking.numberOfGuests}
                value={guestsLabel}
                onClick={() => {
                  setGuestsOpen((prev) => !prev);
                }}
              />
              <GuestsModal
                locale={locale}
                open={guestsOpen}
                value={guests}
                onOpenChange={setGuestsOpen}
                onConfirm={setGuests}
              />
            </div>
          </div>
        </div>
        <div className="lg:sticky lg:top-24">
          <ReservationSummary
            locale={locale}
            rentalTitle={rentalTitle}
            rentalImage={rentalImage}
            detailsHref={detailsHref}
            availability={availability}
            availabilityLoading={availabilityLoading}
            availabilityError={availabilityError}
            quote={quote}
            quoteLoading={quoteLoading}
            quoteError={quoteError}
            promoCode={promoCode}
            onPromoApply={setPromoCode}
            arrivalLabel={checkInLabel}
            departureLabel={checkOutLabel}
            nights={nights}
            guestsLabel={guestsLabel}
            checkoutHref={checkoutHref}
            canBook={canBook}
            hasCheckoutUrl={hasCheckoutUrl}
          />
        </div>
      </div>
    </>
  );
}
