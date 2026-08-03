import { cache } from "react";

import type { Locale } from "../i18n";
import { supabase } from "./client";
import { getServiceClient } from "./service";

/**
 * How long a page waits for the CMS before rendering its fallback content.
 * A constant, not a setting: it is a rendering deadline, and no deployment has
 * ever wanted a different one.
 */
const CMS_QUERY_TIMEOUT_MS = 1200;

const TIMED_OUT = Symbol("cms-query-timeout");

async function raceWithTimeout<T>(
  promise: PromiseLike<T>,
  timeoutMs: number,
): Promise<T | typeof TIMED_OUT> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  const timeout = new Promise<typeof TIMED_OUT>((resolve) => {
    timer = setTimeout(() => resolve(TIMED_OUT), timeoutMs);
  });

  try {
    return await Promise.race([promise, timeout]);
  } finally {
    if (timer) clearTimeout(timer);
  }
}

/** Why a document could not be read. */
export type DocumentUnavailableReason =
  | "not_configured"
  | "no_preview_key"
  | "timeout"
  | "error";

/**
 * The outcome of one document read. A miss is not the same thing as a failure:
 * "there is no document" means the site's fallback content is the right answer,
 * while "the query failed" means we do not know — and in the preview that
 * difference is the whole point, so the caller gets to tell them apart instead
 * of receiving null for both.
 */
export type DocumentOutcome<T> =
  | { status: "ok"; content: T; source: "published" | "draft" }
  | { status: "missing" }
  | { status: "unavailable"; reason: DocumentUnavailableReason; detail?: string };

/** One row of the site's document set, as the reading client can see it. */
export type DocumentIndexEntry = {
  contentType: string;
  slug: string;
  status: string;
  hasDraft: boolean;
};

export type DocumentIndexOutcome =
  | { status: "ok"; entries: DocumentIndexEntry[] }
  | { status: "unavailable"; reason: DocumentUnavailableReason; detail?: string };

/**
 * Picks the client for a read.
 *
 * Public reads use the anon key. Preview reads need the server-side key: RLS
 * only exposes `status = 'published'`, so a document the owner never published
 * is invisible to the anon key — which is exactly what the preview exists to
 * show. Same shared client as the rest of the server-side reads.
 */
function clientFor(includeDrafts: boolean) {
  if (includeDrafts) {
    const client = getServiceClient();
    return client
      ? { client, reason: null as null }
      : { client: null, reason: "no_preview_key" as const };
  }
  return supabase
    ? { client: supabase, reason: null as null }
    : { client: null, reason: "not_configured" as const };
}

/**
 * Reads one document, once per request.
 *
 * Rendering one page asks for the same document several times over: the layout
 * and the page each need `site_config`, and metadata needs it a third time.
 * Every one of those was its own round trip to Supabase — a home page cost
 * six to eight of them, all for four distinct documents. Deduplication is
 * per-request, so it changes no content and cannot serve anything stale; it
 * only stops asking the same question twice in the same breath.
 *
 * Keyed on primitives, not on the options object: `cache` memoizes by argument
 * identity, and a fresh `{includeDrafts}` literal per call would miss every
 * time. Drafts are part of the key — a preview and a public read of the same
 * document are different reads.
 */
const readDocument = cache(
  async (
    siteId: string,
    contentType: string,
    slug: string,
    locale: Locale,
    includeDrafts: boolean,
  ): Promise<DocumentOutcome<unknown>> =>
    readDocumentUncached(siteId, contentType, slug, locale, includeDrafts),
);

export function fetchDocument<T>(
  siteId: string,
  contentType: string,
  slug: string,
  locale: Locale,
  options?: { includeDrafts?: boolean },
): Promise<DocumentOutcome<T>> {
  return readDocument(
    siteId,
    contentType,
    slug,
    locale,
    Boolean(options?.includeDrafts),
  ) as Promise<DocumentOutcome<T>>;
}

