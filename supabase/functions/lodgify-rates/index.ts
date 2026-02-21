import { buildCorsHeaders, jsonError, jsonResponse } from "../_shared/http.ts";

const allowHeaders = [
  "authorization",
  "x-client-info",
  "apikey",
  "content-type",
  "x-apikey",
];

const lodgifyHeaders = (apiKey: string) => ({
  Accept: "application/json",
  "X-APIKEY": apiKey,
});

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("Origin") ?? "*";
  const corsOptions = {
    origin,
    methods: ["GET", "OPTIONS"],
    headers: allowHeaders,
  };
  const corsHeaders = buildCorsHeaders(corsOptions);

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "GET") {
    return jsonError(405, "Method not allowed", corsOptions);
  }

  const apiKey =
    req.headers.get("x-apikey") ?? req.headers.get("x-apikey".toUpperCase());
  if (!apiKey) {
    return jsonError(400, "Missing X-APIKEY header.", corsOptions);
  }

  const incomingUrl = new URL(req.url);
  const propertyId = incomingUrl.searchParams.get("property_id");
  if (!propertyId) {
    return jsonError(400, "Missing property_id query parameter.", corsOptions);
  }

  const start = incomingUrl.searchParams.get("start");
  const end = incomingUrl.searchParams.get("end");

  try {
    // Step 1: Get the room_type_id from the availability endpoint.
    const availUrl = new URL(
      `https://api.lodgify.com/v2/availability/${propertyId}`,
    );
    if (start) availUrl.searchParams.set("start", start);
    if (end) availUrl.searchParams.set("end", end);

    const availResponse = await fetch(availUrl, {
      method: "GET",
      headers: lodgifyHeaders(apiKey),
    });

    if (!availResponse.ok) {
      const errBody = await availResponse.text();
      console.log(
        `[lodgify-rates] availability request failed: status=${availResponse.status} body=${errBody}`,
      );
      return jsonError(
        availResponse.status,
        `Lodgify availability error: ${availResponse.status}`,
        corsOptions,
      );
    }

    const availData = await availResponse.json();
    let roomTypeId: number | null = null;

    if (Array.isArray(availData) && availData.length > 0) {
      roomTypeId = availData[0]?.room_type_id ?? null;
    }

    if (!roomTypeId) {
      console.log(
        `[lodgify-rates] no room_type_id found in availability response for property ${propertyId}`,
      );
      return jsonResponse([], 200, corsOptions);
    }

    // Step 2: Fetch daily rates from the rates calendar endpoint.
    const ratesUrl = new URL("https://api.lodgify.com/v2/rates/calendar");
    ratesUrl.searchParams.set("HouseId", propertyId);
    ratesUrl.searchParams.set("RoomTypeId", String(roomTypeId));
    if (start) ratesUrl.searchParams.set("StartDate", start);
    if (end) ratesUrl.searchParams.set("EndDate", end);

    const ratesResponse = await fetch(ratesUrl, {
      method: "GET",
      headers: lodgifyHeaders(apiKey),
    });

    const ratesBody = await ratesResponse.text();
    const ratesStatus = ratesResponse.status;

    if (!ratesBody) {
      return jsonResponse([], ratesStatus, corsOptions);
    }

    const ratesParsed = JSON.parse(ratesBody);

    // Log the response shape for diagnostics.
    try {
      const items = ratesParsed?.calendar_items;
      const settings = ratesParsed?.rate_settings;
      const itemCount = Array.isArray(items) ? items.length : "n/a";
      console.log(
        `[lodgify-rates] property=${propertyId} roomType=${roomTypeId}` +
          ` status=${ratesStatus} calendar_items=${itemCount}` +
          ` has_rate_settings=${!!settings}`,
      );
      if (Array.isArray(items) && items.length > 0) {
        console.log(
          `[lodgify-rates] sample calendar_item: ${JSON.stringify(items[0])}`,
        );
      }
      if (settings) {
        console.log(
          `[lodgify-rates] rate_settings keys: ${Object.keys(settings).join(", ")}`,
        );
      }
    } catch (_logErr) {
      // Logging must never break the response.
    }

    return jsonResponse(ratesParsed, ratesStatus, corsOptions);
  } catch (err) {
    console.log(`[lodgify-rates] unexpected error: ${err}`);
    return jsonError(502, "Failed to fetch rates from Lodgify.", corsOptions);
  }
});
