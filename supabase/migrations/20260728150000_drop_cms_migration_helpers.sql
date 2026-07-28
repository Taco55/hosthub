-- Remove the one-shot helpers from 20260727150000_cms_stable_row_ids.sql.
--
-- That migration needed five functions to walk the CMS documents once and give
-- every list row a stable id. They were created with `create or replace` and so
-- stayed behind in `public` afterwards, where they are reachable over the API
-- and read as part of the schema while nothing calls them: the console and the
-- sites-renderer generate row ids client-side, and no later migration, Edge
-- Function or test refers to them.
--
-- Replaying the migrations from scratch is unaffected — 20260727150000 creates
-- them, uses them, and this migration drops them again.

begin;

drop function if exists public.cms_migrate_document(jsonb, uuid, text, text);
drop function if exists public.cms_fuse_highlights(jsonb, uuid);
drop function if exists public.cms_add_ids_to_group_list(jsonb, uuid, text, text, text);
drop function if exists public.cms_add_ids_to_object_list(jsonb, uuid, text, text);
drop function if exists public.cms_add_ids_to_text_list(jsonb, uuid, text, text);
drop function if exists public.cms_row_id(uuid, text, text, int);

commit;
