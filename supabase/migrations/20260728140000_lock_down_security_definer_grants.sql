-- Take the SECURITY DEFINER functions out of reach of the public anon key.
--
-- Supabase ships default privileges for the `public` schema:
--
--   ALTER DEFAULT PRIVILEGES ... GRANT ALL ON FUNCTIONS TO anon, authenticated;
--
-- so every function created there is executable by the anon key from the moment
-- it exists. `REVOKE ALL ... FROM PUBLIC` — which is what the earlier migrations
-- did — does not undo that: PUBLIC and anon are different grantees. The result
-- is that a SECURITY DEFINER function, whose whole purpose is to bypass RLS,
-- was callable by anyone holding a key that ships inside the browser bundle.
--
-- Three of those were live, on prd as well:
--
--   create_local_admin_user(text,text,text)  inserts into auth.users and sets
--       profiles.is_admin = true. Anonymous platform takeover.
--   get_site_lodgify_api_key(uuid)           returns the site owner's Lodgify
--       API key in plaintext. site_id is readable from the publicly readable
--       cms_documents, so the key was one RPC call away for any visitor.
--   accept_pending_invitations(uuid,text)    takes the subject as arguments, so
--       a caller could pass somebody else's invited address together with their
--       own id and join that site with the invited role, up to `owner`.
--
-- supabase/tests/security_definer_grants_test.sql pins the result and fails on
-- the next function that is created without thinking about its ACL.

begin;

-- ---------------------------------------------------------------------------
-- The plaintext-key RPCs go entirely.
-- ---------------------------------------------------------------------------
-- Nothing calls them. supabase/functions/_shared/lodgify.ts resolves the key
-- with the service role inside the Edge Function runtime and web/lib/lodgify/
-- server.ts reads the tables directly, both by an explicit choice recorded in
-- comments there. A SECURITY DEFINER function that hands out a third-party
-- credential has no grant configuration that is safe enough to keep around for
-- a caller that does not exist.
drop function if exists public.get_site_lodgify_api_key(uuid);
drop function if exists public.get_effective_lodgify_api_key(uuid);

-- ---------------------------------------------------------------------------
-- The local bootstrap helper becomes superuser-only.
-- ---------------------------------------------------------------------------
-- `make create-admin-local` reaches it over psql as `postgres`, which owns the
-- function and needs no grant. No client role has any business calling it.
revoke all on function public.create_local_admin_user(text, text, text)
  from public, anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Invitation acceptance derives its subject from the session.
-- ---------------------------------------------------------------------------
-- The identity comes from auth.users, keyed on auth.uid(): the verified address
-- Supabase itself holds, not a claim the caller can shape and not the mutable
-- profiles row. The arguments are gone rather than ignored, so an old caller
-- fails loudly instead of silently doing something else than it asks for.
drop function if exists public.accept_pending_invitations(uuid, text);

create or replace function public.accept_pending_invitations()
returns void
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_user_id uuid := auth.uid();
  v_email text;
  inv record;
begin
  if v_user_id is null then
    return;
  end if;

  select lower(trim(u.email)) into v_email
    from auth.users u
   where u.id = v_user_id;

  if v_email is null or v_email = '' then
    return;
  end if;

  for inv in
    select id, site_id, role
      from public.site_invitations
     where email = v_email
       and status = 'pending'
       and expires_at > now()
  loop
    insert into public.site_members (site_id, profile_id, role)
    values (inv.site_id, v_user_id, inv.role)
    on conflict (site_id, profile_id)
      do update set role = excluded.role, updated_at = now();

    update public.site_invitations
       set status = 'accepted'
     where id = inv.id;
  end loop;
end;
$$;

revoke all on function public.accept_pending_invitations() from public, anon;
grant execute on function public.accept_pending_invitations() to authenticated;

-- ---------------------------------------------------------------------------
-- Trigger functions need no grants at all.
-- ---------------------------------------------------------------------------
-- A trigger runs as the table owner; the EXECUTE grants only ever made these
-- callable as an RPC, which is not a thing anybody wants.
revoke all on function public.handle_new_user()
  from public, anon, authenticated;
revoke all on function public.sync_lodgify_api_key_secret()
  from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- account_owner_for is a DEFAULT expression on properties.owner_profile_id and
-- runs as the inserting role. Anonymous callers never insert a property, and it
-- otherwise lets anon probe which account a given user belongs to.
-- ---------------------------------------------------------------------------
revoke all on function public.account_owner_for(uuid) from public, anon;
grant execute on function public.account_owner_for(uuid) to authenticated;

commit;
