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
- current_whole_code_slice: web/app + web/components + web/lib (lint-gate en
  quick wins gedaan; de react-hooks-cluster staat open)
- web_gate: `npm run lint` was onleesbaar — 651 van de 678 errors kwamen uit
  `.open-next/` (Cloudflare build output), naast 15517 warnings. Nu genegeerd,
  waardoor de gate 24 echte errors laat zien. `npm run typecheck` en
  `npm run build` zijn schoon.
- next_review_start: **eerst** D-2026-07-28-05 (auth-mail P0-cluster) zodra
  `supabase/config.toml` vrij is; daarna D-2026-07-28-14 (react-hooks in de
  booking-flow, na de dedup) en `supabase/functions: lodgify-*`

## Open Findings

| id | priority | status | file | summary | first_seen | last_seen |
|---|---|---|---|---|---|---|
| D-2026-07-28-05 | **P0** | open — geblokkeerd | `supabase/functions/generate_password_reset_link_and_otp/index.ts:71`, `generate_magic_link_and_otp/index.ts`, `generate_sign_up_link_and_otp/index.ts:66`, `send_email/index.ts`, `supabase/config.toml:252-276` | **Account-takeover-cluster.** Alle drie link-generators draaien op de service-role key, accepteren een **caller-gekozen e-mailadres** en geven `action_link` + `email_otp` + `hashed_token` terug aan de client. `verify_jwt = true` op de reset- en magic-link-functie bewijst alleen dat de caller *iemand* is: elke ingelogde gebruiker (ook `viewer`, ook van een ander account) kan een werkende password-reset- of magic-sign-in-link voor **elk** adres op het platform opvragen, inclusief een admin. `generate_sign_up_link_and_otp` staat op `verify_jwt = false` en regelt geen eigen autorisatie, dus daar is zelfs geen account nodig. `send_email` staat óók op `verify_jwt = false` en neemt vrije `to`/`subject`/`html` — een open relay vanaf het verified domein. Zie de fix-richting hieronder | 2026-07-28 | 2026-07-28 |
| D-2026-07-28-06 | P1 | open — geblokkeerd | `supabase/functions/generate_sign_up_link_and_otp/index.ts:66` | `generateLink({type:'signup'})` zonder `password`, terwijl GoTrue die voor signup-links vereist (TS2345 op `deno check`). De functie kan dus geen confirmation-link opleveren en `resendSignUpEmail` is stuk. Een random password meesturen is géén fix: dat zou het wachtwoord van de bestaande gebruiker overschrijven. Hoort bij dezelfde ontwerpbeslissing als D-2026-07-28-05 | 2026-07-28 | 2026-07-28 |
| D-2026-07-28-07 | P2 | open | `supabase/functions/delete_image/index.ts:27,33`, `supabase/config.toml` | `delete_image` werkt op storage-bucket `"images"`, die in deze repo nergens bestaat — alleen `site-media` wordt aangemaakt (`20260727210000_add_site_media_storage.sql`). De functie is overgenomen uit een andere repo en is dood. Verwijderen vereist ook de `[functions.delete_image]`-registratie in het geblokkeerde `config.toml` | 2026-07-28 | 2026-07-28 |
| D-2026-07-28-23 | **P1** | open | `web/lib/content.ts` (1786 regels), `web/lib/content-provider.ts:164-174,286-296` | `content.ts` is Trysil's site vermomd als platform-default: `mergeSiteConfig` spreidt `...site` eronder en `getLocalizedContent` spreidt `...localizedContent[locale]` eronder, **ook op het happy path**. Een correct geresolveerde klantsite erft daardoor Trysil's waarden voor elk veld dat hun eigen CMS-document niet zet. D-2026-07-28-20/21 dichten de gevallen waarin er géén document is; dit blijft over voor gedeeltelijke documenten. Fix: `content.ts` splitsen in neutrale schema-defaults (lege strings, lege lijsten, structuur) en Trysil's seed-content, en alleen de eerste als basis spreiden. Niet in deze run gedaan: dat is een aparte pass over 1786 regels met een eigen verificatie | 2026-07-28 | 2026-07-28 |
| D-2026-07-28-24 | P2 | open | lokale `public.site_domains` | De lokale rij is `localhost:43001` — mét poort — terwijl `normalizeDomain` de poort strípt en dus op `localhost` matcht. Die rij kan per definitie nooit matchen. Dat viel niet op omdat de oude fallback het stil opving; nu zou het een 404 zijn. `.env.local` wijst overigens naar de rémote Supabase, waar `localhost` wél een rij heeft — daarom werkt lokaal draaien alsnog. Rij rechttrekken naar `localhost` (zonder poort) in elke omgeving die 'm heeft; `.env.example` vermeldt de eis nu expliciet | 2026-07-28 | 2026-07-28 |
| D-2026-07-28-14 | P2 | open | `web/lib/booking/useBookingState.ts:203,249`, `web/components/booking/BookingWidget.tsx:70,116`, `DateRangeModal.tsx:135,486`, `DateRangePicker.tsx:199,468`, `components/header.tsx:38` | 9× `react-hooks/set-state-in-effect` en 15× `react-hooks/preserve-manual-memoization` in de booking-flow. Het tweede is het zwaarste: de React Compiler kan die `useMemo`/`useCallback` niet behouden, dus de memoisatie doet stilletjes niets. Fix-volgorde: **eerst** D-2026-07-28-15 (dedup), dan de effects één keer in de gedeelde component herschrijven. Niet blind gefixt: `web/` heeft geen testsuite en dit is de live boekingsflow van Trysil; dit vraagt handmatige of geautomatiseerde flowdekking vóór de refactor | 2026-07-28 | 2026-07-28 |
| D-2026-07-28-15 | P2 | open | `web/components/booking/DateRangeModal.tsx` (793 regels), `web/components/booking/DateRangePicker.tsx` (723 regels) | Twee parallelle implementaties van dezelfde datumrange-kalender: ~930 van de ~1516 regels overlappen, en de lint-bevindingen staan op spiegelende regelnummers (135/199, 269/260, 486/468, …). `DateRangeModal` wordt door `BookingPage` gebruikt, `DateRangePicker` door `BookingWidget` + `availability-picker`. Eén component met een `variant`-achtige presentatiekeuze — `DateRangePicker` accepteert al `variant="inline"` — of een gedeelde hook voor de availability-/selectielogica met twee dunne shells | 2026-07-28 | 2026-07-28 |
| D-2026-07-28-16 | P2 | open | `web/components/booking/BookingPage.tsx:151` | `useMemo` mist `guests` en `range` in de dependency array (`react-hooks/exhaustive-deps`), in dezelfde memoisatie-cluster als D-2026-07-28-14 | 2026-07-28 | 2026-07-28 |
| D-2026-07-28-10 | P2 | open | `supabase/functions/delete_image/deno.json`, `supabase/functions/*/deno.json` | Per-functie `deno.json`'s pinnen uiteenlopende supabase-js-versies (`delete_image`: 2.39.7) terwijl de bijbehorende `index.ts` inline `npm:@supabase/supabase-js@2` importeert — de `imports`-entry is dode config. Eén pin op één plek hoort de bron te zijn | 2026-07-28 | 2026-07-28 |

