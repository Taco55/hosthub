// supabase/functions/send_email/index.ts
import { env } from "../_shared/env.ts";
import { buildCorsHeaders } from "../_shared/http.ts";

const RESEND_API_KEY = env("RESEND_API_KEY");
const FROM_EMAIL = env("FROM_EMAIL");
const FROM_NAME = env("FROM_NAME");

const missingResendConfig = [
  ...(RESEND_API_KEY ? [] : ["RESEND_API_KEY"]),
  ...(FROM_EMAIL ? [] : ["FROM_EMAIL"]),
];

const cors = () => buildCorsHeaders();
const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: cors() });
const jsonError = (status: number, message: string) =>
  jsonResponse({ error: message }, status);

type AttachmentPayload = {
  filename?: string;
  content?: string;
  contentType?: string;
  contentId?: string;
  cid?: string;
};

type EmailPayload = {
  to?: string | string[];
  subject?: string;
  html?: string;
  attachments?: AttachmentPayload[];
};

type ResendAttachment = {
  filename: string;
  content: string;
  contentType?: string;
  contentId?: string;
};

const buildFromField = () =>
  FROM_NAME && FROM_NAME.trim().length > 0
    ? `${FROM_NAME.trim()} <${FROM_EMAIL}>`
    : FROM_EMAIL;

const normalizeRecipients = (value: string | string[] | undefined) => {
  if (!value) return [];
  const list = Array.isArray(value) ? value : [value];
  return list
    .map((entry) => (typeof entry === "string" ? entry.trim() : ""))
    .filter((entry) => entry.length > 0);
};

const normalizeAttachments = (
  attachments: AttachmentPayload[] | undefined,
): ResendAttachment[] => {
  if (!attachments || attachments.length === 0) return [];

  return attachments
    .map((att) => ({
      filename: att.filename ?? "attachment",
      content: att.content ?? "",
      contentType: att.contentType ?? "application/octet-stream",
      contentId: att.contentId ?? att.cid,
    }))
    .filter((att) => att.content.length > 0);
};

const buildResendPayload = (payload: EmailPayload) => {
  const to = normalizeRecipients(payload.to);
  const subject = payload.subject?.toString().trim() ?? "";
  const html = payload.html?.toString() ?? "";

  if (to.length === 0) {
    throw new Error("Missing or invalid recipient");
  }

  if (!subject) {
    throw new Error("Missing email subject");
  }

  if (!html) {
    throw new Error("Missing email HTML body");
  }

  const resendPayload: Record<string, unknown> = {
    from: buildFromField(),
    to,
    subject,
    html,
  };

  const attachments = normalizeAttachments(payload.attachments);
  if (attachments.length > 0) {
    resendPayload.attachments = attachments;
  }

  return resendPayload;
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(undefined, { status: 204, headers: cors() });
  }

  if (missingResendConfig.length > 0) {
    return jsonResponse(
      {
        error: "Missing Resend configuration",
        missing: missingResendConfig,
        code: "MISSING_RESEND_CONFIGURATION",
        hint:
          "Provide RESEND_API_KEY and FROM_EMAIL secrets in your Supabase project settings.",
      },
      500,
    );
  }

  if (req.method !== "POST") {
    return jsonError(405, "Method not allowed");
  }

  let payload: EmailPayload;
  try {
    payload = await req.json();
  } catch {
    return jsonError(400, "Invalid JSON payload");
  }

  let resendPayload: Record<string, unknown>;
  try {
    resendPayload = buildResendPayload(payload);
  } catch (error) {
    const message = error instanceof Error ? error.message : "Invalid payload";
    return jsonError(400, message);
  }

  try {
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(resendPayload),
    });

    const text = await response.text();
    let data: unknown;
    try {
      data = JSON.parse(text);
    } catch {
      data = { raw: text };
    }

    if (!response.ok) {
      return jsonResponse(
        {
          error: "Resend API error",
          status: response.status,
          details: data,
        },
        response.status,
      );
    }

    return jsonResponse(
      {
        message: "Email dispatched",
        data,
      },
      200,
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return jsonError(500, `Failed to call Resend API: ${message}`);
  }
});