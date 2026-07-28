-- Guardrail for SECURITY DEFINER reachability from the public API.
--
-- Run it against a local stack:
--   psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/security_definer_grants_test.sql
--
-- Why this test exists: Supabase ships
--   ALTER DEFAULT PRIVILEGES ... GRANT ALL ON FUNCTIONS TO anon, authenticated;
-- so *every* freshly created function in `public` is executable by the anon key
-- the moment it is created. `REVOKE ALL ... FROM PUBLIC` does not undo those
-- role grants — PUBLIC and anon are different grantees. A SECURITY DEFINER
-- function therefore becomes an RLS bypass reachable by anybody holding the
-- (public by design) anon key unless the migration revokes anon explicitly.
--
-- The test inverts the default: any SECURITY DEFINER function in `public` that
-- anon may execute is a failure, unless it is on the allowlist below with a
-- reason. Adding a row to that allowlist is a deliberate act.
--
-- The sweep is deliberately about `anon` and not `authenticated`. Reaching a
-- SECURITY DEFINER function as a signed-in user is normal and often the point;
-- what makes it safe is that the function derives its subject from `auth.uid()`
-- instead of from its arguments. That is a property of the body, not of the ACL,
-- so it is pinned per function further down rather than by this sweep.
--
-- Read-only; the transaction rolls back.

BEGIN;

DO $$
DECLARE
    -- Functions that legitimately need EXECUTE for anon.
    --
    -- These three access helpers are called *inside* RLS policy expressions,
    -- which Postgres evaluates as the querying role. Anonymous visitors of the
    -- sites-renderer hit tables whose policy set includes predicates built on
    -- them (site_domains has a policy without a TO clause, so it applies to
    -- anon as well); without EXECUTE those predicates raise instead of
    -- returning false. They answer a yes/no about access and return no data.
    allowed text[] := ARRAY[
        'has_site_access',
        'has_account_access',
        'is_admin'
    ];
    offender record;
    failures text := '';
BEGIN
    FOR offender IN
        SELECT p.proname,
               pg_get_function_identity_arguments(p.oid) AS args
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public'
          AND p.prosecdef
          AND NOT (p.proname = ANY (allowed))
          AND has_function_privilege('anon', p.oid, 'EXECUTE')
        ORDER BY p.proname
    LOOP
        failures := failures || format(
            E'\n  - public.%s(%s)',
            offender.proname, offender.args
        );
    END LOOP;

    IF failures <> '' THEN
        RAISE EXCEPTION
            'SECURITY DEFINER functions reachable with the public anon key:%s',
            failures;
    END IF;

    RAISE NOTICE 'SECURITY DEFINER grants: nothing unexpected reachable as anon';
END $$;

-- The credential-returning RPCs must not exist at all. Both were superseded by
-- supabase/functions/_shared/lodgify.ts, which resolves the key with the service
-- role inside the Edge Function runtime, and a SECURITY DEFINER function that
-- returns a plaintext third-party API key has no safe grant configuration.
DO $$
DECLARE
    leaked text;
BEGIN
    SELECT string_agg(p.proname || '(' ||
                      pg_get_function_identity_arguments(p.oid) || ')', ', ')
      INTO leaked
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = 'public'
       AND p.proname IN (
           'get_site_lodgify_api_key',
           'get_effective_lodgify_api_key'
       );

    IF leaked IS NOT NULL THEN
        RAISE EXCEPTION
            'plaintext Lodgify key RPC still present: %', leaked;
    END IF;

    RAISE NOTICE 'lodgify key RPCs: gone';
END $$;

-- accept_pending_invitations must take its identity from the JWT, not from
-- caller-supplied parameters. With (p_user_id, p_user_email) any caller could
-- pass somebody else's invited email together with their own id and join that
-- site with the invited role — up to `owner`.
DO $$
DECLARE
    arg_count int;
BEGIN
    SELECT count(*)
      INTO arg_count
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = 'public'
       AND p.proname = 'accept_pending_invitations'
       AND p.pronargs > 0;

    IF arg_count > 0 THEN
        RAISE EXCEPTION
            'accept_pending_invitations still accepts caller-supplied identity (% overload(s))',
            arg_count;
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM pg_proc p
          JOIN pg_namespace n ON n.oid = p.pronamespace
         WHERE n.nspname = 'public'
           AND p.proname = 'accept_pending_invitations'
           AND p.pronargs = 0
    ) THEN
        RAISE EXCEPTION 'accept_pending_invitations() is missing';
    END IF;

    RAISE NOTICE 'accept_pending_invitations: identity comes from the JWT';
