# Deploy HostHub Admin Console (Cloudflare Worker)

Single-worker setup that serves the Flutter web build on
`admin.trysilpanorama.com` at root path (`/`).

Current intent:
- Production website + preview stay on `https://trysilpanorama.com/...`
- HostHub admin is served from `https://admin.trysilpanorama.com`

## Files

- Worker script: `cloudflare/src/worker.js`
- Wrangler config: `cloudflare/wrangler.toml`
- Deploy script: `cloudflare/scripts/deploy_hosthub.sh`
- Local env file (not committed): `secrets/hosthub-prd.env`
- Workspace fallback env file (not committed): `../hosthub_secrets/hosthub-prd.env`

## Deploy

```bash
./cloudflare/scripts/deploy_hosthub.sh
```

Dry run:

```bash
./cloudflare/scripts/deploy_hosthub.sh --dry-run
```

Custom env file:

```bash
./cloudflare/scripts/deploy_hosthub.sh --env-file /path/to/hosthub-prd.env
```

If `--env-file` is provided and the file does not exist, deploy exits with an
error (no fallback).

## Deploy env file

The script uses global `wrangler login` auth by default. To use explicit
settings/tokens, create `secrets/hosthub-prd.env` (or
`../hosthub_secrets/hosthub-prd.env`):

```
CLOUDFLARE_API_TOKEN=<token>
CLOUDFLARE_ACCOUNT_ID=<account-id>
CLOUDFLARE_ZONE_ID=<zone-id>

# Optional routing/base-path overrides (defaults shown)
HOSTHUB_PUBLIC_DOMAIN=admin.trysilpanorama.com
HOSTHUB_ZONE_NAME=trysilpanorama.com
HOSTHUB_ADMIN_PATH=/
```

`HOSTHUB_ADMIN_PATH` controls:
- Flutter build base-href used by deploy script
- Worker prefix used to serve admin assets

The deploy script now also compiles Flutter with `--dart-define` values from
the loaded env context. Required app keys:

```
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<anon-key>    # preferred
# or legacy fallback:
# SUPABASE_KEY=<anon-or-service-key>
```

Optional app keys:

```
APP_ENVIRONMENT=prd             # defaults to prd when omitted
GOOGLE_API_KEY=<key>
PLACES_GOOGLE_API_KEY=<key>
ADMIN_BASE_URL=https://admin.trysilpanorama.com
LODGIFY_BASE_URL=https://api.lodgify.com
TESTFLIGHT_URL=<url>
CMS_PREVIEW_DOMAIN=<host:port>
```

Additional optional env vars:

```
# Enable Flutter wasm dry-run warnings (default is disabled for cleaner deploy logs)
HOSTHUB_WASM_DRY_RUN=1

# Override pinned wrangler version (default: 4.67.0)
HOSTHUB_WRANGLER_VERSION=4.67.0
```

## Routes

`cloudflare/wrangler.toml` currently declares:
- `admin.trysilpanorama.com/*`

If HostHub later moves to another domain, update the `routes` in
`cloudflare/wrangler.toml` and redeploy.

## Notes

- This worker serves the admin app on the configured host and path (defaults:
  `admin.trysilpanorama.com` + `/`).
- Preview pages (`/preview/<locale>`) are served by the website app, not this worker.
- Legacy env fallback is still supported:
  `cloudflare/secrets/hosthub-prd.env`.

See also: `docs/preview_and_routing.md`.
