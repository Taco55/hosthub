import assert from "node:assert/strict";
import { test } from "node:test";

import { isResolvedImageSrc, mediaPublicUrl, mediaPublicUrls } from "./media-url";

const BASE = process.env.NEXT_PUBLIC_SUPABASE_URL;

test("a storage path becomes a public bucket URL", () => {
  process.env.NEXT_PUBLIC_SUPABASE_URL = "https://example.supabase.co";
  try {
    assert.equal(
      mediaPublicUrl("site-1/photo.jpg"),
      "https://example.supabase.co/storage/v1/object/public/site-media/site-1/photo.jpg",
    );
  } finally {
    process.env.NEXT_PUBLIC_SUPABASE_URL = BASE;
  }
});

test("a trailing slash on the base does not double up", () => {
  process.env.NEXT_PUBLIC_SUPABASE_URL = "https://example.supabase.co///";
  try {
    assert.ok(
      mediaPublicUrl("s/p.jpg").startsWith(
        "https://example.supabase.co/storage/v1/",
      ),
    );
  } finally {
    process.env.NEXT_PUBLIC_SUPABASE_URL = BASE;
  }
});

test("each path segment is encoded, and the separators survive", () => {
  // Encoding the whole path would turn the slashes into %2F and every photo
  // with a space in its name into a 404.
  process.env.NEXT_PUBLIC_SUPABASE_URL = "https://example.supabase.co";
  try {
    assert.equal(
      mediaPublicUrl("site 1/my photo.jpg"),
      "https://example.supabase.co/storage/v1/object/public/site-media/site%201/my%20photo.jpg",
    );
  } finally {
    process.env.NEXT_PUBLIC_SUPABASE_URL = BASE;
  }
});

test("an already-resolved src is returned untouched", () => {
  // This is what lets a site be half-migrated: a repo path and a bucket path can
  // sit in the same slot.
  for (const src of [
    "https://cdn.example/x.jpg",
    "http://cdn.example/x.jpg",
    "/images/hero/x.jpg",
  ]) {
    assert.equal(mediaPublicUrl(src), src);
    assert.equal(isResolvedImageSrc(src), true);
  }
  assert.equal(isResolvedImageSrc("site-1/photo.jpg"), false);
});

test("a slot drops everything that is not a non-empty string", () => {
  assert.deepEqual(
    mediaPublicUrls(["/a.jpg", "", null, 3, undefined, "/b.jpg"]),
    ["/a.jpg", "/b.jpg"],
  );
  assert.deepEqual(mediaPublicUrls("not a list"), []);
  assert.deepEqual(mediaPublicUrls(undefined), []);
});
