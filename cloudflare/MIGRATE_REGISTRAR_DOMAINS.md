# Migrate `trysilpanorama.com` and `ev-reward.com` to a new Cloudflare account

Both domains are currently registered at Cloudflare Registrar.  
For Registrar domains, Cloudflare requires a manual account-to-account move
request and acceptance in Dashboard.

Cloudflare docs:
- https://developers.cloudflare.com/registrar/account-options/domain-moves/
- https://developers.cloudflare.com/fundamentals/account/account-security/account-share/transfer-domain-to-another-cloudflare-account/

## 1. Create target account and token

In the new Cloudflare account, create an API token with at least:
- `Account` -> `Account Settings:Read`
- `Zone` -> `Zone:Read`
- `Zone` -> `DNS:Edit`
- `Zone` -> `DNS:Read`

Scope the token to the target account and the two target zones.

Create a local env file (not committed), for example:

```bash
# ../hosthub_secrets/hosthub-prd-new-account.env
CLOUDFLARE_API_TOKEN=<target-account-token>
CLOUDFLARE_ACCOUNT_ID=<target-account-id>
```

## 2. Copy DNS into target account

Run the migration prep script:

```bash
./cloudflare/scripts/prepare_zone_migration.sh \
  --source-env ../hosthub_secrets/hosthub-prd.env \
  --target-env ../hosthub_secrets/hosthub-prd-new-account.env \
  --domains trysilpanorama.com,ev-reward.com
```

Backups and snapshots are stored in:

`cloudflare/migration_backups/<timestamp>/`

## 3. Move Registrar domains between accounts (manual, required)

In Cloudflare Dashboard:
1. Source account: submit domain move request for each domain.
2. Target account: accept each incoming request.

After acceptance, verify both domains are visible in the target account and
that the zone nameservers match the target zone details from:

`cloudflare/migration_backups/<timestamp>/migration_summary.txt`

## 4. Validate traffic

Run checks:

```bash
dig +short NS trysilpanorama.com
dig +short NS ev-reward.com
curl -I https://admin.trysilpanorama.com/
```

If both domains resolve and routes behave as expected, the migration is done.
