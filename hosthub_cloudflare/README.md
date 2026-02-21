# Deploy HostHub Admin Console (Cloudflare Worker)

Single-worker setup that serves the Flutter web build from `/admin` on
`trysilpanorama.com`.

## Files

- Worker script: `cloudflare/hosthub/src/worker.js`
- Wrangler config: `cloudflare/hosthub/wrangler.toml`
- Deploy script: `cloudflare/hosthub/scripts/deploy_hosthub.sh`
- Local secrets file (not committed): `secrets/hosthub-cloudflare-prd.env`

## Deploy

```bash
./cloudflare/hosthub/scripts/deploy_hosthub.sh
```

Dry run:

```bash
./cloudflare/hosthub/scripts/deploy_hosthub.sh --dry-run
```

The script uses global `wrangler login` auth by default. To use an explicit
API token, create `secrets/hosthub-cloudflare-prd.env` with:

```
CLOUDFLARE_API_TOKEN=<token>
CLOUDFLARE_ACCOUNT_ID=<account-id>
CLOUDFLARE_ZONE_ID=<zone-id>
```

Legacy fallback is still supported for compatibility:
`cloudflare/hosthub/secrets/hosthub-prd.env`.
