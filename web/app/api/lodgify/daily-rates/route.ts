import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";

import { checkRateLimit } from "@/lib/lodgify/rate-limit";
import { getClientIp, jsonError, jsonRateLimit } from "@/lib/lodgify/route-utils";
import { resolveLodgifyContext } from "@/lib/lodgify/server";
import { diffDays, parseDateParam } from "@/lib/lodgify/validation";

export const revalidate = 300;

const maxRangeDays = 180;

export async function GET(request: NextRequest) {
  const ip = getClientIp(request);

  if (!checkRateLimit(ip)) {
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

    const { client, propertyId: sitePropertyId, roomTypeId: siteRoomTypeId } =
      await resolveLodgifyContext();

    const roomTypeId =
      url.searchParams.get("roomTypeId") ?? siteRoomTypeId ?? undefined;
    const houseId =
      url.searchParams.get("houseId") ?? sitePropertyId ?? undefined;

    if (!roomTypeId && !houseId) {
      return NextResponse.json(
        { error: "Missing roomTypeId or houseId", status: 400 },
        { status: 400 },
      );
    }
    const rates = await client.getDailyRates({
      startDate: start,
      endDate: end,
      roomTypeId,
      houseId,
    });

    return NextResponse.json(rates);
  } catch (error) {
    return jsonError("Failed to fetch daily rates", error);
  }
}
