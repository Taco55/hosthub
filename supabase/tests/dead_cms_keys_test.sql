-- Tests the dead-key cleanup (README fase 2 §0.1) against documents shaped
-- like the ones on production.
--
--   psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/dead_cms_keys_test.sql
--
-- It runs the migration file itself rather than a copy, inside a transaction
-- that ROLLBACKs: a data migration nobody re-ran against real shapes is a
-- migration nobody tested.

BEGIN;

INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password,
                        email_confirmed_at, created_at, updated_at)
VALUES ('cccccccc-0000-4000-8000-00000000000c'::uuid,
        '00000000-0000-0000-0000-000000000000'::uuid, 'authenticated',
        'authenticated', 'owner-c@keys.test', '', now(), now(), now());

INSERT INTO public.profiles (id, email, is_admin)
VALUES ('cccccccc-0000-4000-8000-00000000000c'::uuid, 'owner-c@keys.test', false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.sites (id, name, owner_profile_id, default_locale, locales)
VALUES ('c5170000-0000-4000-8000-0000000000c5'::uuid, 'Site C',
        'cccccccc-0000-4000-8000-00000000000c'::uuid, 'nl', ARRAY['nl']);

-- cabin/main as production holds it: the four dead blocks next to the live ones.
INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content,
                                  draft_content, status)
VALUES (
    'c5170000-0000-4000-8000-0000000000c5'::uuid, 'cabin', 'main', 'nl',
    jsonb_build_object(
        'hero', jsonb_build_object('title', 'Titel'),
        'description', jsonb_build_array('Alinea'),
        'houseRules', jsonb_build_object('title', 'Goed om te weten'),
        'amenities', jsonb_build_object('title', 'Voorzieningen'),
        'experience', jsonb_build_array('Ski in/out'),
        'layoutAndFacilities', jsonb_build_object('title', 'Indeling'),
        'accessAndTransport', jsonb_build_object('title', 'Bereikbaarheid'),
        'policies', jsonb_build_object('title', 'Voorwaarden')
    ),
    jsonb_build_object(
        'hero', jsonb_build_object('title', 'Titel (concept)'),
        'experience', jsonb_build_array('Ski in/out'),
        'policies', jsonb_build_object('title', 'Voorwaarden')
    ),
    'draft'
);

-- page/home, including a location object whose only key is the dead blurb.
INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content,
                                  status)
VALUES (
    'c5170000-0000-4000-8000-0000000000c5'::uuid, 'page', 'home', 'nl',
    jsonb_build_object(
        'tagline', 'Comfortabel chalet',
        'keyFacts', jsonb_build_array(jsonb_build_object('label', 'gasten')),
        'highlights', jsonb_build_array(jsonb_build_object('title', 'Sauna')),
        'amenities', jsonb_build_array('Vloerverwarming'),
        'reviews', jsonb_build_array(jsonb_build_object('name', 'Sanne')),
        'faq', jsonb_build_array(jsonb_build_object('question', 'Hoe?')),
        'location', jsonb_build_object('description', 'In Fageråsen')
    ),
    'published'
);

-- And a home document whose location holds something real as well, to prove
-- the cleanup takes the blurb and not the object.
INSERT INTO public.cms_documents (site_id, content_type, slug, locale, content,
                                  status)
VALUES (
    'c5170000-0000-4000-8000-0000000000c5'::uuid, 'page', 'home', 'en',
    jsonb_build_object(
        'location', jsonb_build_object('description', 'In Fageråsen',
                                       'mapQuery', 'Fageråsen')
    ),
    'published'
);

INSERT INTO public.site_translations (site_id, page, field_key, language, value)
VALUES
    ('c5170000-0000-4000-8000-0000000000c5'::uuid, 'home',
     'chalet.experience.0', 'en', 'Ski in/out'),
    ('c5170000-0000-4000-8000-0000000000c5'::uuid, 'home',
     'cabin.hero.title', 'en', 'Title');

\i supabase/migrations/20260727220000_drop_dead_cms_keys.sql

DO $$
DECLARE
    cabin jsonb;
    cabin_draft jsonb;
    home_nl jsonb;
    home_en jsonb;
    leftovers int;
BEGIN
    SELECT content, draft_content INTO cabin, cabin_draft
    FROM public.cms_documents
    WHERE content_type = 'cabin' AND slug = 'main'
      AND site_id = 'c5170000-0000-4000-8000-0000000000c5'::uuid;

    IF cabin ? 'experience' OR cabin ? 'layoutAndFacilities'
       OR cabin ? 'accessAndTransport' OR cabin ? 'policies' THEN
        RAISE EXCEPTION 'cabin/main still holds a dead block: %',
            (SELECT string_agg(k, ', ') FROM jsonb_object_keys(cabin) k);
    END IF;

    -- The live blocks are untouched, including the two the handoff keeps.
    IF NOT (cabin ? 'hero' AND cabin ? 'description'
            AND cabin ? 'houseRules' AND cabin ? 'amenities') THEN
        RAISE EXCEPTION 'cabin/main lost a block it renders';
    END IF;

    -- The draft layer gets the same treatment: an unpublished document that
    -- keeps a dead key would put it back on the next publish.
    IF cabin_draft ? 'experience' OR cabin_draft ? 'policies' THEN
        RAISE EXCEPTION 'cabin/main draft still holds a dead block';
    END IF;
    IF NOT cabin_draft ? 'hero' THEN
        RAISE EXCEPTION 'cabin/main draft lost its hero';
    END IF;

    SELECT content INTO home_nl FROM public.cms_documents
    WHERE content_type = 'page' AND slug = 'home' AND locale = 'nl'
      AND site_id = 'c5170000-0000-4000-8000-0000000000c5'::uuid;

    IF home_nl ? 'amenities' OR home_nl ? 'reviews' OR home_nl ? 'faq' THEN
        RAISE EXCEPTION 'page/home still holds a dead key';
    END IF;
    IF home_nl ? 'location' THEN
        RAISE EXCEPTION 'page/home kept a location object with nothing in it';
    END IF;
    IF NOT (home_nl ? 'tagline' AND home_nl ? 'keyFacts'
            AND home_nl ? 'highlights') THEN
        RAISE EXCEPTION 'page/home lost a key it renders';
    END IF;

    SELECT content INTO home_en FROM public.cms_documents
    WHERE content_type = 'page' AND slug = 'home' AND locale = 'en'
      AND site_id = 'c5170000-0000-4000-8000-0000000000c5'::uuid;

    -- The blurb goes; the object survives because it holds something real.
    IF (home_en -> 'location') ? 'description' THEN
        RAISE EXCEPTION 'page/home kept the dead location blurb';
    END IF;
    IF NOT ((home_en -> 'location') ? 'mapQuery') THEN
        RAISE EXCEPTION 'page/home lost a live location key';
    END IF;

    SELECT count(*) INTO leftovers FROM public.site_translations
    WHERE site_id = 'c5170000-0000-4000-8000-0000000000c5'::uuid
      AND field_key LIKE 'chalet.%';
    IF leftovers <> 0 THEN
        RAISE EXCEPTION 'translations for dead fields survived (%)', leftovers;
    END IF;

    SELECT count(*) INTO leftovers FROM public.site_translations
    WHERE site_id = 'c5170000-0000-4000-8000-0000000000c5'::uuid
      AND field_key = 'cabin.hero.title';
    IF leftovers <> 1 THEN
        RAISE EXCEPTION 'a live translation was deleted';
    END IF;

    RAISE NOTICE 'dead keys removed; every live key and translation kept';
END $$;

ROLLBACK;
