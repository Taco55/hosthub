alter table public.user_settings
  add column if not exists export_pdf_orientation text not null default 'portrait';

alter table public.user_settings
  drop constraint if exists user_settings_export_pdf_orientation_check;

alter table public.user_settings
  add constraint user_settings_export_pdf_orientation_check
  check (export_pdf_orientation in ('portrait', 'landscape'));
