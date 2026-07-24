-- Source-language mode for the website editor (design handoff §5):
-- when true, the site's source language follows the owner's interface
-- language ("Same as interface language" switch in Settings). The sync is
-- applied client-side on explicit user actions only; `default_locale`
-- remains the single source of truth for translation/publishing.
DO $$ BEGIN
  ALTER TABLE public.sites
    ADD COLUMN source_locale_follows_ui BOOLEAN NOT NULL DEFAULT FALSE;
EXCEPTION WHEN duplicate_column THEN NULL;
END $$;
