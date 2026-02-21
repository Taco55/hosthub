import { buildCorsHeaders, jsonError, jsonResponse } from "../_shared/http.ts";

const allowHeaders = [
  "authorization",
  "x-client-info",
  "apikey",
  "content-type",
  "x-apikey",
];

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("Origin") ?? "*";
  const corsOptions = {
    origin,
    methods: ["GET", "PATCH", "OPTIONS"],
    headers: allowHeaders,
  };
  const corsHeaders = buildCorsHeaders(corsOptions);

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  const apiKey =
    req.headers.get("x-apikey") ?? req.headers.get("x-apikey".toUpperCase());
  if (!apiKey) {
    return jsonError(400, "Missing X-APIKEY header.", corsOptions);
  }

  if (req.method === "GET") {
    return await handleGet(req, apiKey, corsOptions);
  }

  if (req.method === "PATCH") {
    return await handlePatch(req, apiKey, corsOptions);
  }

  return jsonError(405, "Method not allowed", corsOptions);
});

async function handleGet(
  req: Request,
  apiKey: string,
  corsOptions: Record<string, unknown>,
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

  return proxyResponse(lodgifyResponse, corsOptions);
}

async function handlePatch(
  req: Request,
  apiKey: string,
  corsOptions: Record<string, unknown>,
) {
  const incomingUrl = new URL(req.url);
  const reservationId = incomingUrl.searchParams.get("reservationId");
  if (!reservationId) {
    return jsonError(400, "Missing reservationId query parameter.", corsOptions);
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

  return proxyResponse(lodgifyResponse, corsOptions);
}

async function proxyResponse(
  lodgifyResponse: Response,
  corsOptions: Record<string, unknown>,
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
