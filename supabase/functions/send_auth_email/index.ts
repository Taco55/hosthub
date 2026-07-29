// supabase/functions/send_auth_email/index.ts
//
// Mints an auth link and mails it, in one place, and returns nothing but
// `{ sent: true }`.
//
// This replaces generate_magic_link_and_otp, generate_password_reset_link_and_otp
// and generate_sign_up_link_and_otp. Those ran on the service-role key, took the
// address from the request body, and returned `action_link`, `email_otp` and
// `hashed_token` to the caller. `verify_jwt = true` did not help: the anon key
// is itself a project-signed JWT and ships in the browser bundle, so anybody
// could ask for a working password-reset or magic sign-in link for any address
// on the platform — including an admin's — and never needed access to the
// mailbox.
//
// Handing the address to the function is unavoidable: "forgot my password" is by
// definition asked by someone who is not signed in. What makes that safe is that
// the answer goes to the mailbox instead of to the caller. Supplying somebody
// else's address now only mails that person a password reset, which is what a
// password reset is.
//
// Kept without JWT verification on purpose (see supabase/config.toml): the
// response carries no secret, so a gate that the anon key satisfies would only
// have suggested protection that was not there.

import { createClient } from "npm:@supabase/supabase-js@2";

import {
  authEmailSpec,
  type AuthEmailKind,
  buildSafeAuthEntryLink,
  prefixSubject,
  renderAuthEmail,
} from "../_shared/auth_email.ts";
import { env } from "../_shared/env.ts";
import { buildCorsHeaders } from "../_shared/http.ts";
import { sendViaResend } from "../_shared/resend.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);
const ADMIN_BASE_URL = env("ADMIN_BASE_URL", "ADMIN_DASHBOARD_BASE_URL");
const SUPPORT_EMAIL = env("SUPPORT_EMAIL");
const ENV_LABEL = env("EMAIL_ENV_LABEL");

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error("Missing Supabase configuration for send_auth_email.");
}

const client = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const cors = () => buildCorsHeaders();
const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: cors() });
const jsonError = (status: number, message: string) =>
  jsonResponse({ error: message }, status);

const KINDS: readonly AuthEmailKind[] = [
  "login_otp",
  "sign_up_confirmation",
  "user_created",
  "password_reset",
  "site_invitation",
];

/**
 * The two kinds a caller must be entitled to trigger. The self-service three
 * only ever mail the address they name; these two are staff actions, and
 * site_invitation additionally carries a link the caller already holds.
 */
const REQUIRES_CALLER: ReadonlySet<AuthEmailKind> = new Set([
  "user_created",
  "site_invitation",
]);

type Payload = {
  kind?: string;
  email?: string;
  name?: string;
  siteName?: string;
  isNewUser?: boolean;
  redirectTo?: string;
  /** site_invitation only: the link invite_site_member already minted. */
  actionLink?: string;
  otp?: string;
};

const normalize = (value: string | undefined) => {
  const trimmed = value?.trim();
  return trimmed && trimmed.length > 0 ? trimmed : undefined;
};

function defaultRedirect(): string | undefined {
  if (!ADMIN_BASE_URL) return undefined;
  const base = ADMIN_BASE_URL.trim().replace(/\/+$/, "");
  return base ? `${base}/reset-password` : undefined;
}

/** Resolves the caller and confirms they may trigger a staff mail. */
async function authorizeCaller(
  req: Request,
): Promise<{ ok: true } | { ok: false; status: number; message: string }> {
  const authorization = req.headers.get("Authorization");
  const token = authorization?.replace(/^Bearer\s+/i, "").trim();
  if (!token) {
    return { ok: false, status: 401, message: "Authorization header missing" };
  }

  const { data, error } = await client.auth.getUser(token);
  if (error || !data?.user) {
    // The anon key is a valid project JWT but resolves to no user, so this is
    // also what rejects a caller holding nothing but the public key.
    return { ok: false, status: 401, message: "Invalid or expired token" };
  }

  return { ok: true };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(undefined, { status: 204, headers: cors() });
  }

  if (req.method !== "POST") {
    return jsonError(405, "Method not allowed");
  }

  let payload: Payload;
  try {
    payload = await req.json();
  } catch {
    return jsonError(400, "Invalid JSON payload");
  }

  const kind = normalize(payload.kind) as AuthEmailKind | undefined;
  if (!kind || !KINDS.includes(kind)) {
    return jsonError(400, `Missing or unknown kind (expected one of ${KINDS.join(", ")})`);
  }

  const email = normalize(payload.email);
  if (!email) {
    return jsonError(400, "Missing email");
  }

  if (REQUIRES_CALLER.has(kind)) {
    const authorized = await authorizeCaller(req);
    if (!authorized.ok) {
      return jsonError(authorized.status, authorized.message);
    }
  }

  const spec = authEmailSpec(kind, {
    siteName: payload.siteName,
    isNewUser: payload.isNewUser,
  });
  const redirectTo = normalize(payload.redirectTo) ?? defaultRedirect();

  let actionLink = normalize(payload.actionLink) ?? "";
  let otp = normalize(payload.otp) ?? "";

  if (spec.linkType) {
    try {
      const { data, error } = await client.auth.admin.generateLink({
        type: spec.linkType,
        email,
        options: redirectTo ? { redirectTo } : undefined,
      });

      if (error) {
        // Deliberately terse: whether an address has an account is not something
        // this endpoint should confirm to an anonymous caller.
        console.error(
          `[send_auth_email] generateLink(${spec.linkType}) failed:`,
          error.message ?? error,
        );
        return jsonError(500, "Failed to generate the link");
      }

      const properties = data?.properties ?? {};
      actionLink = properties.action_link ?? "";
      otp = properties.email_otp ?? "";
    } catch (error) {
      console.error("[send_auth_email] generateLink threw:", error);
      return jsonError(500, "Failed to generate the link");
    }
  } else if (!actionLink) {
    return jsonError(400, `kind ${kind} requires actionLink`);
  }

  const linkForMail = spec.rewriteEntryLink
    ? buildSafeAuthEntryLink({
      email,
      actionLink,
      otp,
      otpType: spec.otpType,
      requireOtp: spec.requireOtp,
    })
    : actionLink;

  const html = renderAuthEmail({
    templateId: spec.templateId,
    actionLink: linkForMail,
    otp,
    name: payload.name,
    copy: spec.copy,
    envLabel: ENV_LABEL ?? "",
    supportEmail: SUPPORT_EMAIL ?? "",
    year: new Date().getUTCFullYear(),
  });

  const result = await sendViaResend({
    to: email,
    subject: prefixSubject(spec.subject, ENV_LABEL ?? ""),
    html,
  });

  if (!result.ok) {
    console.error(
      `[send_auth_email] ${kind} to ${email}: ${result.error}`,
      result.details ?? "",
    );
    return jsonResponse({ error: result.error }, result.status);
  }

  // No action_link, no email_otp, no hashed_token. That is the whole point.
  return jsonResponse({ sent: true });
});
