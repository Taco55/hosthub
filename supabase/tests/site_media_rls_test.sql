-- Integration test for the site-media storage policies (CONFORMANCE fase 2 §6:
-- "a user of site A can neither read nor write a file of site B").
--
-- Run it against a local stack:
--   psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/site_media_rls_test.sql
--
-- Everything happens inside one transaction that ROLLBACKs: the fixtures (two
-- users, two sites, two objects) never survive the run, so the test can be
-- repeated on a database somebody is working in.
--
-- It exercises the policy predicates the way PostgREST does — role
-- `authenticated` plus a JWT `sub` claim — because that, and not a Dart mock,
-- is what actually decides whether a byte crosses a tenant boundary.

BEGIN;

-- Fixtures. Non-admin users on purpose: an admin passes has_site_access for
-- every site, so testing with one would prove nothing about tenancy.
INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password,
                        email_confirmed_at, created_at, updated_at)
VALUES
    ('aaaaaaaa-0000-4000-8000-00000000000a'::uuid,
     '00000000-0000-0000-0000-000000000000'::uuid, 'authenticated',
     'authenticated', 'owner-a@rls.test', '', now(), now(), now()),
    ('bbbbbbbb-0000-4000-8000-00000000000b'::uuid,
     '00000000-0000-0000-0000-000000000000'::uuid, 'authenticated',
     'authenticated', 'owner-b@rls.test', '', now(), now(), now());

-- No trigger creates these locally, and is_admin must be false: an admin
-- passes has_site_access for every site.
INSERT INTO public.profiles (id, email, is_admin)
VALUES
    ('aaaaaaaa-0000-4000-8000-00000000000a'::uuid, 'owner-a@rls.test', false),
    ('bbbbbbbb-0000-4000-8000-00000000000b'::uuid, 'owner-b@rls.test', false)
ON CONFLICT (id) DO UPDATE SET is_admin = false;

INSERT INTO public.sites (id, name, owner_profile_id, default_locale, locales)
VALUES
    ('a5170000-0000-4000-8000-0000000000a5'::uuid, 'Site A',
     'aaaaaaaa-0000-4000-8000-00000000000a'::uuid, 'nl', ARRAY['nl']),
    ('b5170000-0000-4000-8000-0000000000b5'::uuid, 'Site B',
     'bbbbbbbb-0000-4000-8000-00000000000b'::uuid, 'nl', ARRAY['nl']);

-- One object per site, written as the service role (the seeding path).
INSERT INTO storage.objects (bucket_id, name, owner)
VALUES
    ('site-media', 'a5170000-0000-4000-8000-0000000000a5/photo-a.jpg', NULL),
    ('site-media', 'b5170000-0000-4000-8000-0000000000b5/photo-b.jpg', NULL);

INSERT INTO public.cms_media (site_id, storage_path, filename)
VALUES
    ('a5170000-0000-4000-8000-0000000000a5'::uuid,
     'a5170000-0000-4000-8000-0000000000a5/photo-a.jpg', 'photo-a.jpg'),
    ('b5170000-0000-4000-8000-0000000000b5'::uuid,
     'b5170000-0000-4000-8000-0000000000b5/photo-b.jpg', 'photo-b.jpg');

-- Act as owner A, the way PostgREST does.
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims =
    '{"sub":"aaaaaaaa-0000-4000-8000-00000000000a","role":"authenticated"}';

DO $$
DECLARE
    visible int;
    denied boolean;
BEGIN
    -- READ: own object yes, the other site's object no.
    SELECT count(*) INTO visible FROM storage.objects
    WHERE name LIKE 'a5170000-0000-4000-8000-0000000000a5/%';
    IF visible <> 1 THEN
        RAISE EXCEPTION 'owner A cannot read its own object (saw %)', visible;
    END IF;

    SELECT count(*) INTO visible FROM storage.objects
    WHERE name LIKE 'b5170000-0000-4000-8000-0000000000b5/%';
    IF visible <> 0 THEN
        RAISE EXCEPTION 'owner A can read site B objects (saw %)', visible;
    END IF;

    -- READ on the metadata rows: same boundary.
    SELECT count(*) INTO visible FROM public.cms_media
    WHERE site_id = 'b5170000-0000-4000-8000-0000000000b5'::uuid;
    IF visible <> 0 THEN
        RAISE EXCEPTION 'owner A can read site B cms_media rows (saw %)', visible;
    END IF;

    -- WRITE into the other site's folder: refused.
    denied := false;
    BEGIN
        INSERT INTO storage.objects (bucket_id, name, owner)
        VALUES ('site-media',
                'b5170000-0000-4000-8000-0000000000b5/sneaked-in.jpg', NULL);
    EXCEPTION WHEN insufficient_privilege THEN
        denied := true;
    END;
    IF NOT denied THEN
        RAISE EXCEPTION 'owner A could upload into site B''s folder';
    END IF;

    -- WRITE into its own folder: allowed.
    INSERT INTO storage.objects (bucket_id, name, owner)
    VALUES ('site-media',
            'a5170000-0000-4000-8000-0000000000a5/second-a.jpg', NULL);

    -- DELETE the other site's object: refused (silently affects no rows,
    -- because the row is not even visible to this user).
    DELETE FROM storage.objects
    WHERE name = 'b5170000-0000-4000-8000-0000000000b5/photo-b.jpg';
    SET LOCAL ROLE postgres;
    SELECT count(*) INTO visible FROM storage.objects
    WHERE name = 'b5170000-0000-4000-8000-0000000000b5/photo-b.jpg';
    IF visible <> 1 THEN
        RAISE EXCEPTION 'owner A deleted site B''s object';
    END IF;

    -- And a cms_media row of the other site cannot be written either.
    SET LOCAL ROLE authenticated;
    denied := false;
    BEGIN
        INSERT INTO public.cms_media (site_id, storage_path, filename)
        VALUES ('b5170000-0000-4000-8000-0000000000b5'::uuid,
                'b5170000-0000-4000-8000-0000000000b5/sneaked-in.jpg',
                'sneaked-in.jpg');
    EXCEPTION WHEN insufficient_privilege THEN
        denied := true;
    END;
    IF NOT denied THEN
        RAISE EXCEPTION 'owner A could add a cms_media row to site B';
    END IF;

    RAISE NOTICE 'site-media RLS: every cross-site read and write refused';
END $$;

ROLLBACK;
