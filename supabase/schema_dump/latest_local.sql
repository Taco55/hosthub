--
-- PostgreSQL database dump
--

\restrict DFgUduSfcmKFIY4bRgHuv581gtnNH42y2fTeebhDu7bUahyOjg5xVsqLDv8dfTe

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.7 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: home_tab; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.home_tab AS ENUM (
    'start',
    'my_lists',
    'calendar'
);


ALTER TYPE public.home_tab OWNER TO postgres;

--
-- Name: site_member_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.site_member_role AS ENUM (
    'owner',
    'editor',
    'viewer'
);


ALTER TYPE public.site_member_role OWNER TO postgres;

--
-- Name: subscription_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.subscription_status AS ENUM (
    'free',
    'personal',
    'family',
    'pro',
    'family_invited',
    'beta',
    'invited'
);


ALTER TYPE public.subscription_status OWNER TO postgres;

--
-- Name: accept_pending_invitations(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.accept_pending_invitations(p_user_id uuid, p_user_email text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
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
        SET status = 'accepted'
        WHERE id = inv.id;
    END LOOP;
END;
$$;


ALTER FUNCTION public.accept_pending_invitations(p_user_id uuid, p_user_email text) OWNER TO postgres;

--
-- Name: cms_next_version(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cms_next_version() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  SELECT COALESCE(MAX(version), 0) + 1
  INTO NEW.version
  FROM public.cms_document_versions
  WHERE document_id = NEW.document_id;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.cms_next_version() OWNER TO postgres;

--
-- Name: create_local_admin_user(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_local_admin_user(admin_email text, admin_password text, admin_username text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'auth', 'public', 'extensions'
    AS $$
DECLARE
  v_email text;
  v_user_id uuid;
BEGIN
  v_email := lower(trim(admin_email));

  IF v_email IS NULL OR v_email = '' THEN
    RAISE EXCEPTION 'Email is required';
  END IF;

  IF admin_password IS NULL OR admin_password = '' THEN
    RAISE EXCEPTION 'Password is required';
  END IF;

  SELECT id
    INTO v_user_id
    FROM auth.users
   WHERE email = v_email;

  IF v_user_id IS NULL THEN
    v_user_id := gen_random_uuid();

    INSERT INTO auth.users (
      instance_id,
      id,
      email,
      encrypted_password,
      email_confirmed_at,
      confirmation_token,
      recovery_token,
      email_change_token_new,
      email_change,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      aud,
      role
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      v_user_id,
      v_email,
      crypt(admin_password, gen_salt('bf', 10)),
      now(),
      '',
      '',
      '',
      '',
      jsonb_build_object(
        'provider', 'email',
        'providers', jsonb_build_array('email')
      ),
      jsonb_build_object('username', admin_username),
      now(),
      now(),
      'authenticated',
      'authenticated'
    );
  END IF;

  IF NOT EXISTS (
    SELECT 1
      FROM auth.identities
     WHERE user_id = v_user_id
       AND provider = 'email'
  ) THEN
    INSERT INTO auth.identities (
      id,
      provider_id,
      user_id,
      identity_data,
      provider,
      last_sign_in_at,
      created_at,
      updated_at
    ) VALUES (
      gen_random_uuid(),
      v_user_id::text,
      v_user_id,
      jsonb_build_object('sub', v_user_id::text, 'email', v_email),
      'email',
      now(),
      now(),
      now()
    );
  END IF;

  INSERT INTO public.profiles (id, email, username, is_admin)
  VALUES (v_user_id, v_email, NULLIF(admin_username, ''), true)
  ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email,
        username = EXCLUDED.username,
        is_admin = true;

  RETURN v_user_id;
END;
$$;


ALTER FUNCTION public.create_local_admin_user(admin_email text, admin_password text, admin_username text) OWNER TO postgres;

--
-- Name: get_effective_lodgify_api_key(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_effective_lodgify_api_key(p_user_id uuid) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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


ALTER FUNCTION public.get_effective_lodgify_api_key(p_user_id uuid) OWNER TO postgres;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (NEW.id, COALESCE(NEW.email, ''))
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- Name: has_site_access(uuid, uuid, public.site_member_role); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.has_site_access(check_site_id uuid, check_user_id uuid, min_role public.site_member_role DEFAULT 'viewer'::public.site_member_role) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
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


ALTER FUNCTION public.has_site_access(check_site_id uuid, check_user_id uuid, min_role public.site_member_role) OWNER TO postgres;

--
-- Name: is_admin(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_admin(user_id uuid) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = user_id
      AND is_admin = true
  );
$$;


ALTER FUNCTION public.is_admin(user_id uuid) OWNER TO postgres;

--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

--
-- Name: sync_lodgify_api_key_secret(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sync_lodgify_api_key_secret() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
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


ALTER FUNCTION public.sync_lodgify_api_key_secret() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_settings (
    id text DEFAULT 'defaults'::text NOT NULL,
    maintenance_mode_enabled boolean DEFAULT false NOT NULL,
    email_user_on_create boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    booking_channel_fee_percentage numeric DEFAULT 15 NOT NULL,
    airbnb_channel_fee_percentage numeric DEFAULT 3 NOT NULL,
    other_channel_fee_percentage numeric DEFAULT 0 NOT NULL
);


ALTER TABLE public.admin_settings OWNER TO postgres;

--
-- Name: cms_document_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cms_document_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    document_id uuid NOT NULL,
    version integer NOT NULL,
    content jsonb NOT NULL,
    published_at timestamp with time zone DEFAULT now() NOT NULL,
    published_by uuid
);


ALTER TABLE public.cms_document_versions OWNER TO postgres;

--
-- Name: cms_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cms_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    content_type text NOT NULL,
    slug text NOT NULL,
    locale text NOT NULL,
    content jsonb DEFAULT '{}'::jsonb NOT NULL,
    status text DEFAULT 'published'::text NOT NULL,
    published_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid,
    CONSTRAINT cms_documents_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'published'::text])))
);


ALTER TABLE public.cms_documents OWNER TO postgres;

--
-- Name: cms_media; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cms_media (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    storage_path text NOT NULL,
    filename text NOT NULL,
    mime_type text,
    width integer,
    height integer,
    file_size_bytes bigint,
    alt_text jsonb DEFAULT '{}'::jsonb,
    tags text[] DEFAULT '{}'::text[],
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.cms_media OWNER TO postgres;

--
-- Name: cms_media_collection_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cms_media_collection_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    collection_id uuid NOT NULL,
    media_id uuid NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.cms_media_collection_items OWNER TO postgres;

--
-- Name: cms_media_collections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cms_media_collections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    key text NOT NULL,
    title jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.cms_media_collections OWNER TO postgres;

--
-- Name: lodgify_api_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lodgify_api_keys (
    profile_id uuid NOT NULL,
    api_key text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.lodgify_api_keys OWNER TO postgres;

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    email text DEFAULT ''::text NOT NULL,
    username text,
    fcm_token text,
    subscription_status public.subscription_status DEFAULT 'free'::public.subscription_status NOT NULL,
    is_development boolean DEFAULT false NOT NULL,
    is_seeded boolean DEFAULT false NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    show_calendar_tab boolean DEFAULT false NOT NULL,
    show_start_tab boolean DEFAULT true NOT NULL,
    default_home_tab public.home_tab DEFAULT 'start'::public.home_tab NOT NULL,
    notification_settings jsonb DEFAULT jsonb_build_object('notificationSound', NULL::unknown, 'notificationsEnabled', true, 'remindersEnabled', true, 'expirationRemindersEnabled', true) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: properties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.properties (
    id bigint NOT NULL,
    name text NOT NULL,
    address text,
    zip text,
    city text,
    country text,
    image_url text,
    has_addons boolean DEFAULT false NOT NULL,
    has_agreement boolean DEFAULT false NOT NULL,
    agreement_text text,
    agreement_url text,
    owner_spoken_languages text[],
    rating numeric,
    price_unit_in_days integer,
    min_price numeric,
    original_min_price numeric,
    max_price numeric,
    original_max_price numeric,
    rooms jsonb,
    in_out_max_date timestamp with time zone,
    in_out jsonb,
    currency jsonb,
    subscription_plans text[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    lodgify_id text,
    booking_channel_fee_percentage_override numeric,
    airbnb_channel_fee_percentage_override numeric,
    other_channel_fee_percentage_override numeric,
    cleaning_cost_fixed numeric DEFAULT 0 NOT NULL,
    linen_cost_fixed numeric DEFAULT 0 NOT NULL,
    service_cost_fixed numeric DEFAULT 0 NOT NULL,
    other_cost_fixed numeric DEFAULT 0 NOT NULL,
    channel_settings jsonb
);


ALTER TABLE public.properties OWNER TO postgres;

--
-- Name: properties_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.properties ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.properties_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.settings (
    id text DEFAULT 'defaults'::text NOT NULL,
    maintenance_mode_enabled boolean DEFAULT false NOT NULL,
    email_user_on_create boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.settings OWNER TO postgres;

--
-- Name: site_domains; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.site_domains (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid,
    domain text NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.site_domains OWNER TO postgres;

--
-- Name: site_invitations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.site_invitations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    email text NOT NULL,
    role public.site_member_role DEFAULT 'editor'::public.site_member_role NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    invited_by uuid,
    expires_at timestamp with time zone DEFAULT (now() + '7 days'::interval) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT site_invitations_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'accepted'::text, 'cancelled'::text])))
);


ALTER TABLE public.site_invitations OWNER TO postgres;

--
-- Name: site_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.site_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    site_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    role public.site_member_role DEFAULT 'viewer'::public.site_member_role NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.site_members OWNER TO postgres;

--
-- Name: sites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sites (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    owner_profile_id uuid,
    name text NOT NULL,
    default_locale text NOT NULL,
    locales text[] NOT NULL,
    timezone text DEFAULT 'Europe/Oslo'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.sites OWNER TO postgres;

--
-- Name: user_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_settings (
    profile_id uuid NOT NULL,
    language_code text,
    lodgify_api_key text,
    lodgify_connected boolean DEFAULT false NOT NULL,
    lodgify_connected_at timestamp with time zone,
    lodgify_last_synced_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    export_language_code text,
    export_columns jsonb,
    export_pdf_orientation text DEFAULT 'portrait'::text NOT NULL,
    CONSTRAINT user_settings_export_pdf_orientation_check CHECK ((export_pdf_orientation = ANY (ARRAY['portrait'::text, 'landscape'::text])))
);


ALTER TABLE public.user_settings OWNER TO postgres;

--
-- Name: admin_settings admin_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_settings
    ADD CONSTRAINT admin_settings_pkey PRIMARY KEY (id);


--
-- Name: cms_document_versions cms_document_versions_document_id_version_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_document_versions
    ADD CONSTRAINT cms_document_versions_document_id_version_key UNIQUE (document_id, version);


--
-- Name: cms_document_versions cms_document_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_document_versions
    ADD CONSTRAINT cms_document_versions_pkey PRIMARY KEY (id);


--
-- Name: cms_documents cms_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_documents
    ADD CONSTRAINT cms_documents_pkey PRIMARY KEY (id);


--
-- Name: cms_documents cms_documents_site_id_content_type_slug_locale_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_documents
    ADD CONSTRAINT cms_documents_site_id_content_type_slug_locale_key UNIQUE (site_id, content_type, slug, locale);


--
-- Name: cms_media_collection_items cms_media_collection_items_collection_id_media_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_media_collection_items
    ADD CONSTRAINT cms_media_collection_items_collection_id_media_id_key UNIQUE (collection_id, media_id);


--
-- Name: cms_media_collection_items cms_media_collection_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_media_collection_items
    ADD CONSTRAINT cms_media_collection_items_pkey PRIMARY KEY (id);


--
-- Name: cms_media_collections cms_media_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_media_collections
    ADD CONSTRAINT cms_media_collections_pkey PRIMARY KEY (id);


--
-- Name: cms_media_collections cms_media_collections_site_id_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_media_collections
    ADD CONSTRAINT cms_media_collections_site_id_key_key UNIQUE (site_id, key);


--
-- Name: cms_media cms_media_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_media
    ADD CONSTRAINT cms_media_pkey PRIMARY KEY (id);


--
-- Name: lodgify_api_keys lodgify_api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lodgify_api_keys
    ADD CONSTRAINT lodgify_api_keys_pkey PRIMARY KEY (profile_id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: properties properties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: site_domains site_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_domains
    ADD CONSTRAINT site_domains_pkey PRIMARY KEY (id);


--
-- Name: site_invitations site_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_invitations
    ADD CONSTRAINT site_invitations_pkey PRIMARY KEY (id);


--
-- Name: site_invitations site_invitations_site_id_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_invitations
    ADD CONSTRAINT site_invitations_site_id_email_key UNIQUE (site_id, email);


--
-- Name: site_members site_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_members
    ADD CONSTRAINT site_members_pkey PRIMARY KEY (id);


--
-- Name: site_members site_members_site_id_profile_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_members
    ADD CONSTRAINT site_members_site_id_profile_id_key UNIQUE (site_id, profile_id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (profile_id);


--
-- Name: idx_cms_doc_versions_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cms_doc_versions_lookup ON public.cms_document_versions USING btree (document_id, version DESC);


--
-- Name: idx_cms_documents_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cms_documents_lookup ON public.cms_documents USING btree (site_id, content_type, slug, locale) WHERE (status = 'published'::text);


--
-- Name: idx_cms_media_collection_items_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cms_media_collection_items_order ON public.cms_media_collection_items USING btree (collection_id, sort_order);


--
-- Name: idx_cms_media_site; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cms_media_site ON public.cms_media USING btree (site_id);


--
-- Name: idx_cms_media_tags; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cms_media_tags ON public.cms_media USING gin (tags);


--
-- Name: idx_site_invitations_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_site_invitations_email ON public.site_invitations USING btree (email);


--
-- Name: idx_site_invitations_site_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_site_invitations_site_id ON public.site_invitations USING btree (site_id);


--
-- Name: idx_site_members_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_site_members_profile_id ON public.site_members USING btree (profile_id);


--
-- Name: idx_site_members_site_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_site_members_site_id ON public.site_members USING btree (site_id);


--
-- Name: admin_settings set_admin_settings_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_admin_settings_updated_at BEFORE UPDATE ON public.admin_settings FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: cms_documents set_cms_documents_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_cms_documents_updated_at BEFORE UPDATE ON public.cms_documents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: cms_media set_cms_media_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_cms_media_updated_at BEFORE UPDATE ON public.cms_media FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: lodgify_api_keys set_lodgify_api_keys_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_lodgify_api_keys_updated_at BEFORE UPDATE ON public.lodgify_api_keys FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: profiles set_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: settings set_settings_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_settings_updated_at BEFORE UPDATE ON public.settings FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: user_settings set_user_settings_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_user_settings_updated_at BEFORE UPDATE ON public.user_settings FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: user_settings sync_lodgify_api_key_secret_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER sync_lodgify_api_key_secret_trigger BEFORE INSERT OR UPDATE OF lodgify_api_key ON public.user_settings FOR EACH ROW EXECUTE FUNCTION public.sync_lodgify_api_key_secret();


--
-- Name: cms_document_versions trg_cms_version_auto_increment; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_cms_version_auto_increment BEFORE INSERT ON public.cms_document_versions FOR EACH ROW EXECUTE FUNCTION public.cms_next_version();


--
-- Name: cms_document_versions cms_document_versions_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_document_versions
    ADD CONSTRAINT cms_document_versions_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.cms_documents(id) ON DELETE CASCADE;


--
-- Name: cms_document_versions cms_document_versions_published_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_document_versions
    ADD CONSTRAINT cms_document_versions_published_by_fkey FOREIGN KEY (published_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- Name: cms_documents cms_documents_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_documents
    ADD CONSTRAINT cms_documents_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: cms_documents cms_documents_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_documents
    ADD CONSTRAINT cms_documents_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- Name: cms_media_collection_items cms_media_collection_items_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_media_collection_items
    ADD CONSTRAINT cms_media_collection_items_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.cms_media_collections(id) ON DELETE CASCADE;


--
-- Name: cms_media_collection_items cms_media_collection_items_media_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_media_collection_items
    ADD CONSTRAINT cms_media_collection_items_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.cms_media(id) ON DELETE CASCADE;


--
-- Name: cms_media_collections cms_media_collections_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_media_collections
    ADD CONSTRAINT cms_media_collections_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: cms_media cms_media_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cms_media
    ADD CONSTRAINT cms_media_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: lodgify_api_keys lodgify_api_keys_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lodgify_api_keys
    ADD CONSTRAINT lodgify_api_keys_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: site_domains site_domains_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_domains
    ADD CONSTRAINT site_domains_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: site_invitations site_invitations_invited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_invitations
    ADD CONSTRAINT site_invitations_invited_by_fkey FOREIGN KEY (invited_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- Name: site_invitations site_invitations_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_invitations
    ADD CONSTRAINT site_invitations_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: site_members site_members_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_members
    ADD CONSTRAINT site_members_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: site_members site_members_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_members
    ADD CONSTRAINT site_members_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.sites(id) ON DELETE CASCADE;


--
-- Name: sites sites_owner_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_owner_profile_id_fkey FOREIGN KEY (owner_profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: user_settings user_settings_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_settings
    ADD CONSTRAINT user_settings_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- Name: admin_settings Admins can manage admin settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage admin settings" ON public.admin_settings TO authenticated USING (public.is_admin(auth.uid())) WITH CHECK (public.is_admin(auth.uid()));


--
-- Name: profiles Admins can manage profiles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage profiles" ON public.profiles TO authenticated USING (public.is_admin(auth.uid())) WITH CHECK (public.is_admin(auth.uid()));


--
-- Name: settings Admins can manage settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage settings" ON public.settings TO authenticated USING (public.is_admin(auth.uid())) WITH CHECK (public.is_admin(auth.uid()));


--
-- Name: cms_media_collection_items CMS collection items are publicly readable; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "CMS collection items are publicly readable" ON public.cms_media_collection_items FOR SELECT TO authenticated, anon USING (true);


--
-- Name: cms_media_collections CMS media collections are publicly readable; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "CMS media collections are publicly readable" ON public.cms_media_collections FOR SELECT TO authenticated, anon USING (true);


--
-- Name: cms_media CMS media is publicly readable; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "CMS media is publicly readable" ON public.cms_media FOR SELECT TO authenticated, anon USING (true);


--
-- Name: site_members Members can view site team; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Members can view site team" ON public.site_members FOR SELECT TO authenticated USING ((public.is_admin(auth.uid()) OR (profile_id = auth.uid()) OR public.has_site_access(site_id, auth.uid())));


--
-- Name: profiles Profiles are viewable by owner or admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Profiles are viewable by owner or admin" ON public.profiles FOR SELECT TO authenticated USING (((id = auth.uid()) OR public.is_admin(auth.uid())));


--
-- Name: cms_documents Published CMS documents are publicly readable; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Published CMS documents are publicly readable" ON public.cms_documents FOR SELECT TO authenticated, anon USING ((status = 'published'::text));


--
-- Name: site_domains Site domain access; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site domain access" ON public.site_domains TO authenticated USING ((public.is_admin(auth.uid()) OR public.has_site_access(site_id, auth.uid(), 'owner'::public.site_member_role))) WITH CHECK ((public.is_admin(auth.uid()) OR public.has_site_access(site_id, auth.uid(), 'owner'::public.site_member_role)));


--
-- Name: site_domains Site domains limited to site owners; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site domains limited to site owners" ON public.site_domains USING ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.sites s
  WHERE ((s.id = site_domains.site_id) AND (s.owner_profile_id = auth.uid())))))) WITH CHECK ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.sites s
  WHERE ((s.id = site_domains.site_id) AND (s.owner_profile_id = auth.uid()))))));


