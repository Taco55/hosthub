import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";

import { checkRateLimit } from "@/lib/lodgify/rate-limit";
import { getClientIp, jsonError, jsonRateLimit } from "@/lib/lodgify/route-utils";
import { LodgifyError } from "@/lib/lodgify/client";
import { getLodgifyClient, getLodgifyPropertyId, getLodgifyRoomTypeId } from "@/lib/lodgify/server";
import { diffDays, parseDateParam } from "@/lib/lodgify/validation";

export const revalidate = 30;

const maxRangeDays = 180;
const rateLimitOptions = { capacity: 240, refillPerMinute: 240 } as const;

function parseCount(
  value: string | null,
  options: { min: number; max: number; required?: boolean },
  fallback = 0,
) {
  if (value === null || value.trim() === "") {
    return options.required ? null : fallback;
  }
  const parsed = Number(value);
  if (!Number.isInteger(parsed)) {
    return null;
  }
  if (parsed < options.min || parsed > options.max) {
    return null;
  }
  return parsed;
}

function isFeeLabel(label: string) {
  const normalized = label.toLowerCase();
  return (
    normalized.includes("fee") ||
    normalized.includes("clean") ||
    normalized.includes("linen") ||
    normalized.includes("towel")
  );
}

function isTaxLabel(label: string) {
  const normalized = label.toLowerCase();
  return normalized.includes("tax");
}

type LodgifyQuoteErrorDetails = {
  message?: string;
  code?: number;
};

function parseLodgifyQuoteError(details: string | null): LodgifyQuoteErrorDetails | null {
  if (!details) {
    return null;
  }

  try {
    const parsed = JSON.parse(details) as Record<string, unknown>;
    const message =
      typeof parsed.message === "string" && parsed.message.trim()
        ? parsed.message.trim()
        : undefined;
    const code = typeof parsed.code === "number" ? parsed.code : undefined;
    return { message, code };
  } catch {
    return null;
  }
}

function isUnavailableQuoteMessage(message: string) {
  const normalized = message.toLowerCase();
  return (
    normalized.includes("already booked") ||
    normalized.includes("not available") ||
    normalized.includes("unavailable")
  );
}

function toSafeStatus(status: number, fallback = 500) {
  return status >= 400 && status < 600 ? status : fallback;
}

export async function GET(request: NextRequest) {
  const ip = getClientIp(request);

  if (!checkRateLimit(ip, rateLimitOptions)) {
    return jsonRateLimit();
  }

  try {
    const url = new URL(request.url);
    const arrival = url.searchParams.get("arrival");
    const departure = url.searchParams.get("departure");
    const arrivalDate = parseDateParam(arrival);
    const departureDate = parseDateParam(departure);

    if (!arrival || !departure || !arrivalDate || !departureDate) {
      return NextResponse.json(
        { error: "Invalid date range", status: 400 },
        { status: 400 },
      );
    }

    const rangeDays = diffDays(arrivalDate, departureDate);
    if (rangeDays <= 0 || rangeDays > maxRangeDays) {
      return NextResponse.json(
        { error: "Date range is not allowed", status: 400 },
        { status: 400 },
      );
    }

    const adults = parseCount(url.searchParams.get("adults"), {
      min: 1,
      max: 16,
      required: true,
    });
    const children = parseCount(url.searchParams.get("children"), { min: 0, max: 16 }, 0);
    const pets = parseCount(url.searchParams.get("pets"), { min: 0, max: 4 }, 0);

    if (adults === null || children === null || pets === null) {
      return NextResponse.json(
        { error: "Invalid guest counts", status: 400 },
        { status: 400 },
      );
    }

    const client = getLodgifyClient();
    const propertyId = getLodgifyPropertyId();
    const roomTypeId = getLodgifyRoomTypeId();
    const quote = await client.getQuote({
      propertyId,
      roomTypeId,
      arrival,
      departure,
      guests: adults + children,
      adults,
      children,
      pets,
    });
    console.info("[lodgify] quote response", quote);

    const nights = Math.max(0, diffDays(arrivalDate, departureDate));
    const breakdown = quote.lines ?? [];
    const discounts = breakdown.filter((line) => line.amount < 0);
    const fees = breakdown.filter(
      (line) => line.amount >= 0 && isFeeLabel(line.label) && !isTaxLabel(line.label),
    );
    const taxesIncluded =
      typeof quote.taxesIncluded === "boolean" ? quote.taxesIncluded : quote.taxesTotal > 0;
    const rental =
      nights > 0 && quote.nightlyTotal > 0
        ? {
            amount: quote.nightlyTotal,
            nightlyRate: quote.nightlyTotal / nights,
            nights,
          }
        : null;

    return NextResponse.json({
      currency: quote.currency,
      total: quote.total,
      arrival,
      departure,
      nights,
      taxesIncluded,
      rental,
      discounts,
      fees,
      breakdown,
      payments: quote.payments ?? [],
    });
  } catch (error) {
    if (error instanceof LodgifyError) {
      console.error("[lodgify] quote error", {
        status: error.status,
        url: error.url,
        details: error.details,
      });
      const parsed = parseLodgifyQuoteError(error.details);
      const message = parsed?.message ?? "Failed to fetch quote";
      const reason =
        parsed?.code === 666 || (parsed?.message && isUnavailableQuoteMessage(parsed.message))
          ? "unavailable"
          : undefined;
      const status = toSafeStatus(error.status);
      return NextResponse.json(
        { error: message, status, ...(reason ? { reason } : {}) },
        { status },
      );
    } else {
      console.error("[lodgify] quote error", error);
    }
    return jsonError("Failed to fetch quote", error);
  }
}
