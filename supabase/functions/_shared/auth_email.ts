// supabase/functions/_shared/auth_email.ts
//
// Rendering for the transactional auth mails, and the entry link they point at.
//
// Ported from the console (SupabaseEmailTemplatesAdapter and
// AuthEntryLinkBuilder). It moved server-side because the console had to be
// handed `action_link` and `email_otp` to render these, and those are sign-in
// credentials: anything that could call the generator got a working link for an
// address it did not own. The link is now minted, rendered and sent inside one
// function, and no response carries it.

import {
  AUTH_EMAIL_TEMPLATES,
  type AuthEmailTemplateId,
} from "./auth_email_templates.ts";

/** Per-mail copy for the action button and the OTP paragraph. */
export type AuthEmailCopy = {
  actionIntro?: string;
  actionButtonLabel?: string;
  actionFallback?: string;
  otpIntroWithAction?: string;
  otpIntroWithoutAction?: string;
};

export type AuthEmailKind =
  | "login_otp"
  | "sign_up_confirmation"
  | "user_created"
  | "password_reset"
  | "site_invitation";

const OTP_TYPES = new Set([
  "signup",
  "invite",
  "magiclink",
  "recovery",
  "email",
  "email_change",
  "phone_change",
]);

function normalizeOtpType(value: string | null | undefined): string | null {
  const normalized = value?.trim().toLowerCase();
  if (!normalized) return null;
  return OTP_TYPES.has(normalized) ? normalized : null;
}

/**
 * Rewrites GoTrue's verify link into the console's own set-password entry.
 *
 * GoTrue's `action_link` consumes the token on first fetch, which mail scanners
 * and link previewers do before the recipient ever clicks. Pointing at the
 * console with the OTP in the query survives that.
 */
export function deriveSetPasswordPath(originalPath: string): string {
  const path = originalPath.trim();
  if (!path || path === "/") return "/set-password";

  const normalized = path.replace(/\/+$/, "");
  if (!normalized || normalized === "/") return "/set-password";

  const authSuffixes = [
    "/reset-password",
    "/set-password",
    "/verify-otp",
    "/reset-password-code",
  ];

  for (const suffix of authSuffixes) {
    if (normalized.endsWith(suffix)) {
      const prefix = normalized.slice(0, normalized.length - suffix.length);
      const rootedPrefix = prefix.startsWith("/") ? prefix : `/${prefix}`;
      const cleanPrefix = rootedPrefix === "/" ? "" : rootedPrefix;
      return `${cleanPrefix}/set-password`;
    }
  }

  const rooted = normalized.startsWith("/") ? normalized : `/${normalized}`;
  return `${rooted}/set-password`;
}

export function buildAuthEntryLink({
  actionLink,
  email,
  otp,
  otpType,
}: {
  actionLink: string;
  email: string;
  otp?: string | null;
  otpType?: string | null;
}): string {
  const trimmedActionLink = actionLink.trim();
  const trimmedEmail = email.trim();
  if (!trimmedActionLink || !trimmedEmail) return trimmedActionLink;

  let verifyUri: URL;
  try {
    verifyUri = new URL(trimmedActionLink);
  } catch {
    return trimmedActionLink;
  }

  const redirectToRaw = verifyUri.searchParams.get("redirect_to")?.trim();
  if (!redirectToRaw) return trimmedActionLink;

  let redirectUri: URL;
  try {
    redirectUri = new URL(redirectToRaw);
  } catch {
    return trimmedActionLink;
  }

  const resolvedOtpType = normalizeOtpType(otpType) ??
    normalizeOtpType(verifyUri.searchParams.get("type"));

  const target = new URL(redirectUri.toString());
  target.pathname = deriveSetPasswordPath(redirectUri.pathname);
  target.hash = "";
  target.search = "";
  target.searchParams.set("email", trimmedEmail);
  if (resolvedOtpType) target.searchParams.set("otp_type", resolvedOtpType);
  const trimmedOtp = otp?.trim();
  if (trimmedOtp) target.searchParams.set("otp", trimmedOtp);

  return target.toString();
}

/**
 * Only used where the console used to require one: an entry link without its
 * OTP cannot complete the flow, so the raw GoTrue link is the better fallback.
 */
