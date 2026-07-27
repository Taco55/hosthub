# Fase 2 voorwerk — website-editor: volledig veldmodel + media

Opgeleverd vóór de bouw, zoals de handoff eist (README/START_HERE in
`hosthub-design/design_handoff_hosthub_cms_fase2/`). Bronnen: de **echte documenten in de
prd-database** (site `d2744793` Trysil Panorama, gelezen 2026-07-27, per document rijen voor
`nl`/`en`/`no`; `draft_content` aanwezig op de nl-rijen) en het **prototype-schema** in
`HostHub CMS Fase 2.dc.html` (het `SCHEMA`-object — de canonieke veldsleutels). Niet gebruikt
als bron: `web/lib/content.ts` (snapshot).

De fase-1-handoff blijft volledig gelden; niets hieronder draait iets daaruit terug.

---

## 1. Mapping veldsleutel → document + JSON-pad

Notatie: `<id>` = stabiel rij-id (fase 1-migratie), `[i]`/`[j]` = lijstindex in het document
(alleen weergaveorde). "bestaat" = pad staat vandaag in het prd-document.

### Home (`/`)

| Kaart | Veldsleutel | Document | JSON-pad | Status |
|---|---|---|---|---|
| 1 Hero | `cabin.hero.title` | cabin/main | `hero.title` | bestaat; heet in de editor nu `hero.headline` (rename in fase 1) |
| 1 Hero | `cabin.meta.locationShort` | cabin/main | `meta.locationShort` | bestaat, nieuw als veld |
| 1 Hero | media `home.hero.photos` (1–5) | site_config/main | `images.heroPhotos` | **nieuw** — verhuist uit repo (`heroImageFilenames` in content.ts); taalonafhankelijk, write-through alle locales (fase 5) |
| 1 Hero | `cabin.hero.photosAlt` | cabin/main | `hero.photosAlt` | **nieuw veld** (samenvattende alt; vandaag gebruikt de renderer `meta.name` als hero-alt) |
| 1 Hero | `cabin.hero.subtitle` | cabin/main | `hero.subtitle` | bestaat (novis: seo — Google-omschrijving + /book) |
| 1 Hero | `cabin.meta.name` | cabin/main | `meta.name` | bestaat, nieuw als veld (novis: seo — browsertab/Google) |
| 2 Kerncijfers | `home.keyFacts.<id>.label` / `.value` | page/home | `keyFacts[i].label` / `.value` | bestaat (4 rijen); 3–6, waarde gedeeld |
| 3 Beschrijving | `cabin.description.<id>.text` | cabin/main | `description[i]` | bestaat (2 alinea's; strings → `{id,text}` in fase 1); heet nu `chalet.description.N` |
| 4 Galerij op home | media `home.gallery` (5–8) | site_config/main | `images.homeGallery` | **nieuw** — verhuist uit repo (`gallery`-selectie in content.ts); subset van de bibliotheek |
| 4 Galerij op home | `home.galleryAlt` | page/home | `galleryAlt` | **nieuw veld** |
| 5 Voorzieningen | `cabin.amenities.title` | cabin/main | `amenities.title` | bestaat (vandaag het enige gerenderde deel) |
| 5 Voorzieningen | `cabin.amenities.groups.<gId>.title` | cabin/main | `amenities.groups[i].title` | bestaat (10 groepen in prd; max 12 past) |
| 5 Voorzieningen | `cabin.amenities.groups.<gId>.items.<iId>.text` | cabin/main | `amenities.groups[i].items[j]` | bestaat (strings → `{id,text}`); pas gerenderd na fase 7 (web leest nu `homeAmenities.ts`) |
| 6 Locatie & afstanden | `cabin.location.title` | cabin/main | `location.title` | bestaat |
| 6 Locatie & afstanden | `cabin.location.distances.<id>.label` / `.value` | cabin/main | `location.distances[i]` | bestaat (4 rijen); 1–8, waarde gedeeld |
| 6 Locatie & afstanden | `cabin.location.mapQuery` | cabin/main | `location.mapQuery` | **nieuw veld** (novis: map — de speld verplaatst mee) |
| 7 Hoogtepunten | `home.highlights.<id>.title` / `.description` | page/home | `highlights[i].title` / `.description` | bestaat (4 rijen); 2–6; description heet nu `highlights.N` |
| 7 Hoogtepunten | `home.highlights.<id>.image` | page/home | `highlights[i].image` | **fusie**: uit `highlightImages[i].src`; taalonafhankelijk, volgt bron |
| 7 Hoogtepunten | `home.highlights.<id>.alt` | page/home | `highlights[i].alt` | **fusie**: uit `highlightImages[i].alt`; per taal |
| 8 Huisregels | `cabin.rules.title` | cabin/main | `houseRules.title` | bestaat; sectie op Home gemount in fase 7 (`HouseRules.tsx`) |
| 8 Huisregels | `cabin.rules.bullets.<id>.text` | cabin/main | `houseRules.bullets[i]` | bestaat (3 rijen); 1–8 |
| 8 Huisregels | `cabin.rules.times` (paar, vaste labels, gedeeld) | cabin/main | `houseRules.checkIn` / `houseRules.checkOut` | bestaat; 2 vaste rijen op scalar-paden |
| 8 Huisregels | `cabin.rules.checkInNote` / `.cleaningNote` / `.wifiNote` | cabin/main | `houseRules.checkInNote` / `.cleaningNote` / `.wifiNote` | bestaat |
| 9 Contactformulier | `contact.title` / `contact.subtitle` | contact_form/main | `title` / `subtitle` | bestaat (nu al veld) |
| 9 Contactformulier | `contact.form.fields` (paar, vast 4, wideValue, níet gedeeld) | contact_form/main | `form.name\|email\|period\|message` `.label`/`.placeholder` | bestaat; rij-ids = de objectsleutels (backend-contract) |
| 9 Contactformulier | `contact.form.submit` / `.success` / `.error` | contact_form/main | `form.submit` / `.success` / `.error` | bestaat (success/error: novis met voorbeeldstaat) |

### Praktisch (`/practical`)

| Kaart | Veldsleutel | Document | JSON-pad | Status |
|---|---|---|---|---|
| 1 Kop | `practical.header.title` / `.subtitle` | page/practical | `header.title` / `.subtitle` | bestaat (nu al veld) |
| 2 Snel overzicht | `practical.quickFacts.<id>.label` / `.value` | page/practical | `quickFacts[i]` | bestaat (6 rijen = max); 2–6, waarde gedeeld |
| 3 Aankomst & toegang | `practical.arrival.title` | page/practical | `arrivalAccess.title` | bestaat |
| 3 Aankomst & toegang | `practical.arrival.times` (paar, vaste labels, gedeeld) | page/practical | `arrivalAccess.checkIn` / `.checkOut` | bestaat; `checkInLabel`/`checkOutLabel` in het doc worden systeemwaarden (gerenderd, niet bewerkbaar) |
| 3 Aankomst & toegang | `practical.arrival.bullets.<id>.text` | page/practical | `arrivalAccess.bullets[i]` | bestaat (2); 1–8 |
| 4 Parkeren & laden | `practical.parking.title` / `.callout` | page/practical | `parkingCharging.title` / `.callout` | bestaat |
| 4 Parkeren & laden | `practical.parking.bullets.<id>.text` | page/practical | `parkingCharging.bullets[i]` | bestaat (3); 1–6 |
| 5 Indeling & faciliteiten | `practical.layout.title` | page/practical | `layoutFacilities.title` | bestaat |
| 5 Indeling & faciliteiten | `practical.layout.sections.<gId>.title` / `.intro` / `.bullets.<iId>.text` | page/practical | `layoutFacilities.sections[i].title` / `.intro` / `.bullets[j]` | bestaat (6 secties = max); intro optioneel |
| 6 Aankomst & vervoer | `practical.transport.title` | page/practical | `transport.title` | bestaat |
| 6 Aankomst & vervoer | `practical.transport.columns.<slot>.bullets.<iId>.text` | page/practical | `transport.columns[i].bullets[j]` | bestaat (3 kolommen); **vaste slots** — zie besluit hieronder |
| 7 Goed om te weten | `practical.goodToKnow.title` + `.bullets.<id>.text` | page/practical | `goodToKnow.*` | bestaat (4); 1–10 |
| 8 Contact & hulp | `practical.contactHelp.title` + `.bullets.<id>.text` | page/practical | `contactHelp.*` | bestaat (2); 1–6 |
| 9 Afspraken & betaling | — (read-only kaart) | page/practical | `agreementsAndPayment` | bestaat; bron = Lodgify, geen velden |

### Omgeving (`/area`)

| Kaart | Veldsleutel | Document | JSON-pad | Status |
|---|---|---|---|---|
| 1 Introductie | `area.intro` | page/area | `intro` | bestaat (nu al veld) |
| 2 Secties | `area.sections.<gId>.title` / `.intro` / `.bullets.<iId>.text` | page/area | `sections[i].title` / **`.description`** / `.bullets[j]` | bestaat (2 secties); max 8. NB: de intro-sub heet in dít document `description` (Praktisch gebruikt `intro`) — het pad staat per lijst in het schema, geen normalisatie |

### Galerij (`/gallery`)

| Kaart | Veldsleutel | Document | JSON-pad | Status |
|---|---|---|---|---|
| 1 Kop | `home.tagline` | page/home | `tagline` | bestaat; hint noemt de andere landingsplekken (Omgeving, Google) |
| 2 Alle foto's | media `gallery.all` (6–40) | site_config/main | `images.galleryAll` | **nieuw** — verhuist uit repo (`galleryAllFilenames`) |
| 2 Alle foto's | `gallery.allAlt` | page/gallery | `galleryAlt` | **nieuw document** `page/gallery` (aangemaakt bij eerste write; tab = route = document) |

### Instellingen → Juridisch (geen tab)

| Veldsleutel | Document | JSON-pad | Status |
|---|---|---|---|
| `privacy.intro` | page/privacy | `intro` | bestaat |
| `privacy.bullets.<id>.text` | page/privacy | `bullets[i]` | bestaat (3) |

### Geen veld (dode inhoud, §0.1 — opruimen in fase 7)

`cabin.experience`, `cabin.layoutAndFacilities`, `cabin.accessAndTransport`, `cabin.policies`,
page/home `amenities` (platte lijst), page/home `location.description`, page/home `faq`,
page/home `reviews` (reviews/FAQ buiten scope). De huidige editor-keys `chalet.experience.N`
vervallen (dood veld); hun `site_translations`-rijen gaan mee weg in de fase 1-migratie.

### Twee vastgelegde afwijkingen (zelf besloten, per memory-regel "bij conflict zelf kiezen")

1. **`cabin.hero.badges` + dual-write naar `meta.sleeps`/`meta.altitude`.** CONFORMANCE §1 eist
   dat badge-waarden ook naar `meta.*` schrijven, maar het prototype seedt `cabin.hero.badges`
   zonder er een kaart aan te binden (geen badge-editor in het definitieve Home-schema), en
   `hero.badges` én `meta.sleeps`/`altitude` worden door geen enkele pagina gerenderd (grep over
   `web/app` + `web/components`). Besluit: het schema **ondersteunt multi-pad-writes** (één
   veldsleutel → meerdere paden, met test — de capaciteit uit §0.2 eis 2), maar er wordt geen
   badge-veld verzonnen dat het ontwerp zelf heeft laten vallen. Terug naar de designkant als
   badges ooit gaan renderen.
2. **`practical.transport.columns`: 5 vaste slots.** Het prototype fixeert vijf koltitels (Met de
   auto / Vliegvelden / Openbaar vervoer / Parkeren / Let op); het echte document heeft er 3
   (Auto / Openbaar vervoer / Luchthavens). Besluit: vaste slot-ids `car`, `airports`,
   `publicTransport`, `parking`, `notes`; de bestaande drie kolommen migreren op titel-match;
   lege slots renderen niet op de site; geen automatische seed uit het dode
   `cabin.accessAndTransport` (eigenaar vult zelf). Koltitels worden interface-labels in de
   editor; de per-locale titels in het document blijven de renderbron.

---

## 2. Library-toevoegingen B1–B15 — met de bestaande basis

| # | Toevoeging | Bouwt voort op (bestaat in `styled_widgets`) | Fase |
|---|---|---|---|
| B1 | `N gewijzigd`-rollup in de sectiekop | `StyledSection.headerAction` (widget-slot rechts in de kop, bestaat al) — hergebruik; alléén als een kaart het slot al bezet komt er een tweede `headerTrailing`-slot | 4 |
| B2 | Read-only sectievariant | `StyledSection` + `StyledSectionThemeData` → nieuw `readOnly:` met `readOnlyBackgroundColor` en een disable-scope voor velden erin | 3 |
| B3 | `StyledSectionSubheader` | nieuw in `sections/`; typografie uit de nieuwe `fieldLists:`-themegroep | 2 |
| B4 | `StyledRepeaterRow` | nieuw in `reorderable/`; grip/acties op het patroon van `StyledReorderableTile`, acties = `StyledIconButton`, `disabledReason` = zichtbaar + gedimd + tooltip; nieuwe `repeaters:`-themegroep | 2 |
| B5 | `StyledFieldList<T>` | nieuw; composeert B3 + B4 + `StyledReorderableList` (bestaat) + B8 + de bestaande undo-compositie (`StyledNotice` + `StyledTextButton`, zelfde vorm als fase-1 undo) | 2 |
| B6 | `sharedAcrossLocales` op het veld | `StyledFormField` (heeft `labelTrailing`/`footer` al uit fase 1) → nieuw param; rendert micro-chip (B9) + read-only-staat | 2 |
| B7 | `StyledFieldGroup` | nieuw; groepskop op `fieldLists.groupHeaderBackground`, body = B5; `fixedTitle:` voor vaste groepen | 2 |
| B8 | `StyledEmptyState.inline` | `StyledEmptyState` (bestaat) + `StyledDashedRoundedRectangleBorder` (bestaat in `utils/`) → compacte gestippelde variant | 2 |
| B9 | `StyledChipSize.micro` | bestaand enum (`display`/`selection`) in `buttons/styled_chip.dart` → derde waarde (10/600, padding 3/7, radius 5) | 2 |
| B10 | `StyledFilterChip` | nieuw naast `StyledChoiceChip`; checkbox-vierkant = `StyledCheckbox` (bestaat); kleuren `chipTheme.filter*` | 4 |
| B11 | `StyledMediaStrip` | nieuw; drag-reorder via `StyledReorderDragSource`/`StyledReorderDropTarget` (bestaan — zelfde drop-indicatie als lijstrijen, CONFORMANCE §6); `imageBuilder`-injectie; nieuwe `media:`-themegroep | 5 |
| B12 | `StyledSelectableGrid<T>` | nieuw; generiek grid + selectievinkje uit het theme; niets media-specifieks | 5 |
| B13 | `StyledDropzone` + `StyledUploadRow` | nieuw; dashed border bestaat; voortgangsbalk uit nieuwe `uploads:`-themegroep (trackHeight 3, done/failed-kleuren) | 5 |
| B14 | `StyledTile.nested` | bestaand `StyledTile` → nieuw param (2 px `outlineVariant`-rail + inzet) uit `StyledTileThemeData` | 6 |
| B15 | Voorbeeld-markering bij veldfocus | **afwijking:** niet in de lib. Het browserframe is in fase 1 bewust app-lokaal gemaakt (`SitePreviewFrame`, besluit D7/S22) en de sectiemarkering gebeurt ín de gerenderde site: focus-berichten over de bestaande postMessage-brug (`PreviewDraftBridge`), plus `chromeHighlighted` op `SitePreviewFrame` voor de SEO-velden | 6/(8) |

Theme-preset (Part C): nieuwe groepen `repeaters:`, `fieldLists:`, `media:`, `uploads:` in
`StyledWidgetsThemeData` + het HostHub-preset; `micro`-size en `filter*`-kleuren in de bestaande
`chips:`-groep. Geen enkel getal uit de mapping-doc in app-code.

---

## 3. Migratieplan stabiele rij-ids (fase 1 — de enige harde datamigratie)

**Vorm.** Elke herhaalbare lijstrij wordt een object met een `id` (8 tekens, deterministisch bij
migratie, client-gegenereerd bij nieuwe rijen):

- strings → `{id, text}`: `cabin/main description`, `houseRules.bullets`, alle
  `bullets`-lijsten op page/practical en page/area, `amenities.groups[].items`,
  page/privacy `bullets`;
- paren → `{id, label, value}`: `keyFacts`, `location.distances`, `quickFacts`;
- groepen → `{id, title, items|bullets: [...]}`: `amenities.groups`,
  `layoutFacilities.sections` (+`intro`), `area.sections` (+`description`);
- **fusie hoogtepunten**: `highlights[i]` + `highlightImages[i]` → `{id, title, description,
  image, alt}`; `highlightImages` verdwijnt uit het document (parallelle arrays zijn precies de
  identiteitsbug die stabiele ids uitsluiten);
- vaste lijsten krijgen **semantische ids** en géén embedded id: `contact.form`-velden = de
  objectsleutels `name|email|period|message`; `transport.columns` = slots
  `car|airports|publicTransport|parking|notes`; `rules.times`/`arrival.times` = 2 rijen op
  scalar-paden (`checkIn`/`checkOut`).

**Migratie-SQL** (één bestand, lokaal direct; prd bij deploy via psql + `NOTIFY pgrst, 'reload
schema'`-gotcha zoals eerder):

1. Per (site, document, lijstpad): ids **deterministisch** afleiden —
   `substr(md5(site_id || pad || index), 1, 8)` — zodat elke locale-rij (én `content` én
   `draft_content`) exact dezelfde ids krijgt (arrays corresponderen vandaag per index) en de
   migratie idempotent herhaalbaar is.
2. `site_translations.field_key` in dezelfde migratie hernoemen: `hero.headline` →
   `cabin.hero.title`, `chalet.description.N` → `cabin.description.<id>.text`, `highlights.N` →
   `home.highlights.<id>.description`; `chalet.experience.N`-rijen verwijderen (veld vervalt).
   Prd heeft 14 rijen (alleen `en`) — triviaal.
3. Web in dezelfde commit mee: `content-provider`/componenten lezen `{id,text}`-vormen en de
   gefuseerde highlights; snapshot-script (`generate-cms-snapshot.mjs`) mee.

**Regressietest (verplicht per de handoff):** rij slepen in de bron (`moveRow`), doeltaal openen
→ de vertalingen zijn met hun rij-id meegereisd; plus de schrijfkant: reorder + save schrijft de
arrays in de nieuwe volgorde met ongewijzigde ids.

---

## Coördinatie

Een tweede sessie werkt op dit moment (mtimes 27-07 20:14) ongecommit in
`website_editor/**` + `web/` aan de live draft-preview via postMessage en de padgebaseerde
veldmapping — feitelijk het fundament van fase 0. De console-fasen (0, 1, 3+) starten hier pas
als dat werk gecommit of gestaakt is; fase 2 (library, buiten deze repo) heeft nergens last van
en gaat eerst. De handoff-map wordt niet de repo in gekopieerd (START_HERE vraagt het, maar de
fase-1-conventie is verwijzen naar `hosthub-design/`, die map wordt mid-sessie ververst).
