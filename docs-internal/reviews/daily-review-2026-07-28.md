# Daily Review 2026-07-28

## Openstaande Issues

#### [P1 Hoog] Deze wijzigingen moeten in de juiste volgorde naar prd

- Bestand: `supabase/migrations/20260728140000_lock_down_security_definer_grants.sql`,
  `supabase/migrations/20260728150000_drop_cms_migration_helpers.sql`,
  `supabase/functions/send_auth_email/`, `supabase/functions/invite_site_member/`,
  `web/`
- Probleem: `supabase/schema_dump/latest_prd.sql` laat zien dat prd de drie
  anon-bereikbare `SECURITY DEFINER`-functies nog heeft:
  `create_local_admin_user` en `get_site_lodgify_api_key` zijn daar nog aan
  `anon` gegrant, en `accept_pending_invitations` heeft nog de
  `(uuid, text)`-signatuur. Zolang dat zo is kan een anonieme caller met de
  publieke anon key op prd een admin-account aanmaken en de Lodgify-key van de
  site-owner ophalen.
- Impact: de P0's van vandaag zijn in de repo gedicht maar op prd nog open.
- Suggestie: in deze volgorde.
  1. Beide migraties los via `psql` (het bewezen pad; de baseline-replay wordt
     geskipt op `to_regclass('public.profiles')`), daarna
     `NOTIFY pgrst, 'reload schema'` — zonder die stap geeft PostgREST PGRST202
     op de gewijzigde RPC.
  2. `SUPPORT_EMAIL` en `EMAIL_ENV_LABEL` als function-secrets zetten, dan
     `make functions-deploy` — `send_auth_email` is nieuw, `invite_site_member`
     is gewijzigd, en `send_email` + de drie `generate_*`-functies zijn
     verwijderd en horen ook op prd te verdwijnen.
  3. Console deployen: die roept `accept_pending_invitations()` parameterloos
     aan en `send_auth_email` in plaats van de generators, dus de migratie en
     de functions moeten er eerst zijn.
  4. Web deployen, met `CMS_SNAPSHOT_SITE_ID` en `EMAIL_FROM_ADDRESS` gezet
     (zie de bevinding hieronder).
- Ontbrekende test/guardrail: `supabase/tests/security_definer_grants_test.sql`
  hoort ná de prd-apply ook tegen prd te draaien.
- Release-blocking: **ja**
- Bewijs/check: `grep -n "ON FUNCTION public.get_site_lodgify_api_key" supabase/schema_dump/latest_prd.sql`
  geeft nog `TO anon`.

#### [P1 Hoog] Mailaflevering van de nieuwe auth-mails is niet geverifieerd

- Bestand: `supabase/functions/send_auth_email/index.ts`,
  `supabase/functions/invite_site_member/index.ts`
- Probleem: de vijf auth-mails worden nu server-side gerenderd en verstuurd. De
  rendering en de entry-link zijn gepind met 14 Deno-tests (de vier Dart-tests
  van `AuthEntryLinkBuilder` zijn één-op-één geport), maar er is in deze
  omgeving geen Resend-sandbox, dus de aflevering zelf is niet getest.
- Impact: een fout in de Resend-aanroep of in de nieuwe env-variabelen valt pas
  op wanneer een gebruiker geen mail krijgt — en dat raakt inloggen en
  wachtwoord-reset.
- Suggestie: na de deploy één keer per flow versturen en controleren:
  wachtwoord vergeten, magic-link inloggen, sign-up bevestigen, gebruiker
  aanmaken als admin, en een site-uitnodiging (nieuw én bestaand adres).
- Ontbrekende test/guardrail: er is nu een Deno-suite
  (`_shared/auth_email_test.ts`); een end-to-end mailtest hoort in een
  staging-omgeving met een Resend-testkey.
- Release-blocking: **ja** (handmatige verificatie, geen code)
- Bewijs/check: `deno test supabase/functions/_shared/auth_email_test.ts` → 14 groen.

#### [P1 Hoog] `content.ts` is Trysil's site als platform-default

- Bestand: `web/lib/content.ts` (1786 regels),
  `web/lib/content-provider.ts:164-174,286-296`
