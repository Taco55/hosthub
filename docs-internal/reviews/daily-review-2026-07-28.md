# Daily Review 2026-07-28

## Openstaande Issues

#### [P0 Kritiek] Elke ingelogde gebruiker kan een sign-in credential voor elk account opvragen

- Bestand: `supabase/functions/generate_password_reset_link_and_otp/index.ts:71`,
  `supabase/functions/generate_magic_link_and_otp/index.ts`,
  `supabase/functions/generate_sign_up_link_and_otp/index.ts:66`,
  `supabase/config.toml:260-276`
- Probleem: alle drie de link-generators draaien op de service-role key,
  accepteren een **caller-gekozen e-mailadres** en geven `action_link`,
  `email_otp` en `hashed_token` terug in de response. Er is geen enkele check
  dat de caller iets met dat adres te maken heeft. `verify_jwt = true` op de
  reset- en magic-link-functie bewijst alleen dat de caller *iemand* is, niet
  dat het adres van hem is. `generate_sign_up_link_and_otp` staat op
  `verify_jwt = false` en regelt geen eigen autorisatie, dus daar is helemaal
  geen account nodig.
- Impact: account-takeover. Een `viewer` op één site — of een gebruiker van een
  heel ander account — vraagt een reset- of magic-link op voor het adres van een
  admin en logt in als die admin. Voor de sign-up-variant is de anon key genoeg.
  Prd heeft echte klantdata (Trysil).
- Suggestie: de credential mag de client niet bereiken. Eén Edge Function per
  flow die de link genereert **en** de mail verstuurt, met
  `{ sent: true }` als enige response. Dan is een caller die
  `victim@example.com` invult niets meer dan iemand die de victim een
  password-reset mailt — precies het bedoelde gedrag. De volledige
  fix-richting, inclusief waarom de mailtemplates dan server-side landen en
  waarom dat niet met de ARB-regel botst, staat in
  `daily-release-readiness-state.md` onder "Fix-richting D-2026-07-28-05/06".
- Ontbrekende test/guardrail: een test die aantoont dat geen enkele
  auth-mail-functie een `action_link`, `email_otp` of `hashed_token` in zijn
  response zet.
- Release-blocking: **ja**
- Bewijs/check: de drie `index.ts`-bestanden nemen `payload.email` ongefilterd
  door naar `client.auth.admin.generateLink(...)` en serialiseren
  `data.properties` terug; `supabase/config.toml` toont de `verify_jwt`-waarden.

#### [P0 Kritiek] `send_email` is een open relay vanaf het verified domein

- Bestand: `supabase/functions/send_email/index.ts:28-32`, `supabase/config.toml:252-258`
- Probleem: de functie staat op `verify_jwt = false` en accepteert vrije `to`,
  `subject`, `html` en `attachments`, die één op één naar Resend gaan. De
  afzender is het geconfigureerde `FROM_EMAIL` van het platform.
- Impact: iedereen kan willekeurige mail met willekeurige HTML versturen die
  afkomstig lijkt van het HostHub-domein. Phishing met een echte, geldige
  afzender, en domeinreputatie-schade die de bezorging van alle transactionele
  mail raakt.
- Suggestie: `send_email` hoort geen client-endpoint te zijn. Zodra de
  auth-mails server-side verstuurd worden (zie de vorige bevinding) heeft de
  console geen ongeauthenticeerd mailpad meer nodig en kan deze functie achter
  `verify_jwt = true` of volledig achter de nieuwe functie verdwijnen.
- Ontbrekende test/guardrail: geen; de gate is de `verify_jwt`-instelling zelf.
- Release-blocking: **ja**
- Bewijs/check: `EmailPayload` in `send_email/index.ts` is `{to, subject, html,
  attachments}` zonder enige autorisatie- of recipient-validatie; de comment bij
  `[functions.send_email]` in `config.toml` noemt expliciet dat JWT-verificatie
  uit staat omdat sign-up-mails vóór de sessie verstuurd worden.

#### [P1 Hoog] De sign-up confirmation link kan niet gegenereerd worden

- Bestand: `supabase/functions/generate_sign_up_link_and_otp/index.ts:66`
- Probleem: `generateLink({ type: "signup", email, options })` mist het
  `password`-veld dat GoTrue voor signup-links vereist. `deno check` faalt hier
  met TS2345.
- Impact: `resendSignUpEmail` en de confirmation-mail direct na `signUp()`
  leveren geen link op — de gebruiker kan zijn account niet bevestigen.
- Suggestie: hoort bij dezelfde ontwerpbeslissing als de P0-cluster hierboven.
  Een willekeurig wachtwoord meesturen is géén oplossing: dat overschrijft het
  wachtwoord dat de gebruiker net bij `signUp()` heeft gekozen.
- Ontbrekende test/guardrail: `deno check` per functie met de eigen import map
  hoort in de gate te zitten —
  `deno check --config supabase/functions/<fn>/deno.json supabase/functions/<fn>/index.ts`.
  `deno check */index.ts` vanuit `supabase/functions/` pakt de parent
  `deno.json` en faalt daardoor ook onterecht op `delete_user`.
- Release-blocking: nee (de flow is nu al stuk, dus geen regressie)
- Bewijs/check: `deno check --config supabase/functions/generate_sign_up_link_and_otp/deno.json …`

#### [P1 Hoog] Migraties 20260728140000 en 20260728150000 moeten naar prd

- Bestand: `supabase/migrations/20260728140000_lock_down_security_definer_grants.sql`,
  `supabase/migrations/20260728150000_drop_cms_migration_helpers.sql`
- Probleem: de drie anon-bereikbare `SECURITY DEFINER`-functies zijn deze run
  lokaal gedicht, maar `supabase/schema_dump/latest_prd.sql` laat zien dat prd
  ze nog heeft: `create_local_admin_user` en `get_site_lodgify_api_key` zijn
  daar nog aan `anon` gegrant, en `accept_pending_invitations` heeft daar nog de
  `(uuid, text)`-signatuur.
- Impact: zolang de migratie niet op prd staat, blijft daar het volgende open:
  een anonieme caller kan met de publieke anon key een admin-account aanmaken,
  en kan de Lodgify API-key van de site-owner ophalen via een `site_id` uit de
  publiek leesbare `cms_documents`.
- Suggestie: beide migraties los toepassen via `psql` (het bewezen pad; de
  baseline-replay wordt geskipt op `to_regclass('public.profiles')`), in deze
  volgorde, **vóór** de console-deploy — `accept_pending_invitations` wijzigt
  van signatuur en de nieuwe console-code roept de parameterloze versie aan.
  Daarna `NOTIFY pgrst, 'reload schema'`, anders geeft PostgREST PGRST202 op de
  gewijzigde RPC.
- Ontbrekende test/guardrail: `supabase/tests/security_definer_grants_test.sql`
  bestaat nu; die hoort ná de prd-apply ook tegen prd te draaien.
- Release-blocking: **ja**
- Bewijs/check: `grep -n "ON FUNCTION public.get_site_lodgify_api_key" supabase/schema_dump/latest_prd.sql`
  geeft nog `TO anon`.

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