--
-- Name: cms_document_versions Site owners can create CMS versions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site owners can create CMS versions" ON public.cms_document_versions FOR INSERT TO authenticated WITH CHECK ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM (public.cms_documents d
     JOIN public.sites s ON ((s.id = d.site_id)))
  WHERE ((d.id = cms_document_versions.document_id) AND (s.owner_profile_id = auth.uid()))))));


--
-- Name: cms_media_collection_items Site owners can manage CMS collection items; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site owners can manage CMS collection items" ON public.cms_media_collection_items TO authenticated USING ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM (public.cms_media_collections mc
     JOIN public.sites s ON ((s.id = mc.site_id)))
  WHERE ((mc.id = cms_media_collection_items.collection_id) AND (s.owner_profile_id = auth.uid())))))) WITH CHECK ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM (public.cms_media_collections mc
     JOIN public.sites s ON ((s.id = mc.site_id)))
  WHERE ((mc.id = cms_media_collection_items.collection_id) AND (s.owner_profile_id = auth.uid()))))));


--
-- Name: cms_documents Site owners can manage CMS documents; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site owners can manage CMS documents" ON public.cms_documents TO authenticated USING ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.sites s
  WHERE ((s.id = cms_documents.site_id) AND (s.owner_profile_id = auth.uid())))))) WITH CHECK ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.sites s
  WHERE ((s.id = cms_documents.site_id) AND (s.owner_profile_id = auth.uid()))))));


