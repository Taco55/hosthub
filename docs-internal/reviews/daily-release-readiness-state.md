# Daily Release-Readiness Review State

State voor de platform-brede daily review volgens
`../review-prompts/release-readiness-review.md`. De CMS-build-loop heeft een
eigen historiek in `cms-website-editor-state.md` (context, geen daily-state).

- last_reviewed_at: 2026-07-28
- last_reviewed_head: e3cf6a3 (`main`); fixes op 48b2f54 + deze commit
- baseline: geen betrouwbare baseline — eerste run met deze prompt; slices 1-2
  gereviewd op committed HEAD
- analyzer_baseline: `hosthub_console` was schoon op e3cf6a3 (`fvm flutter
  analyze`: **0 issues**). De eerder genoteerde "2 pre-existing infos" bestaan
  niet meer — die regel was stale.
- parallelle_sessie: een tweede sessie werkt op 2026-07-28 ongecommit aan een
  `features/messaging`-feature **en** aan een refactor van
  `features/properties/domain` (`account_channel_defaults`, `booking_channel`,
  `channel_settings*`), de l10n-laag (`intl_*.arb`, `messages_*.dart`,
  `l10n.dart`), `app/router` + `app/shell`, `reservations/presentation`,
  `supabase/config.toml` en `supabase/functions/translate-content/index.ts`.
  Daardoor is `fvm flutter analyze` repo-breed **niet** groen (162+ errors, alle
  in hun bestanden) en is `supabase/config.toml` niet beschikbaar voor deze
  loop: partieel stagen kan niet, en de file meenemen zou hun onafgemaakte werk
  committen. Eigen wijzigingen zijn per bestand geanalyseerd (schoon) en met
  gerichte tests gedekt.
- test_baseline: `fvm flutter test` groen (457 tests) op HEAD e3cf6a3
- functions_gate: `deno check` moet **per functie met zijn eigen import map**
  draaien — `deno check */index.ts` vanuit `supabase/functions/` pakt de parent
  `deno.json` (zonder `imports`) en faalt dan onterecht op `delete_user`. Juist:
  `deno check --config supabase/functions/<fn>/deno.json supabase/functions/<fn>/index.ts`
- whole_code_review_policy: continue reviewing committed HEAD slices until all repo-owned code has been covered
- current_whole_code_slice: supabase/functions: auth-links + admin_create_user + delete_user (afgerond, met 1 geblokkeerde P0-cluster)
- next_review_start: **eerst** D-2026-07-28-05 (auth-mail P0-cluster) zodra
  `supabase/config.toml` vrij is; daarna `supabase/functions: lodgify-*`

## Open Findings

| id | priority | status | file | summary | first_seen | last_seen |
|---|---|---|---|---|---|---|
| D-2026-07-28-05 | **P0** | open — geblokkeerd | `supabase/functions/generate_password_reset_link_and_otp/index.ts:71`, `generate_magic_link_and_otp/index.ts`, `generate_sign_up_link_and_otp/index.ts:66`, `send_email/index.ts`, `supabase/config.toml:252-276` | **Account-takeover-cluster.** Alle drie link-generators draaien op de service-role key, accepteren een **caller-gekozen e-mailadres** en geven `action_link` + `email_otp` + `hashed_token` terug aan de client. `verify_jwt = true` op de reset- en magic-link-functie bewijst alleen dat de caller *iemand* is: elke ingelogde gebruiker (ook `viewer`, ook van een ander account) kan een werkende password-reset- of magic-sign-in-link voor **elk** adres op het platform opvragen, inclusief een admin. `generate_sign_up_link_and_otp` staat op `verify_jwt = false` en regelt geen eigen autorisatie, dus daar is zelfs geen account nodig. `send_email` staat óók op `verify_jwt = false` en neemt vrije `to`/`subject`/`html` — een open relay vanaf het verified domein. Zie de fix-richting hieronder | 2026-07-28 | 2026-07-28 |
| D-2026-07-28-06 | P1 | open — geblokkeerd | `supabase/functions/generate_sign_up_link_and_otp/index.ts:66` | `generateLink({type:'signup'})` zonder `password`, terwijl GoTrue die voor signup-links vereist (TS2345 op `deno check`). De functie kan dus geen confirmation-link opleveren en `resendSignUpEmail` is stuk. Een random password meesturen is géén fix: dat zou het wachtwoord van de bestaande gebruiker overschrijven. Hoort bij dezelfde ontwerpbeslissing als D-2026-07-28-05 | 2026-07-28 | 2026-07-28 |
| D-2026-07-28-07 | P2 | open | `supabase/functions/delete_image/index.ts:27,33`, `supabase/config.toml` | `delete_image` werkt op storage-bucket `"images"`, die in deze repo nergens bestaat — alleen `site-media` wordt aangemaakt (`20260727210000_add_site_media_storage.sql`). De functie is overgenomen uit een andere repo en is dood. Verwijderen vereist ook de `[functions.delete_image]`-registratie in het geblokkeerde `config.toml` | 2026-07-28 | 2026-07-28 |
| D-2026-07-28-10 | P2 | open | `supabase/functions/delete_image/deno.json`, `supabase/functions/*/deno.json` | Per-functie `deno.json`'s pinnen uiteenlopende supabase-js-versies (`delete_image`: 2.39.7) terwijl de bijbehorende `index.ts` inline `npm:@supabase/supabase-js@2` importeert — de `imports`-entry is dode config. Eén pin op één plek hoort de bron te zijn | 2026-07-28 | 2026-07-28 |

