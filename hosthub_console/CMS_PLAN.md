# Trysil CMS / HostHub Plan

## Goal
Replace the existing HostHub-focused admin console with a lean Trysil Panorama content manager, remove list/field/client-app overhead, and keep the Supabase CLI workflows while exposing the new database schema.

## Data model (per request)

```sql
CREATE TABLE sites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_profile_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  default_locale text NOT NULL,
  locales text[] NOT NULL,
  timezone text NOT NULL DEFAULT 'Europe/Oslo',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE site_domains (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id uuid REFERENCES sites(id) ON DELETE CASCADE,
  domain text NOT NULL,
  is_primary boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE content_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id uuid REFERENCES sites(id) ON DELETE CASCADE,
  key text NOT NULL,
  schema_json jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE content_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id uuid REFERENCES sites(id) ON DELETE CASCADE,
  type_id uuid REFERENCES content_types(id) ON DELETE CASCADE,
  slug text NOT NULL,
  locale text NOT NULL,
  status text NOT NULL CHECK (status IN ('draft','published')),
  version int NOT NULL DEFAULT 1,
  document jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by uuid,
  published_at timestamptz,
  published_by uuid,
  UNIQUE (site_id, type_id, slug, locale, version)
);

CREATE TABLE content_releases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id uuid REFERENCES sites(id) ON DELETE CASCADE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  published_at timestamptz
);
```

### RLS sketch
- Enable row level security on each table.
- Grant site access to owners via `sites.owner_profile_id`.
- Scope content_types/documents by `site_id`.
- `content_documents` `status = 'published'` for public queries, preview uses service key.

## Admin UI adjustments
1. Keep the authentication + shell (`SectionScaffold`, `AppProviders`) so Supabase credentials, user management, and theming remain.
2. Replace `MenuItem` with Trysil-focused sections (`sites`, `content`, `settings`).
3. Remove existing feature modules (`list_templates`, `field_definitions`, `client_apps`) and their dependencies from the router/side menu.
4. Introduce a new `ContentDocumentsPage` (or similar) that lists `content_documents` per site/type and a simple editor (text editor + locale tabs) that fetches/saves JSON via Supabase. Reuse `FieldRepository` patterns (bloc/cubit) if helpful.
5. Keep Server Settings page for generic toggles (can be repurposed or removed once replaced by workspace/site settings).

## CLI instructions to run the database
Supabase already has `supabase/Makefile` in this workspace. To spin up a local DB:

```bash
cd supabase
make preflight-local-db
supabase start       # boots Supabase local stack (edge runtime + Postgres)
make apply-migrations-local
make dump-schema-local
```

You can reset to a remote snapshot with:
```bash
make sync-env-to-local ENV=dev
```

Add `ADMIN_BASE_URL` / `SUPABASE_DB_URL` into `supabase/.env.*` before running remote commands. We can also expose a root-level `npm run supabase:*` script if desired.

## Next steps
1. Build the new content repository + bloc to interact with `content_documents`.
2. Wire the side menu + router to the new pages.
3. Create a Supabase migration file (and seed JSON schemas for `localizedContent`, `cabinContent`, `contactFormSection`).
4. Update docs/README with CLI instructions and how to seed initial site/content.
