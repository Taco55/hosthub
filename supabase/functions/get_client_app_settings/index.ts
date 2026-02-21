// Fetch allowed/default list types for a client_app. Falls back to the caller's subscription.
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

import { env } from "../_shared/env.ts";
import { buildCorsHeaders } from "../_shared/http.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SUPABASE_ANON_KEY = env("SUPABASE_ANON_KEY", "SUPABASE_KEY");

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error("Missing Supabase environment configuration.");
}

const corsHeaders = () => buildCorsHeaders();
const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders(),
      "Content-Type": "application/json; charset=utf-8",
    },
  });
const jsonError = (status: number, message: string) =>
  jsonResponse({ error: message }, status);

type SettingsRequest = {
  client_app?: string;
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(undefined, { status: 204, headers: corsHeaders() });
  }

  if (req.method !== "POST") {
    return jsonError(405, "Method not allowed");
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return jsonError(401, "Unauthorized");
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: {
      headers: {
        Authorization: authHeader,
      },
    },
  });

  const payload = (await req.json().catch(() => ({}))) as SettingsRequest;

  const clientApp = (() => {
    if (typeof payload.client_app === "string") {
      const trimmed = payload.client_app.trim();
      if (trimmed.length > 0) return trimmed;
    }
    return undefined;
  })();

  if (!clientApp) {
    return jsonError(400, "client_app is required");
  }

  const { data: appSettings, error: settingsError } = await supabase
    .from("client_apps")
    .select("id, allowed_template_keys, default_template_keys")
    .eq("id", clientApp)
    .eq("is_active", true)
    .maybeSingle();

  if (settingsError) {
    return jsonError(500, settingsError.message ?? "Failed to load settings");
  }
  if (!appSettings) {
    return jsonError(404, "Settings not found");
  }

  return jsonResponse({
    client_app: appSettings.id,
    allowed_template_keys: appSettings.allowed_template_keys ?? [],
    default_template_keys: appSettings.default_template_keys ?? [],
  });
});
