-- Store Lodgify API keys server-side only.
-- User-facing `user_settings.lodgify_api_key` becomes a non-secret marker.

create table if not exists public.lodgify_api_keys (
  profile_id uuid primary key
    references public.profiles(id)
    on delete cascade,
  api_key text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists set_lodgify_api_keys_updated_at
on public.lodgify_api_keys;

create trigger set_lodgify_api_keys_updated_at
before update on public.lodgify_api_keys
for each row execute function public.set_updated_at();

-- Backfill existing user-owned keys from user_settings.
insert into public.lodgify_api_keys (profile_id, api_key)
select
  us.profile_id,
  btrim(us.lodgify_api_key)
from public.user_settings us
where us.lodgify_api_key is not null
  and btrim(us.lodgify_api_key) <> ''
  and btrim(us.lodgify_api_key) not in (
    '__server_stored__',
    '__lodgify_server_stored__'
  )
on conflict (profile_id) do update
set api_key = excluded.api_key,
    updated_at = now();

-- Replace raw keys in user_settings with a non-secret marker.
update public.user_settings
set lodgify_api_key = '__lodgify_server_stored__'
where lodgify_api_key is not null
  and btrim(lodgify_api_key) <> ''
  and btrim(lodgify_api_key) not in (
    '__server_stored__',
    '__lodgify_server_stored__'
  );

create or replace function public.sync_lodgify_api_key_secret()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_new_key text;
begin
  v_new_key := nullif(btrim(new.lodgify_api_key), '');

  -- Remove key on explicit clear.
  if v_new_key is null then
    delete from public.lodgify_api_keys
     where profile_id = new.profile_id;
    new.lodgify_api_key := null;
    return new;
  end if;

  -- Marker means "already stored server-side", keep secret unchanged.
  if v_new_key in ('__server_stored__', '__lodgify_server_stored__') then
    new.lodgify_api_key := '__lodgify_server_stored__';
    return new;
  end if;

  -- New raw key: store in secure table and replace visible value with marker.
  insert into public.lodgify_api_keys (profile_id, api_key)
  values (new.profile_id, v_new_key)
  on conflict (profile_id) do update
  set api_key = excluded.api_key,
      updated_at = now();

  new.lodgify_api_key := '__lodgify_server_stored__';
  return new;
end;
$$;

drop trigger if exists sync_lodgify_api_key_secret_trigger
on public.user_settings;

create trigger sync_lodgify_api_key_secret_trigger
before insert or update of lodgify_api_key
on public.user_settings
for each row execute function public.sync_lodgify_api_key_secret();

-- Replace the previous auth-user RPC with a service-role-only resolver.
drop function if exists public.get_effective_lodgify_api_key();

create or replace function public.get_effective_lodgify_api_key(
  p_user_id uuid
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_api_key text;
begin
  if p_user_id is null then
    return null;
  end if;

  select lak.api_key
    into v_api_key
    from public.lodgify_api_keys lak
   where lak.profile_id = p_user_id
     and btrim(lak.api_key) <> ''
   limit 1;

  if v_api_key is not null then
    return v_api_key;
  end if;

  select owner_lak.api_key
    into v_api_key
    from public.site_members sm
    join public.sites s
      on s.id = sm.site_id
    join public.lodgify_api_keys owner_lak
      on owner_lak.profile_id = s.owner_profile_id
   where sm.profile_id = p_user_id
     and btrim(owner_lak.api_key) <> ''
   order by sm.created_at asc
   limit 1;

  return v_api_key;
end;
$$;

revoke all on function public.get_effective_lodgify_api_key(uuid)
from public, anon, authenticated;
grant execute on function public.get_effective_lodgify_api_key(uuid)
to service_role;

-- Prevent client roles from directly reading stored API keys.
revoke all on table public.lodgify_api_keys
from public, anon, authenticated;
grant all on table public.lodgify_api_keys to service_role;

alter table public.lodgify_api_keys enable row level security;
