# HostHub multi-site platform

Status: **decided — Model B (shared worker, domain lookup)**. This document is the
target architecture and the migration/operations guide for running many customer
websites on one HostHub stack.

> Platform domain is not finalized. Placeholder below: **`hosthub.com`**, with the
> admin/dashboard on **`dashboard.hosthub.com`** (tentative — "ofzo"). Substitute the
> real name once chosen. It stands for "the neutral platform domain, not a customer
> domain".

## The model (B)

One shared Next.js worker renders **all** customer sites. For each request the
worker reads the incoming host, looks it up in `public.site_domains`, and serves
that `site_id`'s CMS content.

```
request host ──► site_domains(domain) ──► site_id ──► CMS content (per site)
                         │
                         └─ no match ──► NEXT_PUBLIC_CMS_SITE_ID (env default)
                                          └─ still none ──► static fallback snapshot
```

Code path: `web/lib/runtime-site-context.ts` (`findSiteIdByDomain`) → content
provider. Data model: `sites`, `site_domains {site_id, domain, is_primary}`,
`site_invitations` (per-site members).

Adding a website is **data + DNS**, not a new codebase or deploy.

## Domain scheme

| Purpose | Domain | Served by |
|---|---|---|
| Platform admin console | now `admin.trysilpanorama.com`; later `dashboard.hosthub.com` | `hosthub-admin-router` worker (Flutter console) |
| Shared sites renderer | (no domain of its own) | `hosthub-sites` worker |
| Customer site: Trysil Panorama | `trysilpanorama.com`, `www.…`, `chalet2.…` | `hosthub-sites` (via `site_domains`) |
| Future customer sites | their own domains | `hosthub-sites` (via `site_domains`) |

Trysil Panorama becomes *the first customer*, not the baseline. The platform's own
identity moves to the `hosthub.com` domain later.

## Keys / naming

Aligned to Supabase's current key naming:

- **Publishable key** (`sb_publishable_…`) — public/anon. Env: `SUPABASE_KEY` today
  (Flutter also reads `SUPABASE_ANON_KEY`).
- **Secret key** (`sb_secret_…`) — server-side only, replaces the service-role key.
  Env: **`SUPABASE_SECRET_KEY`** (primary). Legacy `SUPABASE_SERVICE_ROLE_KEY` is
  still accepted everywhere as a fallback, so nothing breaks.

## What changed in the repo (done)

- `web/package.json` name: `trysilpanorama` → `hosthub-sites`
- `web/wrangler.jsonc`: worker `name` + self-reference `service` → `hosthub-sites`;
  `CMS_DOMAIN_LOOKUP_ENABLED` `false` → `true`; comments updated to Model B.
- `web/lib/runtime-site-context.ts`: reads `SUPABASE_SECRET_KEY` first, falls back
  to `SUPABASE_SERVICE_ROLE_KEY`.
- **Admin route is now env-driven.** `cloudflare/wrangler.toml` no longer hardcodes
  a route; `deploy_hosthub.sh` injects it via `--route`, generated from
  `HOSTHUB_PUBLIC_DOMAIN` + `HOSTHUB_ADMIN_PATH`. These live in `hosthub-prd.env`
  (currently `admin.trysilpanorama.com` / `/`). Behavior is identical to before;
  the domain is now a single knob.

## Deploy prerequisites for Model B

The shared worker now needs to reach Supabase for the domain lookup. Set these as
worker secrets/vars (never commit):

```bash
# in web/, per environment
npx wrangler secret put SUPABASE_SECRET_KEY   # the sb_secret_… key
```

- `NEXT_PUBLIC_SUPABASE_URL` must point at the right Supabase project.
- Without the secret key the lookup degrades gracefully to `NEXT_PUBLIC_CMS_SITE_ID`,
  so the site still renders — but it will NOT be multi-site. Treat the key as
  required for B.

## Worker rename migration (one-time, at next deploy)

Renaming the worker means the next `npm run deploy` creates a **new** worker
`hosthub-sites`; the old `trysilpanorama` worker keeps running with its routes
until you move them.

1. Deploy `hosthub-sites` (creates the new worker, no routes yet).
2. Move the routes/custom-domains from `trysilpanorama` → `hosthub-sites`
   (`trysilpanorama.com`, `www.`, `chalet2.`).
3. Verify the live site serves from `hosthub-sites`.
4. Delete the orphaned `trysilpanorama` worker.

## Console route (platform domain) — READY, switch = env edit

The admin route is now driven by `hosthub-prd.env` (single source of truth):

```bash
HOSTHUB_PUBLIC_DOMAIN=admin.trysilpanorama.com
HOSTHUB_ZONE_NAME=trysilpanorama.com
HOSTHUB_ADMIN_PATH=/
```

