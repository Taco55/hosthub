-- Expose a non-secret "last 4 chars" hint for the server-stored Lodgify API
-- key so the console can show e.g. ••••YjvD instead of a blank mask. The full
-- key stays server-side only (public.lodgify_api_keys); only the last 4 chars
-- are surfaced on the user-facing user_settings row.

alter table public.user_settings
  add column if not exists lodgify_api_key_last4 text;

-- Keep the hint in sync with the stored key. Extends the existing
-- sync_lodgify_api_key_secret trigger (see
-- 20260301190000_move_lodgify_keys_to_server_side_storage.sql).
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
    new.lodgify_api_key_last4 := null;
    return new;
  end if;

  -- Marker means "already stored server-side", keep secret + hint unchanged.
  if v_new_key in ('__server_stored__', '__lodgify_server_stored__') then
    new.lodgify_api_key := '__lodgify_server_stored__';
    if tg_op = 'UPDATE' then
      new.lodgify_api_key_last4 := old.lodgify_api_key_last4;
    end if;
    return new;
  end if;

  -- New raw key: store in secure table, replace visible value with marker, and
  -- surface only the last 4 chars as a non-secret hint.
  insert into public.lodgify_api_keys (profile_id, api_key)
  values (new.profile_id, v_new_key)
  on conflict (profile_id) do update
  set api_key = excluded.api_key,
      updated_at = now();

  new.lodgify_api_key := '__lodgify_server_stored__';
  new.lodgify_api_key_last4 := right(v_new_key, 4);
  return new;
end;
$$;

-- Backfill the hint for keys already stored server-side.
update public.user_settings us
   set lodgify_api_key_last4 = right(lak.api_key, 4)
  from public.lodgify_api_keys lak
 where lak.profile_id = us.profile_id
   and btrim(lak.api_key) <> ''
   and us.lodgify_api_key_last4 is null;
