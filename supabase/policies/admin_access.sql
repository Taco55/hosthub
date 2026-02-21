-- Admin access policies for Trysil Panorama admin console
-- Allows users flagged with profiles.is_admin = true to manage admin console data.

-- Helper: admins can manage profiles
DROP POLICY IF EXISTS "Admins can manage profiles" ON public.profiles;
CREATE POLICY "Admins can manage profiles"
  ON public.profiles
  FOR ALL
  TO authenticated
  USING (
    public.is_admin(auth.uid())
  )
  WITH CHECK (
    public.is_admin(auth.uid())
  );

-- Settings: allow admins to manage global configuration.
DROP POLICY IF EXISTS "Admins can manage settings" ON public.settings;
CREATE POLICY "Admins can manage settings"
  ON public.settings
  FOR ALL
  TO authenticated
  USING (
    public.is_admin(auth.uid())
  )
  WITH CHECK (
    public.is_admin(auth.uid())
  );

-- CMS: allow admins to manage all sites and content.

DROP POLICY IF EXISTS "Admins can manage sites" ON public.sites;
CREATE POLICY "Admins can manage sites"
  ON public.sites
  FOR ALL
  TO authenticated
  USING (
    public.is_admin(auth.uid())
  )
  WITH CHECK (
    public.is_admin(auth.uid())
  );

DROP POLICY IF EXISTS "Admins can manage site domains" ON public.site_domains;
CREATE POLICY "Admins can manage site domains"
  ON public.site_domains
  FOR ALL
  TO authenticated
  USING (
    public.is_admin(auth.uid())
  )
  WITH CHECK (
    public.is_admin(auth.uid())
  );
