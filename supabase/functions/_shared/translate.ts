// Machine translation with a provider fallback, shared by every function that
// needs text in another language.
//
// It lives here rather than in translate-content because two callers now need
// it and they need different things around it: page content is cached in
// site_translations and keyed on a source hash, a guest message is translated
// once for reading and never stored. The provider chain is the part they share,
// and duplicating it would mean a second place a key can go missing.
//
// Provider selection (any key stays server-side), first match wins:
//   1. TRANSLATE_PROVIDER env override (deepl | libretranslate | mymemory)
//   2. DEEPL_API_KEY set          -> DeepL (free tier, needs an account key)
//   3. LIBRETRANSLATE_URL set     -> self-hosted LibreTranslate (no key)
//   4. default                    -> MyMemory (keyless, free)

import { env } from "./env.ts";

const DEEPL_API_KEY = env("DEEPL_API_KEY");
const DEEPL_API_URL = env("DEEPL_API_URL") ??
  "https://api-free.deepl.com/v2/translate";
const LIBRETRANSLATE_URL = env("LIBRETRANSLATE_URL");
const LIBRETRANSLATE_API_KEY = env("LIBRETRANSLATE_API_KEY");
const MYMEMORY_URL = env("MYMEMORY_URL") ??
  "https://api.mymemory.translated.net/get";
const MYMEMORY_EMAIL = env("MYMEMORY_EMAIL");

export type TranslationProvider = "deepl" | "libretranslate" | "mymemory";

export function resolveProvider(): TranslationProvider {
  const override = env("TRANSLATE_PROVIDER")?.toLowerCase();
  if (
    override === "deepl" || override === "libretranslate" ||
    override === "mymemory"
  ) {
    return override;
  }
  if (DEEPL_API_KEY) return "deepl";
  if (LIBRETRANSLATE_URL) return "libretranslate";
  return "mymemory";
}

// DeepL target-language codes (NO = Norwegian Bokmål).
const deeplTarget: Record<string, string> = {
  en: "EN-GB",
  nl: "NL",
  no: "NB",
  nb: "NB",
};

async function translateWithDeepl(
  texts: string[],
  sourceLanguage: string,
  targetLanguage: string,
): Promise<string[]> {
  const params = new URLSearchParams();
  for (const text of texts) params.append("text", text);
  params.set("source_lang", sourceLanguage.toUpperCase());
  params.set(
    "target_lang",
    deeplTarget[targetLanguage] ?? targetLanguage.toUpperCase(),
  );

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

async function translateWithLibreTranslate(
  texts: string[],
  sourceLanguage: string,
  targetLanguage: string,
): Promise<string[]> {
  // Norwegian Bokmål is "nb" in LibreTranslate's model list.
  const target = targetLanguage === "no" ? "nb" : targetLanguage;
  const response = await fetch(
    `${LIBRETRANSLATE_URL!.replace(/\/+$/, "")}/translate`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        q: texts,
        source: sourceLanguage,
        target,
        format: "text",
        ...(LIBRETRANSLATE_API_KEY ? { api_key: LIBRETRANSLATE_API_KEY } : {}),
      }),
    },
  );
  if (!response.ok) {
    const detail = await response.text();
    throw new Error(`translation_provider_error: ${response.status} ${detail}`);
  }
  const data = await response.json() as { translatedText: string | string[] };
  const translated = data.translatedText;
  return Array.isArray(translated) ? translated : [translated];
}

async function translateWithMyMemory(
  texts: string[],
  sourceLanguage: string,
  targetLanguage: string,
): Promise<string[]> {
  // MyMemory translates one segment per request; the volumes here are short
  // and few, and cache hits never reach this point.
  const results: string[] = [];
  for (const text of texts) {
    const url = new URL(MYMEMORY_URL);
    url.searchParams.set("q", text);
    url.searchParams.set("langpair", `${sourceLanguage}|${targetLanguage}`);
    if (MYMEMORY_EMAIL) url.searchParams.set("de", MYMEMORY_EMAIL);

    const response = await fetch(url);
    if (!response.ok) {
      const detail = await response.text();
      throw new Error(
        `translation_provider_error: ${response.status} ${detail}`,
      );
    }
    const data = await response.json() as {
      responseStatus: number;
      responseData?: { translatedText?: string };
    };
    const value = data.responseData?.translatedText;
    if (data.responseStatus !== 200 || typeof value !== "string") {
      throw new Error(
        `translation_provider_error: mymemory ${data.responseStatus}`,
      );
    }
    results.push(value);
  }
  return results;
}

/** Translate a batch of texts, in order, through the resolved provider. */
export function translateBatch(
  texts: string[],
  sourceLanguage: string,
  targetLanguage: string,
): Promise<string[]> {
  switch (resolveProvider()) {
    case "deepl":
      return translateWithDeepl(texts, sourceLanguage, targetLanguage);
    case "libretranslate":
      return translateWithLibreTranslate(texts, sourceLanguage, targetLanguage);
    case "mymemory":
      return translateWithMyMemory(texts, sourceLanguage, targetLanguage);
  }
}

export async function sha256Hex(text: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(text),
  );
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}
