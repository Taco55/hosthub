--
-- CMS document versions: immutable snapshots created on publish.
-- Each publish creates a new version with auto-incremented version number.
--

-- ============================================================
-- 1. cms_document_versions — version history
-- ============================================================
CREATE TABLE IF NOT EXISTS public.cms_document_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid NOT NULL REFERENCES public.cms_documents(id) ON DELETE CASCADE,
  version integer NOT NULL,
  content jsonb NOT NULL,
  published_at timestamptz NOT NULL DEFAULT now(),
  published_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  UNIQUE (document_id, version)
);

CREATE INDEX IF NOT EXISTS idx_cms_doc_versions_lookup
  ON public.cms_document_versions (document_id, version DESC);

-- ============================================================
-- 2. Auto-increment trigger for version number
-- ============================================================
CREATE OR REPLACE FUNCTION public.cms_next_version()
RETURNS TRIGGER AS $$
BEGIN
  SELECT COALESCE(MAX(version), 0) + 1
  INTO NEW.version
  FROM public.cms_document_versions
  WHERE document_id = NEW.document_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_cms_version_auto_increment ON public.cms_document_versions;
CREATE TRIGGER trg_cms_version_auto_increment
  BEFORE INSERT ON public.cms_document_versions
  FOR EACH ROW EXECUTE FUNCTION public.cms_next_version();

-- ============================================================
-- 3. Row Level Security
-- ============================================================
ALTER TABLE public.cms_document_versions ENABLE ROW LEVEL SECURITY;

-- Site owners and admins can read version history
DROP POLICY IF EXISTS "Site owners can read CMS versions" ON public.cms_document_versions;
CREATE POLICY "Site owners can read CMS versions"
  ON public.cms_document_versions
  FOR SELECT
  TO authenticated
  USING (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1 FROM public.cms_documents d
      JOIN public.sites s ON s.id = d.site_id
      WHERE d.id = cms_document_versions.document_id
        AND s.owner_profile_id = auth.uid()
    )
  );

-- Site owners and admins can create versions (via publish)
DROP POLICY IF EXISTS "Site owners can create CMS versions" ON public.cms_document_versions;
CREATE POLICY "Site owners can create CMS versions"
  ON public.cms_document_versions
  FOR INSERT
  TO authenticated
  WITH CHECK (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1 FROM public.cms_documents d
      JOIN public.sites s ON s.id = d.site_id
      WHERE d.id = cms_document_versions.document_id
        AND s.owner_profile_id = auth.uid()
    )
  );