--
-- Name: cms_media Site owners can manage CMS media; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site owners can manage CMS media" ON public.cms_media TO authenticated USING ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.sites s
  WHERE ((s.id = cms_media.site_id) AND (s.owner_profile_id = auth.uid())))))) WITH CHECK ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.sites s
  WHERE ((s.id = cms_media.site_id) AND (s.owner_profile_id = auth.uid()))))));


--
-- Name: cms_media_collections Site owners can manage CMS media collections; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site owners can manage CMS media collections" ON public.cms_media_collections TO authenticated USING ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.sites s
  WHERE ((s.id = cms_media_collections.site_id) AND (s.owner_profile_id = auth.uid())))))) WITH CHECK ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM public.sites s
  WHERE ((s.id = cms_media_collections.site_id) AND (s.owner_profile_id = auth.uid()))))));


--
-- Name: site_invitations Site owners can manage invitations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site owners can manage invitations" ON public.site_invitations TO authenticated USING ((public.is_admin(auth.uid()) OR public.has_site_access(site_id, auth.uid(), 'owner'::public.site_member_role))) WITH CHECK ((public.is_admin(auth.uid()) OR public.has_site_access(site_id, auth.uid(), 'owner'::public.site_member_role)));


--
-- Name: site_members Site owners can manage members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site owners can manage members" ON public.site_members TO authenticated USING ((public.is_admin(auth.uid()) OR public.has_site_access(site_id, auth.uid(), 'owner'::public.site_member_role))) WITH CHECK ((public.is_admin(auth.uid()) OR public.has_site_access(site_id, auth.uid(), 'owner'::public.site_member_role)));


