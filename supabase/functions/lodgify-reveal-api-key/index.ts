// Returns the caller's OWN Lodgify API key in plaintext.
//
// The key lives in public.lodgify_api_keys, which no client role can read:
// user_settings only carries the '__lodgify_server_stored__' marker plus a
// last-4 hint, and the SECURITY DEFINER RPCs that used to hand out plaintext
// were dropped in 20260728140000_lock_down_security_definer_grants.sql. The
// console still needs a way to show the user the key they typed in themselves,
// so that path is this function and nothing else.
//
// Two deliberate narrowings versus resolveEffectiveLodgifyApiKey():
//
//  1. No owner fallback. The other Lodgify functions borrow the site owner's
//     key to *call* Lodgify on a member's behalf; borrowing a credential to use
//     it is not the same as handing its plaintext to whoever is logged in. Only
//     profile_id = auth.uid() is ever read here.
//  2. No key means 404, not the owner's key. A member of somebody else's site
//     sees "you have no key", which is the truth.
import { createClient } from "npm:@supabase/supabase-js@2";
import { env } from "../_shared/env.ts";
import { buildCorsHeaders, jsonError } from "../_shared/http.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error(
    "Missing Supabase configuration for lodgify-reveal-api-key function.",
  );
}

const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const allowHeaders = [
  "authorization",
  "x-client-info",
  "apikey",
  "content-type",
];

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("Origin") ?? "*";
  const corsOptions = {
    origin,
    methods: ["POST", "OPTIONS"],
    headers: allowHeaders,
  };
  const corsHeaders = buildCorsHeaders(corsOptions);

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonError(405, "Method not allowed", corsOptions);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return jsonError(401, "Missing Authorization header", corsOptions);
  }

  const token = authHeader.replace("Bearer ", "").trim();
  if (!token) {
    return jsonError(401, "Invalid Authorization header", corsOptions);
  }

  const {
    data: { user },
    error: authError,
  } = await adminClient.auth.getUser(token);

  if (authError || !user) {
    return jsonError(401, "Invalid or expired token", corsOptions);
  }

  const { data, error } = await adminClient
    .from("lodgify_api_keys")
    .select("api_key")
    .eq("profile_id", user.id)
    .maybeSingle();

  if (error) {
    console.error("[lodgify-reveal-api-key] key lookup failed", error);
    return jsonError(500, "Failed to read the Lodgify API key", corsOptions);
  }

  const apiKey = typeof data?.api_key === "string" ? data.api_key.trim() : "";
  if (!apiKey) {
    return jsonError(404, "no_api_key", corsOptions);
  }

  // Not cacheable at any layer: this response body is a third-party credential.
  return new Response(JSON.stringify({ apiKey }), {
    status: 200,
    headers: {
      ...buildCorsHeaders({
        ...corsOptions,
        contentType: "application/json; charset=utf-8",
      }),
      "Cache-Control": "no-store",
    },
  });
});
