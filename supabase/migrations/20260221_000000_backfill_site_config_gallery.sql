-- One-time backfill:
-- Populate `site_config.gallery` from existing `galleryAllFilenames`
-- for documents where `gallery` is missing or empty.

WITH target_docs AS (
  SELECT
    d.id,
    d.content,
    NULLIF(
      regexp_replace(COALESCE(d.content #>> '{imagePaths,galleryAll}', ''), '/+$', ''),
      ''
    ) AS gallery_path
  FROM public.cms_documents d
  WHERE d.content_type = 'site_config'
    AND d.slug = 'main'
    AND CASE
      WHEN jsonb_typeof(d.content->'galleryAllFilenames') = 'array'
      THEN jsonb_array_length(d.content->'galleryAllFilenames') > 0
      ELSE false
    END
    AND (
      NOT (d.content ? 'gallery')
      OR COALESCE(jsonb_typeof(d.content->'gallery'), '') <> 'array'
      OR (
        jsonb_typeof(d.content->'gallery') = 'array'
        AND jsonb_array_length(d.content->'gallery') = 0
      )
    )
),
built_gallery AS (
  SELECT
    t.id,
    COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'src',
          CASE
            WHEN f.filename ~ '^(https?:)?/' THEN f.filename
            WHEN t.gallery_path IS NULL THEN f.filename
            ELSE t.gallery_path || '/' || f.filename
          END,
          'alt',
          jsonb_build_object(
            'nl', '',
            'en', '',
            'no', ''
          )
        )
        ORDER BY f.ord
      ),
      '[]'::jsonb
    ) AS gallery
  FROM target_docs t
  JOIN LATERAL (
    SELECT
      trim(e.value) AS filename,
      e.ord
    FROM jsonb_array_elements_text(t.content->'galleryAllFilenames') WITH ORDINALITY AS e(value, ord)
    WHERE trim(e.value) <> ''
  ) f ON true
  GROUP BY t.id, t.gallery_path
)
UPDATE public.cms_documents d
SET content = jsonb_set(d.content, '{gallery}', b.gallery, true)
FROM built_gallery b
WHERE d.id = b.id;
