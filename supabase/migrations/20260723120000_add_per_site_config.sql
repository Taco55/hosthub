-- Per-site website configuration for the shared "hosthub-sites" worker.
-- The worker resolves the incoming domain -> site_id, then reads these so each
-- consumer site carries its own contact recipient, email sender name, and
-- Lodgify property/room ids instead of the single global env values.
--
-- All columns are nullable: NULL falls back to the worker's env defaults, so this
-- is backward compatible (existing sites keep working until values are set in the
-- HostHub console). Owner/admin edit access is already covered by the existing
-- "Site owners can manage sites" RLS policy on public.sites.

alter table public.sites
  add column if not exists contact_email text,
  add column if not exists email_from_name text,
  add column if not exists lodgify_property_id text,
  add column if not exists lodgify_room_type_id text;

comment on column public.sites.contact_email is
  'Recipient for this site''s contact form (falls back to worker CONTACT_EMAIL_TO).';
comment on column public.sites.email_from_name is
  'Display name for outbound emails from this site (falls back to sites.name).';
comment on column public.sites.lodgify_property_id is
  'Lodgify property/house id for this site''s booking funnel (falls back to env).';
comment on column public.sites.lodgify_room_type_id is
  'Lodgify room type id for this site''s booking funnel (falls back to env).';

-- Site-keyed Lodgify API key resolver for the public website (which has no
-- authenticated user): a site's effective key is its owner's key. SECURITY
-- DEFINER so the shared worker (service role) can read the RLS-protected key.
create or replace function public.get_site_lodgify_api_key(p_site_id uuid)
returns text
language sql
security definer
set search_path to 'public'
as $$
  select lak.api_key
  from public.sites s
  join public.lodgify_api_keys lak
    on lak.profile_id = s.owner_profile_id
  where s.id = p_site_id
    and btrim(lak.api_key) <> ''
  limit 1;
$$;

revoke all on function public.get_site_lodgify_api_key(uuid) from public;
grant execute on function public.get_site_lodgify_api_key(uuid) to service_role;
