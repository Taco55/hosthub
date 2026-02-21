// supabase/functions/generate_magic_link_and_otp/index.ts
import { createClient } from "npm:@supabase/supabase-js@2";

import { buildCorsHeaders } from "../_shared/http.ts";

import { env } from "../_shared/env.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error("Missing Supabase configuration for magic link function.");
}

const client = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const cors = () => buildCorsHeaders();
const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: cors() });
const jsonError = (status: number, message: string) =>
  jsonResponse({ error: message }, status);

type MagicLinkPayload = {
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

  let payload: MagicLinkPayload;
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
  if (!redirectTo) {
    return jsonError(400, "Missing redirectTo");
  }

  try {
    const { data, error } = await client.auth.admin.generateLink({
      type: "magiclink",
      email,
      options: { redirectTo },
    });

    if (error) {
      return jsonResponse(
        {
          error: "Failed to generate magic link",
          details: error.message ?? error,
        },
        500,
      );
    }

    const properties = data?.properties ?? {};
    const originalActionLink = properties.action_link ?? null;

    const adjustedActionLink = typeof originalActionLink === "string"
      ? rewriteRedirect(originalActionLink, redirectTo)
      : null;

    return jsonResponse({
      action_link: adjustedActionLink ?? originalActionLink ?? null,
      email_otp: properties.email_otp ?? null,
      hashed_token: properties.hashed_token ?? null,
      redirect_to: redirectTo,
      original_action_link: originalActionLink,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return jsonError(500, `Unexpected error generating magic link: ${message}`);
  }
});

const rewriteRedirect = (actionLink: string, redirectTo: string) => {
  try {
    const url = new URL(actionLink);
    url.searchParams.set("redirect_to", redirectTo);
    return url.toString();
  } catch {
    return null;
  }
};
