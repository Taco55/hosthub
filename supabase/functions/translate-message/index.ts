// Translate one guest message, for reading.
//
// Separate from translate-content because the two want opposite things around
// the same provider chain (_shared/translate.ts). Page copy is site content:
// it is cached in site_translations, keyed on a source hash, and the stored
// value is what gets published. A guest message is not content — it is a record
// of what somebody wrote. So this function stores nothing: what the guest wrote
// stays the truth, the translation is a reading aid that the owner asks for and
// can dismiss with "Origineel tonen".
//
// Authorisation runs through the thread's property, the same account access the
// inbox itself is behind.

import { createClient } from "npm:@supabase/supabase-js@2";

import { env } from "../_shared/env.ts";
import { buildCorsHeaders, jsonError, jsonResponse } from "../_shared/http.ts";
import { translateBatch } from "../_shared/translate.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error("Missing Supabase configuration for translate-message.");
}

const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const cors = () => buildCorsHeaders();

type Payload = {
  threadId?: string;
  targetLanguage?: string;
  sourceLanguage?: string;
  messageIds?: string[];
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: cors() });
  if (req.method !== "POST") return jsonError(405, "Method not allowed");

  try {
    const authHeader = req.headers.get("authorization");
    if (!authHeader) return jsonError(401, "Missing authorization header");
    const token = authHeader.replace("Bearer ", "").trim();
    const { data: { user }, error: authError } = await adminClient.auth.getUser(
      token,
    );
    if (authError || !user) return jsonError(401, "Unauthorized");

    const body = await req.json() as Payload;
    const threadId = body.threadId?.trim();
    const targetLanguage = body.targetLanguage?.trim().toLowerCase();
    const messageIds = (body.messageIds ?? []).filter((id) =>
      typeof id === "string" && id.trim().length > 0
    );
    if (!threadId || !targetLanguage) {
      return jsonError(400, "Missing threadId or targetLanguage");
    }
    if (messageIds.length === 0) return jsonResponse({ translations: [] });

    const { data: thread, error: threadError } = await adminClient
      .from("message_threads")
      .select("id, property_id, guest_locale")
      .eq("id", threadId)
      .maybeSingle();
    if (threadError) return jsonError(500, threadError.message);
    if (!thread) return jsonError(404, "thread_not_found");

    const { data: property, error: propertyError } = await adminClient
      .from("properties")
      .select("owner_profile_id")
      .eq("id", thread.property_id)
      .maybeSingle();
    if (propertyError) return jsonError(500, propertyError.message);

    const { data: hasAccess, error: accessError } = await adminClient.rpc(
      "has_account_access",
      {
        check_owner_profile_id: property?.owner_profile_id,
        check_user_id: user.id,
      },
    );
    if (accessError) return jsonError(500, accessError.message);
    if (!hasAccess) return jsonError(403, "insufficient_permissions");

    const { data: rows, error: messagesError } = await adminClient
      .from("messages")
      .select("id, body")
      .eq("thread_id", threadId)
      .in("id", messageIds);
    if (messagesError) return jsonError(500, messagesError.message);

    const messages = (rows ?? []).filter((row) =>
      typeof row.body === "string" && row.body.trim().length > 0
    );
    if (messages.length === 0) return jsonResponse({ translations: [] });

    const sourceLanguage = body.sourceLanguage?.trim().toLowerCase() ??
      (typeof thread.guest_locale === "string"
        ? thread.guest_locale.trim().toLowerCase().split("-")[0]
        : "");
    if (!sourceLanguage || sourceLanguage === targetLanguage) {
      // Nothing to do rather than a round trip that returns the input.
      return jsonResponse({ translations: [] });
    }

    const translated = await translateBatch(
      messages.map((message) => message.body as string),
      sourceLanguage,
      targetLanguage,
    );

    return jsonResponse({
      translations: messages.map((message, index) => ({
        messageId: message.id,
        language: targetLanguage,
        value: translated[index] ?? message.body,
      })),
    });
  } catch (error) {
    console.error("[translate-message] Error:", error);
    return jsonError(500, (error as Error).message);
  }
});