export function buildSafeAuthEntryLink({
  email,
  actionLink,
  otp,
  otpType,
  requireOtp = false,
}: {
  email: string;
  actionLink: string | null | undefined;
  otp?: string | null;
  otpType?: string | null;
  requireOtp?: boolean;
}): string {
  const trimmedActionLink = actionLink?.trim() ?? "";
  if (!trimmedActionLink) return "";

  const trimmedOtp = otp?.trim();
  if (requireOtp && !trimmedOtp) return trimmedActionLink;

  return buildAuthEntryLink({
    actionLink: trimmedActionLink,
    email,
    otp: trimmedOtp,
    otpType,
  });
}

function buildGreeting(name: string | null | undefined): string {
  const trimmed = name?.trim();
  return trimmed ? `Hallo ${trimmed},` : "Hallo!";
}

function buildEnvironmentBanner(envLabel: string): string {
  if (!envLabel) return "";
  return `<div style="display:inline-block;margin:6px 0 14px 0;padding:6px 10px;background:#fffae6;color:#663c00;border:1px solid #ffe58f;border-radius:4px;font-size:12px;font-weight:700;">${envLabel}</div>`;
}

function buildActionSection(actionLink: string, copy: AuthEmailCopy): string {
  const intro = copy.actionIntro ??
    "Klik op onderstaande knop om je wachtwoord in te stellen.";
  const buttonLabel = copy.actionButtonLabel ?? "Wachtwoord instellen";
  const fallback = copy.actionFallback ??
    "Werkt de knop niet? Kopieer dan deze link en plak hem in je browser:";
  return `
<p style="font-size:0.95rem;color:#444;margin-top:20px">${intro}</p>
<p style="margin-top:16px;">
  <a href="${actionLink}" style="display:inline-block;padding:12px 22px;background-color:#1c5d99;color:#ffffff;text-decoration:none;border-radius:6px;font-weight:600;">
    ${buttonLabel}
  </a>
</p>
<p style="font-size:0.85rem;color:#666;margin-top:10px;">
  ${fallback}<br />
  <a href="${actionLink}">${actionLink}</a>
</p>
`;
}

function buildOtpSection(
  otp: string,
  hasActionLink: boolean,
  copy: AuthEmailCopy,
): string {
  const trimmed = otp.trim();
  if (!trimmed) return "";

  const intro = hasActionLink
    ? (copy.otpIntroWithAction ??
      "Lukt het niet via de knop? Gebruik dan onderstaande code:")
    : (copy.otpIntroWithoutAction ??
      "Gebruik onderstaande code om je wachtwoord in te stellen:");

  return `
<p style="font-size:0.95rem;color:#444;margin-top:24px;">${intro}</p>
<p style="font-size:1.3rem;font-weight:700;letter-spacing:2px;margin:12px 0;color:#222;">${trimmed}</p>
`;
}

export function prefixSubject(subject: string, envLabel: string): string {
  return envLabel ? `[${envLabel}] ${subject}` : subject;
}

export function renderAuthEmail({
  templateId,
  actionLink,
  otp,
  name,
  copy = {},
  envLabel = "",
  supportEmail,
  year,
}: {
  templateId: AuthEmailTemplateId;
  actionLink?: string | null;
  otp?: string | null;
  name?: string | null;
  copy?: AuthEmailCopy;
  envLabel?: string;
  supportEmail: string;
  year: number;
}): string {
  const template = AUTH_EMAIL_TEMPLATES[templateId];
  const trimmedActionLink = actionLink?.trim() ?? "";
  const hasActionLink = trimmedActionLink.length > 0;
  const trimmedOtp = otp?.trim() ?? "";

  const replacements: Record<string, string> = {
    name: name?.trim() ?? "",
    greeting_line: buildGreeting(name),
    action_link: trimmedActionLink,
    action_section: hasActionLink
      ? buildActionSection(trimmedActionLink, copy)
      : "",
    otp: trimmedOtp,
    otp_section: buildOtpSection(trimmedOtp, hasActionLink, copy),
    env_banner: buildEnvironmentBanner(envLabel),
    support_email: supportEmail,
    year: `${year}`,
  };

  let result = template;
  for (const [key, value] of Object.entries(replacements)) {
    result = result.replaceAll(`{{${key}}}`, value);
  }
  return result;
}