## Resolved Since Last Review

| id | resolved_at | evidence |
|---|---|---|
| D-2026-07-28-01 | 2026-07-28 | **P0** `public.create_local_admin_user(text,text,text)` was `SECURITY DEFINER` én `GRANT`ed aan `anon` — in `latest_local.sql` **en** `latest_prd.sql`. Iedereen met de (publieke) anon key kon een bevestigde admin-account aanmaken (`auth.users` insert + `profiles.is_admin = true`). Gefixt in `supabase/migrations/20260728140000_lock_down_security_definer_grants.sql` (revoke van `public`, `anon`, `authenticated`, `service_role`; `make create-admin-local` loopt als `postgres`-owner en heeft geen grant nodig). Gepind door `supabase/tests/security_definer_grants_test.sql` (anon-sweep), die vóór de fix faalde op precies deze functie |
| D-2026-07-28-02 | 2026-07-28 | **P0** `public.get_site_lodgify_api_key(uuid)` was `SECURITY DEFINER`, gaf de Lodgify API-key in plaintext terug en was `GRANT`ed aan `anon`/`authenticated` (ook op prd). `site_id` is te lezen uit de publiek leesbare `cms_documents`, dus de key van de site-owner lag één RPC-call ver. Nul callers (`web/lib/lodgify/server.ts:18` en `supabase/functions/_shared/lodgify.ts:6` leggen expliciet vast dat ze de tabellen server-side lezen). Samen met de eveneens dode `get_effective_lodgify_api_key(uuid)` gedropt in dezelfde migratie; gepind door de `lodgify key RPCs: gone`-assertie in de guardrail-test |
| D-2026-07-28-03 | 2026-07-28 | **P0** `public.accept_pending_invitations(p_user_id uuid, p_user_email text)` was `SECURITY DEFINER` + `anon`-grant en nam zijn subject uit de argumenten: elke caller kon een e-mailadres van iemand anders met zijn eigen user-id combineren en zo lid worden van die site met de uitgenodigde rol (tot en met `owner`). Vervangen door een parameterloze versie die `auth.uid()` gebruikt en het geverifieerde adres uit `auth.users` leest; grant alleen aan `authenticated`. Gedragsmatig gepind in de guardrail-test: de outsider krijgt niets, de geadresseerde krijgt zijn membership met de uitgenodigde rol. Call site meegemigreerd (`hosthub_console/lib/features/team/data/site_member_repository.dart:443`) |
| D-2026-07-28-04 | 2026-07-28 | **P1** Silent swallow op twee lagen rond invitation-acceptance: `site_member_repository.dart` had `catch (_) {}` met "silently ignore if function doesn't exist yet" (legacy fallback) en `profile_cubit.dart` had er nóg een `catch (_) {}` omheen. Repository mapt nu via `mapError()` naar een `DomainError` zoals elke andere methode in dat bestand; de cubit houdt de niet-blokkerende intentie maar rapporteert via `addError(error, stack)` |
| D-2026-07-28-08 | 2026-07-28 | **P2** De vijf one-shot helpers uit `20260727150000_cms_stable_row_ids.sql` (`cms_row_id`, `cms_add_ids_to_text_list`, `cms_add_ids_to_object_list`, `cms_add_ids_to_group_list`, `cms_fuse_highlights`, `cms_migrate_document`) bleven permanent in `public` staan zonder enige caller. Gedropt in `20260728150000_drop_cms_migration_helpers.sql`; replay blijft werken omdat 20260727150000 ze zelf aanmaakt en gebruikt |
| D-2026-07-28-20 | 2026-07-28 | **P0** Cross-site content-leak in de shared worker. `toSiteContentOptions` gaf `{}` terug wanneer de host niet naar een site resolveerde, waarna elke content-getter doorviel naar `content.generated.ts` / `content.ts` — en dat zijn **Trysil's** bestanden (~1780 regels, 50+ keer "Trysil" in elk). Gevolg: elk domein dat op de worker staat maar niet in `site_domains` resolveert, én elk echt klantdomein tijdens een Supabase-hik, rendeerde Trysil's pagina's, prijzen en contactgegevens onder de eigen naam. Er stond geen enkele guard: de `notFound()`-aanroepen in de pages gaan over een ongeldige **locale**, niet over een onbekende site. Fix: `findSiteIdByDomain` onderscheidt nu `match` / `no_match` / `failed`, `RuntimeSiteContextSource` idem (`domain_lookup` / `unknown_domain` / `lookup_failed`), en `toSiteContentOptions` faalt gesloten — `notFound()` bij een onbekend domein, `SiteLookupFailedError` bij een mislukte lookup (bewust géén 404: dat zou crawlers vertellen dat een levende klantsite weg is omdat Supabase even hikte). Eén choke point dekt alle 14 content-consumers. Geverifieerd tegen de draaiende dev-server: onbekende host → **404** (was 200 met Trysil-content), ook via `x-forwarded-host` (de header die de CF-worker zet); geresolveerde host → **200** en content rendert |
| D-2026-07-28-21 | 2026-07-28 | **P0** Zelfde leak in de snapshot-laag, ook voor een site die wél resolveert: de worker draagt één snapshot en die hoort bij één site, dus site B's mislukte document-read viel door naar A's snapshot. De snapshot-site staat al in de generator (`metadata.siteId`) maar alleen als header-comment. Nu een expliciete runtime-check: `CMS_SNAPSHOT_SITE_ID` moet gelijk zijn aan de geresolveerde site, anders `SiteContentUnavailableError` in plaats van andermans content. **Unset = snapshot wordt nooit gebruikt** (fail closed). `npm run cms:snapshot` print nu de exacte regel om te zetten, en `.env.example` documenteert hem. Geverifieerd: met de var op `d2744793-…` (precies de site in de snapshot-header) rendert `/nl` weer 200; zonder de var faalt dezelfde read gesloten |
| D-2026-07-28-22 | 2026-07-28 | **P0** `web/app/api/contact/route.ts` stuurde bij een onresolveerde host alsnog mail: `getSiteSettings(null)` → `null` → recipient viel terug op de platformbrede `CONTACT_EMAIL_TO`, met `from` hardcoded op `"no-reply@trysilpanorama.com"` — één klantdomein als platform-afzender voor élke site. Een enquiry op klantdomein B belandde zo in de verkeerde inbox, verzonden vanaf een ander klantmerk. Nu: geen site → `404 {"error":"Unknown site"}` met een logregel, en de Trysil-default is weg (`EMAIL_FROM_ADDRESS` zonder default; ontbreekt hij, dan 500 met een duidelijke logregel in plaats van stil verkeerd verzenden). Geverifieerd met een geldige payload: onbekende host → 404, geresolveerde host → 500 "Missing sender address" zolang de var niet gezet is |
| D-2026-07-28-17 | 2026-07-28 | **P2** `npm run lint` was als gate waardeloos: `web/eslint.config.mjs` negeerde `.next`, `out` en `build`, maar niet `.open-next/` (de Cloudflare worker-bundle) of `.wrangler/`. Van de 678 errors kwamen er 651 uit die build output, met 15517 warnings eromheen. Beide toegevoegd aan `globalIgnores`; de gate rapporteert nu 24 echte errors (alle D-2026-07-28-14/16) in plaats van 678 |
| D-2026-07-28-18 | 2026-07-28 | **P2** `web/components/booking/GuestsModal.tsx` is een `role="dialog"` popover die `onOpenChange` kreeg en nooit aanriep. De outside-click-dismissal bestond al in de caller (`BookingPage.tsx:172-187`, gescoped op de wrapper-ref) — de prop was dus dood, niet de dismissal. Prop verwijderd uit de component-API én de call site, en de ontbrekende helft toegevoegd waar de dismissal al woont: **Escape** sluit de popover nu ook. Eerste poging stond in het kind met een capture-phase pointerdown; dat is teruggedraaid omdat het met de toggle van de trigger zou vechten en 'm meteen weer zou openen |
| D-2026-07-28-19 | 2026-07-28 | **P2** Kleinere `web/`-opruiming, alle drie via de nu leesbare lint-gate gevonden: `lib/amenities/amenityRegistry.ts:30` gebruikte `React.ComponentType<any>` waar `LucideIcon` het echte type is (en de `React`-import viel daarmee weg); `components/site/Parallax.tsx:80` hield `viewportHeight` bij dat nergens gelezen werd, inclusief de reassignment in `handleResize`; de `catch (error)`-blokken in `DateRangeModal`/`DateRangePicker` zetten wel een error-state maar gooiden de fout weg — nu gelogd, zodat een 429 van Lodgify te onderscheiden is van een kapotte response. De `require()`-regel is uitgezet voor `scripts/**/*.js` (dit package heeft geen `"type": "module"`, dus die files *zijn* CommonJS; ESM-scripts gebruiken `.mjs`) en `no-unused-vars` respecteert nu het `_`-prefix, zodat een seam als `getMinNightsForArrival(_date)` niet hoeft te kiezen tussen een warning en het weggooien van een argument dat twee callers meegeven. Geverifieerd met `npm run typecheck` en een volledige `npm run build` (alle routes, inclusief `/book`) |
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
| web/app + web/components | partial | 2026-07-28 | lint-gate + booking-component opruiming gedaan; **nog niet gereviewd**: site-scoping in routes/components, published-only rendering, de react-hooks-cluster |
| web/lib + web/proxy.ts + web-config (open-next/wrangler) | done (1 P1 open) | 2026-07-28 | resterend: D-2026-07-28-23 (`content.ts` als platform-default). Nog niet gereviewd: cache-headers/ISR-keys per host, `open-next.config`/`wrangler.jsonc` |
| cloudflare/src + cloudflare/scripts | todo | — | route-injectie uit env, geen hardcodes |
| scripts (provision_cms_site.mjs, ensure_preview_web.sh) | todo | — | provisioning = data + DNS, idempotentie |
| ../../shared/libraries/styled_widgets | todo | — | cross-repo compat, optionaliteit, lib-tests |

