// supabase/functions/delete_user/index.ts
// deno-lint-ignore-file no-explicit-any
import { createClient, type SupabaseClient } from "@supabase/supabase-js";

import { deleteAuthUser } from "../_shared/auth.ts";
import { env } from "../_shared/env.ts";
import { buildCorsHeaders } from "../_shared/http.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SUPABASE_ANON_KEY = env("SUPABASE_ANON_KEY", "SUPABASE_KEY");
const SUPABASE_SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error("Missing Supabase environment configuration.");
}

const cors = () => buildCorsHeaders();
const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: cors() });
const jsonError = (status: number, message: string) =>
  jsonResponse({ error: message }, status);

type EdgeSupabaseClient = SupabaseClient<any, "public", any>;

// The profile row. Everything else that belongs to the user hangs off it or off
// auth.users by a cascading foreign key, so this is the whole of the manual
// cleanup — deleting it before the auth user keeps the order that RLS expects.
const deleteDataForUser = async (
  client: EdgeSupabaseClient,
  userId: string,
) => {
  const { error } = await client.from("profiles").delete().eq("id", userId);
  if (error) {
    console.error("[delete_user] Failed deleting profile:", error);
    throw new Error(
      `Failed to delete profile: ${error.message ?? JSON.stringify(error)}`,
    );
  }
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(undefined, { status: 204, headers: cors() });
  }

  if (req.method !== "POST") {
    return jsonError(405, "Method not allowed");
  }

  try {
    const payload = await req.json().catch(() => ({}));
    const userId = typeof payload?.user_id === "string"
      ? payload.user_id
      : typeof payload?.userId === "string"
      ? payload.userId
      : null;

    if (!userId) {
      return jsonError(400, "Missing or invalid user_id");
    }

    const authorization = req.headers.get("Authorization");
    if (!authorization) {
      return jsonError(401, "Authorization header missing");
    }

    const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: {
        headers: {
          Authorization: authorization,
          apikey: SUPABASE_ANON_KEY,
        },
      },
    });

    const {
      data: authContext,
      error: authError,
    } = await (userClient.auth as Record<string, any>).getUser();

    if (authError) {
      return jsonError(401, authError.message ?? "Unauthorized");
    }

    if (!authContext?.user || authContext.user.id !== userId) {
      return jsonError(403, "Forbidden");
    }

    const adminClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    await deleteDataForUser(adminClient, userId);

    await deleteAuthUser(adminClient, userId);

    console.log("[delete_user] User deleted successfully", userId);

    return jsonResponse({ success: true });
  } catch (error) {
    let message: string;
    if (error instanceof Error) {
      message = error.message;
    } else if (typeof error === "object" && error !== null) {
      try {
        message = JSON.stringify(error);
      } catch (_) {
        message = String(error);
      }
    } else {
      message = String(error);
    }

    console.error("[delete_user] Unexpected error", error);
    return jsonError(500, message);
  }
});
