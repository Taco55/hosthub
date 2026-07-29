-- A role is stated once for the account and holds for every property, now and
-- later.
--
-- The console already presents team membership as account-wide: it invites to
-- every site the account owns, removes from every site, and folds the rows into
-- one entry per person at their highest role. One hole was left: a property
-- created *after* someone was invited had no membership rows, so every new
-- property meant another round of invitations — the exact failure that made the
-- design pick an account-wide role.
--
-- This closes it at the point where the hole appears — a new site — instead of
-- introducing a second membership model beside `site_members`. Membership stays
-- in one table with one meaning, and no policy has to learn a second way to ask
-- whether somebody has access.

create or replace function public.grant_account_members_on_new_site()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.owner_profile_id is null then
    return new;
  end if;

  -- Every distinct person already on this account, at the highest role they
  -- hold anywhere in it. Highest, because that is the role the console shows
  -- and therefore the one the owner believes they granted.
  insert into public.site_members (site_id, profile_id, role)
  select new.id,
         sm.profile_id,
         (array_agg(sm.role order by
            case sm.role
              when 'owner'  then 3
              when 'editor' then 2
              else 1
            end desc))[1]
    from public.site_members sm
    join public.sites s on s.id = sm.site_id
   where s.owner_profile_id = new.owner_profile_id
     and s.id <> new.id
   group by sm.profile_id
  on conflict do nothing;

  return new;
end;
$$;

alter function public.grant_account_members_on_new_site() owner to postgres;

-- A trigger function runs as the table owner; an EXECUTE grant would only ever
-- make it callable as an RPC — and this one writes memberships. See
-- 20260728140000_lock_down_security_definer_grants.sql.
revoke all on function public.grant_account_members_on_new_site()
  from public, anon, authenticated;

drop trigger if exists sites_grant_account_members on public.sites;
create trigger sites_grant_account_members
  after insert on public.sites
  for each row
  execute function public.grant_account_members_on_new_site();
