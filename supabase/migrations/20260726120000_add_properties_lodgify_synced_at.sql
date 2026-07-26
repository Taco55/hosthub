-- Per-property Lodgify sync stamp.
--
-- user_settings.lodgify_last_synced_at records when the console last *discovered*
-- properties for the account; it says nothing about how old the Lodgify-owned
-- columns on any one property row are. The property record page pulls a single
-- property from Lodgify on demand, so the age it reports has to live on the row
-- it is showing.

alter table public.properties
  add column if not exists lodgify_synced_at timestamptz;

comment on column public.properties.lodgify_synced_at is
  'When this row''s Lodgify-owned columns (address, rooms, prices, …) were last written from the Lodgify API. Null means never synced: those columns hold defaults, not Lodgify data.';
