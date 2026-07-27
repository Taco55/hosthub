# Release Readiness Review Prompt

Voer een grondige release-gereedheidsreview uit van de HostHub workspace
(`hosthub_workspace`).

Dit is de canonieke prompt voor de enige standaard dagelijkse release-quality
review. Gebruik hem ook wanneer de gebruiker expliciet om een release gate,
release-readiness, production-readiness of brede kwaliteit/security review
vraagt. Draai geen aparte dagelijkse PR-review of design-conformance review
naast deze workflow; de CMS-website-editor-rubric
(`docs-internal/review-prompts/cms-website-editor-review.md`) is een
specialistische lens voor de build-loop en handmatige conformance-reviews, geen
tweede daily.

Voor de dagelijkse automation geldt: de volledige workspace blijft in scope —
`hosthub_console` (Flutter web console), `web` (Next.js sites-renderer),
`cloudflare` (admin-router worker), `supabase` (functions/migraties/policies),
`scripts`, en de gedeelde libraries buiten de repo voor zover de diff ze raakt.
Multi-site isolatie, de vertaalpipeline, CMS-draft/publish, Supabase/RLS,
secrets-hygiëne, design-conformance, tests en releasekwaliteit worden in deze
ene review meegenomen.

Deze prompt moet bruikbaar zijn voor Claude, Codex en andere code-review
agents. Volg de agentinstructies in deze repo (`AGENTS.md` + `AGENTS_CORE.md`;
`CLAUDE.md` moet inhoudelijk gelijk zijn aan `AGENTS.md`) als bron van
waarheid. Maak geen codewijzigingen, behalve het schrijven van het
reviewrapport en het bijwerken van de daily release-readiness state-file. Als
deze prompt strijdig lijkt met `AGENTS.md`/`AGENTS_CORE.md`, volg die en noteer
het conflict in het rapport.

Houd commando's tool-neutraal: gebruik wat in jouw omgeving werkt (`rg` of
`grep`/`find`, `cat` of `Read`-tool, etc.). De voorbeelden hieronder met `rg`
zijn richtlijnen, geen vereisten.

## Verplichte preflight

Voer deze preflight altijd uit vóór Fase 1 en vóór inhoudelijke
reviewwerkzaamheden. Als een check faalt: stop direct, rapporteer kort welke
check faalde en voer geen gedeeltelijke review uit. Plak geen reviewrapport in
de thread als vervanging voor een bestand dat niet naar disk geschreven kan
worden.

Controleer in elke omgeving dat `docs-internal/reviews/` bestaat of kan worden
aangemaakt en schrijfbaar is:

```bash
mkdir -p docs-internal/reviews
test -w docs-internal/reviews
```

Als deze review in een Codex automation draait, controleer daarnaast de Codex
automation-memory. Gebruik de concrete automation-id uit de actieve automation:

```bash
test -n "${CODEX_HOME:-}"
mkdir -p "$CODEX_HOME/automations/<automation-id>"
test -w "$CODEX_HOME/automations/<automation-id>"
```

`CODEX_HOME` is Codex-specifiek. Wanneer deze prompt in Claude of handmatig
wordt uitgevoerd en er geen Codex automation-memory van toepassing is, mag
ontbrekende `CODEX_HOME` de review niet blokkeren. Noteer dan in het rapport:
`Automation-memory: niet van toepassing voor deze omgeving`. Als de gebruikte
omgeving wél een eigen memory- of state-pad voorschrijft, controleer dat pad op
schrijfbaarheid voordat je verdergaat.

## Reviewmodus en scope

- **Daily release-quality review**: wanneer dit document door de standaard
  dagelijkse automation wordt gebruikt, review de volledige workspace als
  release-quality gate. Maak geen tweede daily-reviewrapport voor
  specialistische prompts; neem relevante PR-review, design-conformance,
  vertaalpipeline- en multi-site-bevindingen hier op.
- **Release-readiness / production-readiness review**: wanneer de gebruiker
  expliciet deze prompt draait, review dan de volledige release-gereedheid,
  met extra aandacht voor wijzigingen sinds de vorige review en de
  multi-site/vertaal/CMS-criteria hieronder. Op `main` is remote schema-drift
  (prd loopt achter op lokale migraties) geen dagelijkse bevinding, P1 of
  release-blocker op zichzelf; behandel dit alleen als context tenzij de
  gebruiker expliciet om een release/deploy-gate vraagt.
- **Release review**: review als release gate. Focus extra op migraties,
  RLS/security, API-contracten, de vertaal-/publish-pipeline, multi-site
  routing en isolatie, secrets, error handling, teststatus en deploy/rollback
  risico's. Benoem dan expliciet welke migraties nog naar prd moeten en in
  welke volgorde t.o.v. de console-/worker-deploys.
- **Scoped review**: als de gebruiker een branch, PR, feature, map of diff
  noemt, review die scope grondig en controleer alleen de direct aangrenzende
  contracts die nodig zijn om productie-impact te beoordelen. Deze repo werkt
  direct op `main` (geen feature branches) — vergelijk diffs t.o.v. de vorige
  review-baseline of een expliciet genoemde commit, niet t.o.v. een
  develop-branch.
- **Architecture-deep review**: gebruik deze modus wanneer de vraag *"is dit
  pre-user fundament structureel goed?"* is — niet *"wat kan in productie
  kapot?"*. Deze modus schakelt vier defaults om die normaal de daily review
  structureel beperken en die anders dezelfde klasse architectuur-bevindingen
  blijft missen, hoeveel scans je ook toevoegt:

  | Default | Daily / release | Architecture-deep |
  |---|---|---|
  | Compat-prior (preserve bestaande contracten) | aan | **uit** — pre-user (Trysil is de eerste en enige klant), breaking changes zijn de bedoeling |
  | Hedging-opening (*"codebase is volwassen, hieronder enkele aandachtspunten"*) | toegestaan | **verboden** — geen opening-frame dat finding-severities dempt |
  | Lens | present-risk (bugs, security, crash, data-corruption) | **future-maintenance** (coupling, laaggrenzen, module-shape, API-hygiëne, oversized units, multi-tenant schaalbaarheid) |
  | Completeness-bar | diff + Fase 4-scans volstaan | **Fase 5b verplicht** (structuur-/completeness-passes, diff-onafhankelijk) |

  Diff-first uit Fase 3 is in deze modus ondergeschikt: de structurele passes
  lopen onafhankelijk van wat in de diff staat. Een arch-deep review die alleen
  diff + scans rapporteert is incompleet, ook als alle scans schoon zijn.

  Hedge-verbod is concreet: geen openingszinnen als *"de codebase is
  volwassen"*, *"sterk fundament met enkele aandachtspunten"*, *"de zwakke
  plekken zitten niet in X"*. Die a-priori-uitsluitingen sluiten hele
  categorieën uit voordat er ook maar één pass is gedraaid.

  Triggers voor deze modus: gebruiker vraagt expliciet om een "diepe",
  "gigantische", "architectuur"- of "structuur"-review; vraagt om "major
  breaking changes nu vs later"; vraagt om "zuivere API / onderhoudbaarheid /
  toekomstige uitbreidingen"; noemt expliciet "geen gebruikers" of "pre-user"
  als reden om breed te kunnen migreren. Bij twijfel: stel de modus uit aan de
  gebruiker voordat je begint, in plaats van impliciet daily te draaien.
- Claim geen volledige dekking als je niet alle relevante bestanden of checks
  hebt bekeken. Vermeld expliciet welke scope is bekeken en welke checks niet
  zijn uitgevoerd.

## Reviewstrategie en diepgang

Deze review is bedoeld om grote én kleine fouten te vinden. Voer hem daarom
fase-gebaseerd uit; een lineaire "lees wat bestanden"-review is onvoldoende.

### Fase 1. Baseline en scope vastleggen

Leg vóór de inhoudelijke review vast:

- huidige datum en lokale tijd;
- branchnaam en `HEAD` (verwacht: `main`);
- pad naar het vorige relevante reviewrapport;
- baseline commit of tag waarmee je vergelijkt;
- dirty worktree-status, inclusief staged, unstaged en untracked files —
  let op: er kunnen parallelle sessies in deze repo werken; schrijf ongecommit
  werk van een andere sessie niet toe aan de beoordeelde wijziging, maar
  beoordeel het wel;
