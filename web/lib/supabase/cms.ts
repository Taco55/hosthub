import type { Locale } from "../i18n";
import { supabase } from "./client";

/**
 * Fetches a single published CMS document's content from Supabase.
 * Returns `null` when the Supabase client is not configured, the document
 * does not exist, or the query fails.
 */
export async function fetchDocument<T>(
  siteId: string,
  contentType: string,
  slug: string,
  locale: Locale,
  options?: { includeDrafts?: boolean },
): Promise<T | null> {
  if (!supabase) return null;

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

  const { data, error } = await query.maybeSingle();

  if (error || !data) return null;
  return data.content as T;
}

/**
 * Fetches all published CMS documents for a given site and content type.
 */
export async function fetchDocuments<T>(
  siteId: string,
  contentType: string,
  locale: Locale,
): Promise<T[]> {
  if (!supabase) return [];

  const { data, error } = await supabase
    .from("cms_documents")
    .select("slug, content")
    .eq("site_id", siteId)
    .eq("content_type", contentType)
    .eq("locale", locale)
    .eq("status", "published");

  if (error || !data) return [];
  return data.map((row) => row.content as T);
}
