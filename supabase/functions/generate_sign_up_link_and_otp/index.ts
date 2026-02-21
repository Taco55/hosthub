// supabase/functions/generate_sign_up_link_and_otp/index.ts
import { createClient } from "npm:@supabase/supabase-js@2";

import { env } from "../_shared/env.ts";
import { buildCorsHeaders } from "../_shared/http.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error(
    "Missing Supabase configuration for sign up confirmation function.",
  );
}

const client = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const cors = () => buildCorsHeaders();
const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: cors() });
const jsonError = (status: number, message: string) =>
  jsonResponse({ error: message }, status);

type SignUpLinkPayload = {
  email?: string;
  redirectTo?: string;
};

const normalizeEmail = (value: string | undefined) => {
  const trimmed = value?.trim();
  return trimmed && trimmed.length > 0 ? trimmed : undefined;
};

const normalizeRedirect = (value: string | undefined) => {
  const trimmed = value?.trim();
  return trimmed && trimmed.length > 0 ? trimmed : undefined;
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(undefined, { status: 204, headers: cors() });
  }

  if (req.method !== "POST") {
    return jsonError(405, "Method not allowed");
  }

  let payload: SignUpLinkPayload;
  try {
    payload = await req.json();
  } catch {
    return jsonError(400, "Invalid JSON payload");
  }

  const email = normalizeEmail(payload.email);
  if (!email) {
    return jsonError(400, "Missing email");
  }

  const redirectTo = normalizeRedirect(payload.redirectTo);

  try {
    const { data, error } = await client.auth.admin.generateLink({
      type: "signup",
      email,
      options: redirectTo ? { redirectTo } : undefined,
    });

    if (error) {
      return jsonResponse(
        {
          error: "Failed to generate sign up confirmation link",
          details: error.message ?? error,
        },
        500,
      );
    }

    const properties = data?.properties ?? {};

    return jsonResponse({
      action_link: properties.action_link ?? null,
      email_otp: properties.email_otp ?? null,
      hashed_token: properties.hashed_token ?? null,
      redirect_to: redirectTo ?? null,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return jsonError(
      500,
      `Unexpected error generating sign up confirmation link: ${message}`,
    );
  }
});