- welke gebieden geraakt zijn: `hosthub_console`, `web`, `cloudflare`,
  `supabase`, `scripts`, en/of gedeelde libraries buiten de repo
  (`../../shared/libraries/<package>`, m.n. `styled_widgets`).

Gebruik waar mogelijk:

```bash
git branch --show-current
git rev-parse HEAD
git log -1 --oneline
git status --short
git diff --stat <baseline>...HEAD
git diff --stat
git diff --cached --stat
```

Als er geen betrouwbare baseline is, review dan de volledige werkboom en noteer
`Baseline: geen betrouwbare baseline`.

Voor gedeelde libraries buiten de repo: als de diff of de beoordeelde feature
op een lib-wijziging leunt, leg dan ook de `HEAD`/tag van die library vast
(aparte git repo) en neem de lib-wijziging in scope.

### Fase 2. Automated gates

Draai eerst harde checks. Gebruik de repo-commandos waar mogelijk en rapporteer
elke ontbrekende check met reden. Alle paden vanaf de workspace-root.

```bash
fvm flutter --version          # pin staat in .fvmrc
git diff --check
(cd hosthub_console && fvm flutter analyze)
(cd hosthub_console && fvm flutter test)
(cd web && npm run lint)
(cd web && npm run typecheck)
(cd supabase/functions && deno check */index.ts)
```

- Analyzer-baseline: vergelijk met de bekende pre-existing issues die in de
  state-file staan genoteerd. Nieuwe issues zijn bevindingen; de baseline zelf
  niet opnieuw rapporteren.
- Raakt de diff een gedeelde library (`../../shared/libraries/styled_widgets`
  of een andere), draai dan ook daar `flutter analyze lib test` en
  `flutter test` met de toolchain van die repo, en beoordeel de wijziging op
  cross-repo-compatibiliteit (zie categorie 7).
- `npm run build` (web) is optioneel en zwaar; draai hem bij release-lens of
  wanneer de diff `web/` substantieel raakt. `npm run build:cf`,
  `npm run deploy`, `make deploy`, `make functions-deploy` en
  `wrangler`-deploys zijn deploy-commando's en horen **niet** in een review.

Als volledige checks te lang duren of lokaal blokkeren, draai de zwaarst
geraakte scopes gericht en vermeld de niet-uitgevoerde volledige gate als
resterend risico. Een review mag niet "groen" lijken wanneer gates ontbreken.

Wanneer je als aanvullende gate lokale Supabase migratiechecks draait, gebruik
de Makefile-route (lokale stack; API-poort staat in `supabase/config.toml`):

```bash
make preflight-local-db
make apply-migrations-local
```

Gebruik plain `supabase migration list` niet als lokale check: die route
gebruikt de linked/remote login-role flow en kan blokkeren op
remote-credentials. Rapporteer zo'n fout als remote/link-configuratie, niet als
lokale migratieblokkade. Als de lokale Supabase stack niet draait, rapporteer
de gate expliciet als niet uitgevoerd met reden; laat het rapport niet
production-ready lijken alsof deze runtime coverage groen was.

Er is geen Deno-testsuite en geen `functions-test` target; `deno check` is de
enige deterministische functions-gate. Noteer dat als bekende gap wanneer een
gewijzigde Edge Function logica bevat die een test verdient (zie categorie 10).

### Fase 3. Diff-first deep review

Review elke gewijzigde file en elke gewijzigde functie/klasse grondig. Lees ook
de directe callers, interfaces, tests en serialisatie-/repository-contracten
rond de wijziging. Beoordeel niet alleen de diffregel, maar ook het gedrag dat
de wijziging raakt.

Diff-first bepaalt de volgorde, niet de totale scope. Voor release-readiness
reviews blijft de volledige workspace in scope: review ook publieke APIs,
gedeelde models, repositories, de console↔Edge-Function↔SQL-contracten, de
worker↔`site_domains`↔CMS-content keten en UI-laaggrenzen die niet direct in de
diff staan maar door de wijziging geraakt kunnen worden.

Voor untracked files geldt dezelfde standaard als voor gewijzigde files: lezen,
beoordelen en opnemen in scope.

### Fase 4. Repo-brede guardrail scans

Draai repo-brede scans voor bekende risicopatronen, ook als ze buiten de diff
vallen. Een daily review mag daardoor regressies detecteren die niet direct in
de diff zichtbaar zijn.

Minimaal:

```bash
# Legacy/deprecated/compat-signalen
rg -n "@Deprecated|deprecated_member_use|compat|compatibility|legacy|fallback|backfill-only|TODO\(remove\)|remove after" hosthub_console/lib web/app web/components web/lib cloudflare/src supabase --glob "!**/*.g.dart" --glob "!**/node_modules/**"

# Verboden UI-patronen in de console
rg -n "ScaffoldMessenger|SnackBar|showDialog\(|AlertDialog\(|Navigator\.pop\(context\)" hosthub_console/lib --glob "*.dart"

# Theme/S-aliases en raw kleuren
rg -n "final \w+ = (Theme|S)\.of\(context\)" hosthub_console/lib --glob "*.dart"
rg -n "Color\(0x" hosthub_console/lib --glob "*.dart"

# Secret-lekkage richting client-code (console-bundle en browser-bundle)
rg -n "SUPABASE_SECRET|SECRET_KEY|SERVICE_ROLE|service_role|API_TOKEN" hosthub_console/lib web/app web/components web/lib --glob "!**/node_modules/**"
rg -n "NEXT_PUBLIC_[A-Z_]*(KEY|TOKEN|SECRET|PASSWORD)" web --glob "!**/node_modules/**"
rg -in "lodgify" hosthub_console/lib web/app web/components web/lib --glob "!**/node_modules/**"

# SQL footguns
rg -n "jsonb_array_elements|IS DISTINCT FROM|CREATE UNIQUE INDEX.*WHERE" supabase/migrations supabase/schema_dump --glob "*.sql"
rg -n "onConflict" supabase/functions hosthub_console/lib --glob "!**/node_modules/**"
```

Bij de Lodgify-scan: hits in de console horen alleen sync-triggers,
status/last4-hints en instellingen-UI te zijn — nooit de API-key zelf richting
client-state of de sites-renderer. Vul deze scans aan met domeinspecifieke
zoekpatronen wanneer de diff daar aanleiding toe geeft.

### Fase 5. Domeinpasses

Voer daarna gerichte passes uit per risicodomein:

- Supabase: migraties/RLS/policies/RPC's/Edge Functions.
- Vertaalpipeline en taalmodel (auto-unless-locked, brontaal-ontkoppeling).
- CMS-documentlifecycle (expliciet opslaan, draft vs published, preview,
  publish).
- Multi-site platform: `site_domains`-routing, per-site isolatie, workers,
  provisioning, DNS/apex.
- Lodgify/channel-integratie: rate limits, key-opslag, sync-correctheid.
- Reserverings-, omzet- en portfolio-logica in de console: datums/tijdzones,
  valuta en aggregaties (sommen per periode/property), filter- en
  scope-gedrag (account vs portfolio vs property), lege-periode vs
  loading-states.
- Repositories/services/API-contracten/error mapping (console).
- State management/UI laaggrenzen/error presentation (console).
- StyledWidgets/theming/localization + gedeelde-lib discipline.
- Secrets en env-layout.
- Tests, guardrails, coverage-risico en regression gaps.
- Legacy/deprecated/dead code en onderhoudbaarheid.

Voor elke pass: rapporteer alleen concrete bevindingen met bestand en
regelnummer, maar noteer ook wanneer de pass niet volledig is uitgevoerd.

### Fase 5b. Structuur- en completeness-passes

Verplicht in **architecture-deep**-modus, optioneel-maar-aanbevolen in
daily/release. Deze passes vinden bewust **niet** wat in de diff staat — ze
meten de codebase als architectuur, onafhankelijk van recente wijzigingen. Daar
zit de categorie bevindingen die diff-first + regex-scans systematisch missen
(cross-layer redeneer-ketens, completeness-gaten in RLS- en
vertaal-registraties, module-scope state in workers). Een arch-deep review die
deze passes overslaat is incompleet, ook als alle Fase 4-scans schoon staan.

