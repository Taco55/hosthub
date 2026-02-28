-- Team management: site_members + site_invitations
-- Run this AFTER creating tables and functions in Supabase Studio.

-- ============================================================================
-- 1. Enum type
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE public.site_member_role AS ENUM ('owner', 'editor', 'viewer');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================================
-- 2. site_members table
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.site_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    role public.site_member_role NOT NULL DEFAULT 'viewer',
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,

    CONSTRAINT site_members_pkey PRIMARY KEY (id),
    CONSTRAINT site_members_site_id_profile_id_key UNIQUE (site_id, profile_id),
    CONSTRAINT site_members_site_id_fkey FOREIGN KEY (site_id)
        REFERENCES public.sites(id) ON DELETE CASCADE,
    CONSTRAINT site_members_profile_id_fkey FOREIGN KEY (profile_id)
        REFERENCES public.profiles(id) ON DELETE CASCADE
);

ALTER TABLE public.site_members ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_site_members_site_id
    ON public.site_members USING btree (site_id);
CREATE INDEX IF NOT EXISTS idx_site_members_profile_id
    ON public.site_members USING btree (profile_id);

GRANT ALL ON TABLE public.site_members TO anon;
GRANT ALL ON TABLE public.site_members TO authenticated;
GRANT ALL ON TABLE public.site_members TO service_role;

-- ============================================================================
-- 3. site_invitations table
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.site_invitations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    email text NOT NULL,
    role public.site_member_role NOT NULL DEFAULT 'editor',
    status text NOT NULL DEFAULT 'pending',
    invited_by uuid,
    expires_at timestamp with time zone DEFAULT (now() + interval '7 days') NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,

    CONSTRAINT site_invitations_pkey PRIMARY KEY (id),
    CONSTRAINT site_invitations_site_id_email_key UNIQUE (site_id, email),
    CONSTRAINT site_invitations_status_check CHECK (status IN ('pending', 'accepted', 'cancelled')),
    CONSTRAINT site_invitations_site_id_fkey FOREIGN KEY (site_id)
        REFERENCES public.sites(id) ON DELETE CASCADE,
    CONSTRAINT site_invitations_invited_by_fkey FOREIGN KEY (invited_by)
        REFERENCES public.profiles(id) ON DELETE SET NULL
);

ALTER TABLE public.site_invitations ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_site_invitations_site_id
    ON public.site_invitations USING btree (site_id);
CREATE INDEX IF NOT EXISTS idx_site_invitations_email
    ON public.site_invitations USING btree (email);

GRANT ALL ON TABLE public.site_invitations TO anon;
GRANT ALL ON TABLE public.site_invitations TO authenticated;
GRANT ALL ON TABLE public.site_invitations TO service_role;

-- ============================================================================
-- 4. has_site_access() helper function
-- ============================================================================

CREATE OR REPLACE FUNCTION public.has_site_access(
    check_site_id uuid,
    check_user_id uuid,
    min_role public.site_member_role DEFAULT 'viewer'
)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = check_user_id AND is_admin = true
    )
    OR EXISTS (
        SELECT 1 FROM public.sites
        WHERE id = check_site_id AND owner_profile_id = check_user_id
    )
    OR EXISTS (
        SELECT 1 FROM public.site_members
        WHERE site_id = check_site_id
          AND profile_id = check_user_id
          AND (
            CASE min_role
                WHEN 'viewer' THEN role IN ('viewer', 'editor', 'owner')
                WHEN 'editor' THEN role IN ('editor', 'owner')
                WHEN 'owner'  THEN role = 'owner'
            END
          )
    );
$$;

GRANT EXECUTE ON FUNCTION public.has_site_access(uuid, uuid, public.site_member_role) TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_site_access(uuid, uuid, public.site_member_role) TO service_role;

-- ============================================================================
-- 5. accept_pending_invitations() function
-- ============================================================================

