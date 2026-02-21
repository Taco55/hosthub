"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { addDays, differenceInCalendarDays, format, isValid, parseISO } from "date-fns";

import type { DateRange, Guests, Money, QuoteLine, QuoteSection, QuoteView } from "@/lib/booking/types";
import { fetchAvailability, fetchQuote, LodgifyApiError, type QuoteLineItem } from "@/lib/lodgify/api";
import { getDateFnsLocale, getDictionary, type Locale } from "@/lib/i18n";
import type { ResponsiveImage } from "@/lib/responsive-images";

const quoteDebounceMs = 300;

function parseDate(value: string | null) {
  if (!value) {
    return null;
  }
  const parsed = parseISO(value);
  return isValid(parsed) ? parsed : null;
}

function formatMoney(amount: number, currency: string, locale: Locale): Money {
  const parsed = typeof amount === "number" ? amount : Number(amount);
  if (!Number.isFinite(parsed)) {
    return { amount: 0, currency, formatted: "" };
  }

  try {
    const formatted = new Intl.NumberFormat(locale, {
      style: "currency",
      currency,
      maximumFractionDigits: 0,
    }).format(parsed);
    return { amount: parsed, currency, formatted };
  } catch {
    return { amount: parsed, currency, formatted: `${currency} ${parsed.toFixed(0)}` };
  }
}

function normalizeFeeLabel(label: string, locale: Locale) {
  const t = getDictionary(locale);
  const normalized = label.toLowerCase();
  if (normalized.includes("clean")) {
    return t.booking.cleaningFee;
  }
  if (normalized.includes("linen") || normalized.includes("linens") || normalized.includes("towel")) {
    return t.booking.linens;
  }
  return label;
}

function buildQuoteSections(params: {
  locale: Locale;
  currency: string;
  nights: number;
  rentalAmount: number | null;
  nightlyRate: number | null;
  discounts: QuoteLineItem[];
  fees: QuoteLineItem[];
}): QuoteSection[] {
  const { locale, currency, nights, rentalAmount, nightlyRate, discounts, fees } = params;
  const t = getDictionary(locale);
  const sections: QuoteSection[] = [];

  if (rentalAmount && rentalAmount > 0 && nights > 0) {
    const lineMeta = nightlyRate
      ? `${formatMoney(nightlyRate, currency, locale).formatted} x ${nights} ${t.booking.nights}`
      : `${nights} ${t.booking.nights}`;
    const line: QuoteLine = {
      label: t.booking.rental,
      amount: formatMoney(rentalAmount, currency, locale),
      meta: lineMeta,
    };
    sections.push({
      title: t.booking.rental,
      lines: [line],
      subtotal: formatMoney(rentalAmount, currency, locale),
    });
  }

  if (discounts.length) {
    sections.push({
      title: t.booking.discounts,
      lines: discounts.map((line) => ({
        label: line.label,
        amount: formatMoney(line.amount, currency, locale),
      })),
    });
  }

  if (fees.length) {
    sections.push({
      title: t.booking.fees,
      lines: fees.map((line) => ({
        label: normalizeFeeLabel(line.label, locale),
        amount: formatMoney(line.amount, currency, locale),
      })),
    });
  }

  return sections;
}

function buildDateKeys(start: Date, end: Date) {
  const keys: string[] = [];
  let cursor = new Date(start);
  while (cursor < end) {
    keys.push(format(cursor, "yyyy-MM-dd"));
    cursor = addDays(cursor, 1);
  }
  return keys;
}

function mergeUniqueDates(prev: string[], next: string[]) {
  if (!next.length) {
    return prev;
  }
  const set = new Set(prev);
  for (const date of next) {
    set.add(date);
  }
  return Array.from(set).sort((a, b) => a.localeCompare(b));
}

function getQuoteErrorReason(error: unknown) {
  if (!(error instanceof LodgifyApiError)) {
    return null;
  }
  if (!error.details || typeof error.details !== "object") {
    return null;
  }
  const record = error.details as Record<string, unknown>;
  return typeof record.reason === "string" ? record.reason : null;
}

