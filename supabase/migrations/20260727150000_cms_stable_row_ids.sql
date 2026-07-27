-- Stable ids for repeatable CMS list rows.
--
-- Until now a list row was addressed by its array index (`highlights.0`).
-- That makes identity positional: drag row 1 to position 3 and the
-- translation of row 1 becomes the translation of row 2. This migration gives
-- every row an `id` it keeps for life; the array index becomes display order
-- and nothing else.
--
-- Shapes:
--   ["Eerste", "Tweede"]                -> [{id, text}, {id, text}]
--   [{title, description}]              -> [{id, title, description, ...}]
--   highlights[i] + highlightImages[i]  -> highlights[i] {id, ..., image, alt}
--
-- Ids are **deterministic** — md5(site_id || document || path || index),
-- first 8 hex characters — so every locale of the same document (and both its
-- `content` and `draft_content`) gets the same id for the same row. The arrays
-- correspond by index today, which is exactly what makes that safe, and it is
-- also what makes this migration idempotent: re-running it is a no-op because
-- rows that already have an id are left alone.

begin;

-- Row id for one array element. Deterministic in the row's position *today*;
-- from then on the id travels with the row and the position may change.
create or replace function public.cms_row_id(
  p_site_id uuid,
  p_document text,
  p_path text,
  p_index int
) returns text
language sql
immutable
as $$
  select substr(
    md5(p_site_id::text || ':' || p_document || ':' || p_path || ':' || p_index::text),
    1,
    8
  );
$$;

-- Adds ids to a text list: ["a"] -> [{"id": "...", "text": "a"}].
-- Rows that are already objects with an id are returned untouched.
create or replace function public.cms_add_ids_to_text_list(
  p_list jsonb,
  p_site_id uuid,
  p_document text,
  p_path text
) returns jsonb
language sql
immutable
as $$
  select case
    when p_list is null or jsonb_typeof(p_list) <> 'array' then p_list
    else coalesce(
      (
        select jsonb_agg(
          case
            when jsonb_typeof(elem) = 'object' and elem ? 'id' then elem
            when jsonb_typeof(elem) = 'object' then
              elem || jsonb_build_object(
                'id',
                public.cms_row_id(p_site_id, p_document, p_path, (idx - 1)::int)
              )
            else jsonb_build_object(
              'id',
              public.cms_row_id(p_site_id, p_document, p_path, (idx - 1)::int),
              'text',
              elem
            )
          end
          order by idx
        )
        from jsonb_array_elements(p_list) with ordinality as t(elem, idx)
      ),
      '[]'::jsonb
    )
  end;
$$;

-- Adds ids to an object list, leaving the objects' own keys alone.
create or replace function public.cms_add_ids_to_object_list(
  p_list jsonb,
  p_site_id uuid,
  p_document text,
  p_path text
) returns jsonb
language sql
immutable
as $$
  select case
    when p_list is null or jsonb_typeof(p_list) <> 'array' then p_list
    else coalesce(
      (
        select jsonb_agg(
          case
            when jsonb_typeof(elem) <> 'object' or elem ? 'id' then elem
            else elem || jsonb_build_object(
              'id',
              public.cms_row_id(p_site_id, p_document, p_path, (idx - 1)::int)
            )
          end
          order by idx
        )
        from jsonb_array_elements(p_list) with ordinality as t(elem, idx)
      ),
      '[]'::jsonb
    )
  end;
$$;

-- Adds ids to a group list *and* to each group's own item list, keying the
-- items' path on the group's id so two groups cannot collide.
create or replace function public.cms_add_ids_to_group_list(
  p_list jsonb,
  p_site_id uuid,
  p_document text,
  p_path text,
  p_items_key text
) returns jsonb
language plpgsql
immutable
as $$
declare
  v_groups jsonb;
  v_index int;
  v_items jsonb;
  v_group_id text;
begin
  if p_list is null or jsonb_typeof(p_list) <> 'array' then
    return p_list;
  end if;

  v_groups := public.cms_add_ids_to_object_list(
    p_list, p_site_id, p_document, p_path
  );

  for v_index in 0 .. jsonb_array_length(v_groups) - 1 loop
    v_items := v_groups #> array[v_index::text, p_items_key];
    if jsonb_typeof(v_items) = 'array' then
      v_group_id := v_groups #>> array[v_index::text, 'id'];
      v_groups := jsonb_set(
        v_groups,
        array[v_index::text, p_items_key],
        public.cms_add_ids_to_text_list(
          v_items,
          p_site_id,
          p_document,
          p_path || '.' || coalesce(v_group_id, v_index::text) || '.' || p_items_key
        )
      );
    end if;
  end loop;

  return v_groups;
end;
$$;

