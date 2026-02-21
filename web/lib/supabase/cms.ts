import type { Locale } from "../i18n";
import { supabase } from "./client";

const DEFAULT_CMS_QUERY_TIMEOUT_MS = 1200;

function getCmsQueryTimeoutMs(): number {
  const raw = process.env.CMS_QUERY_TIMEOUT_MS;
  if (!raw) return DEFAULT_CMS_QUERY_TIMEOUT_MS;

  const parsed = Number.parseInt(raw, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return DEFAULT_CMS_QUERY_TIMEOUT_MS;
  }
  return parsed;
}

async function raceWithTimeout<T>(
  promise: PromiseLike<T>,
  timeoutMs: number,
): Promise<T | null> {
  let timer: ReturnType<typeof setTimeout> | undefined;
  const timeout = new Promise<null>((resolve) => {
    timer = setTimeout(() => resolve(null), timeoutMs);
  });

  try {
    return (await Promise.race([promise, timeout])) as T | null;
  } finally {
    if (timer) clearTimeout(timer);
  }
}

/**
 * Fetches a single published CMS document's content from Supabase.
 * Returns `null` when the Supabase client is not configured, the document
 * does not exist, times out, or the query fails.
 */
export async function fetchDocument<T>(
  siteId: string,
  contentType: string,
  slug: string,
  locale: Locale,
  options?: { includeDrafts?: boolean },
): Promise<T | null> {
  if (!supabase) return null;

  try {
    let query = supabase
      .from("cms_documents")
      .select("content")
      .eq("site_id", siteId)
      .eq("content_type", contentType)
      .eq("slug", slug)
      .eq("locale", locale);

    if (!options?.includeDrafts) {
      query = query.eq("status", "published");
    }

    const result = await raceWithTimeout(
      Promise.resolve(query.maybeSingle()),
      getCmsQueryTimeoutMs(),
    );
    if (!result) return null;

    const { data, error } = result;
    if (error || !data) return null;
    return data.content as T;
  } catch {
    return null;
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
      getCmsQueryTimeoutMs(),
    );

    if (!result) return [];
    const { data, error } = result;
    if (error || !data) return [];
    return data.map((row) => row.content as T);
  } catch {
    return [];
  }
}
