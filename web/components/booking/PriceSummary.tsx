"use client";

import { useMemo } from "react";

import type { QuoteResponse } from "@/lib/lodgify/api";
import { getDictionary, type Locale } from "@/lib/i18n";

export type PriceSummaryProps = {
  locale: Locale;
  hasSelection: boolean;
  availabilityStatus: "idle" | "loading" | "available" | "unavailable" | "error";
  quoteStatus: "idle" | "loading" | "ready" | "error";
  quote: QuoteResponse | null;
  currencyFallback: string;
};

function formatCurrency(amount: number, currency: string) {
  const parsed = typeof amount === "number" ? amount : Number(amount);
  if (!Number.isFinite(parsed)) {
    return "";
  }

  if (!currency) {
    return parsed.toFixed(0);
  }

  try {
    return new Intl.NumberFormat(undefined, {
      style: "currency",
      currency,
      maximumFractionDigits: 0,
    }).format(parsed);
  } catch {
    return `${currency} ${parsed.toFixed(0)}`;
  }
}

export function PriceSummary({
  locale,
  hasSelection,
  availabilityStatus,
  quoteStatus,
  quote,
  currencyFallback,
}: PriceSummaryProps) {
  const t = getDictionary(locale);
  const formattedTotal = useMemo(() => {
    if (!quote) {
      return "";
    }
    const currency = quote.currency || currencyFallback;
    return formatCurrency(quote.total, currency);
  }, [currencyFallback, quote]);

  const priceStatus = useMemo(() => {
    if (!hasSelection) {
      return { label: t.booking.priceHint, tone: "muted" } as const;
    }
    if (availabilityStatus === "loading") {
      return { label: t.booking.loading, tone: "muted" } as const;
    }
    if (availabilityStatus === "error") {
      return { label: t.booking.error, tone: "muted" } as const;
    }
    if (availabilityStatus === "unavailable") {
      return { label: t.booking.unavailable, tone: "error" } as const;
    }
    if (quote && formattedTotal) {
      return {
        label: `${t.booking.priceTotalLabel} ${formattedTotal}`,
        tone: "primary",
      } as const;
    }
    if (quoteStatus === "loading") {
      return { label: t.booking.priceLoading, tone: "muted" } as const;
    }
    if (quoteStatus === "error") {
      return { label: t.booking.priceError, tone: "muted" } as const;
    }
    return { label: t.booking.priceHint, tone: "muted" } as const;
  }, [
    availabilityStatus,
    formattedTotal,
    hasSelection,
    quote,
    quoteStatus,
    t.booking.error,
    t.booking.loading,
    t.booking.priceError,
    t.booking.priceHint,
    t.booking.priceLoading,
    t.booking.priceTotalLabel,
    t.booking.unavailable,
  ]);

  return (
    <div className="rounded-xl border border-border/60 bg-background/80 px-3 py-3 text-sm">
      <div className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
        {t.booking.priceLabel}
      </div>
      {priceStatus.tone === "muted" && quoteStatus === "loading" ? (
        <div className="mt-2 h-4 w-32 animate-pulse rounded-full bg-muted/40" />
      ) : (
        <div
          className={
            priceStatus.tone === "error"
              ? "mt-1 text-sm text-rose-600"
              : priceStatus.tone === "primary"
                ? "mt-1 text-base font-semibold text-foreground"
                : "mt-1 text-sm text-muted-foreground"
          }
        >
          {priceStatus.label}
        </div>
      )}
      {quote?.breakdown?.length ? (
        <details className="mt-2 text-xs text-muted-foreground">
          <summary className="cursor-pointer select-none">
            {t.booking.priceBreakdownLabel}
          </summary>
          <div className="mt-2 space-y-1">
            {quote.breakdown.map((line) => (
              <div key={line.label} className="flex items-center justify-between">
                <span>{line.label}</span>
                <span>{formatCurrency(line.amount, quote.currency || currencyFallback)}</span>
              </div>
            ))}
          </div>
        </details>
      ) : null}
    </div>
  );
}
