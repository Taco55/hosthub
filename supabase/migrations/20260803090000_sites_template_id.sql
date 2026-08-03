-- Which website template a site is built from.
--
-- The console's editor now takes its pages, cards, field paths, media routing
-- and labels from a `WebsiteTemplate` instance instead of globals, so a second
-- template can exist — but every site still got the same one, because nothing
-- recorded which. This is that record.
--
-- Defaulted rather than nullable: every existing site is the chalet template,
-- and a site without a template is not a state the editor can render. The id
-- matches `WebsiteTemplate.id` in the console; an unknown value falls back to
-- the default there rather than failing closed, because a site whose template
-- was renamed should still open.
DO $$ BEGIN
  ALTER TABLE public.sites
    ADD COLUMN template_id TEXT NOT NULL DEFAULT 'chalet-v1';
EXCEPTION WHEN duplicate_column THEN NULL;
END $$;

COMMENT ON COLUMN public.sites.template_id IS
  'WebsiteTemplate.id in the console. Decides the editor''s pages and fields.';