## Whole-Code Review Ledger

| area | reviewed_at | files_or_patterns | result |
|---|---|---|---|
| web (gate + booking-componenten) | 2026-07-28 | `web/eslint.config.mjs`, `components/booking/{BookingPage,BookingWidget,GuestsModal,DateRangeModal,DateRangePicker}.tsx`, `components/header.tsx`, `components/site/Parallax.tsx`, `lib/amenities/amenityRegistry.ts`, `lib/booking/{config,useBookingState}.ts`, `scripts/*.js` | Lint-gate hersteld (678 → 24 echte errors) en 3× P2 gefixt. Open: de react-hooks-cluster (D-2026-07-28-14/16) en de DateRangeModal/DateRangePicker-duplicatie (D-2026-07-28-15). Nog niet gedaan in deze slice: de multi-site isolatie-pass over `web/lib` — dat is de hoogste-risico rest van `web/` |
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
| Multi-site isolatie-pass | 2026-07-28 | 3× P0 gevonden en gefixt, 1× P1 open | Module-scope state: alleen `web/lib/supabase/service.ts:11` (`let cached`), en dat is een service-role client zonder site-state — veilig om te hergebruiken. **Schoon**: elke content-read loopt via `fetchDocument(siteId, …)` en `siteId` komt uitsluitend uit de host → `site_domains`-keten; er is geen env-default site meer. **Niet schoon**: de fallback-keten (D-2026-07-28-20/21) en de contact-route (D-2026-07-28-22), alle drie gefixt; `content.ts` als platform-default blijft open (D-2026-07-28-23). Per-site e-mail: recipient komt uit `sites.contact_email` via `getSiteSettings`, sender-adres nu uit env zonder klant-hardcode. Nog te doen: cache-headers/ISR-keys op host of `site_id` |
| Secret-flow-pass | — | — | — |