Elke pass produceert óf een concrete bevinding met bestand/regelnummer óf een
expliciete "schoon"-regel ("alle publieke tabellen hebben RLS + policies",
"worker cachet niets site-overstijgends"). Stilzwijgend weglaten = review-fout.

#### Feature-modulegrenzen (console)

`hosthub_console/lib` is een single-package app met `app/`, `core/`,
`features/<feature>/` en `shared/`.

- Flag cross-feature imports (`features/x` importeert `features/y`); gedeelde
  logica hoort in `shared/` of `core/`, of de feature-grens klopt niet.
- Flag features die de Supabase-client of storage direct aanspreken buiten hun
  repository-laag.

```bash
for f in hosthub_console/lib/features/*/; do
  name=$(basename "$f")
  rg -l "features/$name/" hosthub_console/lib/features --glob "!**/$name/**" | sed "s/^/import van $name uit: /"
done
```

#### Oversized units

- Flag bestanden >800 regels en methoden >100 regels als P2
  (merge-conflict-epicentrum, moeilijk te testen); widget-files >1500 regels
  altijd.

```bash
find hosthub_console/lib web/app web/components web/lib cloudflare/src supabase/functions -name "*.dart" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" | grep -v node_modules | xargs wc -l | sort -nr | head -20
```

#### RLS-completeness-map

Bouw uit `supabase/schema_dump/latest_local.sql` een tabel
`tabel × RLS enabled × policies (select/insert/update/delete) × scoping-basis`
voor **elke** tabel in `public`. **Elke lege cel is een bevinding** (of een
expliciet gedocumenteerde service-role-only keuze met rationale).

- Scoping-basis is per tabel expliciet: site-scoped (via site-membership,
  bv. een `has_site_access`-achtige helper), account-scoped (bv. `properties`),
  of user-scoped (bv. `user_settings`, `profiles`).
- `lodgify_api_keys` (en elke andere credential-tabel) verdient een eigen
  regel: keys zijn server-side; clients mogen hoogstens een hint (last4) lezen,
  nooit de key zelf — ook niet via een view of RPC-omweg.
- Vergelijk `supabase/policies/*.sql` met wat er werkelijk in de dump staat;
  een policy-bestand dat niet (meer) overeenkomt met de dump is een bevinding.

```bash
rg -n "^CREATE TABLE public\." supabase/schema_dump/latest_local.sql
rg -n "ENABLE ROW LEVEL SECURITY|CREATE POLICY" supabase/schema_dump/latest_local.sql
```

#### SECURITY DEFINER grant-resets (DROP+CREATE)

`CREATE OR REPLACE FUNCTION` kan de RETURNS/parameter-signatuur niet wijzigen,
dus signatuurwijzigingen vragen `DROP FUNCTION` + `CREATE`. Een `DROP+CREATE`
**reset de ACL van de functie**, en Supabase default privileges re-`GRANT`en de
verse functie aan `anon` — waarmee een `SECURITY DEFINER` RPC stilletjes
aanroepbaar wordt voor niet-ingelogde clients (datalek). Elke migratie die zo'n
functie dropt+hercreëert moet opnieuw `REVOKE ALL ... FROM PUBLIC` **en**
`FROM anon` doen, en daarna alleen `authenticated`/`service_role` granten.
Verifieer dat geen enkele SECURITY DEFINER-functie aan `anon`/`PUBLIC` is
gegrant, tenzij dat bewust en gedocumenteerd is (bv. een publiek leesbare
site-content-RPC voor de sites-renderer — dan hoort de functie zelf zijn
scope te bewaken).

```bash
rg -n "SECURITY DEFINER" supabase/schema_dump/latest_local.sql supabase/migrations
rg -n "GRANT (ALL|EXECUTE) ON FUNCTION .* TO (anon|PUBLIC)" supabase/schema_dump/latest_local.sql
rg -n "^DROP FUNCTION" supabase/migrations/*.sql
```

#### Cross-layer redeneer-keten: client-payload × SQL jsonb-vergelijkingen

1. Lijst elke SQL-functie/expressie met `payload->'key' IS DISTINCT FROM
   <column>` (of `=`) waarbij `payload` jsonb is en `column` SQL-typed.
2. Identificeer welke client de payload produceert (console-model met
   `@JsonSerializable`, Edge Function, of worker).
3. Verifieer **beide**: de client stuurt nullable velden bewust
   (`includeIfNull: false` of expliciet strippen) **én** SQL normaliseert met
   `NULLIF(value,'null'::jsonb)`.

Eén kant zuiver is onvoldoende — anders ontstaan phantom-overrides of
phantom-clears. Dit geldt in HostHub met name voor jsonb-dragende kolommen
zoals CMS-content, vertaal-payloads en `user_settings`-scopes.

```bash
rg -n "IS DISTINCT FROM" supabase/migrations supabase/schema_dump --glob "*.sql"
rg -nU "@JsonSerializable\(" hosthub_console/lib --glob "*.dart" -A3 | rg -B1 -v "includeIfNull: false"
```

#### Vertaal-completeness-map

Maak een tabel `veld × taal × status × source_hash` voor de vertaalde
CMS-content: elk vertaalbaar veld heeft per doeltaal een status
(`auto`/`locked`/`stale`) en een `source_hash`; de brontaal zelf heeft er geen.

- **Elke lege cel is een bevinding**: een veld dat wel gerenderd wordt maar
  niet in de vertaalregistratie zit, drijft stilletjes uit sync.
- Verifieer de state machine op code- en SQL-niveau: source-edit markeert
  afhankelijke `auto`-velden `stale`; publish hervertaalt alleen `auto`;
  `locked` wordt **nooit** door de pipeline overschreven (dit is het
  belangrijkste data-integriteitscontract van de CMS).
- Verifieer de hash-keten client=server: dezelfde bron moet dezelfde
  `source_hash` opleveren, anders wordt cache/stale-detectie onbetrouwbaar.

#### Multi-site isolatie-pass (sites-renderer + workers)

- De worker draait als één gedeelde instantie voor alle klantdomeinen.
  Module-scope state (caches, memoized clients, globals in `web/lib` of
  `cloudflare/src`) wordt tussen requests — en dus tussen **sites** —
  hergebruikt. Flag elke module-level cache die niet per `site_id`/host
  gekeyed is.
- Elke content-, config- en secret-resolutie loopt via de host →
  `site_domains` → `site_id` keten (`web/lib/runtime-site-context.ts`); flag
  elke route/component die site-data zonder die keten ophaalt.
- De fallback-keten (env-default site → statische snapshot) mag nooit content
  van klant A op het domein van klant B tonen; beoordeel de volgorde en de
  no-match-tak expliciet.
- Cache-headers/ISR/edge-caching: cache-keys moeten host of `site_id`
  bevatten.
- Per-site e-mail (contact/notificaties): recipient en sender komen per site
  uit de DB, niet platform-breed hardcoded.

#### Secret-flow-pass

Bouw de map `secret × bron-envfile × waar gelezen × waar het terecht mag
komen` voor alle secrets in `Makefile` (`FUNCTION_SECRET_VARS`,
`WEB_SECRET_KEYS`) en `web/.env.local`-conventies:

- Platform-brede secrets horen alleen in Edge Functions of de worker-runtime
  (Cloudflare secrets), nooit in de console-bundle of client-side Next.js
  code (`NEXT_PUBLIC_*`).
- Per-consumer secrets (Lodgify) horen in de DB (server-side tabel), worden
  per site geresolved en staan bewust **niet** in `WEB_SECRET_KEYS` — flag
  elke poging ze platform-breed te maken.
- Dart-defines/`String.fromEnvironment` in de console: alleen publieke config
  (URLs, anon key); alles wat "secret"/"service"/"token" heet is een bevinding.

#### Architecture-deep modus output-eis

Leg per-pass resultaat vast als concrete bevinding of "schoon"-regel. Voor
daily issue-only rapporten hoort die pass-status in de state-file, niet in het
rapport, tenzij de pass een openstaand issue oplevert. Voor expliciete
architecture-deep rapporten met uitgebreide output: lever in het rapport een
aparte sectie **"Structuur- en completeness-status"** met per-pass resultaat.
Diff-first vondsten staan elders. Overlapping is geen probleem; weglaten van
een pass wel.

### Fase 6. Findings triage

