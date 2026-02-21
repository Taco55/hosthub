"use client";

import { useEffect, useMemo, useState } from "react";
import type { DateRange } from "react-day-picker";
import { format, isValid, parseISO, startOfDay } from "date-fns";

import { LodgifyErrorBanner } from "@/components/booking/LodgifyErrorBanner";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { getDateFnsLocale, getDictionary, type Locale } from "@/lib/i18n";

type AvailabilityRange = {
  start: string;
  end: string;
};

type BookingFormProps = {
  locale: Locale;
  checkoutUrl: string;
  currency?: string;
};

const guestOptions = Array.from({ length: 9 }, (_, index) => index + 1);

function parseDate(value: string) {
  const parsed = parseISO(value);
  return isValid(parsed) ? parsed : null;
}

function isRangeAvailable(range: DateRange, disabled: DateRange[]) {
  const rangeFrom = range.from;
  const rangeTo = range.to;

  if (!rangeFrom || !rangeTo) {
    return true;
  }

  return !disabled.some((blocked) => {
    if (!blocked.from || !blocked.to) {
      return false;
    }
    return !(rangeTo < blocked.from || rangeFrom > blocked.to);
  });
}

function buildCheckoutUrl(
  baseUrl: string,
  range: DateRange | undefined,
  adults: number,
  currency: string,
) {
  if (!baseUrl || !range?.from || !range?.to) {
    return "";
  }

  try {
    const url = new URL(baseUrl);
    url.searchParams.set("arrival", format(range.from, "yyyy-MM-dd"));
    url.searchParams.set("departure", format(range.to, "yyyy-MM-dd"));
    url.searchParams.set("adults", String(adults));
    if (currency) {
      url.searchParams.set("currency", currency);
    }
    return url.toString();
  } catch {
    return baseUrl;
  }
}

export function BookingForm({ locale, checkoutUrl, currency = "NOK" }: BookingFormProps) {
  const t = getDictionary(locale);
  const dateLocale = getDateFnsLocale(locale);
  const [range, setRange] = useState<DateRange | undefined>();
  const [adults, setAdults] = useState<number>(2);
  const [blocked, setBlocked] = useState<AvailabilityRange[]>([]);
  const [status, setStatus] = useState<"idle" | "loading" | "error">("loading");

  useEffect(() => {
    let active = true;

    async function loadAvailability() {
      try {
        setStatus("loading");
        const response = await fetch("/api/availability");
        if (!response.ok) {
          throw new Error("Failed to load availability");
        }
        const data = (await response.json()) as { ranges?: AvailabilityRange[] };
        if (active) {
          setBlocked(data.ranges ?? []);
          setStatus("idle");
        }
      } catch {
        if (active) {
          setStatus("error");
        }
      }
    }

    loadAvailability();
    return () => {
      active = false;
    };
  }, []);

  const disabledRanges = useMemo<DateRange[]>(() => {
    return blocked.flatMap((range) => {
      const from = parseDate(range.start);
      const to = parseDate(range.end);
      if (!from || !to) {
        return [];
      }
      return [{ from, to }];
    });
  }, [blocked]);

  const today = useMemo(() => startOfDay(new Date()), []);
  const disabledMatchers = useMemo(
    () => [{ before: today }, ...disabledRanges],
    [disabledRanges, today],
  );

  const isAvailable = range?.from && range?.to ? isRangeAvailable(range, disabledRanges) : false;
  const canSubmit = Boolean(
    checkoutUrl && range?.from && range?.to && status === "idle" && isAvailable,
  );

  const statusMessage = useMemo(() => {
    if (status === "loading") {
      return t.booking.loading;
    }
    if (status === "error") {
      return t.booking.error;
    }
    if (range?.from && range?.to) {
      return isAvailable ? t.booking.available : t.booking.unavailable;
    }
    return t.booking.rangeHint;
  }, [isAvailable, range, status, t.booking]);

  const rangeLabel =
    range?.from && range?.to
      ? `${format(range.from, "PPP", { locale: dateLocale })} - ${format(range.to, "PPP", {
          locale: dateLocale,
        })}`
      : t.booking.selectDates;

  const bookHref = useMemo(
    () => buildCheckoutUrl(checkoutUrl, range, adults, currency),
    [checkoutUrl, range, adults, currency],
  );

  return (
    <>
      <LodgifyErrorBanner
        message={status === "error" ? t.booking.connectionError : null}
      />
      <Card className="bg-background/80">
      <CardHeader>
        <CardTitle>{t.booking.title}</CardTitle>
        <CardDescription>{t.booking.subtitle}</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="grid gap-6 lg:grid-cols-[minmax(0,1.2fr)_minmax(0,0.8fr)]">
          <div className="rounded-2xl border border-border/60 bg-background/80">
            <Calendar
              mode="range"
              selected={range}
              onSelect={setRange}
              disabled={disabledMatchers}
              numberOfMonths={2}
              locale={dateLocale}
            />
          </div>
          <div className="space-y-5">
            <div className="space-y-2">
              <label
                htmlFor="adult-count"
                className="text-xs font-semibold uppercase tracking-wide text-muted-foreground"
              >
                {t.labels.guests}
              </label>
              <select
                id="adult-count"
                name="adults"
                value={adults}
                onChange={(event) => setAdults(Number(event.target.value))}
                className="w-full rounded-xl border border-border/60 bg-background/80 px-3 py-2 text-sm text-foreground"
              >
                {guestOptions.map((count) => (
                  <option key={count} value={count}>
                    {count}
                  </option>
                ))}
              </select>
            </div>
            <div className="rounded-2xl border border-border/60 bg-background/80 p-4">
              <div className="text-xs uppercase tracking-wide text-muted-foreground">
                {t.booking.selectDates}
              </div>
              <div className="mt-2 text-sm font-semibold text-foreground">{rangeLabel}</div>
              <div
                className={cn(
                  "mt-2 text-sm",
                  statusMessage === t.booking.available && "text-emerald-600",
                  statusMessage === t.booking.unavailable && "text-rose-600",
                )}
              >
                {statusMessage}
              </div>
            </div>
            {!checkoutUrl ? (
              <div className="rounded-2xl border border-border/60 bg-accent/40 p-4 text-sm text-foreground">
                {t.booking.missingCheckout}
              </div>
            ) : null}
          </div>
        </div>
      </CardContent>
      <CardFooter className="flex flex-col gap-3">
        <Button asChild className="w-full" disabled={!canSubmit}>
          <a href={bookHref || "#"} target="_blank" rel="noreferrer">
            {t.cta.bookNow}
          </a>
        </Button>
        <p className="text-center text-xs text-muted-foreground">{t.booking.note}</p>
      </CardFooter>
      </Card>
    </>
  );
}
