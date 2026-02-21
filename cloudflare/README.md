# Deploy HostHub Admin Console (Cloudflare Worker)

Single-worker setup that serves the Flutter web build from `/admin` on
`trysilpanorama.com` (apex + `www`).

Current intent:
- Production website + preview stay on `https://trysilpanorama.com/...`
- HostHub admin is served from `https://trysilpanorama.com/admin`

## Files

- Worker script: `cloudflare/src/worker.js`
- Wrangler config: `cloudflare/wrangler.toml`
- Deploy script: `cloudflare/scripts/deploy_hosthub.sh`
- Local env file (not committed): `secrets/hosthub-cloudflare-prd.env`

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
./cloudflare/scripts/deploy_hosthub.sh --env-file /path/to/hosthub-cloudflare-prd.env
```

If `--env-file` is provided and the file does not exist, deploy exits with an
error (no fallback).

## Deploy env file

The script uses global `wrangler login` auth by default. To use explicit
settings/tokens, create `secrets/hosthub-cloudflare-prd.env`:

```
CLOUDFLARE_API_TOKEN=<token>
CLOUDFLARE_ACCOUNT_ID=<account-id>
CLOUDFLARE_ZONE_ID=<zone-id>

# Optional routing/base-path overrides (defaults shown)
HOSTHUB_PUBLIC_DOMAIN=trysilpanorama.com
HOSTHUB_ZONE_NAME=trysilpanorama.com
HOSTHUB_ADMIN_PATH=/admin
```

`HOSTHUB_ADMIN_PATH` controls:
- Flutter build base-href used by deploy script
- Worker prefix used to serve admin assets

Additional optional env vars:

```
# Enable Flutter wasm dry-run warnings (default is disabled for cleaner deploy logs)
HOSTHUB_WASM_DRY_RUN=1

# Override pinned wrangler version (default: 4.67.0)
HOSTHUB_WRANGLER_VERSION=4.67.0
```

## Routes

`cloudflare/wrangler.toml` currently declares:
- `trysilpanorama.com/admin*`
- `www.trysilpanorama.com/admin*`

If HostHub later moves to another domain, update the `routes` in
`cloudflare/wrangler.toml` and redeploy.

## Notes

- This worker only serves the admin app path (`/admin` by default).
- Preview pages (`/preview/<locale>`) are served by the website app, not this worker.
- Legacy env fallback is still supported:
  `cloudflare/secrets/hosthub-prd.env`.

See also: `docs/preview_and_routing.md`.
