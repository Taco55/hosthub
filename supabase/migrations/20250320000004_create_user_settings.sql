CREATE TABLE IF NOT EXISTS public.user_settings (
  profile_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  language_code text,
  lodgify_api_key text,
  lodgify_connected boolean NOT NULL DEFAULT false,
  lodgify_connected_at timestamptz,
  lodgify_last_synced_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'set_user_settings_updated_at'
      AND tgrelid = 'public.user_settings'::regclass
  ) THEN
    CREATE TRIGGER set_user_settings_updated_at
    BEFORE UPDATE ON public.user_settings
    FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();
  END IF;
END $$;

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own user settings" ON public.user_settings;
CREATE POLICY "Users can manage own user settings"
  ON public.user_settings
  FOR ALL
  TO authenticated
  USING (profile_id = auth.uid() OR public.is_admin(auth.uid()))
  WITH CHECK (profile_id = auth.uid() OR public.is_admin(auth.uid()));
