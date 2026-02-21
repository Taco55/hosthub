--
-- Local helper: create an admin user (auth.users + profiles).
-- Intended for local development only.
--

CREATE OR REPLACE FUNCTION public.create_local_admin_user(
  admin_email text,
  admin_password text,
  admin_username text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = auth, public, extensions
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

-- Revoke from API roles so the function is only callable via psql (as postgres).
REVOKE ALL ON FUNCTION public.create_local_admin_user(text, text, text) FROM anon, authenticated, service_role;