--
-- Name: sites Site owners can manage sites; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site owners can manage sites" ON public.sites TO authenticated USING ((public.is_admin(auth.uid()) OR public.has_site_access(id, auth.uid()))) WITH CHECK ((public.is_admin(auth.uid()) OR (owner_profile_id = auth.uid())));


--
-- Name: cms_document_versions Site owners can read CMS versions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site owners can read CMS versions" ON public.cms_document_versions FOR SELECT TO authenticated USING ((public.is_admin(auth.uid()) OR (EXISTS ( SELECT 1
   FROM (public.cms_documents d
     JOIN public.sites s ON ((s.id = d.site_id)))
  WHERE ((d.id = cms_document_versions.document_id) AND (s.owner_profile_id = auth.uid()))))));


--
-- Name: site_invitations Site owners can view invitations; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Site owners can view invitations" ON public.site_invitations FOR SELECT TO authenticated USING ((public.is_admin(auth.uid()) OR public.has_site_access(site_id, auth.uid(), 'owner'::public.site_member_role)));


--
-- Name: profiles Users can insert their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT TO authenticated WITH CHECK (((id = auth.uid()) AND (is_admin = false)));


--
-- Name: user_settings Users can manage own user settings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can manage own user settings" ON public.user_settings TO authenticated USING (((profile_id = auth.uid()) OR public.is_admin(auth.uid()))) WITH CHECK (((profile_id = auth.uid()) OR public.is_admin(auth.uid())));