Elke bevinding moet fix-klaar zijn:

- severity `P0-P3`;
- exact bestand en regelnummer;
- impact op gebruiker, data, security, multi-site isolatie, vertaalintegriteit,
  onderhoudbaarheid of release;
- concrete structurele fix;
- ontbrekende of aan te passen test;
- release-blocking: ja/nee.

### Fase 7. Fix-verificatie

Wanneer deze review na een fixronde opnieuw draait, verifieer dan expliciet:

- of eerdere bevindingen werkelijk zijn opgelost;
- of de fix geen legacy/deprecated fallback introduceert;
- of regressietests/guardrails zijn toegevoegd;
- welke checks opnieuw zijn gedraaid.

## Voorbereiding

Lees eerst:

- `AGENTS.md` en `AGENTS_CORE.md` (`CLAUDE.md` moet inhoudelijk gelijk zijn aan
  `AGENTS.md`)
- `.fvmrc`
- `Makefile` en `supabase/make/supabase-common.mk` (welke targets bestaan echt)
- `docs/multi-site-platform.md` en `docs/preview_and_routing.md`
- `hosthub_console/CMS_PLAN.md` waar de CMS geraakt wordt
- de design-handoffs in `../hosthub-design/` wanneer UI beoordeeld wordt
  (`design_handoff_hosthub_cms*/README.md`, `CONFORMANCE.md`,
  `TRANSLATION.md`, `STYLED_WIDGETS_MAPPING.md`) — die map wordt tussendoor
  ververst; herlees bij designvragen in plaats van op geheugen te varen

Lees daarnaast de relevante skills voordat je bijbehorende categorieën
beoordeelt (merk-neutraal, kies de single-package kolom):

- Feature/data-flow/repository/state: `tk-feature`
- Dart static analysis/analyzer/lints: `tk-dart-analysis`
- Supabase/migraties/RLS/Edge Functions/secrets/deploys: `tk-supabase`
- StyledWidgets/component-keuze/modals: `tk-styledwidgets`
- Theming/kleuren/typografie: `tk-styling`
- Localization/ARB/l10n: `tk-localization`
- Componentgids van de lib zelf:
  `../../shared/libraries/styled_widgets/.claude/skills/styled-widgets-guide/SKILL.md`
  (actueler dan elke kopie)

Werk systematisch. Rapporteer alleen concrete risico's, bugs, inconsistenties,
onderhoudsproblemen of ontbrekende validatie/tests. Onderbouw elke bevinding
met bestandspad en regelnummer. Vermijd vage opmerkingen zonder aantoonbare
impact.

Gebruik lokale datum voor rapportnamen. Vermijd destructieve commando's en
deploy-commando's tijdens de review.

## Reviewcategorieen

### 1. Migraties, schema en policies

- Review alle SQL in `supabase/migrations/`.
- Markeer destructieve operaties: `DROP`, column rename/drop, type changes,
  constraint changes, backfills en RLS/policy-wijzigingen.
- **Vergelijk de schema_dump-bestanden** (`latest_local.sql`,
  `latest_prd.sql`) op aanwezigheid van nieuwe of hernoemde
  tabel-/kolom-namen, maar koppel de conclusie aan de reviewmodus:
  - Bij daily-lens reviews op `main`: meld niet dat prd N migraties
    achterloopt als bevinding, P1, release-blocker of prioriteit. De developer
    bepaalt zelf wanneer migraties naar prd gaan.
  - Een stale `latest_local.sql` is in daily reviews hoogstens een
    verificatie-gap wanneer reviewconclusies expliciet op de dump leunen; het
    is geen release-blocker op zichzelf.
  - Bij release reviews of expliciete deploy-reviews: behandel prd wel als
    deploy-gate wanneer console-code, Edge Functions of de sites-renderer
    schema verwacht dat daar nog niet bestaat. Benoem dan de migratievolgorde
    vóór de bijbehorende deploys.
  - Controleer in alle modi of Dart/TS-code in de beoordeelde wijziging al
    tegen nieuwe of hernoemde schema-namen praat. Rapporteer dat alleen als
    runtime-compatibiliteitsrisico voor environments waarop de wijziging
    daadwerkelijk uitgerold gaat worden.

  Quick check:

  ```bash
  rg -c '<nieuwe_tabel_naam>' supabase/schema_dump/latest_*.sql
  rg -c '<oude_tabel_naam>'   supabase/schema_dump/latest_*.sql
  ```
- Controleer idempotentie:
  - `CREATE TABLE/INDEX IF NOT EXISTS`
  - `DROP POLICY/TRIGGER IF EXISTS` voor recreate
  - `ADD COLUMN IF NOT EXISTS`
  - constraints via `DO $$ ... duplicate_object ... $$`
  - `CREATE OR REPLACE FUNCTION/VIEW` waar passend
- Identificeer migraties die lang kunnen locken op grote tabellen.
- **Baseline-replay-risico**: `20260218000000_remote_baseline.sql` is de
  remote-baseline. De apply-targets horen de baseline te skippen wanneer het
  schema al bestaat; verifieer dat gedrag vóór je een remote apply aanbeveelt,
  en beveel anders het bewezen pad aan: de losse nieuwe migratie(s) via `psql`
  toepassen. Neem in release-reviews op welke individuele migraties nog naar
  prd moeten.
- **PGRST202 / PostgREST schema-cache**: elke DDL op prd (nieuwe
  kolom/functie/RPC) vereist `NOTIFY pgrst, 'reload schema'` (of een
  API-herstart) vóór de API de wijziging ziet. Een migratie- of deploy-advies
  zonder die stap is een bevinding bij release-lens.
- Controleer of `supabase/policies/*.sql` (o.a. admin-access en
  storage-policies) logisch overeenkomen met migraties en dump; policies die
  alleen in dat mapje bestaan maar nooit zijn toegepast (of andersom) zijn een
  bevinding.
- Er is geen `supabase/seed/`; introduceert een wijziging seed-afhankelijkheid,
  dan hoort daar een expliciete plek en een idempotent script bij.
- Controleer bij release reviews of een rollback- of herstelpad nodig is voor
  destructieve/data-mutating migraties — prd heeft echte klantdata (Trysil).
- Verwacht **geen** hand-edits in `supabase/schema_dump/`; dat is een
  gegenereerd artefact (`make dump-schema-local` / `make dump-schema`).

#### jsonb hygiene

Twee terugkerende SQL footguns die elke nieuwe/aangepaste migratie of
SQL-functie moet doorstaan. Beide kunnen latent zijn (functie werkt op clean
data, klapt zodra echte payloads binnenkomen) — controleer daarom proactief op
de patronen, niet alleen op gerapporteerde fouten.

- **Ongegarde `jsonb_array_elements` / `jsonb_array_elements_text`.** Elke
  call moet beschermd zijn met `jsonb_typeof(x) = 'array'` of geroutet via een
  helper. Een rauwe `ARRAY(SELECT jsonb_array_elements_text(x))` klapt met
  SQLSTATE `22023` zodra `x` jsonb-null of een scalar is. Relevant voor alle
  jsonb-content in HostHub (CMS-documenten, vertaal-payloads, scopes). Check:

  ```bash
  rg -n "jsonb_array_elements" supabase/migrations supabase/schema_dump --glob "*.sql"
  ```

  Markeer als bevinding tenzij de call type-geguard is of via een helper loopt.

- **jsonb-null vs SQL-NULL asymmetrie in diff/override-logica.**
  `'null'::jsonb IS DISTINCT FROM NULL` is **TRUE** in Postgres. Elke
  vergelijking `payload->'key' IS DISTINCT FROM column` waarbij `payload`
  jsonb is en `column` SQL-typed synthetiseert phantom-overrides zodra de
  client `"key": null` meestuurt. Veilige patronen:

  - `NULLIF(payload->'key', 'null'::jsonb) IS DISTINCT FROM column`
  - `jsonb_strip_nulls(payload)` aan de poort, mits `"key": null` daar geen
    "clear"-signaal hoort te zijn
  - expliciete custom normalisatie per veld

  Check op patch/override-RPC's:

  ```bash
  rg -n "IS DISTINCT FROM" supabase/migrations supabase/schema_dump --glob "*.sql"
  ```

