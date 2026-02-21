# HostHub (Trysil CMS)

This workspace hosts the Flutter web HostHub console that talks to the Supabase backend defined in `supabase/`. The goal is to manage Trysil content (sites → localized content documents) while keeping the CLI flow you're already familiar with.

## Setup

```bash
cd hosthub/hosthub_console
flutter pub get
```

You can then run the console with `flutter run -d chrome --dart-define APP_ENVIRONMENT=dev` from `hosthub/hosthub_console` (see `hosthub/hosthub_console/assets/env/dev.env.example` for the required `SUPABASE_URL` / `SUPABASE_ANON_KEY`).

## Supabase CLI / database

All Supabase helpers live under `supabase/`. Run commands from that directory:

- `make preflight-local-db` – verifies local Supabase CLI + DB tooling and config.
- `supabase start` / `supabase stop` – bring up or stop the local Supabase stack (Postgres + Studio + edge runtime).
- `make apply-migrations-local` – applies the migrations (including the new workspace/site/content tables) to the local database.
- `make dump-schema-local` – snapshots the schema for inspection.
- `make sync-env-to-local ENV=dev` – resets the local schema from a remote project.

The CMS schema migrations are included in `supabase/migrations/` (for example `20260218_000001_create_cms_tables.sql` and follow-up migrations), so running `supabase start` and then `make apply-migrations-local` will ensure the schema exists locally.

## Content workflow

1. Use the `Sites` page to add a site and it will be linked to your profile automatically.
2. Insert content types / documents via Supabase SQL (the Flutter UI currently lists documents and can serve as a reference for future editors).

See `hosthub_console/CMS_PLAN.md` for the full content model, RLS strategy, and roadmap toward releases/CRM.
