ALTER TABLE public.user_settings
  ADD COLUMN IF NOT EXISTS export_language_code text,
  ADD COLUMN IF NOT EXISTS export_columns jsonb;
