ALTER TABLE IF EXISTS public.user_settings
  ADD COLUMN IF NOT EXISTS lodgify_api_key text,
  ADD COLUMN IF NOT EXISTS lodgify_connected boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS lodgify_connected_at timestamptz;
