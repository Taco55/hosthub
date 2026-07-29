// supabase/functions/_shared/resend.ts
//
// One place that talks to Resend, so a function that needs to send mail does not
// have to be reachable by a client to do it.

import { env } from "./env.ts";

const RESEND_API_KEY = env("RESEND_API_KEY");
const FROM_EMAIL = env("FROM_EMAIL");
const FROM_NAME = env("FROM_NAME");

export type ResendResult =
  | { ok: true; data: unknown }
  | { ok: false; status: number; error: string; details?: unknown };

/** Missing config names, empty when Resend is usable. */
export function missingResendConfig(): string[] {
  return [
    ...(RESEND_API_KEY ? [] : ["RESEND_API_KEY"]),
    ...(FROM_EMAIL ? [] : ["FROM_EMAIL"]),
  ];
}

export function buildFromField(overrideName?: string | null): string {
  const address = FROM_EMAIL ?? "";
  const name = overrideName?.trim() || FROM_NAME?.trim();
  return name ? `${name} <${address}>` : address;
}

export async function sendViaResend({
  to,
  subject,
  html,
  fromName,
}: {
  to: string;
  subject: string;
  html: string;
  fromName?: string | null;
}): Promise<ResendResult> {
  const missing = missingResendConfig();
  if (missing.length > 0) {
    return {
      ok: false,
      status: 500,
      error: "Missing Resend configuration",
      details: { missing },
    };
  }

  try {
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: buildFromField(fromName),
        to: [to],
        subject,
        html,
      }),
    });

    const text = await response.text();
    let data: unknown;
    try {
      data = JSON.parse(text);
    } catch {
      data = { raw: text };
    }

    if (!response.ok) {
      return {
        ok: false,
        status: response.status,
        error: "Resend API error",
        details: data,
      };
    }

    return { ok: true, data };
  } catch (error) {
    return {
      ok: false,
      status: 500,
      error: `Failed to call Resend API: ${
        error instanceof Error ? error.message : String(error)
      }`,
    };
  }
}
