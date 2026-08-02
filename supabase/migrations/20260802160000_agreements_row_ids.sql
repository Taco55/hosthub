-- Stable row ids for the agreements blocks and their lines.
--
-- The stable-row-id migration gave every repeatable list objects carrying an
-- `id`, but it skipped `agreementsAndPayment`: that section was read-only in
-- the editor at the time, labelled as coming from Lodgify. It is editable now,
-- and the editor addresses a row by its id — a row without one is skipped, so
-- the card would render its title above nothing at all.
--
-- The id is derived from the site and the row's position, not random, so every
-- locale of the same document lands on the same ids. That is what makes a
-- translation stay attached to the line it translates.
--
-- Idempotent: a row that already has an id keeps it, and re-running changes
-- nothing.
UPDATE public.cms_documents AS d
SET content = jsonb_set(
      content,
      '{agreementsAndPayment,blocks}',
      (
        SELECT jsonb_agg(
                 block
                 || jsonb_build_object(
                      'id',
                      COALESCE(
                        block ->> 'id',
                        substr(md5(d.site_id::text || ':agreements:' || (bi - 1)::text), 1, 8)
                      ),
                      'items',
                      COALESCE(
                        (
                          SELECT jsonb_agg(
                                   CASE
                                     WHEN jsonb_typeof(item) = 'object' THEN
                                       item || jsonb_build_object(
                                         'id',
                                         COALESCE(
                                           item ->> 'id',
                                           substr(md5(d.site_id::text || ':agreements:' || (bi - 1)::text || ':' || (ii - 1)::text), 1, 8)
                                         )
                                       )
                                     ELSE
                                       jsonb_build_object(
                                         'id',
                                         substr(md5(d.site_id::text || ':agreements:' || (bi - 1)::text || ':' || (ii - 1)::text), 1, 8),
                                         'text', item #>> '{}'
                                       )
                                   END
                                   ORDER BY ii
                                 )
                          FROM jsonb_array_elements(block -> 'items')
                               WITH ORDINALITY AS items(item, ii)
                        ),
                        '[]'::jsonb
                      )
                    )
                 ORDER BY bi
               )
        FROM jsonb_array_elements(d.content -> 'agreementsAndPayment' -> 'blocks')
             WITH ORDINALITY AS blocks(block, bi)
      )
    )
WHERE d.content_type = 'page'
  AND d.slug = 'practical'
  AND jsonb_typeof(d.content -> 'agreementsAndPayment' -> 'blocks') = 'array'
  AND EXISTS (
    SELECT 1
    FROM jsonb_array_elements(d.content -> 'agreementsAndPayment' -> 'blocks') AS b
    WHERE NOT (b ? 'id')
       OR EXISTS (
         SELECT 1 FROM jsonb_array_elements(b -> 'items') AS i
         WHERE jsonb_typeof(i) <> 'object' OR NOT (i ? 'id')
       )
  );
