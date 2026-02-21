--
-- Baseline schema for Trysil Panorama admin console (profiles + CMS)
--

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

DO $$
BEGIN
  CREATE TYPE public.subscription_status AS ENUM (
    'free',
    'personal',
    'family',
    'pro',
    'family_invited',
    'beta',
    'invited'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE public.home_tab AS ENUM (
    'start',
    'my_lists',
    'calendar'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL DEFAULT '',
  username text,
  fcm_token text,
  subscription_status public.subscription_status NOT NULL DEFAULT 'free',
  is_development boolean NOT NULL DEFAULT false,
  is_seeded boolean NOT NULL DEFAULT false,
  is_admin boolean NOT NULL DEFAULT false,
  show_calendar_tab boolean NOT NULL DEFAULT false,
  show_start_tab boolean NOT NULL DEFAULT true,
  default_home_tab public.home_tab NOT NULL DEFAULT 'start',
  notification_settings jsonb NOT NULL DEFAULT jsonb_build_object(
    'notificationSound', NULL,
    'notificationsEnabled', true,
    'remindersEnabled', true,
    'expirationRemindersEnabled', true
  ),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.settings (
  id text PRIMARY KEY DEFAULT 'defaults',
  maintenance_mode_enabled boolean NOT NULL DEFAULT false,
  email_user_on_create boolean NOT NULL DEFAULT true,
  max_lists_per_user integer NOT NULL DEFAULT 100,
  max_items_per_list integer NOT NULL DEFAULT 1000,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION public.is_admin(user_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = user_id
      AND is_admin = true
  );
$$;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, COALESCE(NEW.email, ''))
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

CREATE TRIGGER set_settings_updated_at
BEFORE UPDATE ON public.settings
FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by owner or admin"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (id = auth.uid() OR public.is_admin(auth.uid()));

CREATE POLICY "Users can insert their own profile"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid() AND is_admin = false);

CREATE POLICY "Users can update their own profile"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid() AND is_admin = false);

CREATE POLICY "Admins can manage profiles"
  ON public.profiles
  FOR ALL
  TO authenticated
  USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

CREATE POLICY "Admins can manage settings"
  ON public.settings
  FOR ALL
  TO authenticated
  USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

-- CMS tables (sites owned by profiles)
CREATE TABLE public.sites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_profile_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  default_locale text NOT NULL,
  locales text[] NOT NULL,
  timezone text NOT NULL DEFAULT 'Europe/Oslo',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.site_domains (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id uuid REFERENCES public.sites(id) ON DELETE CASCADE,
  domain text NOT NULL,
  is_primary boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.content_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id uuid REFERENCES public.sites(id) ON DELETE CASCADE,
  key text NOT NULL,
  schema_json jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.content_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id uuid REFERENCES public.sites(id) ON DELETE CASCADE,
  type_id uuid REFERENCES public.content_types(id) ON DELETE CASCADE,
  slug text NOT NULL,
  locale text NOT NULL,
  status text NOT NULL CHECK (status IN ('draft','published')),
  version int NOT NULL DEFAULT 1,
  document jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by uuid,
  published_at timestamptz,
  published_by uuid,
  UNIQUE (site_id, type_id, slug, locale, version)
);

CREATE TABLE public.content_releases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id uuid REFERENCES public.sites(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  published_at timestamptz
);

ALTER TABLE public.sites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.site_domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_releases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Site owners can manage sites"
  ON public.sites
  FOR ALL
  USING (
    public.is_admin(auth.uid()) OR owner_profile_id = auth.uid()
  )
  WITH CHECK (
    public.is_admin(auth.uid()) OR owner_profile_id = auth.uid()
  );

CREATE POLICY "Site domains limited to site owners"
  ON public.site_domains
  FOR ALL
  USING (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1
      FROM public.sites s
      WHERE s.id = site_domains.site_id
        AND s.owner_profile_id = auth.uid()
    )
  )
  WITH CHECK (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1
      FROM public.sites s
      WHERE s.id = site_domains.site_id
        AND s.owner_profile_id = auth.uid()
    )
  );

CREATE POLICY "Content types scoped to site owners"
  ON public.content_types
  FOR ALL
  USING (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1
      FROM public.sites s
      WHERE s.id = content_types.site_id
        AND s.owner_profile_id = auth.uid()
    )
  )
  WITH CHECK (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1
      FROM public.sites s
      WHERE s.id = content_types.site_id
        AND s.owner_profile_id = auth.uid()
    )
  );

CREATE POLICY "Content documents scoped to site owners"
  ON public.content_documents
  FOR ALL
  USING (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1
      FROM public.sites s
      WHERE s.id = content_documents.site_id
        AND s.owner_profile_id = auth.uid()
    )
  )
  WITH CHECK (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1
      FROM public.sites s
      WHERE s.id = content_documents.site_id
        AND s.owner_profile_id = auth.uid()
    )
  );

CREATE POLICY "Content releases scoped to site owners"
  ON public.content_releases
  FOR ALL
  USING (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1
      FROM public.sites s
      WHERE s.id = content_releases.site_id
        AND s.owner_profile_id = auth.uid()
    )
  )
  WITH CHECK (
    public.is_admin(auth.uid()) OR EXISTS (
      SELECT 1
      FROM public.sites s
      WHERE s.id = content_releases.site_id
        AND s.owner_profile_id = auth.uid()
    )
  );
