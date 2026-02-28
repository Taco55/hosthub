import { createClient } from "npm:@supabase/supabase-js@2";

import { env } from "../_shared/env.ts";
import { buildCorsHeaders, jsonResponse, jsonError } from "../_shared/http.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error(
    "Missing Supabase configuration for invite_site_member function.",
  );
}

const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

type InvitePayload = {
  siteId?: string;
  email?: string;
  role?: string;
  redirectTo?: string;
};

const normalizeEmail = (value: string | undefined): string | undefined => {
  const trimmed = value?.trim().toLowerCase();
  return trimmed && trimmed.length > 0 ? trimmed : undefined;
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

  // ── Extract calling user from JWT ──────────────────────────────────────
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

  // ── Parse payload ──────────────────────────────────────────────────────
  let payload: InvitePayload;
  try {
    payload = await req.json();
  } catch {
    return jsonError(400, "Invalid JSON payload");
  }

  const siteId = payload.siteId?.trim();
  const email = normalizeEmail(payload.email);
  const role = payload.role?.trim();
  const redirectTo = payload.redirectTo?.trim();

  if (!siteId) return jsonError(400, "Missing siteId");
  if (!email) return jsonError(400, "Missing email");
  if (!role || !["editor", "viewer"].includes(role)) {
    return jsonError(400, "Invalid role. Must be 'editor' or 'viewer'.");
  }

  // ── Verify caller is site owner or admin ───────────────────────────────
  const { data: accessCheck } = await adminClient.rpc("has_site_access", {
    check_site_id: siteId,
    check_user_id: caller.id,
    min_role: "owner",
  });

  if (!accessCheck) {
    return jsonError(403, "You must be a site owner to invite members");
  }

  // ── Check for existing pending invitation ──────────────────────────────
  const { data: existingInv } = await adminClient
    .from("site_invitations")
    .select("id, status")
    .eq("site_id", siteId)
    .eq("email", email)
    .maybeSingle();

  if (existingInv && existingInv.status === "pending") {
    return jsonError(409, "An invitation for this email is already pending");
  }

  // ── Check if user already exists ───────────────────────────────────────
  const { data: existingUsers } = await adminClient.auth.admin.listUsers({
    page: 1,
    perPage: 1,
  });

  // Search by email using the admin API
  let existingUser = null;
  const { data: userList } = await adminClient.auth.admin.listUsers();
  if (userList?.users) {
    existingUser = userList.users.find(
      (u) => u.email?.toLowerCase() === email,
    );
  }

  const isNewUser = !existingUser;

  // ── Generate auth link ─────────────────────────────────────────────────
  try {
    const linkType = isNewUser ? "invite" : "magiclink";
    const { data: linkData, error: linkError } =
      await adminClient.auth.admin.generateLink({
        type: linkType,
        email,
        options: redirectTo ? { redirectTo } : undefined,
      });

    if (linkError) {
      return jsonResponse(
        {
          error: `Failed to generate ${linkType} link`,
          details: linkError.message ?? linkError,
        },
        500,
      );
    }

    const actionLink = linkData?.properties?.action_link ?? null;
    const emailOtp = linkData?.properties?.email_otp ?? null;

    // ── Upsert invitation record ───────────────────────────────────────
    const { data: invitation, error: invError } = await adminClient
      .from("site_invitations")
      .upsert(
        {
          site_id: siteId,
          email,
          role,
          status: "pending",
          invited_by: caller.id,
          expires_at: new Date(
            Date.now() + 7 * 24 * 60 * 60 * 1000,
          ).toISOString(),
        },
        { onConflict: "site_id,email" },
      )
      .select("id")
      .single();

    if (invError) {
      return jsonResponse(
        {
          error: "Failed to create invitation record",
          details: invError.message,
        },
        500,
      );
    }

    // ── If existing user, auto-create site_member ────────────────────────
    if (!isNewUser && existingUser) {
      await adminClient
        .from("site_members")
        .upsert(
          {
            site_id: siteId,
            profile_id: existingUser.id,
            role,
          },
          { onConflict: "site_id,profile_id" },
        );

      // Mark invitation as accepted immediately
      await adminClient
        .from("site_invitations")
        .update({ status: "accepted" })
        .eq("id", invitation.id);
    }

    return jsonResponse({
      invitation_id: invitation.id,
      action_link: actionLink,
      email_otp: emailOtp,
      is_new_user: isNewUser,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return jsonError(500, `Unexpected error: ${message}`);
  }
});