END $$;

-- And the behavioural half: a signed-in user may only accept invitations that
-- were addressed to their own e-mail address.
INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password,
                        email_confirmed_at, created_at, updated_at)
VALUES
    ('cccccccc-0000-4000-8000-00000000000c'::uuid,
     '00000000-0000-0000-0000-000000000000'::uuid, 'authenticated',
     'authenticated', 'invited@grants.test', '', now(), now(), now()),
    ('dddddddd-0000-4000-8000-00000000000d'::uuid,
     '00000000-0000-0000-0000-000000000000'::uuid, 'authenticated',
     'authenticated', 'outsider@grants.test', '', now(), now(), now()),
    ('eeeeeeee-0000-4000-8000-00000000000e'::uuid,
     '00000000-0000-0000-0000-000000000000'::uuid, 'authenticated',
     'authenticated', 'siteowner@grants.test', '', now(), now(), now());

INSERT INTO public.profiles (id, email, is_admin)
VALUES
    ('cccccccc-0000-4000-8000-00000000000c'::uuid, 'invited@grants.test', false),
    ('dddddddd-0000-4000-8000-00000000000d'::uuid, 'outsider@grants.test', false),
    ('eeeeeeee-0000-4000-8000-00000000000e'::uuid, 'siteowner@grants.test', false)
ON CONFLICT (id) DO UPDATE SET is_admin = false;

INSERT INTO public.sites (id, name, owner_profile_id, default_locale, locales)
VALUES ('c5170000-0000-4000-8000-0000000000c5'::uuid, 'Site C',
        'eeeeeeee-0000-4000-8000-00000000000e'::uuid, 'nl', ARRAY['nl']);

INSERT INTO public.site_invitations (site_id, email, role, status, expires_at)
VALUES ('c5170000-0000-4000-8000-0000000000c5'::uuid, 'invited@grants.test',
        'owner', 'pending', now() + interval '7 days');

DO $$
DECLARE
    members int;
BEGIN
    -- The outsider, acting as themselves, gets nothing: the invitation is not
    -- addressed to their e-mail address.
    SET LOCAL ROLE authenticated;
    PERFORM set_config(
        'request.jwt.claims',
        '{"sub":"dddddddd-0000-4000-8000-00000000000d","role":"authenticated","email":"outsider@grants.test"}',
        true
    );
    PERFORM public.accept_pending_invitations();

    SET LOCAL ROLE postgres;
    SELECT count(*) INTO members
      FROM public.site_members
     WHERE site_id = 'c5170000-0000-4000-8000-0000000000c5'::uuid
       AND profile_id = 'dddddddd-0000-4000-8000-00000000000d'::uuid;
    IF members <> 0 THEN
        RAISE EXCEPTION 'an outsider claimed an invitation addressed to someone else';
    END IF;

    -- The invited user does get their membership, with the invited role.
    SET LOCAL ROLE authenticated;
    PERFORM set_config(
        'request.jwt.claims',
        '{"sub":"cccccccc-0000-4000-8000-00000000000c","role":"authenticated","email":"invited@grants.test"}',
        true
    );
    PERFORM public.accept_pending_invitations();

    SET LOCAL ROLE postgres;
    SELECT count(*) INTO members
      FROM public.site_members
     WHERE site_id = 'c5170000-0000-4000-8000-0000000000c5'::uuid
       AND profile_id = 'cccccccc-0000-4000-8000-00000000000c'::uuid
       AND role = 'owner';
    IF members <> 1 THEN
        RAISE EXCEPTION 'the invited user did not receive their membership (saw %)', members;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM public.site_invitations
         WHERE site_id = 'c5170000-0000-4000-8000-0000000000c5'::uuid
           AND email = 'invited@grants.test'
           AND status = 'accepted'
    ) THEN
        RAISE EXCEPTION 'the invitation was not marked accepted';
    END IF;

    RAISE NOTICE 'accept_pending_invitations: only the addressee can accept';
END $$;

ROLLBACK;