/** What each kind sends: which template, subject, GoTrue link type and copy. */
export type AuthEmailSpec = {
  templateId: AuthEmailTemplateId;
  subject: string;
  /** GoTrue generateLink type, or null when the caller supplies the link. */
  linkType: "magiclink" | "recovery" | null;
  otpType: string | null;
  /**
   * Whether to point the button at the console's own set-password entry instead
   * of GoTrue's verify URL. Only the mails that ask the recipient to choose a
   * password do; a magic link is meant to land on GoTrue and sign them in.
   */
  rewriteEntryLink: boolean;
  /** Fall back to the raw GoTrue link when there is no OTP. */
  requireOtp: boolean;
  copy: AuthEmailCopy;
};

const ACTION_FALLBACK =
  "Werkt de knop niet? Kopieer dan deze link en plak hem in je browser:";

export function authEmailSpec(
  kind: AuthEmailKind,
  options: { siteName?: string | null; isNewUser?: boolean } = {},
): AuthEmailSpec {
  switch (kind) {
    case "login_otp":
      return {
        templateId: "loginOtp",
        subject: "Log in bij HostHub",
        linkType: "magiclink",
        otpType: null,
        rewriteEntryLink: false,
        requireOtp: false,
        copy: {
          actionIntro:
            "Log direct in via de knop hieronder. De link opent HostHub automatisch.",
          actionButtonLabel: "Open HostHub",
          actionFallback: ACTION_FALLBACK,
          otpIntroWithAction:
            "Lukt het niet via de knop? Gebruik dan onderstaande code:",
          otpIntroWithoutAction: "Gebruik onderstaande code om in te loggen:",
        },
      };
    case "sign_up_confirmation":
      return {
        templateId: "signUpConfirmation",
        subject: "Bevestig je e-mailadres",
        // Not GoTrue's `signup` type, which is what this used to ask for: that
        // one requires a password and would overwrite the one the user just
        // chose in signUp(). A magic link confirms the address on verify and
        // signs them in, which is what the copy below promises.
        linkType: "magiclink",
        otpType: null,
        rewriteEntryLink: false,
        requireOtp: false,
        copy: {
          actionIntro:
            "Bevestig je e-mailadres via de knop hieronder. De link opent HostHub automatisch.",
          actionButtonLabel: "Bevestig e-mailadres",
          actionFallback: ACTION_FALLBACK,
          otpIntroWithAction:
            "Werkt de knop niet? Gebruik dan onderstaande code om je account te bevestigen:",
          otpIntroWithoutAction:
            "Gebruik onderstaande code om je account te bevestigen:",
        },
      };
    case "user_created":
      return {
        templateId: "userCreated",
        subject: "Welkom bij HostHub",
        linkType: "recovery",
        otpType: null,
        rewriteEntryLink: true,
        requireOtp: true,
        copy: {},
      };
    case "password_reset":
      return {
        templateId: "passwordReset",
        subject: "Wachtwoord resetten",
        linkType: "recovery",
        otpType: "recovery",
        rewriteEntryLink: true,
        requireOtp: true,
        copy: {},
      };
    case "site_invitation": {
      const isNewUser = options.isNewUser ?? true;
      return {
        templateId: "siteInvitation",
        subject: `Je bent uitgenodigd voor ${
          options.siteName?.trim() || "een site"
        } op HostHub`,
        // invite_site_member has already minted the link for this address.
        linkType: null,
        otpType: null,
        rewriteEntryLink: true,
        requireOtp: true,
        copy: {
          actionIntro: isNewUser
            ? "Maak je account aan via de knop hieronder om toegang te krijgen."
            : "Klik op de knop hieronder om direct naar HostHub te gaan.",
          actionButtonLabel: isNewUser ? "Account aanmaken" : "Open HostHub",
          actionFallback: ACTION_FALLBACK,
          otpIntroWithAction:
            "Lukt het niet via de knop? Gebruik dan onderstaande code:",
          otpIntroWithoutAction: "Gebruik onderstaande code om in te loggen:",
        },
      };
    }
  }
}
