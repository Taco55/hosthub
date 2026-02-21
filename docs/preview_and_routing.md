# HostHub Preview and Routing

This document defines the current routing model, local debug flow, and the
future migration path to a dedicated HostHub domain.

## Current production model (unchanged)

- Website: `https://trysilpanorama.com/<locale>`
- Website preview: `https://trysilpanorama.com/preview/<locale>`
- HostHub admin: `https://trysilpanorama.com/admin`

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

- Serves only admin path (`/admin` by default)
- Does not serve website preview pages (`/preview/...`)

Relevant files:

- `cloudflare/src/worker.js`
- `cloudflare/wrangler.toml`
- `cloudflare/scripts/deploy_hosthub.sh`

## Cloudflare deploy env variables

Optional variables for `secrets/hosthub-cloudflare-prd.env`:

```text
CLOUDFLARE_API_TOKEN=<token>
CLOUDFLARE_ACCOUNT_ID=<account-id>
CLOUDFLARE_ZONE_ID=<zone-id>
HOSTHUB_PUBLIC_DOMAIN=trysilpanorama.com
HOSTHUB_ZONE_NAME=trysilpanorama.com
HOSTHUB_ADMIN_PATH=/admin
```

Notes:

- `HOSTHUB_ADMIN_PATH` controls Flutter `--base-href` during deploy.
- `HOSTHUB_ADMIN_PATH` must match Worker route patterns in `cloudflare/wrangler.toml`.

## Future migration checklist (HostHub own domain)

1. Update Cloudflare route patterns in `cloudflare/wrangler.toml`.
2. Update deploy env (`HOSTHUB_PUBLIC_DOMAIN`, optionally `HOSTHUB_ADMIN_PATH`).
3. Set/verify `site_domains.is_primary` for preview domain selection.
4. Remove `CMS_PREVIEW_DOMAIN` from production launch/build configuration.
5. Redeploy website + admin worker.

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