## Resolved Since Last Review

| id | resolved_at | evidence |
|---|---|---|
| D-2026-07-28-01 | 2026-07-28 | **P0** `public.create_local_admin_user(text,text,text)` was `SECURITY DEFINER` én `GRANT`ed aan `anon` — in `latest_local.sql` **en** `latest_prd.sql`. Iedereen met de (publieke) anon key kon een bevestigde admin-account aanmaken (`auth.users` insert + `profiles.is_admin = true`). Gefixt in `supabase/migrations/20260728140000_lock_down_security_definer_grants.sql` (revoke van `public`, `anon`, `authenticated`, `service_role`; `make create-admin-local` loopt als `postgres`-owner en heeft geen grant nodig). Gepind door `supabase/tests/security_definer_grants_test.sql` (anon-sweep), die vóór de fix faalde op precies deze functie |
| D-2026-07-28-02 | 2026-07-28 | **P0** `public.get_site_lodgify_api_key(uuid)` was `SECURITY DEFINER`, gaf de Lodgify API-key in plaintext terug en was `GRANT`ed aan `anon`/`authenticated` (ook op prd). `site_id` is te lezen uit de publiek leesbare `cms_documents`, dus de key van de site-owner lag één RPC-call ver. Nul callers (`web/lib/lodgify/server.ts:18` en `supabase/functions/_shared/lodgify.ts:6` leggen expliciet vast dat ze de tabellen server-side lezen). Samen met de eveneens dode `get_effective_lodgify_api_key(uuid)` gedropt in dezelfde migratie; gepind door de `lodgify key RPCs: gone`-assertie in de guardrail-test |
| D-2026-07-28-03 | 2026-07-28 | **P0** `public.accept_pending_invitations(p_user_id uuid, p_user_email text)` was `SECURITY DEFINER` + `anon`-grant en nam zijn subject uit de argumenten: elke caller kon een e-mailadres van iemand anders met zijn eigen user-id combineren en zo lid worden van die site met de uitgenodigde rol (tot en met `owner`). Vervangen door een parameterloze versie die `auth.uid()` gebruikt en het geverifieerde adres uit `auth.users` leest; grant alleen aan `authenticated`. Gedragsmatig gepind in de guardrail-test: de outsider krijgt niets, de geadresseerde krijgt zijn membership met de uitgenodigde rol. Call site meegemigreerd (`hosthub_console/lib/features/team/data/site_member_repository.dart:443`) |
| D-2026-07-28-04 | 2026-07-28 | **P1** Silent swallow op twee lagen rond invitation-acceptance: `site_member_repository.dart` had `catch (_) {}` met "silently ignore if function doesn't exist yet" (legacy fallback) en `profile_cubit.dart` had er nóg een `catch (_) {}` omheen. Repository mapt nu via `mapError()` naar een `DomainError` zoals elke andere methode in dat bestand; de cubit houdt de niet-blokkerende intentie maar rapporteert via `addError(error, stack)` |
| D-2026-07-28-08 | 2026-07-28 | **P2** De vijf one-shot helpers uit `20260727150000_cms_stable_row_ids.sql` (`cms_row_id`, `cms_add_ids_to_text_list`, `cms_add_ids_to_object_list`, `cms_add_ids_to_group_list`, `cms_fuse_highlights`, `cms_migrate_document`) bleven permanent in `public` staan zonder enige caller. Gedropt in `20260728150000_drop_cms_migration_helpers.sql`; replay blijft werken omdat 20260727150000 ze zelf aanmaakt en gebruikt |
| D-2026-07-28-11 | 2026-07-28 | **P1** `supabase_onboarding_adapter.dart:159` logde de gegenereerde magic link via `developer.log` — in Flutter web belandt dat in de browserconsole, en een magic link ís een sign-in credential. Log-regel verwijderd (en daarmee de `dart:developer`-import) |
| D-2026-07-28-12 | 2026-07-28 | **P2** `supabase_onboarding_adapter.dart:145` beoordeelde `functions.invoke` op `response.status != 200`, wat categorie 3 van de reviewprompt expliciet verbiedt: een non-2xx komt als exception binnen, dus die tak vuurde nooit en dubbel-mapte de fout alleen maar. Verwijderd; `mapError` in de catch is nu het enige pad. Gedekt door `test/features/auth` (16 tests groen) |
| D-2026-07-28-13 | 2026-07-28 | **P2** `supabase/functions/delete_user/index.ts` bevatte ~130 regels overgenomen cross-repo cleanup: `FILE_REFERENCE_LOOKUPS` op tabellen `file_references`/`items` die hier niet bestaan, met `isMissingRelationError`/`isMissingColumnError`-fallbacks eromheen, plus storage-opruiming in bucket `"images"` die hier niet bestaat. `collectImageKeys` gaf dus altijd `[]` terug en de storage-stap was structureel een no-op. Teruggebracht tot wat er werkelijk gebeurt: de `profiles`-rij en daarna de auth-user. 250 → 118 regels; `deno check --config supabase/functions/delete_user/deno.json` schoon |
| D-2026-07-28-09 | 2026-07-28 | **P2** `supabase/schema_dump/latest_local.sql` was stale: de `cms_*`-helpers ontbraken en de `cms_media`-policies stonden er nog onder hun oude namen ("CMS media is publicly readable" `TO anon`) terwijl `20260727210000_add_site_media_storage.sql` ze had vervangen door "Site editors manage CMS media"/"Site members read CMS media" (`authenticated`-only). Live nagetrokken via `pg_policies` — géén RLS-gat, wél een verificatie-gap voor elke reviewconclusie die op de dump leunt. Opnieuw gegenereerd met `make dump-schema-local` |

