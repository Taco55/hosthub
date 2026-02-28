import { createClient } from "npm:@supabase/supabase-js@2";

import { env } from "../_shared/env.ts";
import { buildCorsHeaders, jsonResponse, jsonError } from "../_shared/http.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);
const DASHBOARD_BASE_URL = env("ADMIN_BASE_URL", "DASHBOARD_BASE_URL");

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

type InviteLinkType = "invite" | "magiclink";

const normalizeEmail = (value: string | undefined): string | undefined => {
  const trimmed = value?.trim().toLowerCase();
  return trimmed && trimmed.length > 0 ? trimmed : undefined;
};

const normalizeRedirect = (value: string | undefined): string | undefined => {
  const trimmed = value?.trim();
  if (trimmed && trimmed.length > 0) {
    try {
      const parsed = new URL(trimmed);
      if (parsed.protocol === "http:" || parsed.protocol === "https:") {
        return trimmed;
      }
    } catch {
      // Ignore malformed override and fallback to dashboard base when available.
    }
  }

  if (!DASHBOARD_BASE_URL) return undefined;
  const base = DASHBOARD_BASE_URL.trim().replace(/\/+$/, "");
  if (!base) return undefined;

  try {
    const parsed = new URL(base);
    if (parsed.protocol !== "http:" && parsed.protocol !== "https:") {
      return undefined;
    }
  } catch {
    return undefined;
  }

  return `${base}/set-password`;
};

const rewriteRedirect = (actionLink: string, redirectTo: string): string => {
  try {
    const url = new URL(actionLink);
    url.searchParams.set("redirect_to", redirectTo);
    return url.toString();
  } catch {
    return actionLink;
  }
};

const isAlreadyRegisteredError = (message: string | undefined): boolean => {
  const normalized = (message ?? "").toLowerCase();
  return normalized.includes("already") && normalized.includes("register");
};

const isUserNotFoundError = (message: string | undefined): boolean => {
  const normalized = (message ?? "").toLowerCase();
  return normalized.includes("user") && normalized.includes("not found");
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
  const redirectTo = normalizeRedirect(payload.redirectTo);

  if (!siteId) return jsonError(400, "Missing siteId");
  if (!email) return jsonError(400, "Missing email");
  if (!role || !["editor", "viewer"].includes(role)) {
    return jsonError(400, "Invalid role. Must be 'editor' or 'viewer'.");
  }

  // ── Verify caller is site owner or admin ───────────────────────────────
  const { data: accessCheck, error: accessError } = await adminClient.rpc("has_site_access", {
    check_site_id: siteId,
    check_user_id: caller.id,
    min_role: "owner",
  });

  if (accessError) {
    return jsonResponse(
      {
        error: "Failed to verify site access",
        details: accessError.message,
      },
      500,
    );
  }

  if (!accessCheck) {
    return jsonError(403, "You must be a site owner to invite members");
  }

  // ── Check for existing pending invitation ──────────────────────────────
  const { data: existingInv, error: existingInvError } = await adminClient
    .from("site_invitations")
    .select("id, status")
    .eq("site_id", siteId)
    .eq("email", email)
    .maybeSingle();

  if (existingInvError) {
    return jsonResponse(
      {
        error: "Failed to check existing invitation",
        details: existingInvError.message,
      },
      500,
    );
  }

  if (existingInv && existingInv.status === "pending") {
    return jsonError(409, "An invitation for this email is already pending");
  }

  // ── Check if profile already exists ────────────────────────────────────
  const { data: existingProfile, error: profileLookupError } = await adminClient
    .from("profiles")
    .select("id")
    .ilike("email", email)
    .limit(1)
    .maybeSingle();

  if (profileLookupError) {
    return jsonResponse(
      {
        error: "Failed to resolve existing user profile",
        details: profileLookupError.message,
      },
      500,
    );
  }

  // ── Generate auth link ─────────────────────────────────────────────────
  try {
    let linkType: InviteLinkType = existingProfile ? "magiclink" : "invite";
    let { data: linkData, error: linkError } =
      await adminClient.auth.admin.generateLink({
        type: linkType,
        email,
        options: redirectTo ? { redirectTo } : undefined,
      });

    // Retry once with the alternate link type when the first attempt clearly
    // mismatches account state (new vs existing user).
    if (linkError) {
      const shouldFallback =
        (linkType === "invite" && isAlreadyRegisteredError(linkError.message)) ||
        (linkType === "magiclink" && isUserNotFoundError(linkError.message));

      if (shouldFallback) {
        linkType = linkType === "invite" ? "magiclink" : "invite";
        const retry = await adminClient.auth.admin.generateLink({
          type: linkType,
          email,
          options: redirectTo ? { redirectTo } : undefined,
        });
        linkData = retry.data;
        linkError = retry.error;
      }
    }

    if (linkError) {
      return jsonResponse(
        {
          error: `Failed to generate ${linkType} link`,
          details: linkError.message ?? linkError,
        },
        500,
      );
    }

    const rawActionLink = linkData?.properties?.action_link ?? null;
    const actionLink = rawActionLink && redirectTo
      ? rewriteRedirect(rawActionLink, redirectTo)
      : rawActionLink;
    const emailOtp = linkData?.properties?.email_otp ?? null;
    const isNewUser = linkType === "invite";

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
    if (!isNewUser && existingProfile) {
      const { error: memberUpsertError } = await adminClient
        .from("site_members")
        .upsert(
          {
            site_id: siteId,
            profile_id: existingProfile.id,
            role,
          },
          { onConflict: "site_id,profile_id" },
        );

      if (memberUpsertError) {
        return jsonResponse(
          {
            error: "Failed to add member to site",
            details: memberUpsertError.message,
          },
          500,
        );
      }

      // Mark invitation as accepted immediately
      const { error: invitationAcceptError } = await adminClient
        .from("site_invitations")
        .update({ status: "accepted" })
        .eq("id", invitation.id);

      if (invitationAcceptError) {
        return jsonResponse(
          {
            error: "Failed to finalize invitation",
            details: invitationAcceptError.message,
          },
          500,
        );
      }
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
