import { createClient } from "npm:@supabase/supabase-js@2";

import { env } from "../_shared/env.ts";
import { buildCorsHeaders, jsonError, jsonResponse } from "../_shared/http.ts";

// Translates the auto fields of a page into one or more target languages
// (TRANSLATION.md). Locked fields are never sent here by the client; on top of
// that this function skips rows whose stored source_hash still matches the
// incoming source text (cache hit) and rows stored as locked (safety net).
// The provider key stays server-side: DeepL when DEEPL_API_KEY is set,
// otherwise a passthrough fallback so local development works without a key.

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env("SUPABASE_SERVICE_ROLE_KEY", "SUPABASE_SECRET_KEY");
const DEEPL_API_KEY = env("DEEPL_API_KEY");
const DEEPL_API_URL = env("DEEPL_API_URL") ?? "https://api-free.deepl.com/v2/translate";

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error("Missing Supabase configuration for translate-content function.");
}

const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

type FieldPayload = { key?: string; sourceText?: string };
type TranslatePayload = {
  siteId?: string;
  page?: string;
  sourceLanguage?: string;
  targetLanguages?: string[];
  fields?: FieldPayload[];
};

type TranslationResult = { key: string; language: string; value: string };

// DeepL target-language codes (TRANSLATION.md: NO = Norwegian Bokmål).
const deeplTarget: Record<string, string> = {
  en: "EN-GB",
  nl: "NL",
  no: "NB",
  nb: "NB",
};

async function sha256Hex(text: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(text),
  );
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

async function translateBatch(
  texts: string[],
  sourceLanguage: string,
  targetLanguage: string,
): Promise<string[]> {
  if (!DEEPL_API_KEY) {
    // Key-free fallback: return the source text unchanged. Publishing still
    // works; owners see untranslated copy until a provider key is configured.
    return texts;
  }
  const params = new URLSearchParams();
  for (const text of texts) params.append("text", text);
  params.set("source_lang", sourceLanguage.toUpperCase());
  params.set("target_lang", deeplTarget[targetLanguage] ?? targetLanguage.toUpperCase());

  const response = await fetch(DEEPL_API_URL, {
    method: "POST",
    headers: {
      "Authorization": `DeepL-Auth-Key ${DEEPL_API_KEY}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: params,
  });
  if (!response.ok) {
    const detail = await response.text();
    throw new Error(`translation_provider_error: ${response.status} ${detail}`);
  }
  const data = await response.json() as { translations: { text: string }[] };
  return data.translations.map((t) => t.text);
}

const cors = () => buildCorsHeaders();

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: cors() });
  if (req.method !== "POST") return jsonError(405, "Method not allowed");

  try {
    const authHeader = req.headers.get("authorization");
    if (!authHeader) return jsonError(401, "Missing authorization header");
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await adminClient.auth.getUser(token);
    if (authError || !user) return jsonError(401, "Unauthorized");

    const body = await req.json() as TranslatePayload;
    const siteId = body.siteId?.trim();
    const page = body.page?.trim();
    const sourceLanguage = body.sourceLanguage?.trim().toLowerCase();
    const targetLanguages = (body.targetLanguages ?? [])
      .map((l) => l.trim().toLowerCase())
      .filter((l) => l.length > 0 && l !== sourceLanguage);
    const fields = (body.fields ?? []).filter(
      (f): f is { key: string; sourceText: string } =>
        typeof f.key === "string" && typeof f.sourceText === "string",
    );
    if (!siteId || !page || !sourceLanguage) {
      return jsonError(400, "Missing siteId, page or sourceLanguage");
    }
    if (targetLanguages.length === 0 || fields.length === 0) {
      return jsonResponse({ translations: [] });
    }

    const { data: hasAccess, error: accessError } = await adminClient.rpc(
      "has_site_access",
      { check_site_id: siteId, check_user_id: user.id, min_role: "editor" },
    );
    if (accessError) return jsonError(500, accessError.message);
    if (!hasAccess) return jsonError(403, "insufficient_permissions");

    const sourceHashes = new Map<string, string>();
    for (const field of fields) {
      sourceHashes.set(field.key, await sha256Hex(field.sourceText));
    }

    const { data: existingRows, error: fetchError } = await adminClient
      .from("site_translations")
      .select("field_key, language, value, status, source_hash")
      .eq("site_id", siteId)
      .eq("page", page)
      .in("language", targetLanguages);
    if (fetchError) return jsonError(500, fetchError.message);

    const existing = new Map(
      (existingRows ?? []).map((r) => [`${r.language}:${r.field_key}`, r]),
    );

    const results: TranslationResult[] = [];
    const upserts: Record<string, unknown>[] = [];
    const translatedAt = new Date().toISOString();

    for (const language of targetLanguages) {
      const pending: { key: string; sourceText: string }[] = [];
      for (const field of fields) {
        const row = existing.get(`${language}:${field.key}`);
        if (row?.status === "locked") {
          // Safety net: never overwrite owner-authored text.
          results.push({ key: field.key, language, value: row.value });
          continue;
        }
        if (row && row.source_hash === sourceHashes.get(field.key)) {
          // Cache hit: source unchanged since this auto value was generated.
          results.push({ key: field.key, language, value: row.value });
          continue;
        }
        pending.push(field);
      }
      if (pending.length === 0) continue;

      const translated = await translateBatch(
        pending.map((f) => f.sourceText),
        sourceLanguage,
        language,
      );
      pending.forEach((field, index) => {
        const value = translated[index] ?? field.sourceText;
        results.push({ key: field.key, language, value });
        upserts.push({
          site_id: siteId,
          page,
          field_key: field.key,
          language,
          value,
          status: "auto",
          source_hash: sourceHashes.get(field.key),
          translated_at: translatedAt,
        });
      });
    }

    if (upserts.length > 0) {
      const { error: upsertError } = await adminClient
        .from("site_translations")
        .upsert(upserts, { onConflict: "site_id,page,field_key,language" });
      if (upsertError) return jsonError(500, upsertError.message);
    }

    return jsonResponse({ translations: results });
  } catch (error) {
    console.error("[translate-content] Error:", error);
    return jsonError(500, (error as Error).message);
  }
});