-- Fuses the highlight rows with their parallel image array, by index — the
-- last moment those two arrays still correspond, which is the whole reason
-- this cannot wait.
create or replace function public.cms_fuse_highlights(
  p_content jsonb,
  p_site_id uuid
) returns jsonb
language sql
immutable
as $$
  select case
    when p_content is null
      or jsonb_typeof(p_content -> 'highlights') <> 'array' then p_content
    else (p_content - 'highlightImages') || jsonb_build_object(
      'highlights',
      coalesce(
        (
          select jsonb_agg(
            case
              when jsonb_typeof(row) <> 'object' then row
              else row
                || case
                     when row ? 'id' then '{}'::jsonb
                     else jsonb_build_object(
                       'id',
                       public.cms_row_id(p_site_id, 'page/home', 'highlights', (idx - 1)::int)
                     )
                   end
                || case
                     when row ? 'image' then '{}'::jsonb
                     when jsonb_typeof(p_content #> array['highlightImages', (idx - 1)::text]) = 'object'
                       then jsonb_build_object(
                         'image',
                         p_content #>> array['highlightImages', (idx - 1)::text, 'src'],
                         'alt',
                         p_content #>> array['highlightImages', (idx - 1)::text, 'alt']
                       )
                     else '{}'::jsonb
                   end
            end
            order by idx
          )
          from jsonb_array_elements(p_content -> 'highlights') with ordinality as t(row, idx)
        ),
        '[]'::jsonb
      )
    )
  end;
$$;

-- Applies every list transform for one document's JSON.
create or replace function public.cms_migrate_document(
  p_content jsonb,
  p_site_id uuid,
  p_content_type text,
  p_slug text
) returns jsonb
language plpgsql
immutable
as $$
declare
  v_document text := p_content_type || '/' || p_slug;
  v_result jsonb := p_content;
  v_key text;
begin
  if v_result is null or jsonb_typeof(v_result) <> 'object' then
    return v_result;
  end if;

  if v_document = 'cabin/main' then
    if v_result ? 'description' then
      v_result := jsonb_set(
        v_result,
        '{description}',
        public.cms_add_ids_to_text_list(
          v_result -> 'description', p_site_id, v_document, 'description'
        )
      );
    end if;
    if v_result ? 'experience' then
      v_result := jsonb_set(
        v_result,
        '{experience}',
        public.cms_add_ids_to_text_list(
          v_result -> 'experience', p_site_id, v_document, 'experience'
        )
      );
    end if;
    if jsonb_typeof(v_result #> '{houseRules,bullets}') = 'array' then
      v_result := jsonb_set(
        v_result,
        '{houseRules,bullets}',
        public.cms_add_ids_to_text_list(
          v_result #> '{houseRules,bullets}', p_site_id, v_document, 'houseRules.bullets'
        )
      );
    end if;
    if jsonb_typeof(v_result #> '{location,distances}') = 'array' then
      v_result := jsonb_set(
        v_result,
        '{location,distances}',
        public.cms_add_ids_to_object_list(
          v_result #> '{location,distances}', p_site_id, v_document, 'location.distances'
        )
      );
    end if;
    if jsonb_typeof(v_result #> '{hero,badges}') = 'array' then
      v_result := jsonb_set(
        v_result,
        '{hero,badges}',
        public.cms_add_ids_to_object_list(
          v_result #> '{hero,badges}', p_site_id, v_document, 'hero.badges'
        )
      );
    end if;
    -- Amenity groups: ids on the groups and on each group's items.
    if jsonb_typeof(v_result #> '{amenities,groups}') = 'array' then
      v_result := jsonb_set(
        v_result,
        '{amenities,groups}',
        public.cms_add_ids_to_group_list(
          v_result #> '{amenities,groups}',
          p_site_id,
          v_document,
          'amenities.groups',
          'items'
        )
      );
    end if;
  end if;

  if v_document = 'page/home' then
    v_result := public.cms_fuse_highlights(v_result, p_site_id);
    if v_result ? 'keyFacts' then
      v_result := jsonb_set(
        v_result,
        '{keyFacts}',
        public.cms_add_ids_to_object_list(
          v_result -> 'keyFacts', p_site_id, v_document, 'keyFacts'
        )
      );
    end if;
    if v_result ? 'amenities' then
      v_result := jsonb_set(
        v_result,
        '{amenities}',
        public.cms_add_ids_to_text_list(
          v_result -> 'amenities', p_site_id, v_document, 'amenities'
        )
      );
    end if;
  end if;

  if v_document = 'page/practical' then
    foreach v_key in array array['arrivalAccess', 'parkingCharging', 'goodToKnow', 'contactHelp'] loop
      if jsonb_typeof(v_result #> array[v_key, 'bullets']) = 'array' then
        v_result := jsonb_set(
          v_result,
          array[v_key, 'bullets'],
          public.cms_add_ids_to_text_list(
            v_result #> array[v_key, 'bullets'], p_site_id, v_document, v_key || '.bullets'
          )
        );
      end if;
    end loop;
    if v_result ? 'quickFacts' then
      v_result := jsonb_set(
        v_result,
        '{quickFacts}',
        public.cms_add_ids_to_object_list(
          v_result -> 'quickFacts', p_site_id, v_document, 'quickFacts'
        )
      );
    end if;
    -- Sections and columns: ids on the group and on each group's bullets.
    if jsonb_typeof(v_result #> '{layoutFacilities,sections}') = 'array' then
      v_result := jsonb_set(
        v_result,
        '{layoutFacilities,sections}',
        public.cms_add_ids_to_group_list(
          v_result #> '{layoutFacilities,sections}',
          p_site_id,
          v_document,
          'layoutFacilities.sections',
          'bullets'
        )
      );
    end if;
    if jsonb_typeof(v_result #> '{transport,columns}') = 'array' then
      v_result := jsonb_set(
        v_result,
        '{transport,columns}',
        public.cms_add_ids_to_group_list(
          v_result #> '{transport,columns}',
          p_site_id,
          v_document,
          'transport.columns',
          'bullets'
        )
      );
    end if;
  end if;

  if v_document = 'page/area' and jsonb_typeof(v_result -> 'sections') = 'array' then
    v_result := jsonb_set(
      v_result,
      '{sections}',
      public.cms_add_ids_to_group_list(
        v_result -> 'sections', p_site_id, v_document, 'sections', 'bullets'
      )
    );
  end if;

  if v_document = 'page/privacy' and v_result ? 'bullets' then
    v_result := jsonb_set(
      v_result,
      '{bullets}',
      public.cms_add_ids_to_text_list(
        v_result -> 'bullets', p_site_id, v_document, 'bullets'
      )
    );
  end if;

  return v_result;
end;
$$;

update public.cms_documents
set
  content = public.cms_migrate_document(content, site_id, content_type, slug),
  draft_content = case
    when draft_content is null then null
    else public.cms_migrate_document(draft_content, site_id, content_type, slug)
  end;

-- Version snapshots stay as they were: they are a record of what was published
-- at the time, and rewriting history to a shape that did not exist then would
-- make a rollback restore something nobody ever saw.

-- The editor's field keys move with the documents. Index-based keys become
-- id-based ones by looking the row's id up in the (already migrated) source
-- document, so a translation stays attached to the row it was written for.
update public.site_translations t
set field_key = 'cabin.hero.title'
where field_key = 'hero.headline';

update public.site_translations t
set field_key = 'cabin.hero.subtitle'
where field_key = 'hero.subtitle';

update public.site_translations t
set field_key = 'cabin.description.'
  || (
    select d.content #>> array['description', split_part(t.field_key, '.', 3), 'id']
    from public.cms_documents d
    join public.sites s on s.id = d.site_id
    where d.site_id = t.site_id
      and d.content_type = 'cabin'
      and d.slug = 'main'
      and d.locale = s.default_locale
    limit 1
  )
  || '.text'
where t.field_key like 'chalet.description.%'
  and exists (
    select 1
    from public.cms_documents d
    join public.sites s on s.id = d.site_id
    where d.site_id = t.site_id
      and d.content_type = 'cabin'
      and d.slug = 'main'
      and d.locale = s.default_locale
      and d.content #>> array['description', split_part(t.field_key, '.', 3), 'id'] is not null
  );

update public.site_translations t
set field_key = 'home.highlights.'
  || (
    select d.content #>> array['highlights', split_part(t.field_key, '.', 2), 'id']
    from public.cms_documents d
    join public.sites s on s.id = d.site_id
    where d.site_id = t.site_id
      and d.content_type = 'page'
      and d.slug = 'home'
      and d.locale = s.default_locale
    limit 1
  )
  || '.description'
where t.field_key like 'highlights.%'
  and exists (
    select 1
    from public.cms_documents d
    join public.sites s on s.id = d.site_id
    where d.site_id = t.site_id
      and d.content_type = 'page'
      and d.slug = 'home'
      and d.locale = s.default_locale
      and d.content #>> array['highlights', split_part(t.field_key, '.', 2), 'id'] is not null
  );

-- `chalet.experience.*` had a field in the old editor and does not have one
-- now: the block is dead content (fase 2 README §0.1) and the model only
-- translates what has a field. Its rows keep their ids in the document; the
-- translation rows go.
delete from public.site_translations
where field_key like 'chalet.experience.%';

-- Anything still index-keyed points at a row whose id could not be resolved
-- (a document that does not exist in the source locale). Those rows cannot be
-- attached to a row and would resurface as orphans, so they go too; the model
-- re-translates from the source on the next publish.
delete from public.site_translations
where field_key like 'chalet.%'
   or field_key ~ '^highlights\.[0-9]+$';

commit;