### Fix-richting D-2026-07-28-05/06 (auth-mail)

De gemene oorzaak is één ontwerpkeuze: **de credential reist via de client.**
De console vraagt de link op, en stuurt hem daarna met `send_email` naar het
adres. Zolang dat zo is, is er geen autorisatiecheck die helpt — bij
"wachtwoord vergeten" en "confirmation opnieuw sturen" kiest per definitie een
niet-ingelogde bezoeker het adres.

De zuivere vorm is één Edge Function per flow die de link **en** de mail
server-side doet en niets teruggeeft behalve `{ sent: true }`:

- `generateLink` met de service role, template renderen, via Resend versturen;
- response bevat geen `action_link`, `email_otp` of `hashed_token`;
- `verify_jwt = false` mag dan blijven staan: een aanvaller die
  `victim@example.com` invult, mailt alleen de victim — precies wat een
  password-reset hoort te doen;
- `send_email` wordt daarna geen client-endpoint meer en gaat op
  `verify_jwt = true` (of verdwijnt achter de nieuwe functie), waarmee de open
  relay dicht is;
- de client-plumbing in `supabase_onboarding_adapter.dart` (`action_link`/`otp`
  door de app dragen) vervalt volledig.

De mailcopy verhuist daarmee server-side. Dat botst niet met de ARB-regel uit
`AGENTS_CORE.md`: die gaat over user-facing text in widgets, niet over
transactionele mailtemplates. De locale gaat als parameter mee.

Waarom niet in deze loop gefixt: (1) elke variant vraagt wijzigingen in
`supabase/config.toml`, dat een parallelle sessie op dit moment gewijzigd heeft
— partieel stagen kan niet en de file meenemen zou hun onafgemaakte werk
committen; (2) het is een herontwerp van het onboarding-mailpad met een
keuze over waar de templates landen, en zonder Resend-sandbox is aflevering
hier niet te verifiëren. Een half-fix (bv. alleen `verify_jwt` omzetten) breekt
de flows zonder het lek te dichten en is daarom bewust niet gedaan.

## Deferred Deep-Dive Queue

| area | deferred_because | next_lens |
|---|---|---|
| `hosthub_console/lib/features/team` + `profile` | P0/P1 opgelost in slice 1 (invitation-RPC + silent swallows); omliggend gebied verdient een eigen laag | invite-flow end-to-end, `I.isRegistered<...>()`-guards als DI-smell, rol-escalatie via `site_members` |
| `features/messaging` (console) + `supabase/functions/messaging-sync`, `translate-message` + `20260728120000_add_messaging.sql` | wordt op 2026-07-28 door een parallelle sessie geschreven; ongecommit en nog niet compileerbaar | zodra gecommit: RLS op de nieuwe tabellen, per-site scoping, `locked`-contract in `translate-message`, 429-pad |

