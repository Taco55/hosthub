# HostHub (Trysil CMS)

This workspace hosts the Flutter web HostHub console that talks to the Supabase backend defined in `supabase/`. The goal is to manage Trysil content (sites → localized content documents) while keeping the CLI flow you're already familiar with.

## Setup

```bash
cd hosthub_console
flutter pub get
```

You can then run the console with `flutter run -d chrome --dart-define APP_ENVIRONMENT=dev` from `hosthub_console` (see `hosthub_console/assets/env/dev.env.example` for the required `SUPABASE_URL` / `SUPABASE_ANON_KEY`).

## Website preview (local debug)

The CMS "Preview website" button opens `/preview/<locale>` on the website host.

Run the website locally (port 43001):

```bash
cd web
npm install
npm run dev
```

Or use the helper that starts it if needed:

```bash
./scripts/ensure_preview_web.sh
```

The VS Code launch configuration runs this helper automatically as a pre-launch
task, so preview should be available whenever you start HostHub from launch.

Run the admin console locally (port 43000):

```bash
cd hosthub_console
flutter run -d web-server --web-port=43000
```

Run local debug against the production Supabase project on a fixed, non-conflicting port:

```bash
cd hosthub_console
flutter run -d chrome \
  --dart-define-from-file=../../hosthub_secrets/hosthub-prd.env \
  --dart-define=APP_ENVIRONMENT=prd \
  --dart-define=ADMIN_BASE_URL=http://localhost:43002 \
  --dart-define=DASHBOARD_BASE_URL=http://localhost:43002 \
  --web-hostname=localhost \
  --web-port=43002
```

In VS Code launch, `CMS_PREVIEW_DOMAIN=localhost:43001` is set for debug so preview opens your local website even when a production domain exists in `site_domains`.

No production deploy is triggered by these local steps.

In production builds (without `CMS_PREVIEW_DOMAIN`), the console preview button uses the site's `site_domains.is_primary = true` domain and opens `https://<primary-domain>/preview/<locale>`.

## Domain and routing strategy

Current production:
- Website: `https://trysilpanorama.com/<locale>`
- Website preview: `https://trysilpanorama.com/preview/<locale>`
- HostHub admin: `https://admin.trysilpanorama.com`

Generic website mode (single deploy, multiple domains/subdomains):
- Website runtime can resolve `site_id` by request host via `site_domains.domain`.
- Fallback remains `NEXT_PUBLIC_CMS_SITE_ID` when host lookup is unavailable.
- See `web/README.md` section "Generic multi-site mode" for required env vars.

Local development:
- HostHub admin (dev backend): `http://localhost:43000`
- HostHub admin (prd backend debug): `http://localhost:43002`
- Website + preview: `http://localhost:43001` and `http://localhost:43001/preview/<locale>`

When changing the admin host/path:
1. Update Cloudflare Worker routes in `cloudflare/wrangler.toml`.
2. Update deploy env (`HOSTHUB_PUBLIC_DOMAIN`, `HOSTHUB_ADMIN_PATH` if needed).
3. Set `site_domains.is_primary` in Supabase for the site that should drive preview links.
4. Remove debug override `CMS_PREVIEW_DOMAIN` from launch/build configs for production.

Full reference: `docs/preview_and_routing.md`.

## Supabase CLI / database

All Supabase helpers live under `supabase/`. Run commands from that directory:

- `make preflight-local-db` – verifies local Supabase CLI + DB tooling and config.
- `supabase start` / `supabase stop` – bring up or stop the local Supabase stack (Postgres + Studio + edge runtime).
- `make apply-migrations-local` – applies the migrations (including the new workspace/site/content tables) to the local database.
- `make dump-schema-local` – snapshots the schema for inspection.
- `make sync-env-to-local ENV=dev` – resets the local schema from a remote project.

The CMS schema migrations are included in `supabase/migrations/` (for example `20260218000001_create_cms_tables.sql` and follow-up migrations), so running `supabase start` and then `make apply-migrations-local` will ensure the schema exists locally.

## Content workflow

1. Use the `Sites` page to add a site and it will be linked to your profile automatically.
2. Insert content types / documents via Supabase SQL (the Flutter UI currently lists documents and can serve as a reference for future editors).

## Provision a new CMS site (one command)

You can create a new site, attach a primary domain, and clone baseline
`cms_documents` from a template site:

```bash
node scripts/provision_cms_site.mjs \
  --name "My New Chalet" \
  --domain chalet2.trysilpanorama.com \
  --source-site-id <template-site-uuid>
```

Dry run:

```bash
node scripts/provision_cms_site.mjs \
  --name "My New Chalet" \
  --domain chalet2.trysilpanorama.com \
  --source-site-id <template-site-uuid> \
  --dry-run
```

Required env vars:
- `NEXT_PUBLIC_SUPABASE_URL` (or `SUPABASE_URL`)
- `SUPABASE_SERVICE_ROLE_KEY`

See `hosthub_console/CMS_PLAN.md` for the full content model, RLS strategy, and roadmap toward releases/CRM.