- **Client `toJson` contract voor diff/patch-RPC's.** `@JsonSerializable`
  zonder `includeIfNull: false` serialiseert nullable velden als
  `"key": null`. Niet per se fout, **wel** fout zodra zo'n payload landt in
  een RPC die jsonb-null-vs-SQL-NULL doet. Controleer bij elke nieuwe
  payload-builder of nullable velden bewust worden meegestuurd of expliciet
  worden gestript, en houd beide kanten (client én SQL) zuiver.

#### Partial unique indexes en PostgREST `onConflict`

Een latente footgun die alleen op werkelijke Postgres-data zichtbaar wordt en
die unit-tests met gemockte Supabase-clients niet vangen.

- **PostgREST kan geen `index_predicate` doorgeven.** `upsert(...,
  onConflict: "col1,col2")` genereert `INSERT ... ON CONFLICT (col1, col2) DO
  UPDATE` zonder `WHERE`-clausule. PostgreSQL weigert een **partial** unique
  index als arbiter te inferren wanneer de `index_predicate` ontbreekt;
  resultaat is SQLSTATE `42P10`.
- **Check elke migratie die een partial unique index introduceert of dropt**,
  parallel met de upsert-callsites (Edge Functions én console):

  ```bash
  rg -n "CREATE UNIQUE INDEX.*WHERE" supabase/migrations supabase/schema_dump --glob "*.sql"
  rg -n "onConflict" supabase/functions hosthub_console/lib
  ```

  Voor elke `onConflict`-tuple die alleen overeenkomt met een partial unique
  index: markeer als **HOOG** tenzij er live-DB-bewijs is dat de upsert
  slaagt. Dit raakt in HostHub met name de Lodgify-sync-upserts
  (properties/rates/reservations) en vertaal-cache-upserts.
- **Veilige patronen:** expliciet `select → update-of-insert`; non-partial
  unique constraint (eventueel op een generated column); of geen partial
  unique voor PostgREST-geüpserte tabellen.
- **Tests:** een test met een gemockte client bewijst dit niet. Vereis live
  verificatie tegen de lokale stack of documenteer de handmatige check.

### 2. Edge Functions en API-contracten

- Review alle functions in `supabase/functions/` (auth-linkgeneratie,
  `lodgify-properties`/`lodgify-rates`/`lodgify-reservations`,
  `translate-content`, `send_email`, `send_notifications`,
  `invite_site_member`, `admin_create_user`, `delete_user`, `delete_image`,
  `get_client_app_settings`, `jsonize`).
- Controleer request-validatie, response-shape, HTTP-statussen en consistente
  error responses.
- Controleer of gedeelde helpers uit `supabase/functions/_shared` consequent
  worden gebruikt (auth, CORS, error-shape, Supabase-clients).
- Controleer of console-repositories dezelfde contracts verwachten.
- Controleer `verify_jwt`-keuzes in `supabase/config.toml` per functie: een
  functie zonder JWT-verificatie moet zijn eigen autorisatie aantoonbaar
  regelen.
- Controleer of service-role clients alleen worden gebruikt voor operations
  die echt elevated access nodig hebben; user-scoped operations moeten RLS
  respecteren. Admin-operaties (user-creatie, deletes) horen hun
  admin-autorisatie expliciet te checken, niet impliciet via "de functie is
  toch privé".
- **Lodgify-functies**: afhandeling van HTTP 429/rate limits moet expliciet
  zijn (backoff/retry of nette fout richting UI, geen half-geschreven
  sync-state). Upserts idempotent; `lodgify_synced_at`-achtige
  status-timestamps alleen zetten bij werkelijk succes. De API-key wordt
  server-side geresolved (per owner/site uit de DB); de key of afgeleide
  geheimen mogen nooit in een response naar de client lekken — hoogstens een
  last4-hint.
- **translate-content**: provider-keten (keyless default, self-hosted optie,
  betaalde provider als opt-in) mag bij ontbrekende keys niet crashen maar
  degradeert netjes; cache op `source_hash`; `locked` velden worden
  overgeslagen; kosten worden begrensd (alleen enabled locales, één request
  per taal waar mogelijk).
- **E-mailfuncties**: afzender/ontvanger per site uit de DB waar het om
  site-mail gaat; platform-brede defaults alleen voor platform-mail.

### 3. Repository/service API's en error mapping (console)

- Review repository-interfaces en implementaties in
  `hosthub_console/lib` (per feature en in `core`/`shared`).
- Method signatures moeten voorspelbaar, typed, DRY en toekomstvast zijn.
- Supabase/Edge Function calls moeten fouten mappen via `mapError()` naar
  `DomainError`.
- `functions.invoke()` mag niet via `response.status` worden beoordeeld;
  non-2xx gooit een exception die via de mapping loopt.
- Edge Function error context moet de functienaam bevatten.
- Repository error handling als single `catch (error, stack)` met `mapError()`
  — geen meervoudige type-specifieke catches en geen silent swallow.
- PostgREST-foutcodes verdienen bewuste mapping waar de UI erop stuurt;
  behandel een `PGRST202` (functie/kolom onbekend na DDL) als
  server/deploy-probleem, niet als gebruikersfout.

### 4. Vertaalpipeline en taalmodel

Het belangrijkste HostHub-datacontract: per (veld, taal) een status
`auto`/`locked` met `source_hash`; source-edits markeren afhankelijke
`auto`-velden `stale`; publish hervertaalt `auto` en laat `locked` staan.

- **`locked` is heilig**: geen enkel code-pad (publish, preview-refresh,
  "reset", bulk-acties, sync) mag een `locked` veld overschrijven behalve de
  expliciete gebruikersactie daarvoor ("Reset to AI" / handmatige edit).
- **Brontaal-ontkoppeling**: de brontaal van de content staat los van de
  interfacetaal van de console. Een interfacetaal-switch mag de brontaal
  nooit wijzigen. Er bestaat bewust geen follow-toggle of follow-kolom; de
  enige koppeling is een eenmalige overneem-actie met bevestigingsdialoog.
  Elke nieuwe "handige" koppeling tussen die twee is een bevinding.
- Statusovergangen kloppen in beide richtingen: edit in doeltaal → `locked`;
  source-edit → dependent `auto` velden `stale`; publish → `auto` opnieuw
  vertaald, stale cleared. Verifieer de cubit-tests die dit pinnen.
- `source_hash` wordt aan beide kanten (client en Edge Function) op dezelfde
  manier berekend; drift maakt cache en stale-detectie onbetrouwbaar.
- Vertaal-writes zijn per site en per document gescoped; geen pad dat
  vertalingen van een ander document of andere site raakt.
- Kostenbeheersing blijft intact: cache-hits op ongewijzigde bron, locked
  skip, alleen ingeschakelde talen.

### 5. CMS-documentlifecycle

- **Geen autosave.** Opslaan is een expliciete gebruikersactie. Elke
  debounced/impliciete write die draft-content persisteert zonder expliciete
  save is een bevinding.
- Draft en published content zijn gescheiden; een draft-save mag de
  gepubliceerde site niet wijzigen, en publish is de enige weg van draft naar
  live. Verifieer dat de sites-renderer voor bezoekers uitsluitend published
  content leest en dat draft-weergave alleen in de editor-preview bestaat.
- Publish is atomair per actie: content + vertalingen + statusvelden
  consistent, geen half-gepubliceerde tussenstand bij een fout halverwege.
- Preview toont de draft van de editor (incl. vertaalstatus-badges); een
  preview die stiekem published content toont — of andersom — is een
  bevinding.
- Versie-snapshots bij publish blijven kloppen (geen snapshot = geen
  herstelpad).
- Dirty-state klopt: cancel laat de staat intact, een mislukte save laat geen
  half-opgeslagen document achter.

### 6. Multi-site platform, workers en routing

Model B: één gedeelde Next.js-worker (`hosthub-sites`) rendert alle
klantsites; de Flutter-console wordt door een aparte worker
(`hosthub-admin-router`, `cloudflare/`) geserveerd.

- Elke request-resolutie loopt host → `site_domains` → `site_id` → content
  van die site. Geen route, API-handler of component die site-content zonder
  die keten ophaalt.
- Fallback-keten (geen domain-match → env-default site → statische snapshot)
  is bewust en kan nooit klant-A-content op klant-B-domein tonen.
