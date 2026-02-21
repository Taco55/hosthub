CREATE TABLE IF NOT EXISTS public.admin_settings (
  id text PRIMARY KEY DEFAULT 'defaults',
  maintenance_mode_enabled boolean NOT NULL DEFAULT false,
  email_user_on_create boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'set_admin_settings_updated_at'
      AND tgrelid = 'public.admin_settings'::regclass
  ) THEN
    CREATE TRIGGER set_admin_settings_updated_at
    BEFORE UPDATE ON public.admin_settings
    FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
  END IF;
END $$;

ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can manage admin settings" ON public.admin_settings;
CREATE POLICY "Admins can manage admin settings"
  ON public.admin_settings
  FOR ALL
  TO authenticated
  USING (
    public.is_admin(auth.uid())
  )
  WITH CHECK (
    public.is_admin(auth.uid())
  );
