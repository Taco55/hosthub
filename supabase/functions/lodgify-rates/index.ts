import { createClient } from "npm:@supabase/supabase-js@2";
import { env } from "../_shared/env.ts";
import { buildCorsHeaders, jsonError, jsonResponse } from "../_shared/http.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error("Missing Supabase configuration for lodgify-rates function.");
}

const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const allowHeaders = [
  "authorization",
  "x-client-info",
  "apikey",
  "content-type",
];

const lodgifyHeaders = (apiKey: string) => ({
  Accept: "application/json",
  "X-APIKEY": apiKey,
});

type CorsOptions = {
  origin: string;
  methods: string[];
  headers: string[];
};

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("Origin") ?? "*";
  const corsOptions: CorsOptions = {
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

  const resolved = await resolveLodgifyApiKey(req, corsOptions);
  if (resolved.error) return resolved.error;
  const apiKey = resolved.apiKey;

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
          `[lodgify-rates] rate_settings keys: ${
            Object.keys(settings).join(", ")
          }`,
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

async function resolveLodgifyApiKey(
  req: Request,
  corsOptions: CorsOptions,
): Promise<
  { apiKey: string; error?: undefined } | {
    apiKey?: undefined;
    error: Response;
  }
> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return {
      error: jsonError(401, "Missing Authorization header", corsOptions),
    };
  }

  const token = authHeader.replace("Bearer ", "").trim();
  if (!token) {
    return {
      error: jsonError(401, "Invalid Authorization header", corsOptions),
    };
  }

  const {
    data: { user },
    error: authError,
  } = await adminClient.auth.getUser(token);

  if (authError || !user) {
    return { error: jsonError(401, "Invalid or expired token", corsOptions) };
  }

  const { data, error } = await adminClient.rpc(
    "get_effective_lodgify_api_key",
    { p_user_id: user.id },
  );

  if (error) {
    console.error("[lodgify-rates] key lookup failed", error);
    return {
      error: jsonError(
        500,
        "Failed to resolve Lodgify credentials",
        corsOptions,
      ),
    };
  }

  const apiKey = typeof data === "string" ? data.trim() : "";
  if (!apiKey) {
    return {
      error: jsonError(
        400,
        "Missing Lodgify API key. Add one in Settings.",
        corsOptions,
      ),
    };
  }

  return { apiKey };
}