--
-- Name: profiles Users can update their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE TO authenticated USING ((id = auth.uid())) WITH CHECK (((id = auth.uid()) AND (is_admin = false)));


--
-- Name: admin_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: cms_document_versions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cms_document_versions ENABLE ROW LEVEL SECURITY;

--
-- Name: cms_documents; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cms_documents ENABLE ROW LEVEL SECURITY;

--
-- Name: cms_media; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cms_media ENABLE ROW LEVEL SECURITY;

--
-- Name: cms_media_collection_items; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cms_media_collection_items ENABLE ROW LEVEL SECURITY;

--
-- Name: cms_media_collections; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.cms_media_collections ENABLE ROW LEVEL SECURITY;

--
-- Name: lodgify_api_keys; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.lodgify_api_keys ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

--
-- Name: site_domains; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.site_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: site_invitations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.site_invitations ENABLE ROW LEVEL SECURITY;

--
-- Name: site_members; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.site_members ENABLE ROW LEVEL SECURITY;

--
-- Name: sites; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.sites ENABLE ROW LEVEL SECURITY;

--
-- Name: user_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: FUNCTION accept_pending_invitations(p_user_id uuid, p_user_email text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.accept_pending_invitations(p_user_id uuid, p_user_email text) TO anon;
GRANT ALL ON FUNCTION public.accept_pending_invitations(p_user_id uuid, p_user_email text) TO authenticated;
GRANT ALL ON FUNCTION public.accept_pending_invitations(p_user_id uuid, p_user_email text) TO service_role;


--
-- Name: FUNCTION cms_next_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.cms_next_version() TO anon;
GRANT ALL ON FUNCTION public.cms_next_version() TO authenticated;
GRANT ALL ON FUNCTION public.cms_next_version() TO service_role;


--
-- Name: FUNCTION create_local_admin_user(admin_email text, admin_password text, admin_username text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_local_admin_user(admin_email text, admin_password text, admin_username text) TO anon;
GRANT ALL ON FUNCTION public.create_local_admin_user(admin_email text, admin_password text, admin_username text) TO authenticated;


--
-- Name: FUNCTION get_effective_lodgify_api_key(p_user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.get_effective_lodgify_api_key(p_user_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.get_effective_lodgify_api_key(p_user_id uuid) TO service_role;


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- Name: FUNCTION has_site_access(check_site_id uuid, check_user_id uuid, min_role public.site_member_role); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.has_site_access(check_site_id uuid, check_user_id uuid, min_role public.site_member_role) TO anon;
GRANT ALL ON FUNCTION public.has_site_access(check_site_id uuid, check_user_id uuid, min_role public.site_member_role) TO authenticated;
GRANT ALL ON FUNCTION public.has_site_access(check_site_id uuid, check_user_id uuid, min_role public.site_member_role) TO service_role;


--
-- Name: FUNCTION is_admin(user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_admin(user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.is_admin(user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.is_admin(user_id uuid) TO service_role;


--
-- Name: FUNCTION set_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.set_updated_at() TO anon;
GRANT ALL ON FUNCTION public.set_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.set_updated_at() TO service_role;


--
-- Name: FUNCTION sync_lodgify_api_key_secret(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.sync_lodgify_api_key_secret() TO anon;
GRANT ALL ON FUNCTION public.sync_lodgify_api_key_secret() TO authenticated;
GRANT ALL ON FUNCTION public.sync_lodgify_api_key_secret() TO service_role;


--
-- Name: TABLE admin_settings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.admin_settings TO anon;
GRANT ALL ON TABLE public.admin_settings TO authenticated;
GRANT ALL ON TABLE public.admin_settings TO service_role;


--
-- Name: TABLE cms_document_versions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.cms_document_versions TO anon;
GRANT ALL ON TABLE public.cms_document_versions TO authenticated;
GRANT ALL ON TABLE public.cms_document_versions TO service_role;


--
-- Name: TABLE cms_documents; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.cms_documents TO anon;
GRANT ALL ON TABLE public.cms_documents TO authenticated;
GRANT ALL ON TABLE public.cms_documents TO service_role;


--
-- Name: TABLE cms_media; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.cms_media TO anon;
GRANT ALL ON TABLE public.cms_media TO authenticated;
GRANT ALL ON TABLE public.cms_media TO service_role;


--
-- Name: TABLE cms_media_collection_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.cms_media_collection_items TO anon;
GRANT ALL ON TABLE public.cms_media_collection_items TO authenticated;
GRANT ALL ON TABLE public.cms_media_collection_items TO service_role;


--
-- Name: TABLE cms_media_collections; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.cms_media_collections TO anon;
GRANT ALL ON TABLE public.cms_media_collections TO authenticated;
GRANT ALL ON TABLE public.cms_media_collections TO service_role;


--
-- Name: TABLE lodgify_api_keys; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.lodgify_api_keys TO service_role;


--
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- Name: TABLE properties; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.properties TO anon;
GRANT ALL ON TABLE public.properties TO authenticated;
GRANT ALL ON TABLE public.properties TO service_role;


--
-- Name: SEQUENCE properties_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.properties_id_seq TO anon;
GRANT ALL ON SEQUENCE public.properties_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.properties_id_seq TO service_role;


--
-- Name: TABLE settings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.settings TO anon;
GRANT ALL ON TABLE public.settings TO authenticated;
GRANT ALL ON TABLE public.settings TO service_role;


--
-- Name: TABLE site_domains; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.site_domains TO anon;
GRANT ALL ON TABLE public.site_domains TO authenticated;
GRANT ALL ON TABLE public.site_domains TO service_role;


--
-- Name: TABLE site_invitations; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.site_invitations TO anon;
GRANT ALL ON TABLE public.site_invitations TO authenticated;
GRANT ALL ON TABLE public.site_invitations TO service_role;


--
-- Name: TABLE site_members; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.site_members TO anon;
GRANT ALL ON TABLE public.site_members TO authenticated;
GRANT ALL ON TABLE public.site_members TO service_role;


--
-- Name: TABLE sites; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.sites TO anon;
GRANT ALL ON TABLE public.sites TO authenticated;
GRANT ALL ON TABLE public.sites TO service_role;


--
-- Name: TABLE user_settings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_settings TO anon;
GRANT ALL ON TABLE public.user_settings TO authenticated;
GRANT ALL ON TABLE public.user_settings TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- PostgreSQL database dump complete
--

\unrestrict DFgUduSfcmKFIY4bRgHuv581gtnNH42y2fTeebhDu7bUahyOjg5xVsqLDv8dfTe

