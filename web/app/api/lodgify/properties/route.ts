import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";

import { checkRateLimit } from "@/lib/lodgify/rate-limit";
import { getClientIp, jsonError, jsonRateLimit } from "@/lib/lodgify/route-utils";
import { getLodgifyClient } from "@/lib/lodgify/server";

export const revalidate = 3600;

export async function GET(request: NextRequest) {
  if (process.env.LODGIFY_ADMIN_ENABLED !== "true") {
    return NextResponse.json({ error: "Not found", status: 404 }, { status: 404 });
  }

  const ip = getClientIp(request);

  if (!checkRateLimit(ip)) {
    return jsonRateLimit();
  }

  try {
    const client = getLodgifyClient();
    const properties = await client.getProperties();
    return NextResponse.json({ properties });
  } catch (error) {
    return jsonError("Failed to fetch properties", error);
  }
}
