--
-- CMS content tables: document-based content management with localization.
-- Stores all property website content (previously hardcoded in web/lib/content.ts)
-- as JSONB documents, one row per locale.
--

-- ============================================================
-- 1. cms_documents — core content storage
-- ============================================================
CREATE TABLE IF NOT EXISTS public.cms_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id uuid NOT NULL REFERENCES public.sites(id) ON DELETE CASCADE,
  content_type text NOT NULL,
  slug text NOT NULL,
  locale text NOT NULL,
  content jsonb NOT NULL DEFAULT '{}',
  status text NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published')),
  published_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  UNIQUE (site_id, content_type, slug, locale)
);

DROP TRIGGER IF EXISTS set_cms_documents_updated_at ON public.cms_documents;
CREATE TRIGGER set_cms_documents_updated_at
  BEFORE UPDATE ON public.cms_documents
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_cms_documents_lookup
  ON public.cms_documents (site_id, content_type, slug, locale)
  WHERE status = 'published';

-- ============================================================
-- 2. cms_media — media/image management
-- ============================================================
CREATE TABLE IF NOT EXISTS public.cms_media (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id uuid NOT NULL REFERENCES public.sites(id) ON DELETE CASCADE,
  storage_path text NOT NULL,
  filename text NOT NULL,
  mime_type text,
  width integer,
  height integer,
  file_size_bytes bigint,
  alt_text jsonb DEFAULT '{}',
  tags text[] DEFAULT '{}',
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS set_cms_media_updated_at ON public.cms_media;
CREATE TRIGGER set_cms_media_updated_at
  BEFORE UPDATE ON public.cms_media
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_cms_media_site
  ON public.cms_media (site_id);

CREATE INDEX IF NOT EXISTS idx_cms_media_tags
  ON public.cms_media USING gin (tags);

-- ============================================================
-- 3. cms_media_collections — ordered image groupings
-- ============================================================
CREATE TABLE IF NOT EXISTS public.cms_media_collections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id uuid NOT NULL REFERENCES public.sites(id) ON DELETE CASCADE,
  key text NOT NULL,
  title jsonb DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (site_id, key)
);

-- ============================================================
-- 4. cms_media_collection_items — items within collections
-- ============================================================
CREATE TABLE IF NOT EXISTS public.cms_media_collection_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id uuid NOT NULL REFERENCES public.cms_media_collections(id) ON DELETE CASCADE,
  media_id uuid NOT NULL REFERENCES public.cms_media(id) ON DELETE CASCADE,
  sort_order integer NOT NULL DEFAULT 0,
  UNIQUE (collection_id, media_id)
);

CREATE INDEX IF NOT EXISTS idx_cms_media_collection_items_order
  ON public.cms_media_collection_items (collection_id, sort_order);

-- ============================================================
-- 5. Row Level Security
-- ============================================================
ALTER TABLE public.cms_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cms_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cms_media_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cms_media_collection_items ENABLE ROW LEVEL SECURITY;

-- Published content is publicly readable (for the website)
DROP POLICY IF EXISTS "Published CMS documents are publicly readable" ON public.cms_documents;
CREATE POLICY "Published CMS documents are publicly readable"
  ON public.cms_documents
  FOR SELECT
  TO anon, authenticated
  USING (status = 'published');

-- Site owners and admins can manage all CMS documents (including drafts)
DROP POLICY IF EXISTS "Site owners can manage CMS documents" ON public.cms_documents;
CREATE POLICY "Site owners can manage CMS documents"
  ON public.cms_documents
  FOR ALL
  TO authenticated
  USING (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1 FROM public.sites s
      WHERE s.id = cms_documents.site_id
        AND s.owner_profile_id = auth.uid()
    )
  )
  WITH CHECK (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1 FROM public.sites s
      WHERE s.id = cms_documents.site_id
        AND s.owner_profile_id = auth.uid()
    )
  );

-- Media is publicly readable
DROP POLICY IF EXISTS "CMS media is publicly readable" ON public.cms_media;
CREATE POLICY "CMS media is publicly readable"
  ON public.cms_media
  FOR SELECT
  TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "Site owners can manage CMS media" ON public.cms_media;
CREATE POLICY "Site owners can manage CMS media"
  ON public.cms_media
  FOR ALL
  TO authenticated
  USING (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1 FROM public.sites s
      WHERE s.id = cms_media.site_id
        AND s.owner_profile_id = auth.uid()
    )
  )
  WITH CHECK (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1 FROM public.sites s
      WHERE s.id = cms_media.site_id
        AND s.owner_profile_id = auth.uid()
    )
  );

-- Media collections are publicly readable
DROP POLICY IF EXISTS "CMS media collections are publicly readable" ON public.cms_media_collections;
CREATE POLICY "CMS media collections are publicly readable"
  ON public.cms_media_collections
  FOR SELECT
  TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "Site owners can manage CMS media collections" ON public.cms_media_collections;
CREATE POLICY "Site owners can manage CMS media collections"
  ON public.cms_media_collections
  FOR ALL
  TO authenticated
  USING (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1 FROM public.sites s
      WHERE s.id = cms_media_collections.site_id
        AND s.owner_profile_id = auth.uid()
    )
  )
  WITH CHECK (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1 FROM public.sites s
      WHERE s.id = cms_media_collections.site_id
        AND s.owner_profile_id = auth.uid()
    )
  );

-- Collection items readable through their collection
DROP POLICY IF EXISTS "CMS collection items are publicly readable" ON public.cms_media_collection_items;
CREATE POLICY "CMS collection items are publicly readable"
  ON public.cms_media_collection_items
  FOR SELECT
  TO anon, authenticated
  USING (true);

DROP POLICY IF EXISTS "Site owners can manage CMS collection items" ON public.cms_media_collection_items;
CREATE POLICY "Site owners can manage CMS collection items"
  ON public.cms_media_collection_items
  FOR ALL
  TO authenticated
  USING (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1 FROM public.cms_media_collections mc
      JOIN public.sites s ON s.id = mc.site_id
      WHERE mc.id = cms_media_collection_items.collection_id
        AND s.owner_profile_id = auth.uid()
    )
  )
  WITH CHECK (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1 FROM public.cms_media_collections mc
      JOIN public.sites s ON s.id = mc.site_id
      WHERE mc.id = cms_media_collection_items.collection_id
        AND s.owner_profile_id = auth.uid()
    )
  );
