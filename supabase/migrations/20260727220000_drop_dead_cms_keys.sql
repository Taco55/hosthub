-- Removes the CMS keys no page renders (README fase 2 §0.1).
--
-- These sat in the documents while nothing on the site read them, and the
-- editor deliberately gives them no field: a field the owner edits that never
-- appears anywhere is worse than no field. Once they are also out of the
-- documents they stop showing up in schema dumps, translation scopes and
-- everyone's mental model of what a page holds.
--
-- Kept on purpose, and therefore absent from this list:
--   cabin.houseRules      -- now rendered on the homepage (HouseRules.tsx)
--   cabin.amenities       -- its items became editable and are rendered
--   home.tagline          -- rendered on Gallery and Area
--
-- Reviews and FAQ go too: they are a separate design question (where on the
-- page, how many, with or without a source), not a field-model question, so
-- nothing renders them today and nothing should pretend to.
--
-- Idempotent: `-` on a jsonb object is a no-op for a key that is not there.

UPDATE public.cms_documents
SET content = content
        - 'experience'
        - 'layoutAndFacilities'
        - 'accessAndTransport'
        - 'policies',
    draft_content = CASE
        WHEN draft_content IS NULL THEN NULL
        ELSE draft_content
            - 'experience'
            - 'layoutAndFacilities'
            - 'accessAndTransport'
            - 'policies'
    END
WHERE content_type = 'cabin'
  AND slug = 'main';

-- page/home: the flat amenities list (the grouped one on cabin/main is what
-- renders), the unused location blurb, and the two unmounted sections.
UPDATE public.cms_documents
SET content = (content - 'amenities' - 'reviews' - 'faq')
        || CASE
            WHEN content -> 'location' IS NULL THEN '{}'::jsonb
            ELSE jsonb_build_object(
                'location',
                (content -> 'location') - 'description'
            )
        END,
    draft_content = CASE
        WHEN draft_content IS NULL THEN NULL
        ELSE (draft_content - 'amenities' - 'reviews' - 'faq')
            || CASE
                WHEN draft_content -> 'location' IS NULL THEN '{}'::jsonb
                ELSE jsonb_build_object(
                    'location',
                    (draft_content -> 'location') - 'description'
                )
            END
    END
WHERE content_type = 'page'
  AND slug = 'home';

-- A `location` object that held nothing but that blurb is now empty; drop it
-- rather than leave a key whose only content was dead.
UPDATE public.cms_documents
SET content = content - 'location',
    draft_content = CASE
        WHEN draft_content IS NULL THEN NULL
        ELSE draft_content - 'location'
    END
WHERE content_type = 'page'
  AND slug = 'home'
  AND content -> 'location' = '{}'::jsonb;

-- The translation rows that belonged to those fields have nothing left to
-- translate; they are the only rows keyed by a `chalet.*` field key, which the
-- schema stopped using when the field model became path-based.
DELETE FROM public.site_translations
WHERE field_key LIKE 'chalet.experience.%'
   OR field_key LIKE 'chalet.layoutAndFacilities.%'
   OR field_key LIKE 'chalet.accessAndTransport.%'
   OR field_key LIKE 'chalet.policies.%';
