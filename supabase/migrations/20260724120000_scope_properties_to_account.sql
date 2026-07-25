-- Scope listings (public.properties) to the account that owns them.
--
-- Until now properties was the only tenant table without an owner column and
-- without RLS, while GRANT ALL was handed to anon and authenticated. Every
-- signed-in user could therefore read, edit and delete every account's
-- listings. This migration adds the owner column, backfills it, and closes the
-- table off with the same access model the console already uses elsewhere:
-- the account owner and their invited partners (site_members on any site they
-- own — see site_members_cubit.loadAccountTeam / inviteToAllSites), plus
-- platform admins.

-- ---------------------------------------------------------------------------
-- 1. Owner column
-- ---------------------------------------------------------------------------

alter table public.properties
  add column if not exists owner_profile_id uuid;

do $$ begin
  alter table public.properties
    add constraint properties_owner_profile_id_fkey
    foreign key (owner_profile_id) references public.profiles(id) on delete set null;
exception when duplicate_object then null;
end $$;

create index if not exists idx_properties_owner_profile_id
  on public.properties(owner_profile_id);

-- ---------------------------------------------------------------------------
-- 2. Account resolution
-- ---------------------------------------------------------------------------

-- Which account does a user act on behalf of? Own account when they own at
-- least one site; the inviting account when they are only a partner and that
-- partnership is unambiguous (a single owner across their memberships);
-- themselves otherwise — which is also the pre-site onboarding case, where a
-- listing is created before any site exists (see PropertySetupPage).
create or replace function public.account_owner_for(check_user_id uuid)
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select case
    when check_user_id is null then null
    when exists (
      select 1 from public.sites where owner_profile_id = check_user_id
    ) then check_user_id
    else (
      select case
               when count(distinct s.owner_profile_id) = 1
                 then (array_agg(distinct s.owner_profile_id))[1]
               else check_user_id
             end
        from public.site_members sm
        join public.sites s on s.id = sm.site_id
       where sm.profile_id = check_user_id
         and s.owner_profile_id is not null
    )
  end;
$$;

alter function public.account_owner_for(uuid) owner to postgres;

-- New rows get their owner from the inserting session, so no client change is
-- needed for PropertyRepository.createProperty / the Lodgify sync.
alter table public.properties
  alter column owner_profile_id set default public.account_owner_for(auth.uid());

-- Account-level counterpart of public.has_site_access: access to an account's
-- data, rather than to one site.
create or replace function public.has_account_access(
  check_owner_profile_id uuid,
  check_user_id uuid,
  min_role public.site_member_role default 'viewer'::public.site_member_role
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_admin(check_user_id)
    or (
      check_owner_profile_id is not null
      and (
        check_owner_profile_id = check_user_id
        or exists (
          select 1
            from public.site_members sm
            join public.sites s on s.id = sm.site_id
           where s.owner_profile_id = check_owner_profile_id
             and sm.profile_id = check_user_id
             and (
               case min_role
                 when 'viewer' then sm.role in ('viewer', 'editor', 'owner')
                 when 'editor' then sm.role in ('editor', 'owner')
                 when 'owner'  then sm.role = 'owner'
               end
             )
        )
      )
    );
$$;

alter function public.has_account_access(uuid, uuid, public.site_member_role)
  owner to postgres;

-- ---------------------------------------------------------------------------
-- 3. Backfill
-- ---------------------------------------------------------------------------

-- Existing rows predate the column. Resolve the account in order of evidence:
-- the sole Lodgify connection (listings come from that sync), then the sole
-- site owner, then the sole admin. Anything left unresolved stays null and is
-- visible to admins only — deliberately, since guessing an owner here would
-- hand one account's listings to another.
do $$
declare
  v_owner uuid;
  v_updated bigint;
  v_remaining bigint;
begin
  if not exists (select 1 from public.properties where owner_profile_id is null) then
    return;
  end if;

  select case when count(distinct profile_id) = 1
              then (array_agg(distinct profile_id))[1] end
    into v_owner
    from public.lodgify_api_keys;

  if v_owner is null then
    select case when count(distinct owner_profile_id) = 1
                then (array_agg(distinct owner_profile_id))[1] end
      into v_owner
      from public.sites
     where owner_profile_id is not null;
  end if;

  if v_owner is null then
    select case when count(*) = 1 then (array_agg(id))[1] end
      into v_owner
      from public.profiles
     where is_admin;
  end if;

  if v_owner is not null then
    update public.properties
       set owner_profile_id = v_owner
     where owner_profile_id is null;
    get diagnostics v_updated = row_count;
    raise notice 'properties: backfilled owner_profile_id = % for % row(s)',
      v_owner, v_updated;
  end if;

  select count(*) into v_remaining
    from public.properties
   where owner_profile_id is null;

  if v_remaining > 0 then
    raise warning 'properties: % row(s) without owner_profile_id — admin-visible only until assigned', v_remaining;
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 4. RLS
-- ---------------------------------------------------------------------------

alter table public.properties enable row level security;

-- Read for the whole account team, writes for editors and up. Mirrors the
-- viewer/editor split the site_* tables already use.
drop policy if exists "Account can read listings" on public.properties;
create policy "Account can read listings" on public.properties
  for select to authenticated
  using (public.has_account_access(owner_profile_id, auth.uid()));

drop policy if exists "Account editors manage listings" on public.properties;
create policy "Account editors manage listings" on public.properties
  for all to authenticated
  using (
    public.has_account_access(
      owner_profile_id, auth.uid(), 'editor'::public.site_member_role
    )
  )
  with check (
    public.has_account_access(
      owner_profile_id, auth.uid(), 'editor'::public.site_member_role
    )
  );

-- Listings are never public: the website worker and web app read cms_* and
-- site_* only, and the Edge Functions use the service role (RLS-exempt).
revoke all on table public.properties from anon;
revoke all on sequence public.properties_id_seq from anon;