CREATE OR REPLACE FUNCTION public.accept_pending_invitations(
    p_user_id uuid,
    p_user_email text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    inv RECORD;
BEGIN
    FOR inv IN
        SELECT id, site_id, role
        FROM public.site_invitations
        WHERE email = lower(trim(p_user_email))
          AND status = 'pending'
          AND expires_at > now()
    LOOP
        INSERT INTO public.site_members (site_id, profile_id, role)
        VALUES (inv.site_id, p_user_id, inv.role)
        ON CONFLICT (site_id, profile_id)
            DO UPDATE SET role = EXCLUDED.role, updated_at = now();

        UPDATE public.site_invitations
        SET status = 'accepted', updated_at = now()
        WHERE id = inv.id;
    END LOOP;
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_pending_invitations(uuid, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.accept_pending_invitations(uuid, text) TO service_role;

-- ============================================================================
-- 6. RLS Policies – site_members
-- ============================================================================

DROP POLICY IF EXISTS "Members can view site team" ON public.site_members;
CREATE POLICY "Members can view site team"
    ON public.site_members
    FOR SELECT
    TO authenticated
    USING (
        public.is_admin(auth.uid())
        OR profile_id = auth.uid()
        OR public.has_site_access(site_id, auth.uid())
    );

DROP POLICY IF EXISTS "Site owners can manage members" ON public.site_members;
CREATE POLICY "Site owners can manage members"
    ON public.site_members
    FOR ALL
    TO authenticated
    USING (
        public.is_admin(auth.uid())
        OR public.has_site_access(site_id, auth.uid(), 'owner')
    )
    WITH CHECK (
        public.is_admin(auth.uid())
        OR public.has_site_access(site_id, auth.uid(), 'owner')
    );

-- ============================================================================
-- 7. RLS Policies – site_invitations
-- ============================================================================

DROP POLICY IF EXISTS "Site owners can view invitations" ON public.site_invitations;
CREATE POLICY "Site owners can view invitations"
    ON public.site_invitations
    FOR SELECT
    TO authenticated
    USING (
        public.is_admin(auth.uid())
        OR public.has_site_access(site_id, auth.uid(), 'owner')
    );

DROP POLICY IF EXISTS "Site owners can manage invitations" ON public.site_invitations;
CREATE POLICY "Site owners can manage invitations"
    ON public.site_invitations
    FOR ALL
    TO authenticated
    USING (
        public.is_admin(auth.uid())
        OR public.has_site_access(site_id, auth.uid(), 'owner')
    )
    WITH CHECK (
        public.is_admin(auth.uid())
        OR public.has_site_access(site_id, auth.uid(), 'owner')
    );

-- ============================================================================
-- 8. Update existing RLS policies to use has_site_access()
-- ============================================================================

-- Sites: owners and members can view, only owners can modify
DROP POLICY IF EXISTS "Site owners can manage sites" ON public.sites;
CREATE POLICY "Site owners can manage sites"
    ON public.sites
    FOR ALL
    TO authenticated
    USING (
        public.is_admin(auth.uid())
        OR public.has_site_access(id, auth.uid())
    )
    WITH CHECK (
        public.is_admin(auth.uid())
        OR owner_profile_id = auth.uid()
    );

-- Site domains: only owners can manage
DROP POLICY IF EXISTS "Admins can manage site domains" ON public.site_domains;
CREATE POLICY "Site domain access"
    ON public.site_domains
    FOR ALL
    TO authenticated
    USING (
        public.is_admin(auth.uid())
        OR public.has_site_access(site_id, auth.uid(), 'owner')
    )
    WITH CHECK (
        public.is_admin(auth.uid())
        OR public.has_site_access(site_id, auth.uid(), 'owner')
    );

-- ============================================================================
-- 9. Seed existing site owners into site_members
-- ============================================================================

INSERT INTO public.site_members (site_id, profile_id, role)
SELECT id, owner_profile_id, 'owner'::public.site_member_role
FROM public.sites
WHERE owner_profile_id IS NOT NULL
ON CONFLICT (site_id, profile_id) DO NOTHING;
