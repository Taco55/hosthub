"use client";

import { BookingWidget } from "@/components/booking/BookingWidget";
import type { Locale } from "@/lib/i18n";

type BookingCardProps = {
  locale: Locale;
  bookingUrl?: string;
};

export function BookingCard({ locale, bookingUrl }: BookingCardProps) {
  const checkoutUrl =
    bookingUrl ?? process.env.NEXT_PUBLIC_LODGIFY_CHECKOUT_URL ?? "";
  const currency = process.env.NEXT_PUBLIC_LODGIFY_CURRENCY ?? "NOK";

  return <BookingWidget locale={locale} checkoutUrl={checkoutUrl} currency={currency} />;
}
