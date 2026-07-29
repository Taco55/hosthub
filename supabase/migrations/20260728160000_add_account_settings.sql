-- Account-level settings that are not per channel.
--
-- Two things live here today and they belong together because they answer the
-- same question — what is true of this account rather than of one property:
--
--  * the languages a *new* property starts with. Deliberately a starting point,
--    not a global switch: it never touches an existing site, which is what the
--    section footer says out loud.
--  * the VAT / company number that goes on the invoice. One optional field, not
--    a "business account" mode — HostHub is for people with a few homes, and a
--    company number is the only thing the business ones actually need.

create table if not exists public.account_settings (
  owner_profile_id uuid primary key
    references public.profiles(id) on delete cascade,
  -- The language a new property's content is authored in.
  default_source_language text not null default 'nl',
  -- The languages a new property's website is published in. Always contains
  -- default_source_language; the console keeps that true.
  default_languages text[] not null default array['nl', 'en'],
  vat_number text,
  updated_at timestamptz not null default now()
);

alter table public.account_settings enable row level security;

-- The team reads (a new property's languages are visible to whoever creates
-- one); the owner writes — this and billing are owner scope.
drop policy if exists "Account can read settings" on public.account_settings;
create policy "Account can read settings" on public.account_settings
  for select to authenticated
  using (public.has_account_access(owner_profile_id, auth.uid()));

drop policy if exists "Account owner manages settings" on public.account_settings;
create policy "Account owner manages settings" on public.account_settings
  for all to authenticated
  using (
    public.has_account_access(
      owner_profile_id, auth.uid(), 'owner'::public.site_member_role
    )
  )
  with check (
    public.has_account_access(
      owner_profile_id, auth.uid(), 'owner'::public.site_member_role
    )
  );

revoke all on table public.account_settings from anon;
grant select, insert, update, delete on table public.account_settings
  to authenticated;