/**
 * Reads one CMS document from Supabase.
 *
 * Public reads see published content only. Preview reads (`includeDrafts`)
 * prefer the document's `draft_content` when it has one — that is the copy the
 * owner saved but has not published yet.
 */
async function readDocumentUncached(
  siteId: string,
  contentType: string,
  slug: string,
  locale: Locale,
  includeDrafts: boolean,
): Promise<DocumentOutcome<unknown>> {
  const { client, reason } = clientFor(includeDrafts);
  if (!client) return { status: "unavailable", reason };

  try {
    let query = client
      .from("cms_documents")
      .select("content, draft_content")
      .eq("site_id", siteId)
      .eq("content_type", contentType)
      .eq("slug", slug)
      .eq("locale", locale);

    if (!includeDrafts) {
      query = query.eq("status", "published");
    }

    const result = await raceWithTimeout(
      Promise.resolve(query.maybeSingle()),
      CMS_QUERY_TIMEOUT_MS,
    );
    if (result === TIMED_OUT) return { status: "unavailable", reason: "timeout" };

    const { data, error } = result;
    if (error) {
      return { status: "unavailable", reason: "error", detail: error.message };
    }
    if (!data) return { status: "missing" };
    // A document keeps its unpublished work in `draft_content`; only the
    // preview reads it. Live pages render what was published, which is why a
    // save in the console can no longer change what a guest sees.
    if (includeDrafts && data.draft_content) {
      return { status: "ok", content: data.draft_content, source: "draft" };
    }
    if (!data.content) return { status: "missing" };
    return { status: "ok", content: data.content, source: "published" };
  } catch (error) {
    return {
      status: "unavailable",
      reason: "error",
      detail: error instanceof Error ? error.message : String(error),
    };
  }
}

/**
 * Lists the site's documents for one locale, as the reading client can see
 * them. The preview banner uses this to state what it is actually showing:
 * with the same client and the same RLS path as the reads themselves, so it
 * cannot claim "loaded from CMS" while the pages render fallback content.
 */
export async function fetchDocumentIndex(
  siteId: string,
  locale: Locale,
  options?: { includeDrafts?: boolean },
): Promise<DocumentIndexOutcome> {
  const includeDrafts = Boolean(options?.includeDrafts);
  const { client, reason } = clientFor(includeDrafts);
  if (!client) return { status: "unavailable", reason };

  try {
    let query = client
      .from("cms_documents")
      .select("content_type, slug, status, draft_content")
      .eq("site_id", siteId)
      .eq("locale", locale);

    if (!includeDrafts) {
      query = query.eq("status", "published");
    }

    const result = await raceWithTimeout(
      Promise.resolve(query),
      CMS_QUERY_TIMEOUT_MS,
    );
    if (result === TIMED_OUT) return { status: "unavailable", reason: "timeout" };

    const { data, error } = result;
    if (error) {
      return { status: "unavailable", reason: "error", detail: error.message };
    }
    return {
      status: "ok",
      entries: (data ?? []).map((row) => ({
        contentType: row.content_type as string,
        slug: row.slug as string,
        status: row.status as string,
        hasDraft: Boolean(row.draft_content),
      })),
    };
  } catch (error) {
    return {
      status: "unavailable",
      reason: "error",
      detail: error instanceof Error ? error.message : String(error),
    };
  }
}

/**
 * Fetches all published CMS documents for a given site and content type.
 * Returns [] when the query times out or fails.
 */
export async function fetchDocuments<T>(
  siteId: string,
  contentType: string,
  locale: Locale,
): Promise<T[]> {
  if (!supabase) return [];

  try {
    const result = await raceWithTimeout(
      Promise.resolve(
        supabase
          .from("cms_documents")
          .select("slug, content")
          .eq("site_id", siteId)
          .eq("content_type", contentType)
          .eq("locale", locale)
          .eq("status", "published"),
      ),
      CMS_QUERY_TIMEOUT_MS,
    );

    if (result === TIMED_OUT) return [];
    const { data, error } = result;
    if (error || !data) return [];
    return data.map((row) => row.content as T);
  } catch {
    return [];
  }
}
