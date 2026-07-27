-- Keep properties.updated_at honest.
--
-- Every other table with an updated_at column (admin_settings, cms_documents,
-- cms_media, lodgify_api_keys, profiles, settings, site_translations,
-- user_settings) carries this trigger; properties was the one that missed it.
-- Without it the column keeps its insert-time default forever, unless a writer
-- happens to send the column itself — which made the stamp depend on which code
-- path did the update rather than on when the row actually changed.

drop trigger if exists set_properties_updated_at on public.properties;

create trigger set_properties_updated_at
before update on public.properties
for each row execute function public.set_updated_at();
