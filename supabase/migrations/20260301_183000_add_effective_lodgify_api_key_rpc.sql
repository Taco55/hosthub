create or replace function public.get_effective_lodgify_api_key()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_api_key text;
begin
  if v_user_id is null then
    return null;
  end if;

  -- Prefer the current user's own Lodgify key if one exists.
  select us.lodgify_api_key
    into v_api_key
    from public.user_settings us
   where us.profile_id = v_user_id
     and us.lodgify_api_key is not null
     and btrim(us.lodgify_api_key) <> ''
   limit 1;

  if v_api_key is not null then
    return v_api_key;
  end if;

  -- Fallback to the site owner's Lodgify key for any site the current
  -- user is a member of.
  select owner_us.lodgify_api_key
    into v_api_key
    from public.site_members sm
    join public.sites s
      on s.id = sm.site_id
    join public.user_settings owner_us
      on owner_us.profile_id = s.owner_profile_id
   where sm.profile_id = v_user_id
     and owner_us.lodgify_api_key is not null
     and btrim(owner_us.lodgify_api_key) <> ''
   order by sm.created_at asc
   limit 1;

  return v_api_key;
end;
$$;

grant execute on function public.get_effective_lodgify_api_key()
to authenticated;