- Geen module-scope caches of singletons in `web/` of `cloudflare/src` die
  per-site data zonder site-key bewaren (workers hergebruiken module-scope
  tussen requests van verschillende domeinen).
- Apex + `www` + subdomeinen: routing en redirects kloppen voor alle rijen in
  `site_domains`; `is_primary` wordt consistent gebruikt voor canonicals.
- Site-provisioning (`scripts/provision_cms_site.mjs`) blijft consistent met
  het schema: nieuwe site = data + DNS, geen codewijziging. Een feature die
  een per-site codepad of hardcoded sitenaam introduceert ondermijnt het model
  en is een bevinding (Trysil is de eerste klant, niet de baseline —
  `trysilpanorama`-hardcodes buiten config/DNS-documentatie zijn verdacht).
- Admin-router: de admin-route wordt at-deploy-time geïnjecteerd uit env
  (`HOSTHUB_PUBLIC_DOMAIN` + `HOSTHUB_ADMIN_PATH`); nieuwe hardcoded routes in
  `cloudflare/wrangler.toml` of `cloudflare/src/worker.js` zijn een bevinding.
- De statische CMS-snapshot (`cms:snapshot` → `content.generated.ts`) is een
  gegenereerd artefact: hand-edits daar zijn een bevinding; de
  snapshot-fallback mag nooit stiller winnen van live content dan ontworpen.

### 7. StyledWidgets, gedeelde libraries en actuele UI API's

Controleer alle Flutter UI-code in `hosthub_console/`.

#### Gedeelde-library discipline (cross-repo)

- `styled_widgets` (en andere `../../shared/libraries/*`) worden door meerdere
  repo's geconsumeerd — sommige per pad, andere per git tag. Een lib-wijziging
  is dus een cross-repo change: nieuwe capabilities landen **optioneel en
  uitschakelbaar** (bestaand gedrag ongewijzigd zonder opt-in), met tests in
  de lib zelf.
- De lib moet blijven compileren op de oudste consumerende toolchain
  (Diplora); gebruik geen Flutter/Dart-APIs die nieuwer zijn dan die pin.
  HostHub draait zelf op de `.fvmrc`-pin — verwar die twee niet.
- Geen brand names of HostHub-specifieke aannames in shared code;
  HostHub-specifiek gedrag hoort app-lokaal of als generieke, benoemde optie.
- Library-first: een generieke UI-capability die app-lokaal is nagebouwd
  (kopie van een lib-widget, eigen chrome naast een bestaand lib-component) is
  een bevinding — de fix is de lib uitbreiden, niet de app.

#### Modals en dialogen

- Simpele bevestigingen/destructieve acties: `showStyledAlertDialog` (met
  `isDestructiveAction: true` voor destructief), niet `showStyledModal`,
  `showDialog`, `AlertDialog` of `Dialog`. Async bevestigingen via de
  door de lib bedoelde action-callback, niet met een eigen spinner-workaround.
- Inhoudsmodals/formulieren/detailcontent: `showStyledModal`.
- Multi-step flows: `showStyledModal<T>(steps: StyledModalSteps(...))`.
  Step-velden `action`, `isDirty`, `onActionPressed` overrulen modal-niveau.
- Close button alleen wanneer bewust nodig, leading (links); primaire actie
  rechts of in de footer. Sluiten via `controller.close(result)` /
  `controller.closeWithoutResult()` — nooit `Navigator.pop(context)` vanuit
  een modal-body.
- `contentPadding` unset laten tenzij de content full-bleed is.

#### Layout en componenten

- In modal/content: alleen StyledWidgets voor layout, controls, acties en form
  fields, tenzij een required capability aantoonbaar ontbreekt (en dan eerst
  de lib-route overwegen).
- Boolean keuzes: `StyledSwitchTile`. Drie of meer opties:
  `StyledSelectionTile.dropdown` / `.inlineDropdown`. Segmented choices:
  `StyledSegmentedControl`.
- Tabellen: `StyledDataTable` met nette empty state; toasts alleen voor
  succes/info via `showStyledToast`.
- Bekende lib-valkuilen om actief op te controleren:
  - `StyledTile` met `selectable: false` vangt taps die voor een overlay
    bedoeld zijn — controleer tap-doorloop bij tiles met custom overlays;
  - `StyledContainer` heeft default padding — in fixed-size boxes expliciet
    op nul zetten waar het design dat vraagt;
  - `StyledWebPageScaffold` met vaste `leftPaneSize` vult de leegte niet
    wanneer de rechterpane verborgen is — check het gedrag bij verborgen
    panes.

#### Page chrome (console)

- De console is een webapp met een rail/side-menu-shell
  (`StyledSideMenu`-compositie) en `StyledWebPageScaffold`-pagina's; nieuwe
  pagina's volgen die shell in plaats van eigen `Scaffold`-chrome te bouwen.
- Volg de designbron: `../hosthub-design/HostHub CMS.dc.html` + de
  `_ds`-tokens. Bewuste, gedocumenteerde afwijkingen (bv. railbreedte) staan
  in de handoff-notes; nieuwe afwijkingen zonder notitie zijn een bevinding.
- Hub pattern voor beheer-secties: hub page met `StyledSection` +
  `StyledTile` navigatie naar sub-pagina's per concern; geen long-form
  settings dump op één pagina.
- Errors altijd via `showAppError`, nooit toast/snackbar.

### 8. State management, error handling en crash reporting (console)

#### Data/UI scheiding

- View/UI mag geen repository, Supabase client, storage of API direct
  aanroepen.
- Feature-acties moeten via Cubit/Bloc/state layer lopen.
- Geen Cubit/Bloc aanmaken in `build()`.
- Page-local Cubits in `initState` of route-level provider aanmaken en in
  `dispose()` sluiten.
- Page-local Cubits niet als DI-singleton registreren.

#### Error flow

- Business errors landen als `DomainError` in state en worden getoond via
  `showAppError(context, AppError.fromDomain(context, domainError))`.
- Echte fouten (network, server, 404, permission) gaan **altijd** via
  `showAppError`, **nooit** via `showStyledToast`. Een mislukte load is een
  blocking error-state, geen toast.
- `showStyledToast` alleen voor success/info.
- `ScaffoldMessenger` / `SnackBar` zijn verboden — flag elk gebruik.
- Inline error rendering alleen voor field-specifieke validatie.
- Geen `try/catch` in view code voor feature-acties.

#### Crash reporting

- Controleer de bootstrap-wiring: als er een crash-reporting hook bestaat,
  moet `DomainError.onUnexpectedError` erop aangesloten zijn; staat crash
  reporting bewust uit voor deze console, dan is dat geen bevinding — maar
  swallowed errors, lege catches en alleen-loggen-zonder-state zijn dat wél.
- In Cubit/Bloc: onverwachte fouten via `addError(error, stack)`.
- Buiten Cubit/Bloc (repositories, services): nooit silent swallow; fouten
  mappen of rethrown.

### 9. Theming, localization en Material 3

- Geen raw `Theme.of(context)` waar de theme-extensions van het project
  (`context.theme`/`context.colors` e.d.) beschikbaar zijn.
- Geen lokale alias voor `Theme.of(context)` of `S.of(context)`.
  Voorbeeldzoek:

  ```bash
  rg -n "final \w+ = (Theme|S)\.of\(context\)" hosthub_console/lib --glob "*.dart"
  ```

- Uitzonderingen: `StyledWidgetsTheme.of(context)`, `IconTheme.of(context)`,
  en single-property extracties zoals `final label = S.of(context).save;`.
- Geen raw hex kleuren in widgets; kleuren via `ColorScheme`-roles of de
  theme-tokens. Gedocumenteerde status-token-uitzonderingen (bv. de
  vertaalstatus-kleuren) blijven op één plek gedefinieerd, niet verspreid.
- Let op contrast bij secundaire tekstrollen in het HostHub-thema (o.a. de
  te-lichte secundaire tekstkleur die eerder is gesignaleerd): een rol die in
  dit thema onleesbaar wordt is een bevinding, ook als de rolkeuze "volgens
  het boekje" is.
- Geen lokale `ThemeData`; theming loopt via de theme preset/builder.
- Material 3; M3 color roles, geen verwijderde M2-spellingen (`background`,
  `onBackground`, `surfaceVariant`).
