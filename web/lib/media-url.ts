/**
 * Turns a stored media path into the URL the site renders.
 *
 * The console stores `<siteId>/<uuid>.<ext>` — the path the storage policies
 * read to decide who may write it. Reading is public by design: a public
 * website's photos are public, and a signed URL whose TTL fights HTML caching
 * would break the very pages that render them.
 *
 * A value that is already a URL (or a repo path like `/images/hero/x.jpg`) is
 * returned untouched, so a site can be half-migrated without the pages caring.
 */

const BUCKET = "site-media";

export function isResolvedImageSrc(value: string): boolean {
  return (
    value.startsWith("http://") ||
    value.startsWith("https://") ||
    value.startsWith("/")
  );
}

export function mediaPublicUrl(storagePath: string): string {
  if (isResolvedImageSrc(storagePath)) return storagePath;

  const base = (process.env.NEXT_PUBLIC_SUPABASE_URL ?? "").replace(/\/+$/, "");
  if (!base) {
    // Without a Supabase URL there is nothing to resolve against. Returning the
    // bare path keeps the page rendering (a broken image beats a 500) and the
    // warning says why it broke.
    console.warn(
      `[media] NEXT_PUBLIC_SUPABASE_URL is not set; cannot resolve ${storagePath}`,
    );
    return storagePath;
  }
  const encoded = storagePath.split("/").map(encodeURIComponent).join("/");
  return `${base}/storage/v1/object/public/${BUCKET}/${encoded}`;
}

/** The same for a whole slot, dropping anything that is not a string. */
export function mediaPublicUrls(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value
    .filter((entry): entry is string => typeof entry === "string" && entry !== "")
    .map(mediaPublicUrl);
}