## Whole-Code Review Queue

| area | status | last_reviewed_at | next_lens |
|---|---|---|---|
| supabase/migrations + policies + schema_dump-consistentie | done | 2026-07-28 | — |
| supabase/functions: auth-links + admin_create_user + delete_user | done (P0-cluster open) | 2026-07-28 | heropenen zodra `config.toml` vrij is: server-side auth-mail per D-2026-07-28-05; `admin_create_user` is nog niet regel-voor-regel gelezen |
| supabase/functions: lodgify-* | todo | — | 429/backoff, idempotente upserts, key-resolutie server-side |
| supabase/functions: translate-content | todo | — | provider-keten, cache/source_hash, locked skip |
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
| supabase/functions: auth-links + admin_create_user + delete_user | 2026-07-28 | `generate_magic_link_and_otp`, `generate_password_reset_link_and_otp`, `generate_sign_up_link_and_otp`, `delete_user`, `send_email`, `delete_image`, `supabase/config.toml` (`verify_jwt` per functie), console-callers `supabase_onboarding_adapter.dart` + `supabase_auth_adapter.dart` + `supabase_email_templates_adapter.dart` | 1× P0-cluster (link-generators geven credentials voor een caller-gekozen adres terug; `send_email` open relay) — **open, geblokkeerd**, met fix-richting vastgelegd. 1× P1 (signup-link kan niet werken) open. 3× gefixt: magic link uit de logs, `response.status`-guardrail, dode cross-repo cleanup in `delete_user`. `admin_create_user` staat nog open voor een eigen leesronde |
| supabase/migrations + policies + schema_dump-consistentie | 2026-07-28 | alle 15 committed migraties, `supabase/policies/*.sql`, `latest_local.sql` + `latest_prd.sql`, `supabase/tests/*.sql`, ACL's van alle 10 `SECURITY DEFINER`-functies | 3× P0 (anon-bereikbare SECURITY DEFINER: admin-creatie, Lodgify-key, invitation-hijack), 1× P1 (silent swallow op de invitation-call), 2× P2 (dode migratiehelpers, stale dump) — alle 6 gefixt en gepind. Schoon: alle 16 `public`-tabellen hebben RLS enabled; `jsonb_array_elements` overal type-geguard; geen `IS DISTINCT FROM`; geen partial unique index en dus geen PostgREST-42P10-risico; baseline-replay wordt correct geskipt via `to_regclass('public.profiles')` |

## Structure And Completeness Passes

| pass | reviewed_at | result | evidence |
|---|---|---|---|
| Feature-modulegrenzen (console) | — | — | — |
| Oversized units | — | — | — |
| RLS-completeness-map | 2026-07-28 | schoon met 2 genoteerde keuzes | Alle 16 tabellen RLS enabled. `lodgify_api_keys` heeft bewust **nul** policies (service-role-only; clients zien hoogstens de last4-hint) — dat is precies de reden dat de plaintext-key-RPC een P0 was. `cms_document_versions` heeft alleen INSERT+SELECT: snapshots zijn append-only, wat een herstelpad garandeert. `sites`/`site_translations` hebben geen anon-SELECT; de sites-renderer leest ze via de service-role client (`web/lib/supabase/service.ts`), te verifiëren in de `web/lib`-slice |
| SECURITY DEFINER grant-resets | 2026-07-28 | 3× P0 gevonden en gefixt | Zie D-2026-07-28-01/02/03. Oorzaak is generiek: Supabase's `ALTER DEFAULT PRIVILEGES ... GRANT ALL ON FUNCTIONS TO anon, authenticated` grant elke nieuwe functie aan anon, en `REVOKE ALL ... FROM PUBLIC` — wat de migraties deden — haalt die rol-grants niet weg. `supabase/tests/security_definer_grants_test.sql` is de blijvende guardrail |
| Client-payload × SQL jsonb-vergelijkingen | 2026-07-28 | n.v.t. — schoon | Nul `IS DISTINCT FROM` in `supabase/migrations` en `supabase/schema_dump`, dus geen phantom-override/clear-oppervlak. Herbeoordelen zodra er een patch/diff-RPC bijkomt |
| Vertaal-completeness-map | — | — | — |
| Multi-site isolatie-pass | — | — | — |
| Secret-flow-pass | — | — | — |
