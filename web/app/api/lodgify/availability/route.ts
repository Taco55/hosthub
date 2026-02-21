import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";

import { checkRateLimit } from "@/lib/lodgify/rate-limit";
import { getClientIp, jsonError, jsonRateLimit } from "@/lib/lodgify/route-utils";
import { getLodgifyClient, getLodgifyPropertyId } from "@/lib/lodgify/server";
import { diffDays, parseDateParam } from "@/lib/lodgify/validation";

export const revalidate = 60;

const maxRangeDays = 180;
const dayMs = 24 * 60 * 60 * 1000;
const rateLimitOptions = { capacity: 240, refillPerMinute: 240 } as const;

function normalizeDateKey(value: string) {
  const match = value.match(/^(\d{4}-\d{2}-\d{2})/);
  return match ? match[1] : value;
}

function toDateKey(date: Date) {
  return date.toISOString().slice(0, 10);
}

function buildDateKeys(start: Date, end: Date) {
  const keys: string[] = [];
  let cursor = new Date(start);
  while (cursor < end) {
    keys.push(toDateKey(cursor));
    cursor = new Date(cursor.getTime() + dayMs);
  }
  return keys;
}

export async function GET(request: NextRequest) {
  const ip = getClientIp(request);

  if (!checkRateLimit(ip, rateLimitOptions)) {
    return jsonRateLimit();
  }

  try {
    const url = new URL(request.url);
    const start = url.searchParams.get("start");
    const end = url.searchParams.get("end");
    const startDate = parseDateParam(start);
    const endDate = parseDateParam(end);

    if (!start || !end || !startDate || !endDate) {
      return NextResponse.json(
        { error: "Invalid date range", status: 400 },
        { status: 400 },
      );
    }

    const rangeDays = diffDays(startDate, endDate);
    if (rangeDays <= 0 || rangeDays > maxRangeDays) {
      return NextResponse.json(
        { error: "Date range is not allowed", status: 400 },
        { status: 400 },
      );
    }

    const client = getLodgifyClient();
    const propertyId = getLodgifyPropertyId();
    const availability = await client.getAvailability(propertyId, start, end);

    const availabilityMap = new Map(
      availability.map((day) => [normalizeDateKey(day.date), day.isAvailable]),
    );
    const keys = buildDateKeys(startDate, endDate);
    const unavailable = keys.filter((key) => availabilityMap.get(key) === false);
    const daysAvailable = keys.filter((key) => availabilityMap.get(key) === true);

    return NextResponse.json({
      start,
      end,
      unavailable,
      daysAvailable,
      daysUnavailable: unavailable,
      available: unavailable.length === 0,
    });
  } catch (error) {
    return jsonError("Failed to fetch availability", error);
  }
}
