# HostHub Preview and Routing

This document defines the current routing model and local debug flow.

## Current production model

- Website: `https://trysilpanorama.com/<locale>`
- Website preview: `https://trysilpanorama.com/preview/<locale>`
- HostHub admin: `https://admin.trysilpanorama.com`

## Generic multi-site website mode

- The website app can resolve CMS `site_id` per request host (`site_domains.domain`)
  when `CMS_DOMAIN_LOOKUP_ENABLED=true` and `SUPABASE_SERVICE_ROLE_KEY` is set.
- If host lookup does not resolve, website runtime falls back to
  `NEXT_PUBLIC_CMS_SITE_ID`.
- This enables one website deployment to serve multiple subdomains/sites from CMS.
- Hero/gallery/booking runtime settings are read from `site_config/main`
  (`bookingUrl`, `heroImages`, `galleryAllFilenames`, `gallery`).

## Local development model

- HostHub admin: `http://localhost:43000`
- Website + preview: `http://localhost:43001` and `http://localhost:43001/preview/<locale>`

Reason: keep admin and website as separate local apps to avoid reverse-proxy
complexity during development.

## CMS preview URL resolution

HostHub resolves preview URLs in this order:

1. `CMS_PREVIEW_DOMAIN` (build-time override; debug/local use)
2. `site_domains.is_primary` from Supabase
3. fallback `localhost:43001`

Relevant code:

- `hosthub_console/lib/core/config/app_config.dart`
- `hosthub_console/lib/features/cms/application/cms_cubit.dart`

## Cloudflare admin worker

Worker scope:

- Serves admin on the configured host/path (default host
  `admin.trysilpanorama.com`, default path `/`)
- Does not serve website preview pages (`/preview/...`)

Relevant files:

- `cloudflare/src/worker.js`
- `cloudflare/wrangler.toml`
- `cloudflare/scripts/deploy_hosthub.sh`

## Cloudflare deploy env variables

Optional variables for `secrets/hosthub-prd.env`:

```text
CLOUDFLARE_API_TOKEN=<token>
CLOUDFLARE_ACCOUNT_ID=<account-id>
CLOUDFLARE_ZONE_ID=<zone-id>
HOSTHUB_PUBLIC_DOMAIN=admin.trysilpanorama.com
HOSTHUB_ZONE_NAME=trysilpanorama.com
HOSTHUB_ADMIN_PATH=/
```

Notes:

- `HOSTHUB_ADMIN_PATH` controls Flutter `--base-href` during deploy.
- `HOSTHUB_ADMIN_PATH` must match Worker route patterns in `cloudflare/wrangler.toml`.

## Quick local start

Website:

```bash
cd web
npm install
npm run dev
```

Admin:

```bash
cd hosthub_console
flutter run -d web-server --web-port=43000 \
  --dart-define=CMS_PREVIEW_DOMAIN=localhost:43001
```