`deploy_hosthub.sh` generates `--route "${HOSTHUB_PUBLIC_DOMAIN}/*"` from these.
**To move the console to the platform domain when it exists:**
1. Add the `hosthub.com` zone to the Cloudflare account.
2. In `hosthub-prd.env` set `HOSTHUB_PUBLIC_DOMAIN=dashboard.hosthub.com` and
   `HOSTHUB_ZONE_NAME=hosthub.com`.
3. Redeploy. (Optionally keep `admin.trysilpanorama.com` as a redirect.)

No code edits — that is the "prepared" state.

## How to add a new website (target flow)

1. Admin console → create a `sites` row + its CMS content.
2. Add the domain(s) to `site_domains` (mark one `is_primary`).
3. In Cloudflare, point the domain at the `hosthub-sites` worker (route / custom domain).
4. Done — no rebuild, no new worker.

## Config model: per-site vs platform

Everything per consumer is configured in the HostHub console and stored in the DB,
then resolved per request by the shared worker (via `SUPABASE_SECRET_KEY`).
Only genuinely platform-wide values are worker secrets.

| Config | Scope | Set where | Stored |
|---|---|---|---|
| CMS content | per site | console | CMS tables (by `site_id`) |
| Lodgify API key | per consumer | console | `lodgify_api_keys` (by owner) ✓ exists |
| Lodgify property / room id | per site | console | new per-site field(s) — TODO |
| Contact recipient (`CONTACT_EMAIL_TO`) | per site | console | new per-site field — TODO |
| Email sender name + Reply-To | per site | console | new per-site field(s) — TODO |
| Resend API key | platform | worker secret | `make web-secrets` |
| Supabase secret key | platform | worker secret | `make web-secrets` |

Two email types: **HostHub → business users** (invites, magic links) via the
`send_email` Edge Function, HostHub-branded; **consumer-site contact** (visitor →
site owner) with per-site recipient + sender name, one shared platform Resend key,
one verified platform sending domain. The `CONTACT_EMAIL_TO` currently set as a
global worker secret is a temporary fallback until the per-site field exists.

## Implemented — per-site config (backend + web)

Migration `supabase/migrations/20260723120000_add_per_site_config.sql`:
- Adds `contact_email`, `email_from_name`, `lodgify_property_id`,
  `lodgify_room_type_id` to `public.sites` (nullable → env fallback).
- Adds `get_site_lodgify_api_key(site_id)` (SECURITY DEFINER, service_role only):
  a site's key = its owner's key via `sites.owner_profile_id → lodgify_api_keys`.

Web (`hosthub-sites`):
- `lib/supabase/service.ts` — shared service-role client.
- `lib/site-settings.ts` — `getSiteSettings(siteId)`.
- `app/api/contact/route.ts` — per-site recipient + sender name (env fallback);
  hardcoded Trysil `from` removed; sending address via `EMAIL_FROM_ADDRESS`.
- `lib/lodgify/server.ts` — `resolveLodgifyContext()` (per-site key + property/room,
  env fallback); the 4 `app/api/lodgify/*` routes now use it.

## Open items

- **Apply the migration** (`make apply-migrations-local`, then `make apply-migrations ENV=prd`)
  and set each site's values in the console. Until then everything falls back to env.
- **Verify the platform sending domain** in Resend and set `EMAIL_FROM_ADDRESS`
  (e.g. `no-reply@mail.hosthub.com`); today it defaults to `no-reply@trysilpanorama.com`.
- **Console UI (Flutter) — Phase 3.** Screens for the owner to set contact email,
  sender name, Lodgify property/room id per site (the Lodgify *key* console flow
  already exists via `lodgify_api_keys`).
- **Per-site fallback snapshot.** `web/lib/content.ts` / `content.generated.ts` is
  the CMS-downtime fallback (intentional). Today it holds Trysil-specific content,
  so if the CMS is down *every* site would show Trysil. Make the fallback per-site
  (e.g. `content.generated.<site>.ts` selected by `site_id`) so the safety net is
  correct in a multi-site world. Mechanism stays the same.
- **Secret-key naming rollout.** `runtime-site-context.ts` done. Still on the legacy
  primary name: the Edge Functions (`env("SUPABASE_SERVICE_ROLE_KEY", "SUPABASE_SECRET_KEY")`
  — already accept the new name as fallback), `web/scripts/generate-cms-snapshot.mjs`,
  `web/README.md`, `web/.env.example`. Flip these to `SUPABASE_SECRET_KEY`-first when convenient.
- **Blast radius.** One shared worker = one deploy for all sites. Consider a
  per-site override (Model A) only for a customer that demands hard isolation.
