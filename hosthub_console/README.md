# HostHub Admin Console

Flutter web app for managing HostHub users. Admins can browse profiles, review app subscriptions, inspect user lists, and toggle admin access.

## Configure environment

Copy `assets/env/dev.env` and fill in the Supabase credentials for the environment you want to target:

```bash
cp assets/env/dev.env assets/env/stg.env
```

Required keys:

```text
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Select the env file at runtime with `--dart-define APP_ENVIRONMENT=stg` (defaults to `dev`).

## Run locally

```bash
flutter pub get
flutter run -d chrome \
  --dart-define APP_ENVIRONMENT=dev
```

## Supabase policies

The admin console requires the policies defined in `../../supabase/policies/admin_access.sql`. Apply them to your Supabase project so users with `profiles.is_admin = true` can query other accounts and lists.
