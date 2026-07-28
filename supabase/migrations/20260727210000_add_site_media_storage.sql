-- Storage for a site's own photos, and CMS media rows an editor may manage.
--
-- One bucket, and the **first path segment is the site id**:
--   site-media/<site_id>/<uuid>.<ext>
-- Every policy below reads that segment and asks public.has_site_access, so a
-- file's tenant is a property of where it lives and not of a column somebody
-- has to remember to set.
--
-- Read access is deliberately split (see docs-internal note in the build-loop
-- state): objects are served to the public website by URL — a public site's
-- photos are public by definition, and signed URLs whose TTL fights HTML
-- caching would break the pages that render them — while the **API** path is
-- scoped, so a console user of site A cannot list or fetch site B's objects
-- through Supabase. Writing is scoped everywhere.

-- The bucket. Public reads (the website), 8 MB per object and image types
-- only, matching the upload requirements the picker states in its dropzone.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'site-media',
    'site-media',
    true,
    8388608,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE
SET public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Reading through the API: only for someone who has access to that site.
DROP POLICY IF EXISTS "Site members read their site's media objects" ON storage.objects;
CREATE POLICY "Site members read their site's media objects"
ON storage.objects
FOR SELECT
TO authenticated
USING (
    bucket_id = 'site-media'
    AND public.has_site_access(
        ((storage.foldername(name))[1])::uuid,
        auth.uid(),
        'viewer'
    )
);

-- Writing: an editor of that site, and nobody else. Upload, replace, remove.
DROP POLICY IF EXISTS "Site editors upload their site's media objects" ON storage.objects;
CREATE POLICY "Site editors upload their site's media objects"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'site-media'
    AND public.has_site_access(
        ((storage.foldername(name))[1])::uuid,
        auth.uid(),
        'editor'
    )
);

DROP POLICY IF EXISTS "Site editors replace their site's media objects" ON storage.objects;
CREATE POLICY "Site editors replace their site's media objects"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
    bucket_id = 'site-media'
    AND public.has_site_access(
        ((storage.foldername(name))[1])::uuid,
        auth.uid(),
        'editor'
    )
)
WITH CHECK (
    bucket_id = 'site-media'
    AND public.has_site_access(
        ((storage.foldername(name))[1])::uuid,
        auth.uid(),
        'editor'
    )
);

DROP POLICY IF EXISTS "Site editors delete their site's media objects" ON storage.objects;
CREATE POLICY "Site editors delete their site's media objects"
ON storage.objects
FOR DELETE
TO authenticated
USING (
    bucket_id = 'site-media'
    AND public.has_site_access(
        ((storage.foldername(name))[1])::uuid,
        auth.uid(),
        'editor'
    )
);

-- cms_media was publicly readable — filenames, alt text and (now) which page
-- uses a photo, for every site, to anyone with the anon key. Nothing reads it
-- that way: the public website renders image keys out of its documents and
-- fetches the bytes from the bucket by URL, so the library is a console-only
-- table. Scope it to the site, which is what CONFORMANCE §6 asks for.
DROP POLICY IF EXISTS "CMS media is publicly readable" ON public.cms_media;
DROP POLICY IF EXISTS "Site members read CMS media" ON public.cms_media;
CREATE POLICY "Site members read CMS media"
ON public.cms_media
FOR SELECT
TO authenticated
USING (public.has_site_access(site_id, auth.uid(), 'viewer'));

-- cms_media carried an owner-only manage policy while every other CMS table
-- lets an editor work (site_translations, cms_documents). A site member who
-- may write the copy but not the photo it sits next to is an accident, not a
-- rule: bring it in line with has_site_access.
DROP POLICY IF EXISTS "Site owners can manage CMS media" ON public.cms_media;
DROP POLICY IF EXISTS "Site editors manage CMS media" ON public.cms_media;
CREATE POLICY "Site editors manage CMS media"
ON public.cms_media
FOR ALL
TO authenticated
USING (public.has_site_access(site_id, auth.uid(), 'editor'))
WITH CHECK (public.has_site_access(site_id, auth.uid(), 'editor'));

-- Which fields of the site use a file, so the picker can say `Home (hero)` and
-- refuse to delete something a live page still renders.
ALTER TABLE public.cms_media
    ADD COLUMN IF NOT EXISTS usage jsonb NOT NULL DEFAULT '[]'::jsonb;

COMMENT ON COLUMN public.cms_media.usage IS
    'Field addresses that reference this file (["page/home:heroPhotos"]). '
    'Kept by the console when it writes image keys, so the picker can name a '
    'file''s use and block deleting one that is still on a page.';

-- The console addresses a file by its storage path; that has to be unique per
-- site, and it is the natural key for "is this file already in the library".
CREATE UNIQUE INDEX IF NOT EXISTS cms_media_site_storage_path_key
    ON public.cms_media (site_id, storage_path);