- Alle nieuwe user-facing strings via ARB (`S.of(context).key` /
  `S.current.key`), geen hardcoded strings, geen inline locale branching
  (`isNl`/`isEn`, `switch (lang)`).
- ARB-keys altijd in **beide** ARB-bestanden tegelijk (`intl_en.arb`,
  `intl_nl.arb`) en l10n regenereren via `dart run intl_utils:generate`
  vanuit `hosthub_console/` (single-package layout; geen melos-target hier).
- Interfacetaal ≠ brontaal van content: zie categorie 4; l10n-werk mag nooit
  aan het content-taalmodel morrelen.

### 10. Test coverage

Run wat in jouw omgeving past:

```bash
(cd hosthub_console && fvm flutter test)
```

- Rapporteer failures met testbestand/naam. Onderzoek of een failure bij de
  beoordeelde wijziging hoort of bij parallel/ongecommit werk van een andere
  sessie — benoem dat onderscheid expliciet.
- Als de volledige suite te lang duurt of niet kan draaien, draai de meest
  relevante feature-tests (`fvm flutter test test/features/<feature>`) en
  rapporteer waarom de volledige suite ontbreekt.
- Edge Functions hebben geen testsuite; `deno check` is de enige gate. Voor
  elke gewijzigde functie met echte logica (Lodgify-mapping,
  vertaal-provider-keten, auth-links): rapporteer ontbrekende deterministische
  tests als gap, en stel de kleinste zinvolle testvorm voor.
- Web (`web/`): `npm run lint` + `npm run typecheck` zijn de gates; er is geen
  unit-testsuite. Logica die daar groeit (site-resolutie, contact-flows)
  verdient testbare extractie — rapporteer wanneer logica in componenten
  onttestbaar wordt.
- Identificeer cubits, repositories, models en edge-case-heavy code zonder
  tests.
- Rapporteer welke edge cases ontbreken: errors, null/empty states, permission
  failures, parse failures, network failures (incl. 429), race/lifecycle
  cases.
- Maak een prioriteitenlijst voor extra tests op basis van complexiteit,
  branching en publieke API-impact.
- Widget-/golden-tests voor de CMS-editor volgen het CONFORMANCE-recept uit de
  design-handoff; regressies daar zijn bevindingen, geen "flaky goldens".

### 11. Analyse, onderhoudbaarheid en duplicatie

Run:

```bash
(cd hosthub_console && fvm flutter analyze)
```

- Zoek naar TODO/FIXME/HACK, ongebruikte code, magic numbers, hardcoded
  strings en duplicate logic — in Dart én TS/JS (worker, web, functions).
- Zoek naar legacy/deprecated signalen en rapporteer ze als verwijderwerk
  tenzij er een expliciet extern compatibiliteitscontract is:

  ```bash
  rg -n "@Deprecated|deprecated_member_use|compat|compatibility|legacy|fallback|backfill-only|TODO\(remove\)|remove after" hosthub_console/lib web/app web/components web/lib cloudflare/src supabase --glob "!**/*.g.dart" --glob "!**/node_modules/**"
  ```

- Rapporteer methods >30 regels wanneer complex of moeilijk testbaar.
- Rapporteer files >300 regels alleen wanneer dit echte onderhoudsrisico's
  geeft.
- Zoek dubbele models/enums/helpers tussen console, functions en web —
  met name gedeelde contracten (veldnamen, statuswaarden, hashes) die op twee
  plekken met de hand zijn uitgeschreven; stel één bron voor waar dat kan.
- Controleer naming-consistentie en laaggrenzen per feature (`domain`, `data`,
  `application`, `presentation` waar aanwezig).
- Rapporteer alleen TODO/FIXME/HACK als er productie-impact, release-risico of
  ontbrekende ownership is — geen ruislijst.
- Manuele edits in generated files (`*.g.dart`, `*.freezed.dart`,
  `lib/generated/**`, `content.generated.ts`) zijn altijd een bevinding.

### 12. Zuivere code, API-ontwerp en toekomstbestendigheid

Controleer actief of de code schoon, generiek, testbaar en toekomstbestendig
is. Behandel "werkt nu" niet als voldoende wanneer de gekozen vorm later
migraties, duplicatie of onduidelijke APIs afdwingt.

- Code moet DRY zijn zonder geforceerde abstracties. Rapporteer copy-paste
  logica, parallelle implementaties en bijna-dezelfde helperfuncties.
- Publieke APIs moeten simpel, voorspelbaar en typed zijn:
  - geen boolean/config flags die meerdere gedragingen in een methode
    verstoppen
  - geen brede parameterlijsten waar een duidelijk request/model object
    passender is
  - geen API die internal state, UI-keuzes of backend-details lekt naar een
    verkeerde laag
  - geen inconsistent naamgebruik voor dezelfde concepten
- Interne helpers moeten logisch gegroepeerd zijn:
  - geen kleine private helpers verspreid over veel files als ze samen een
    concept vormen
  - geen helper-sprawl waarbij de call flow moeilijk te volgen of te testen
    wordt
  - verplaats gedeelde helperlogica naar een passende module wanneer meerdere
    features dezelfde logica nodig hebben
- Generieke code moet echt generiek zijn:
  - geen hardcoded feature- of klantspecifieke aannames in gedeelde code
    (zie ook de Trysil-hardcode-check in categorie 6)
  - geen herbruikbare class/function die stiekem maar een enkele use case
    ondersteunt
  - geen premature abstraction zonder minimaal twee duidelijke call sites of
    een vastgesteld projectpatroon
- Testbaarheid is een ontwerpcriterium:
  - businesslogica moet zonder widget test of echte Supabase client testbaar
    zijn
  - tijd, randomness, auth/session context en externe clients (Lodgify,
    vertaalproviders, Resend) moeten injecteerbaar of goed af te schermen zijn
  - pure transformaties (veldmapping, hashing, site-resolutie) moeten als
    pure functies of kleine services testbaar zijn
  - UI moet zo dun mogelijk blijven en feature-acties delegeren aan state
    management
- Toekomstbestendigheid:
  - geen tijdelijke migratievormen, shared-state hacks of "we clean this up
    later" patronen
  - API parameter changes moeten direct end-to-end worden doorgevoerd
  - nieuwe code moet passen bij de uiteindelijke multi-tenant architectuur
    (N sites, N accounts), niet bij het single-customer heden
  - abstractions moeten uitbreiding ondersteunen zonder bestaande callers te
    breken
- Legacy/deprecated beleid:
  - er is nog nauwelijks productie (één klant), dus runtime-compatibiliteit
    is geen standaardreden om oude code te behouden — maar prd-data van die
    klant is wél echt: datamigraties blijven zorgvuldig
  - verwijder oude codepaden, fallback readers/writers, oude payload keys en
    deprecated wrappers zodra callers zijn gemigreerd
  - introduceer geen nieuwe `@Deprecated` APIs of deprecation-suppressions
    voor eigen code; vervang direct alle callers — voor gedeelde libraries
    geldt de cross-repo regel uit categorie 7
  - gebruik geen deprecated Flutter/Dart/package APIs; migreer in dezelfde
    wijziging
  - als externe compatibiliteit echt nodig is, documenteer eigenaar,
    einddatum en verwijdercriterium in het reviewrapport
- Stille no-op widgets als visibility-mechanisme zijn een design-smell. Een
  `build()` die conditioneel `SizedBox.shrink()` teruggeeft vertelt zijn
  caller niet dat de widget "afwezig" is — voor lay-outs die om children
  itereren (sections met dividers, `Wrap`/`Row` met spacing) blijft het kind
  meetellen en levert het fantoom-dividers of dubbele spacing op. Zoek:

  ```bash
  rg -n "return const SizedBox\.shrink\(\)" hosthub_console/lib --glob "*.dart"
  ```

  Beoordeel elke hit: hoort de visibility-beslissing bij de caller, is het een
  echte boundary check (documenteer waarom), of hoort er een expliciete
  `Widget?`-retour?
- Rapporteer ook wanneer de voorgestelde oplossing voor een bevinding
  waarschijnlijk een shortcut zou zijn. Geef dan de zuivere
  alternatief-richting.

### 13. Documentatie- en outputlocatie-discipline

