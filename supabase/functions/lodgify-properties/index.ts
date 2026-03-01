import { createClient } from "npm:@supabase/supabase-js@2";
import { env } from "../_shared/env.ts";
import { buildCorsHeaders, jsonError, jsonResponse } from "../_shared/http.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error(
    "Missing Supabase configuration for lodgify-properties function.",
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

const lodgifyHeaders = (apiKey: string) => ({
  Accept: "application/json",
  "X-APIKEY": apiKey,
});

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
  const propertyId = incomingUrl.searchParams.get("property_id") ??
    incomingUrl.searchParams.get("propertyId");

  const targetUrl = propertyId
    ? new URL(
      `https://api.lodgify.com/v1/properties/${encodeURIComponent(propertyId)}`,
    )
    : new URL("https://api.lodgify.com/v1/properties");

  incomingUrl.searchParams.forEach((value, key) => {
    if (key === "property_id" || key === "propertyId") return;
    targetUrl.searchParams.set(key, value);
  });

  try {
    const lodgifyResponse = await fetch(targetUrl, {
      method: "GET",
      headers: lodgifyHeaders(apiKey),
    });

    return await proxyResponse(lodgifyResponse, corsOptions);
  } catch (error) {
    console.error("[lodgify-properties] request failed", error);
    return jsonError(
      502,
      "Failed to fetch properties from Lodgify.",
      corsOptions,
    );
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
    console.error("[lodgify-properties] key lookup failed", error);
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

async function proxyResponse(
  lodgifyResponse: Response,
  corsOptions: CorsOptions,
) {
  const body = await lodgifyResponse.text();
  const status = lodgifyResponse.status;

  if (!body) {
    return jsonResponse({}, status, corsOptions);
  }

  try {
    const parsed = JSON.parse(body);
    return jsonResponse(parsed, status, corsOptions);
  } catch (_) {
    return jsonError(502, "Invalid JSON returned by Lodgify.", corsOptions);
  }
}