function getQuoteErrorMessage(error: unknown, fallback: string) {
  if (!(error instanceof LodgifyApiError)) {
    return fallback;
  }
  const message = error.message;
  if (!message || message === "Request failed" || message === "Failed to fetch quote") {
    return fallback;
  }
  return message;
}

export type BookingState = {
  range: DateRange;
  guests: Guests;
  promoCode: string;
  availability: { available: boolean; unavailableDates: string[] } | null;
  quote: QuoteView | null;
  availabilityLoading: boolean;
  quoteLoading: boolean;
  availabilityError: string | null;
  quoteError: string | null;
  quoteErrorReason: string | null;
  blockedDates: string[];
  setRange: (range: DateRange) => void;
  setGuests: (guests: Guests) => void;
  setPromoCode: (promoCode: string) => void;
};

export function useBookingState(params: {
  locale: Locale;
  rentalTitle: string;
  rentalImage: ResponsiveImage;
  currencyFallback: string;
}): BookingState {
  const { locale, rentalTitle, rentalImage, currencyFallback } = params;
  const t = getDictionary(locale);
  const dateLocale = getDateFnsLocale(locale);

  const [range, setRange] = useState<DateRange>({ arrival: null, departure: null });
  const [guests, setGuests] = useState<Guests>({ adults: 2, children: 0, pets: 0 });
  const [promoCode, setPromoCode] = useState("");
  const [availability, setAvailability] = useState<{
    available: boolean;
    unavailableDates: string[];
  } | null>(null);
  const [quote, setQuote] = useState<QuoteView | null>(null);
  const [availabilityLoading, setAvailabilityLoading] = useState(false);
  const [quoteLoading, setQuoteLoading] = useState(false);
  const [availabilityError, setAvailabilityError] = useState<string | null>(null);
  const [quoteError, setQuoteError] = useState<string | null>(null);
  const [quoteErrorReason, setQuoteErrorReason] = useState<string | null>(null);
  const [blockedDates, setBlockedDates] = useState<string[]>([]);

  const availabilityAbortRef = useRef<AbortController | null>(null);
  const quoteAbortRef = useRef<AbortController | null>(null);
  const quoteTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const arrivalDate = useMemo(() => parseDate(range.arrival), [range.arrival]);
  const departureDate = useMemo(() => parseDate(range.departure), [range.departure]);
  const nights = useMemo(() => {
    if (!arrivalDate || !departureDate) {
      return 0;
    }
    return Math.max(0, differenceInCalendarDays(departureDate, arrivalDate));
  }, [arrivalDate, departureDate]);

  useEffect(() => {
    if (!range.arrival || !range.departure) {
      setAvailability(null);
      setAvailabilityLoading(false);
      setAvailabilityError(null);
      setQuote(null);
      setQuoteLoading(false);
      setQuoteError(null);
      setQuoteErrorReason(null);
      return;
    }

    availabilityAbortRef.current?.abort();
    const controller = new AbortController();
    availabilityAbortRef.current = controller;

    setAvailabilityLoading(true);
    setAvailabilityError(null);
    setAvailability(null);
    setQuote(null);
    setQuoteLoading(false);
    setQuoteError(null);

    fetchAvailability(
      { start: range.arrival, end: range.departure },
      { signal: controller.signal },
    )
      .then((data) => {
        if (controller.signal.aborted) {
          return;
        }
        setAvailability({ available: data.available, unavailableDates: data.unavailable });
        setAvailabilityLoading(false);
      })
      .catch(() => {
        if (controller.signal.aborted) {
          return;
        }
        setAvailabilityLoading(false);
        setAvailabilityError(t.booking.error);
      });

    return () => controller.abort();
  }, [range.arrival, range.departure, t.booking.error]);

  useEffect(() => {
    if (!range.arrival || !range.departure || !availability?.available) {
      if (availability && !availability.available) {
        setQuote(null);
        setQuoteLoading(false);
        setQuoteError(null);
        setQuoteErrorReason(null);
      }
      return;
    }

    if (quoteTimeoutRef.current) {
      clearTimeout(quoteTimeoutRef.current);
    }

    quoteAbortRef.current?.abort();
    const controller = new AbortController();
    quoteAbortRef.current = controller;

    setQuoteLoading(true);
    setQuoteError(null);
    setQuoteErrorReason(null);

    quoteTimeoutRef.current = setTimeout(() => {
      fetchQuote(
        {
          arrival: range.arrival ?? "",
          departure: range.departure ?? "",
          adults: guests.adults,
          children: guests.children,
          pets: guests.pets,
          promo: promoCode.trim() || undefined,
        },
        { signal: controller.signal },
      )
        .then((data) => {
          if (controller.signal.aborted) {
            return;
          }
          const currency = data.currency || currencyFallback;
          const arrivalLabel = arrivalDate
            ? format(arrivalDate, "PPP", { locale: dateLocale })
            : range.arrival ?? "";
          const departureLabel = departureDate
            ? format(departureDate, "PPP", { locale: dateLocale })
            : range.departure ?? "";

          const sections = buildQuoteSections({
            locale,
            currency,
            nights: data.nights || nights,
            rentalAmount: data.rental?.amount ?? null,
            nightlyRate: data.rental?.nightlyRate ?? null,
            discounts: data.discounts ?? [],
            fees: data.fees ?? [],
          });

          const paymentItems = (data.payments ?? []).map((payment, index) => {
            const dueDate = payment.dueDate ?? null;
            const dueDateValue = dueDate ? parseDate(dueDate) : null;
            const dueLabel = dueDateValue
              ? `${t.booking.dueOn} ${format(dueDateValue, "PPP", { locale: dateLocale })}`
              : index === 0
                ? t.booking.dueToday
                : t.booking.dueOnAgreement;
            return {
              label: payment.label,
              dueLabel,
              amount: formatMoney(payment.amount, currency, locale),
              dueDate,
            };
          });

          setQuote({
            rentalTitle,
            rentalImageSrc: rentalImage.src,
            arrival: arrivalLabel,
            departure: departureLabel,
            nights: data.nights || nights,
            currency,
            sections,
            total: formatMoney(data.total, currency, locale),
            taxesIncluded: data.taxesIncluded,
            payments: paymentItems,
          });
          setQuoteLoading(false);
        })
        .catch((error) => {
          if (controller.signal.aborted) {
            return;
          }
          setQuote(null);
          setQuoteLoading(false);
          const reason = getQuoteErrorReason(error);
          const message = getQuoteErrorMessage(error, t.booking.priceError);
          setQuoteError(message);
          setQuoteErrorReason(reason);

          if (reason === "unavailable" && arrivalDate && departureDate) {
            const blockedRange = buildDateKeys(arrivalDate, departureDate);
            if (blockedRange.length) {
              setBlockedDates((prev) => mergeUniqueDates(prev, blockedRange));
              setAvailability((prev) => {
                const unavailableDates = mergeUniqueDates(
                  prev?.unavailableDates ?? [],
                  blockedRange,
                );
                return { available: false, unavailableDates };
              });
            } else {
              setAvailability((prev) =>
                prev ? { ...prev, available: false } : { available: false, unavailableDates: [] },
              );
            }
          }
        });
    }, quoteDebounceMs);

    return () => {
      if (quoteTimeoutRef.current) {
        clearTimeout(quoteTimeoutRef.current);
      }
      controller.abort();
    };
  }, [
    arrivalDate,
    availability,
    currencyFallback,
    dateLocale,
    departureDate,
    guests.adults,
    guests.children,
    guests.pets,
    locale,
    nights,
    promoCode,
    range.arrival,
    range.departure,
    rentalImage.src,
    rentalTitle,
    t.booking.dueOn,
    t.booking.dueOnAgreement,
    t.booking.dueToday,
    t.booking.priceError,
  ]);

  return {
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
  };
}