- Generated artefacts (reviews, plans, summaries, scratch notes) horen onder
  `docs-internal/`, **nooit** onder `docs/` (dat is de curated technische
  documentatie van de workspace) en nooit ergens onder `web/` (alles daar kan
  publiek geserveerd worden).
- Bestaande indelingen onder `docs-internal/`: `reviews/`, `review-prompts/`.
  Nieuwe sibling-folder mag.
- `CLAUDE.md` moet inhoudelijk gelijk zijn aan `AGENTS.md`; drift tussen die
  twee is een bevinding. `AGENTS_CORE.md` is bewust gevendored en wordt
  handmatig in sync gehouden met de andere repo's — een lokale wijziging
  daarin zonder notitie dat de andere repo's meemoeten is een bevinding.
- Design-conformance beoordeel je tegen de actuele inhoud van
  `../hosthub-design/` (de map wordt ververst); citeer welk handoff-bestand en
  welke sectie een bevinding onderbouwt.

## Severity model

Gebruik deze ernstniveaus:

- **P0 Kritiek**: data loss (incl. overschreven `locked`-vertalingen of
  gepubliceerde content), cross-site leakage (content, config of secrets van
  site A zichtbaar op domein/sessie van site B), security/RLS issue,
  gelekte credentials (Lodgify-key, service-role key) richting client,
  productie-crash, migratie die prd kan breken.
- **P1 Hoog**: foutafhandeling ontbreekt in belangrijke flow, API-contract
  inconsistent (console ↔ Edge Function ↔ SQL, of hash/statuscontract
  client ↔ server), UI direct naar data layer, belangrijke testdekking
  ontbreekt, autosave/impliciete publish-paden die het expliciete
  save/publish-model ondermijnen, deploy-advies zonder
  migratievolgorde/PGRST202-stap, gedeelde-lib wijziging die een andere
  consumer breekt, legacy/deprecated runtime path dat canonical gedrag kan
  ondermijnen.
- **P2 Medium**: onderhoudbaarheidsrisico, duplicatie, helper-sprawl,
  incomplete edge-case tests (bv. geen 429-pad), inconsistent
  StyledWidgets/API-gebruik, toast-gebruik voor errors, klantspecifieke
  hardcodes die het multi-site model eroderen, guardrail ontbreekt voor een
  risicovol contract.
- **P3 Laag**: naming, kleine cleanup, beperkte technische schuld zonder
  direct productie-impact.

Markeer een bevinding als `release-blocking: ja` wanneer P0 of P1 niet veilig
kan worden uitgesteld. P2/P3 kunnen ook release-blocking zijn als ze een
patroon aantonen dat meerdere features raakt.

## Vergelijk met vorige reviews

Zoek eerdere rapporten in deze volgorde:

1. `docs-internal/reviews/`
2. `docs-internal/reviews/cms-website-editor-state.md` (historiek van de
   CMS-build-loop: opgeleverde slices, bekende user-gated restpunten en
   gedocumenteerde afwijkingen — geen daily-state, wel context)

Gebruik het meest recente relevante rapport als baseline.

Benoem:

- opgelost/verbeterd
- nog openstaand
- nieuw geintroduceerd
- trend voor Theme/S alias hits en raw-color hits
- terugkerende bevindingen die nog geen eigenaar of roadmap-item hebben

## Daily state

De dagelijkse release-quality review is stateful zodat de volledige repo over
meerdere runs aantoonbaar dieper wordt bekeken. Lees vóór de inhoudelijke
review de state-file als die bestaat en werk hem na afloop bij:

`docs-internal/reviews/daily-release-readiness-state.md`

Gebruik dit contract:

```markdown
# Daily Release-Readiness Review State

- last_reviewed_at:
- last_reviewed_head:
- baseline:
- analyzer_baseline: (bekende pre-existing analyzer-issues, met aantal en aard)
- whole_code_review_policy: continue reviewing committed HEAD slices until all repo-owned code has been covered
- current_whole_code_slice:
- next_review_start:

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

## Whole-Code Review Ledger

| area | reviewed_at | files_or_patterns | result |
|---|---|---|---|

## Structure And Completeness Passes

| pass | reviewed_at | result | evidence |
|---|---|---|---|
```

Regels:

- Hergebruik bestaande finding-id's wanneer dezelfde bug nog open is.
- Markeer een finding pas resolved wanneer de codewijziging de oorzaak oplost
  of de finding aantoonbaar ongeldig maakt.
- Als een P1/P2-finding opgelost is, voeg het omliggende gebied toe aan de
  deep-dive queue voor de volgende reviewlaag.
- Als er nog geen whole-code queue bestaat, initialiseer hem met de
  belangrijkste repo-owned codegebieden:
  `hosthub_console/lib/app` + `core` + `shared`,
  `hosthub_console/lib/features/auth` + `profile` + `users` + `team`,
  `hosthub_console/lib/features/properties` + `portfolio`,
  `hosthub_console/lib/features/reservations` + `revenue` +
  `channel_manager`,
  `hosthub_console/lib/features/cms` + `website_editor` + `sites`,
  `hosthub_console/lib/features/server_settings` + `user_settings`,
  `web/app` + `web/components`, `web/lib` + `web/proxy.ts` + web-config,
  `cloudflare/src` + `cloudflare/scripts`,
  `supabase/functions` (per functie-cluster: auth-links, lodgify-*,
  translate-content, send_*, overige),
  `supabase/migrations` + `supabase/policies` + schema_dump-consistentie,
  `scripts`, en `../../shared/libraries/styled_widgets` (cross-repo lens:
  compatibiliteit, optionaliteit, tests).
- Splits grote gebieden in opvolgende slices in plaats van ze oppervlakkig af
  te vinken. Een slice is pas afgerond na file-level lezen van de relevante
  productiecode, directe tests, en directe callgraph/contractcontrole waar
  zinvol.
- Als de committed diff leeg of klein is, ga alsnog door met de hoogste-risico
  whole-code slice uit de queue of een open finding/deep-dive gebied.
- Verwijder geen historiek die nodig is om voortgang en hercontrole te
  begrijpen; houd de state wel kort.

## Outputlocatie

Schrijf het rapport naar `docs-internal/reviews/`.

Bestandsnaam:

- Daily release-quality review: `docs-internal/reviews/daily-review-YYYY-MM-DD.md`
- Release review: `docs-internal/reviews/release-review-YYYY-MM-DD.md`
- Architecture-deep review: `docs-internal/reviews/architecture-deep-review-YYYY-MM-DD.md`
- Scoped review: `docs-internal/reviews/<scope>-review-YYYY-MM-DD.md` met een
  korte slug voor `<scope>`

Als het doelbestand al bestaat, overschrijf het niet stilzwijgend. Voeg een
korte suffix toe (bijv. `-2`), of werk het bestaande rapport alleen bij als de
gebruiker dat expliciet vraagt.

Schrijf **niet** naar `docs/`, `web/` of `.claude/`.

## Outputformat

Voor release-readiness reviews is het rapport **issue-only**. De gebruiker wil
niet zien welke stappen, checks of trends zijn uitgevoerd; die informatie is
alleen werkcontext voor de reviewer. Schrijf in het rapport uitsluitend
openstaande issues. Neem een check, ontbrekende gate of niet-uitgevoerde scope
alleen op wanneer die zelf een openstaand issue of concreet release-risico is.

Niet opnemen in release-readiness reports:

- trend t.o.v. vorige review;
- samenvattingen van wat is gedaan;
- tabellen met geslaagde checks;
- dirty-diff beschrijvingen zonder open issue;
- "schoon"-regels per scan/pass.

Als er geen openstaande issues zijn, schrijf alleen:

```md
# Daily Review YYYY-MM-DD

Geen openstaande issues gevonden.
```

Als er wel openstaande issues zijn, gebruik dit format:

```md
# Daily Review YYYY-MM-DD

## Openstaande Issues

#### [P1 Hoog] Korte titel

- Bestand: `pad/naar/file.dart:123`
- Probleem:
- Impact:
- Suggestie:
- Ontbrekende test/guardrail:
- Release-blocking: ja/nee
- Bewijs/check:
```

Voor release, scoped en architecture-deep reviews mag een uitgebreider rapport
alleen wanneer de gebruiker daar expliciet om vraagt of wanneer de extra
context nodig is om een open issue te begrijpen.
