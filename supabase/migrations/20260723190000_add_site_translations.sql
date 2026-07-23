-- Per-field translation storage for the CMS website editor (TRANSLATION.md).
-- One row per (site, page, field, language): the current text, whether it is
-- machine-generated (auto) or owner-edited (locked), and the hash of the
-- source text an auto value was generated from — auto rows whose source_hash
-- no longer matches the current source are stale and get re-translated on
-- publish (locked rows are never overwritten).

CREATE TABLE IF NOT EXISTS public.site_translations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id UUID NOT NULL REFERENCES public.sites(id) ON DELETE CASCADE,
  page TEXT NOT NULL,
  field_key TEXT NOT NULL,
  language TEXT NOT NULL,
  value TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'auto' CHECK (status IN ('auto', 'locked')),
  source_hash TEXT,
  translated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (site_id, page, field_key, language)
);

CREATE INDEX IF NOT EXISTS idx_site_translations_site_page_lang
  ON public.site_translations(site_id, page, language);

ALTER TABLE public.site_translations ENABLE ROW LEVEL SECURITY;

-- Editors and owners manage a site's translations; admins everything.
DROP POLICY IF EXISTS "Site editors manage translations" ON public.site_translations;
CREATE POLICY "Site editors manage translations" ON public.site_translations
  FOR ALL TO authenticated
  USING (
    public.is_admin(auth.uid())
    OR public.has_site_access(site_id, auth.uid(), 'editor')
  )
  WITH CHECK (
    public.is_admin(auth.uid())
    OR public.has_site_access(site_id, auth.uid(), 'editor')
  );

DROP TRIGGER IF EXISTS set_site_translations_updated_at ON public.site_translations;
CREATE TRIGGER set_site_translations_updated_at
  BEFORE UPDATE ON public.site_translations
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
