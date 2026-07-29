import { createClient } from "npm:@supabase/supabase-js@2";
import { env } from "../_shared/env.ts";
import { buildCorsHeaders, jsonError, jsonResponse } from "../_shared/http.ts";
import {
  proxyLodgifyResponse,
  resolveEffectiveLodgifyApiKey,
  type SiteMemberRole,
} from "../_shared/lodgify.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error(
    "Missing Supabase configuration for lodgify-reservations function.",
  );
}

const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const allowHeaders = [
  "authorization",
  "x-client-info",
  "apikey",
  "content-type",
];

type CorsOptions = {
  origin: string;
  methods: string[];
  headers: string[];
};

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("Origin") ?? "*";
  const corsOptions: CorsOptions = {
    origin,
    methods: ["GET", "PATCH", "OPTIONS"],
    headers: allowHeaders,
  };
  const corsHeaders = buildCorsHeaders(corsOptions);

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "GET" && req.method !== "PATCH") {
    return jsonError(405, "Method not allowed", corsOptions);
  }

  // A PATCH changes something in the key owner's Lodgify account, so borrowing
  // their key for it takes `editor`. Reading is fine for any member.
  const resolved = await resolveLodgifyApiKey(
    req,
    corsOptions,
    req.method === "PATCH" ? "editor" : "viewer",
  );
  if (resolved.error) return resolved.error;

  if (req.method === "GET") {
    return await handleGet(req, resolved.apiKey, corsOptions);
  }

  return await handlePatch(req, resolved.apiKey, corsOptions);
});

async function resolveLodgifyApiKey(
  req: Request,
  corsOptions: CorsOptions,
  minRole: SiteMemberRole,
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

  // Read the key from the tables directly instead of the get_effective_lodgify
  // _api_key RPC, whose PostgREST schema-cache exposure has proven unreliable
  // (intermittent PGRST202). See _shared/lodgify.ts.
  const { data, error } = await resolveEffectiveLodgifyApiKey(
    adminClient,
    user.id,
    { minRole },
  );

  if (error) {
    console.error("[lodgify-reservations] key lookup failed", error);
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

async function handleGet(
  req: Request,
  apiKey: string,
  corsOptions: CorsOptions,
) {
  const incomingUrl = new URL(req.url);
  const targetUrl = new URL(
    "https://api.lodgify.com/v2/reservations/bookings",
  );
  incomingUrl.searchParams.forEach((value, key) => {
    targetUrl.searchParams.set(key, value);
  });

  const lodgifyResponse = await fetch(targetUrl, {
    method: "GET",
    headers: {
      Accept: "application/json",
      "X-APIKEY": apiKey,
    },
  });

  return proxyLodgifyResponse(lodgifyResponse, corsOptions);
}

async function handlePatch(
  req: Request,
  apiKey: string,
  corsOptions: CorsOptions,
) {
  const incomingUrl = new URL(req.url);
  const reservationId = incomingUrl.searchParams.get("reservationId");
  if (!reservationId) {
    return jsonError(
      400,
      "Missing reservationId query parameter.",
      corsOptions,
    );
  }

  const targetUrl = new URL(
    `https://api.lodgify.com/v2/reservations/${reservationId}`,
  );

  let body: string;
  try {
    body = await req.text();
  } catch (_) {
    return jsonError(400, "Invalid request body.", corsOptions);
  }

  const lodgifyResponse = await fetch(targetUrl, {
    method: "PATCH",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-APIKEY": apiKey,
    },
    body,
  });

  return proxyLodgifyResponse(lodgifyResponse, corsOptions);
}
