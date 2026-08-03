-- A translation is identified by its site, its field and its language.
--
-- The unique key carried `page` as well, and the console wrote the literal
-- 'home' into it for every field of every page — so the column contributed
-- nothing to identity and quietly asserted something false. Worse, it was a
-- trap: writing the real page would have made the upsert's ON CONFLICT miss,
-- inserting a second row for a field that already had one.
--
-- One site runs one template, so the site already scopes the field key; the
-- page does not narrow it further. The column stays, informational, and is
-- filled with the field's real page from here on.
DO $$ BEGIN
  ALTER TABLE public.site_translations
    DROP CONSTRAINT site_translations_site_id_page_field_key_language_key;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

DO $$ BEGIN
  ALTER TABLE public.site_translations
    ADD CONSTRAINT site_translations_site_field_language_key
      UNIQUE (site_id, field_key, language);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL;
END $$;
