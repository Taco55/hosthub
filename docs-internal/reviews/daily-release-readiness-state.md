# Daily Release-Readiness Review State

State voor de platform-brede daily review volgens
`../review-prompts/release-readiness-review.md`. De CMS-build-loop heeft een
eigen historiek in `cms-website-editor-state.md` (context, geen daily-state).

- last_reviewed_at: — (nog geen daily review gedraaid met deze prompt)
- last_reviewed_head: —
- baseline: geen betrouwbare baseline — eerste run reviewt de volledige werkboom
- analyzer_baseline: laatst bekend 2 pre-existing infos in `hosthub_console`
  (o.a. `bootstrap.dart` anonKey-deprecation); herverifiëren bij de eerste run
- whole_code_review_policy: continue reviewing committed HEAD slices until all repo-owned code has been covered
- current_whole_code_slice: —
- next_review_start: hoogste-risico slice: supabase/migrations + policies + schema_dump-consistentie

## Open Findings

| id | priority | status | file | summary | first_seen | last_seen |
|---|---|---|---|---|---|---|

## Resolved Since Last Review

| id | resolved_at | evidence |
|---|---|---|

## Deferred Deep-Dive Queue

| area | deferred_because | next_lens |
|---|---|---|

## Whole-Code Review Queue

| area | status | last_reviewed_at | next_lens |
|---|---|---|---|
| supabase/migrations + policies + schema_dump-consistentie | todo | — | RLS-completeness-map, jsonb hygiene, baseline-replay |
| supabase/functions: lodgify-* | todo | — | 429/backoff, idempotente upserts, key-resolutie server-side |
| supabase/functions: translate-content | todo | — | provider-keten, cache/source_hash, locked skip |
| supabase/functions: auth-links + admin_create_user + delete_user | todo | — | service-role discipline, autorisatie, response-contracten |
| supabase/functions: send_email + send_notifications + overige | todo | — | per-site sender/recipient, _shared-gebruik |
| hosthub_console/lib/app + core + shared | todo | — | bootstrap/DI, routing, error-wiring |
| hosthub_console/lib/features/cms + website_editor + sites | todo | — | draft/publish, vertaal-state-machine, brontaal-ontkoppeling |
| hosthub_console/lib/features/properties + portfolio | todo | — | account-scoping, sync-status, scope-gedrag |
| hosthub_console/lib/features/reservations + revenue + channel_manager | todo | — | datums/tijdzones, valuta/aggregaties, filters |
| hosthub_console/lib/features/auth + profile + users + team | todo | — | sessies, invites, permissies |
| hosthub_console/lib/features/server_settings + user_settings | todo | — | defaults vs overrides, settings-persistentie |
| web/app + web/components | todo | — | site-scoping in routes/components, published-only rendering |
| web/lib + web/proxy.ts + web-config (open-next/wrangler) | todo | — | runtime-site-context, module-scope caches, cache-keys |
| cloudflare/src + cloudflare/scripts | todo | — | route-injectie uit env, geen hardcodes |
| scripts (provision_cms_site.mjs, ensure_preview_web.sh) | todo | — | provisioning = data + DNS, idempotentie |
| ../../shared/libraries/styled_widgets | todo | — | cross-repo compat, optionaliteit, lib-tests |

## Whole-Code Review Ledger

| area | reviewed_at | files_or_patterns | result |
|---|---|---|---|

## Structure And Completeness Passes

| pass | reviewed_at | result | evidence |
|---|---|---|---|
| Feature-modulegrenzen (console) | — | — | — |
| Oversized units | — | — | — |
| RLS-completeness-map | — | — | — |
| SECURITY DEFINER grant-resets | — | — | — |
| Client-payload × SQL jsonb-vergelijkingen | — | — | — |
| Vertaal-completeness-map | — | — | — |
| Multi-site isolatie-pass | — | — | — |
| Secret-flow-pass | — | — | — |