- Probleem: `mergeSiteConfig` spreidt `...site` onder het CMS-document en
  `getLocalizedContent` spreidt `...localizedContent[locale]` eronder — ook op
  het happy path. Beide komen uit `content.ts`, dat Trysil's content is.
- Impact: een correct geresolveerde klantsite erft Trysil's waarden voor elk veld
  dat hun eigen document niet zet. De fixes van deze run dichten de gevallen
  waarin er géén document is; gedeeltelijke documenten blijven over.
- Suggestie: `content.ts` splitsen in neutrale schema-defaults (lege strings,
  lege lijsten, structuur) en Trysil's seed-content, en alleen de eerste als
  basis spreiden.
- Ontbrekende test/guardrail: een test die een minimaal CMS-document rendert en
  aantoont dat er geen enkele waarde uit `content.ts` in de output zit.
- Release-blocking: nee voor Trysil (het is hun eigen content); **ja** vóór de
  tweede klant live gaat.
- Bewijs/check: `grep -c -i trysil web/lib/content.ts` → 51.

#### [P2 Medium] Deploy-variabelen die de web-deploy nu vereist

- Bestand: `web/.env.example`, `web/wrangler.jsonc`
- Probleem: deze run heeft twee fail-closed checks toegevoegd die elk een
  variabele nodig hebben die nergens geconfigureerd staat.
  `CMS_SNAPSHOT_SITE_ID` bepaalt welke site de gebundelde snapshot mag
  gebruiken; zonder hem valt een onleesbaar CMS terug op een neutrale fout in
  plaats van op de snapshot. `EMAIL_FROM_ADDRESS` heeft geen default meer — de
  oude was `no-reply@trysilpanorama.com`, een klantdomein als platform-afzender.
- Impact: zonder `EMAIL_FROM_ADDRESS` geeft het contactformulier na de volgende
  deploy een 500 met een expliciete logregel. Dat is bewust luidruchtig, maar
  het moet gezet worden.
- Suggestie: beide zetten op de web-deploy. `npm run cms:snapshot` print de
  exacte `CMS_SNAPSHOT_SITE_ID`-regel.
- Ontbrekende test/guardrail: n.v.t.
- Release-blocking: **ja** voor de volgende web-deploy
- Bewijs/check: `grep -rn "EMAIL_FROM_ADDRESS" web/.env.local web/wrangler.jsonc Makefile`
  geeft niets.

#### [P2 Medium] Twee parallelle implementaties van dezelfde datumrange-kalender

- Bestand: `web/components/booking/DateRangeModal.tsx` (793 regels),
  `web/components/booking/DateRangePicker.tsx` (723 regels)
- Probleem: ~930 van de ~1516 regels overlappen. Dat de lint-bevindingen op
  spiegelende regelnummers staan (135/199, 269/260, 486/468, 490/472) laat zien
  hoe strak parallel ze meelopen. `DateRangeModal` wordt door `BookingPage`
  gebruikt, `DateRangePicker` door `BookingWidget` en `availability-picker`.
- Impact: elke fix aan de availability- of selectielogica moet twee keer, en de
  react-hooks-bevindingen hieronder staan daardoor ook dubbel.
- Suggestie: één component met een presentatiekeuze — `DateRangePicker`
  accepteert al `variant="inline"` — of de availability-/selectielogica in één
  hook met twee dunne shells eromheen.
- Ontbrekende test/guardrail: `web/` heeft geen testsuite; de dedup verdient
  dekking op de selectie- en availability-logica vóór de refactor.
- Release-blocking: nee
- Bewijs/check: `diff` genormaliseerd op whitespace geeft 586 verschillende
  regels op 1516 totaal.

#### [P2 Medium] React-hooks-bevindingen in de booking-flow

- Bestand: `web/lib/booking/useBookingState.ts:203,249`,
  `web/components/booking/BookingWidget.tsx:70,116`,
  `web/components/booking/DateRangeModal.tsx:135,486`,
  `web/components/booking/DateRangePicker.tsx:199,468`,
  `web/components/header.tsx:38`, `web/components/booking/BookingPage.tsx:151`
