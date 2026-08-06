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

/**
 * The availability question a quote key was asked under: the two dates it
 * starts with. A quote refusal answers for those dates, not for the guest count
 * that happened to be set when it was asked.
 */
function availabilityKeyOfQuoteKey(quoteKey: string) {
  const [arrival, departure] = quoteKey.split("|");
  return `${arrival}|${departure}`;
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
  // Every answer carries the request it answers. "Loading" is then a question
  // this hook can answer by looking — asked, and no answer for *these* dates
  // yet — instead of a flag an effect has to raise on the way out and lower on
  // the way back, which is what made a stale price outlive the dates it was
  // for.
  const [availabilityAnswer, setAvailabilityAnswer] = useState<{
    key: string;
    available: boolean;
    unavailableDates: string[];
  } | null>(null);
  const [availabilityFailure, setAvailabilityFailure] = useState<{
    key: string;
    message: string;
  } | null>(null);
  const [quoteAnswer, setQuoteAnswer] = useState<{
    key: string;
    view: QuoteView;
  } | null>(null);
  const [quoteFailure, setQuoteFailure] = useState<{
    key: string;
    message: string;
    reason: string | null;
  } | null>(null);
  const [blockedDates, setBlockedDates] = useState<string[]>([]);

  /** Identifies one availability question: the dates, and nothing else. */
  const availabilityKey =
    range.arrival && range.departure ? `${range.arrival}|${range.departure}` : null;

  // An answer counts only for the question that is on screen now.
  const availability =
    availabilityAnswer && availabilityAnswer.key === availabilityKey
      ? {
          available: availabilityAnswer.available,
          unavailableDates: availabilityAnswer.unavailableDates,
        }
      : null;
  const availabilityError =
    availabilityFailure && availabilityFailure.key === availabilityKey
      ? availabilityFailure.message
      : null;
  const availabilityLoading =
    availabilityKey !== null && availability === null && availabilityError === null;

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

  /**
   * Identifies one quote question. Wider than the availability key: guests and
   * a promo code change the price for the same dates, so an answer to the old
   * combination must not be shown for the new one.
   */
  const quoteKey =
    availabilityKey && availability?.available
      ? `${availabilityKey}|${guests.adults}|${guests.children}|${guests.pets}|${promoCode.trim()}`
      : null;
  const quote = quoteAnswer && quoteAnswer.key === quoteKey ? quoteAnswer.view : null;
  const quoteFailureNow =
    quoteFailure && quoteFailure.key === quoteKey ? quoteFailure : null;
  const quoteLoading = quoteKey !== null && quote === null && quoteFailureNow === null;

  useEffect(() => {
    // Nothing to ask without both ends of the range — and nothing to clear
    // either, because every answer below is stamped with the dates it answers
    // for. The effect writes state only once a reply is in.
    if (!availabilityKey || !range.arrival || !range.departure) return;

    availabilityAbortRef.current?.abort();
    const controller = new AbortController();
    availabilityAbortRef.current = controller;
    const key = availabilityKey;

    fetchAvailability(
      { start: range.arrival, end: range.departure },
      { signal: controller.signal },
    )
      .then((data) => {
        if (controller.signal.aborted) {
          return;
        }
        setAvailabilityAnswer({
          key,
          available: data.available,
          unavailableDates: data.unavailable,
        });
      })
      .catch(() => {
        if (controller.signal.aborted) {
          return;
        }
        setAvailabilityFailure({ key, message: t.booking.error });
      });

    return () => controller.abort();
  }, [availabilityKey, range.arrival, range.departure, t.booking.error]);

  useEffect(() => {
    // Same again: dates that are not available have no price to ask for, and a
    // reply that is still in flight is described by `quoteLoading` above rather
    // than raised here.
    if (!quoteKey || !range.arrival || !range.departure) {
      return;
    }

    if (quoteTimeoutRef.current) {
      clearTimeout(quoteTimeoutRef.current);
    }

    quoteAbortRef.current?.abort();
    const controller = new AbortController();
    quoteAbortRef.current = controller;
    const key = quoteKey;

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

          setQuoteAnswer({
            key,
            view: {
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
            },
          });
        })
        .catch((error) => {
          if (controller.signal.aborted) {
            return;
          }
          const reason = getQuoteErrorReason(error);
          const message = getQuoteErrorMessage(error, t.booking.priceError);
          setQuoteFailure({ key, message, reason });

          // Lodgify can refuse a quote for dates its own availability call just
          // called free. That refusal is the more specific answer, so it
          // overwrites the availability one for the same dates.
          if (reason === "unavailable" && arrivalDate && departureDate) {
            const blockedRange = buildDateKeys(arrivalDate, departureDate);
            if (blockedRange.length) {
              setBlockedDates((prev) => mergeUniqueDates(prev, blockedRange));
            }
            setAvailabilityAnswer((prev) => ({
              key: availabilityKeyOfQuoteKey(key),
              available: false,
              unavailableDates: mergeUniqueDates(
                prev?.unavailableDates ?? [],
                blockedRange,
              ),
            }));
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
    availabilityKey,
    currencyFallback,
    dateLocale,
    departureDate,
    guests.adults,
    guests.children,
    guests.pets,
    locale,
    nights,
    promoCode,
    quoteKey,
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
    quoteError: quoteFailureNow?.message ?? null,
    quoteErrorReason: quoteFailureNow?.reason ?? null,
    blockedDates,
    setRange,
    setGuests,
    setPromoCode,
  };
}
