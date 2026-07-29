// supabase/functions/_shared/auth_email_test.ts
//
// Run: deno test supabase/functions/_shared/auth_email_test.ts
//
// The entry-link cases are ported one-for-one from the Dart test that covered
// AuthEntryLinkBuilder before this logic moved server-side, so the move is
// provably behaviour-preserving rather than merely plausible.

import { assert, assertEquals } from "jsr:@std/assert@1";

import {
  authEmailSpec,
  buildAuthEntryLink,
  buildSafeAuthEntryLink,
  prefixSubject,
  renderAuthEmail,
} from "./auth_email.ts";

Deno.test("builds a safe set-password link from a recovery verify link", () => {
  const actionLink =
    "https://example.supabase.co/auth/v1/verify?token=abc&type=recovery&redirect_to=http%3A%2F%2Flocalhost%3A43002%2Freset-password";

  const url = new URL(
    buildAuthEntryLink({
      actionLink,
      email: "test@example.com",
      otp: "123456",
    }),
  );

  assertEquals(url.origin, "http://localhost:43002");
  assertEquals(url.pathname, "/set-password");
  assertEquals(url.searchParams.get("email"), "test@example.com");
  assertEquals(url.searchParams.get("otp"), "123456");
  assertEquals(url.searchParams.get("otp_type"), "recovery");
});

Deno.test("preserves the invite otp type", () => {
  const actionLink =
    "https://example.supabase.co/auth/v1/verify?token=abc&type=invite&redirect_to=http%3A%2F%2Flocalhost%3A43002%2Fset-password";

  const url = new URL(
    buildAuthEntryLink({
      actionLink,
      email: "test@example.com",
      otp: "654321",
    }),
  );

  assertEquals(url.origin, "http://localhost:43002");
  assertEquals(url.pathname, "/set-password");
  assertEquals(url.searchParams.get("otp"), "654321");
  assertEquals(url.searchParams.get("otp_type"), "invite");
});

Deno.test("keeps a nested path prefix for the redirect path", () => {
  const actionLink =
    "https://example.supabase.co/auth/v1/verify?token=abc&type=recovery&redirect_to=https%3A%2F%2Fadmin.example.com%2Fauth%2Freset-password";

  const url = new URL(
    buildAuthEntryLink({ actionLink, email: "test@example.com" }),
  );

  assertEquals(url.origin, "https://admin.example.com");
  assertEquals(url.pathname, "/auth/set-password");
  assertEquals(url.searchParams.get("email"), "test@example.com");
  assertEquals(url.searchParams.get("otp_type"), "recovery");
  assertEquals(url.searchParams.has("otp"), false);
});

Deno.test("falls back to the original link when redirect_to is missing", () => {
  const actionLink =
    "https://example.supabase.co/auth/v1/verify?token=abc&type=recovery";

  assertEquals(
    buildAuthEntryLink({
      actionLink,
      email: "test@example.com",
      otp: "123456",
    }),
    actionLink,
  );
});

Deno.test("requireOtp keeps the raw link when no otp came back", () => {
  const actionLink =
    "https://example.supabase.co/auth/v1/verify?token=abc&type=recovery&redirect_to=http%3A%2F%2Flocalhost%3A43002%2Freset-password";

  assertEquals(
    buildSafeAuthEntryLink({
      email: "test@example.com",
      actionLink,
      otp: "",
      requireOtp: true,
    }),
    actionLink,
  );
});

Deno.test("an empty action link stays empty", () => {
  assertEquals(
    buildSafeAuthEntryLink({ email: "test@example.com", actionLink: null }),
    "",
  );
});

Deno.test("the rendered mail carries the link and the code, and no placeholders", () => {
  // userCreated is one of the three templates that has a {{greeting_line}};
  // login_otp and password_reset deliberately have none.
  const html = renderAuthEmail({
    templateId: "userCreated",
    actionLink: "https://admin.example.com/set-password?email=a%40b.c&otp=123456",
    otp: "123456",
    name: "Taco",
    envLabel: "DEV",
    supportEmail: "support@example.com",
    year: 2026,
  });

  assert(html.includes("Hallo Taco,"));
  assert(html.includes("https://admin.example.com/set-password"));
  assert(html.includes("123456"));
  assert(html.includes("support@example.com"));
  assert(html.includes("2026"));
  assert(html.includes("DEV"));
  assertEquals(/\{\{[a-z_]+\}\}/.test(html), false, "unsubstituted placeholder");
});

Deno.test("without a name the greeting stays generic", () => {
  const html = renderAuthEmail({
    templateId: "userCreated",
    actionLink: "https://admin.example.com/set-password",
    otp: "999888",
    supportEmail: "support@example.com",
    year: 2026,
  });

  assert(html.includes("Hallo!"));
  assertEquals(html.includes("Hallo ,"), false);
});

Deno.test("no action link drops the button and switches the otp copy", () => {
  const spec = authEmailSpec("login_otp");
  const html = renderAuthEmail({
    templateId: spec.templateId,
    actionLink: "",
    otp: "999888",
    copy: spec.copy,
    supportEmail: "support@example.com",
    year: 2026,
  });

  assert(html.includes("999888"));
  assertEquals(html.includes("Open HostHub"), false);
  assert(html.includes("Gebruik onderstaande code om in te loggen:"));
});

Deno.test("sign-up confirmation asks GoTrue for a magic link, not a signup link", () => {
  // `signup` requires a password and would overwrite the one the user just
  // chose in signUp(); that is the bug this replaced.
  const spec = authEmailSpec("sign_up_confirmation");
  assertEquals(spec.linkType, "magiclink");
  assertEquals(spec.rewriteEntryLink, false);
});

Deno.test("only the set-password mails rewrite the entry link", () => {
  assertEquals(authEmailSpec("login_otp").rewriteEntryLink, false);
  assertEquals(authEmailSpec("sign_up_confirmation").rewriteEntryLink, false);
  assertEquals(authEmailSpec("user_created").rewriteEntryLink, true);
  assertEquals(authEmailSpec("password_reset").rewriteEntryLink, true);
  assertEquals(authEmailSpec("site_invitation").rewriteEntryLink, true);
});

Deno.test("the invitation subject names the site, and falls back when it does not", () => {
  assertEquals(
    authEmailSpec("site_invitation", { siteName: "Trysil Panorama" }).subject,
    "Je bent uitgenodigd voor Trysil Panorama op HostHub",
  );
  assertEquals(
    authEmailSpec("site_invitation", { siteName: "  " }).subject,
    "Je bent uitgenodigd voor een site op HostHub",
  );
});

Deno.test("the invitation button follows whether the user is new", () => {
  assertEquals(
    authEmailSpec("site_invitation", { isNewUser: true }).copy
      .actionButtonLabel,
    "Account aanmaken",
  );
  assertEquals(
    authEmailSpec("site_invitation", { isNewUser: false }).copy
      .actionButtonLabel,
    "Open HostHub",
  );
});

Deno.test("the env label prefixes the subject only when set", () => {
  assertEquals(prefixSubject("Wachtwoord resetten", "DEV"), "[DEV] Wachtwoord resetten");
  assertEquals(prefixSubject("Wachtwoord resetten", ""), "Wachtwoord resetten");
});
