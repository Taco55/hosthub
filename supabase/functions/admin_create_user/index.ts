// supabase/functions/admin_create_user/index.ts
//
// Creates a password-based account on behalf of a platform admin.
//
// The console runs on the publishable (anon) key, so it cannot call
// `auth.admin.*` itself — those endpoints answer 403 `not_admin`. This function
// holds the service-role key server-side and gates every call on the caller
// being a platform admin (`public.is_admin`).
//
// There is no trigger on `auth.users`, so the `profiles` row is created here
// explicitly; if that insert fails the freshly created auth user is removed
// again so a half-provisioned account never lingers.
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
    "Missing Supabase configuration for admin_create_user function.",
  );
}

const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const MIN_PASSWORD_LENGTH = 8;

type CreateUserPayload = {
  email?: string;
  password?: string;
  username?: string;
};

const normalizeEmail = (value: string | undefined): string | undefined => {
  const trimmed = value?.trim().toLowerCase();
  return trimmed && trimmed.length > 0 ? trimmed : undefined;
};

const isValidEmail = (value: string): boolean =>
  /^[^@\s]+@[^@\s.]+\.[^@\s]+$/.test(value);

const isAlreadyRegisteredError = (message: string | undefined): boolean => {
  const normalized = (message ?? "").toLowerCase();
  return (
    (normalized.includes("already") &&
      (normalized.includes("register") || normalized.includes("exist"))) ||
    normalized.includes("duplicate key")
  );
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(undefined, {
      status: 204,
      headers: buildCorsHeaders(),
    });
  }

  if (req.method !== "POST") {
    return jsonError(405, "Method not allowed");
  }

  // ── Identify the caller ────────────────────────────────────────────────────
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return jsonError(401, "Missing Authorization header");
  }

  const token = authHeader.replace("Bearer ", "");
  const {
    data: { user: caller },
    error: authError,
  } = await adminClient.auth.getUser(token);

  if (authError || !caller) {
    return jsonError(401, "Invalid or expired token");
  }

  // ── Authorize: platform admins only ───────────────────────────────────────
  const { data: callerIsAdmin, error: adminCheckError } = await adminClient.rpc(
    "is_admin",
    { user_id: caller.id },
  );

  if (adminCheckError) {
    console.error("[admin_create_user] is_admin failed", adminCheckError);
    return jsonError(500, "Failed to verify admin rights");
  }

  if (callerIsAdmin !== true) {
    return jsonError(403, "Admin rights required");
  }

  // ── Validate payload ──────────────────────────────────────────────────────
  let payload: CreateUserPayload;
  try {
    payload = await req.json();
  } catch {
    return jsonError(400, "Invalid JSON body");
  }

  const email = normalizeEmail(payload.email);
  if (!email || !isValidEmail(email)) {
    return jsonError(400, "A valid email is required");
  }

  const password = payload.password;
  if (typeof password !== "string" || password.length < MIN_PASSWORD_LENGTH) {
    return jsonError(
      400,
      `Password must be at least ${MIN_PASSWORD_LENGTH} characters`,
    );
  }

  const username = payload.username?.trim();

  // ── Create the auth user ──────────────────────────────────────────────────
  const { data: created, error: createError } = await adminClient.auth.admin
    .createUser({
      email,
      password,
      email_confirm: true,
    });

  if (createError) {
    if (isAlreadyRegisteredError(createError.message)) {
      return jsonError(409, "A user with this email already exists");
    }
    console.error("[admin_create_user] createUser failed", createError);
    return jsonError(500, createError.message ?? "Failed to create user");
  }

  const newUser = created?.user;
  if (!newUser) {
    return jsonError(500, "Auth user was not returned");
  }

  // ── Provision the profile row (no trigger on auth.users) ──────────────────
  const { error: profileError } = await adminClient.from("profiles").upsert({
    id: newUser.id,
    email,
    username: username && username.length > 0 ? username : null,
    is_admin: false,
  });

  if (profileError) {
    console.error(
      "[admin_create_user] profile upsert failed, rolling back auth user",
      profileError,
    );
    const { error: rollbackError } = await adminClient.auth.admin.deleteUser(
      newUser.id,
    );
    if (rollbackError) {
      console.error(
        "[admin_create_user] rollback failed; orphaned auth user",
        newUser.id,
        rollbackError,
      );
    }
    return jsonError(500, profileError.message ?? "Failed to create profile");
  }

  console.log("[admin_create_user] created user", newUser.id);

  return jsonResponse({ user_id: newUser.id, email });
});
