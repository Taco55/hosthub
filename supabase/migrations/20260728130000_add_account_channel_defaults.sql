-- Account-wide channel defaults: the tier a property falls back to.
--
-- Until now the "account" defaults were three commission percentages on
-- public.admin_settings — one row for the whole *environment*, editable by
-- platform admins only. Every account therefore shared one set of channel fees,
-- and an owner could not state their own. This gives the tier a home per
-- account, with all the fields a property can already override.
--
-- Inheritance stays resolution, never a copy: a property follows the account
-- because its own value in `properties.channel_settings` is absent, so changing
-- a default writes exactly one row and reaches every property that has not
-- spoken for itself. Nothing is backfilled into properties — a backfill of N
-- rows that can fail halfway is precisely what this model avoids.

create table if not exists public.account_channel_defaults (
  owner_profile_id uuid not null
    references public.profiles(id) on delete cascade,
  -- The three channels the console resolves a booking source into.
  -- 'other' is direct bookings and anything the source does not name.
  channel text not null check (channel in ('booking', 'airbnb', 'other')),

  -- Percentages and money are exact decimals rather than floats: these are the
  -- inputs to the payout arithmetic, and a rounding artefact in a commission
  -- shows up as cents that do not add up.
  commission_percentage numeric(6, 3) not null default 0,
  rate_markup_percentage numeric(6, 3) not null default 0,

  -- Each cost carries how it is calculated, the same shape a property override
  -- has, so the two tiers can merge field by field.
  cleaning_amount numeric(12, 2) not null default 0,
  cleaning_type text not null default 'per_booking'
    check (cleaning_type in ('per_booking', 'per_person', 'per_night')),
  linen_amount numeric(12, 2) not null default 0,
  linen_type text not null default 'per_booking'
    check (linen_type in ('per_booking', 'per_person', 'per_night')),
  service_amount numeric(12, 2) not null default 0,
  service_type text not null default 'per_person'
    check (service_type in ('per_booking', 'per_person', 'per_night')),
  other_amount numeric(12, 2) not null default 0,
  other_type text not null default 'per_booking'
    check (other_type in ('per_booking', 'per_person', 'per_night')),

  updated_at timestamptz not null default now(),
  primary key (owner_profile_id, channel)
);

-- ---------------------------------------------------------------------------
-- Seed from what the environment-wide row said
-- ---------------------------------------------------------------------------

-- Every account that owns a property keeps the fees it was silently getting, so
-- no payout figure changes the day this lands.
do $$
declare
  v_booking numeric(6, 3) := 15;
  v_airbnb  numeric(6, 3) := 15.5;
  v_other   numeric(6, 3) := 0;
begin
  if to_regclass('public.admin_settings') is not null then
    select coalesce(booking_channel_fee_percentage, 15),
           coalesce(airbnb_channel_fee_percentage, 15.5),
           coalesce(other_channel_fee_percentage, 0)
      into v_booking, v_airbnb, v_other
      from public.admin_settings
     limit 1;
  end if;

  insert into public.account_channel_defaults
    (owner_profile_id, channel, commission_percentage)
  select owner_profile_id, channel, percentage
    from (
      select distinct owner_profile_id from public.properties
       where owner_profile_id is not null
    ) accounts
    cross join (
      values ('booking', v_booking), ('airbnb', v_airbnb), ('other', v_other)
    ) as defaults(channel, percentage)
  on conflict (owner_profile_id, channel) do nothing;
end $$;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

-- The default row is the account's own money: the whole team may read it (every
-- payout figure on screen resolves through it), but only the owner may move it.
-- Per-property overrides stay editable by editors — deviating for one property
-- is day-to-day work, changing what every property inherits is not.

alter table public.account_channel_defaults enable row level security;

drop policy if exists "Account can read channel defaults"
  on public.account_channel_defaults;
create policy "Account can read channel defaults"
  on public.account_channel_defaults
  for select to authenticated
  using (public.has_account_access(owner_profile_id, auth.uid()));

drop policy if exists "Account owner manages channel defaults"
  on public.account_channel_defaults;
create policy "Account owner manages channel defaults"
  on public.account_channel_defaults
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

revoke all on table public.account_channel_defaults from anon;
grant select, insert, update, delete
  on table public.account_channel_defaults to authenticated;

-- ---------------------------------------------------------------------------
-- A new account starts from the same defaults, not from zero
-- ---------------------------------------------------------------------------

-- The seed above covers the accounts that exist today. An account that appears
-- tomorrow needs the same starting point, or every payout figure would read 0%
-- commission until somebody opened Standaardwaarden. An account becomes real
-- when it gets its first property, so that is where the rows appear.
--
-- `on conflict do nothing`: this only ever *starts* an account off. It can
-- never overwrite a value the owner has since set.
create or replace function public.seed_account_channel_defaults()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.owner_profile_id is null then
    return new;
  end if;

  insert into public.account_channel_defaults
    (owner_profile_id, channel, commission_percentage)
  values
    (new.owner_profile_id, 'booking', 15),
    (new.owner_profile_id, 'airbnb', 15.5),
    (new.owner_profile_id, 'other', 0)
  on conflict (owner_profile_id, channel) do nothing;

  return new;
end;
$$;

alter function public.seed_account_channel_defaults() owner to postgres;

-- A trigger function runs as the table owner; an EXECUTE grant would only ever
-- make it callable as an RPC, which nobody wants. See
-- 20260728140000_lock_down_security_definer_grants.sql.
revoke all on function public.seed_account_channel_defaults()
  from public, anon, authenticated;

drop trigger if exists properties_seed_channel_defaults on public.properties;
create trigger properties_seed_channel_defaults
  after insert on public.properties
  for each row
  execute function public.seed_account_channel_defaults();