- Probleem: 9× `react-hooks/set-state-in-effect` en 15×
  `react-hooks/preserve-manual-memoization`, plus één `exhaustive-deps` waarin
  `guests` en `range` ontbreken. Het tweede is het zwaarste: de React Compiler
  kan die `useMemo`/`useCallback` niet behouden, dus de memoisatie doet
  stilletjes niets terwijl de code suggereert van wel.
- Impact: cascading renders en niet-werkende memoisatie in de flow waarin
  availability en prijsopgave opgevraagd worden — de weg naar de boeking.
- Suggestie: eerst de dedup hierboven, dan de effects één keer herschrijven in
  de gedeelde component in plaats van twee keer in de kopieën.
- Ontbrekende test/guardrail: dekking op de booking-flow vóór de refactor; dit
  is de live flow van Trysil en er is geen testsuite in `web/`.
- Release-blocking: nee
- Bewijs/check: `npm run lint` in `web/` (nu leesbaar: 24 errors in plaats van
  678, zie de state-file).

#### [P2 Medium] `delete_image` werkt op een bucket die niet bestaat

- Bestand: `supabase/functions/delete_image/index.ts:27,33`
- Probleem: de functie verwijdert uit storage-bucket `"images"`. Deze repo
  creëert die bucket nergens — alleen `site-media`, in
  `20260727210000_add_site_media_storage.sql`. De functie is overgenomen uit een
  andere repo.
- Impact: een deploy-target en een aanvalsoppervlak zonder enige werking; de
  aanroep slaagt of faalt stil op een niet-bestaande bucket.
- Suggestie: functie en `[functions.delete_image]`-registratie verwijderen.
  `supabase/config.toml` is op dit moment door een parallelle sessie gewijzigd,
  dus dit kon in deze run niet gecommit worden.
- Ontbrekende test/guardrail: n.v.t.
- Release-blocking: nee
- Bewijs/check: `grep -rn "site-media\|'images'" supabase/migrations supabase/policies`
  geeft alleen `site-media`.

#### [P2 Medium] Uiteenlopende supabase-js-pins in per-functie `deno.json`'s

- Bestand: `supabase/functions/delete_image/deno.json:7`,
  `supabase/functions/*/deno.json`
- Probleem: `delete_image/deno.json` pint `npm:@supabase/supabase-js@2.39.7`,
  terwijl `delete_image/index.ts` inline `npm:@supabase/supabase-js@2`
  importeert — de `imports`-entry is dode config die een andere versie
  suggereert dan er gebruikt wordt. 15 van de 16 functies importeren inline;
  alleen `delete_user` gebruikt de bare specifier echt.
- Impact: onderhoudsverwarring en het risico dat een gate of een deploy een
  andere versie oplost dan de review gelezen heeft.
- Suggestie: één pin op één plek — of overal de inline specifier, of één import
  map in `supabase/functions/deno.json`. Vereist ook opruiming van de
  `import_map`-regels in het nu geblokkeerde `config.toml`.
- Ontbrekende test/guardrail: n.v.t.
- Release-blocking: nee
- Bewijs/check: `grep -rn "supabase-js" supabase/functions/`

## Niet beoordeeld in deze run

Alleen genoemd omdat het geen dekking claimt: `supabase/functions/lodgify-*`,
`translate-content`, `send_notifications`, `admin_create_user` regel-voor-regel,
de console-features (`cms`/`website_editor`/`sites`, `properties`/`portfolio`,
`reservations`/`revenue`/`channel_manager`, `server_settings`/`user_settings`),
`web/lib` multi-site isolatie, `cloudflare/`, `scripts/` en
`../../shared/libraries/styled_widgets`. De queue in
`daily-release-readiness-state.md` houdt bij wat waar staat.

Een parallelle sessie werkt ongecommit aan een `features/messaging`-feature en
aan een refactor van `features/properties/domain`, de l10n-laag, `app/router`,
`app/shell`, `reservations/presentation`, `supabase/config.toml` en
`supabase/functions/translate-content/index.ts`. Daardoor is `fvm flutter
analyze` repo-breed niet groen — alle 162 errors staan in hun bestanden — en was
`config.toml` in deze run niet beschikbaar.
