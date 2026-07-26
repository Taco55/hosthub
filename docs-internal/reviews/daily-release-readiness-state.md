# Daily release-readiness state — HostHub CMS website editor

Source of truth for the `/build-loop` implementing the design handoff at
`hosthub-design/design_handoff_hosthub_cms/`. Rubric: `../review-prompts/release-readiness-review.md`.

- **branch:** `main` (regel: nooit feature branches)
- **severities in scope:** P0–P2
- **Started:** 2026-07-23

## Legend
`status`: `todo` · `in_progress` · `done` (with evidence) · `blocked` (with reason)

## Slice queue (dependency order)

Foundational `styled_widgets` lib additions first (everything else depends on them), then the
console CMS feature, then tests + backend wiring.

| # | slice | scope | status | evidence |
|---|-------|-------|--------|----------|
| S1 | B6 `StyledSegment.statusDotColor` | styled_widgets | done | sw@a1591ec; +4 tests in `styled_segmented_control_layout_test.dart` (dot renders/absent × pill/plain); `flutter analyze lib test` clean |
| S2 | B5 `StyledNotice` trailing slot + `warning` tone | styled_widgets | done | sw@595d169; +3 tests (warning light/dark, trailing action); analyze clean |
| S3 | B4 field `labelTrailing` + `footer` slots | styled_widgets | done | sw@36dd929; +4 tests in `styled_form_field_footer_slot_test.dart`; analyze clean |
| S4 | B7 `StyledMeter` | styled_widgets | done | sw@3a9099e; new `styled_meter.dart` + barrel export; +4 tests; analyze clean |
| S5 | B3 `StyledBrowserFrame` (desktop + mobile) | styled_widgets | done | sw@24faa1f; new `styled_browser_frame.dart` + barrel; +4 tests; analyze clean |
| S6 | B2 `StyledSplitView` | styled_widgets | done | sw@f5ebc38; new `styled_split_view.dart` + barrel; +5 tests; analyze clean |
| S7 | B1 `StyledSideMenu` | styled_widgets | done | sw@40198c4; new `styled_side_menu.dart` + `StyledNavItem` + barrel; +6 tests; full suite 664 pass (no regressions) |
| S8 | `SiteContentCubit` + models + repository + DI (state machine) | console | done | eb5db11; `features/website_editor/` (domain+service+cubit+DI); +8 cubit tests; scoped analyze clean |
| S9 | Editor mode A (source editor: bar, tabs, banner, Hero, Highlights, save bar) | console | done | 6616de7 (`editor_column.dart`); lib fix sw@9885132 (plain tabs scroll); widget tests |
| S10 | Editor mode B (translation: chips, source-ref, Reset to AI, coverage, stale/fresh) | console | done | 6616de7 (`website_field_row.dart` labelTrailing/footer, `WebsiteStatusColors`); tests: lock-on-type, Reset to AI |
| S11 | Preview pane (browser/mobile frame, toolbar, locale switch, rendered site, ribbons) | console | done | 6616de7 (`preview_pane.dart`: StyledBrowserFrame web/mobiel, AI-badges + stale dots, ribbons); tests: binding + device toggle |
| S12 | Publish modal | console | done | 6616de7 (`publish_modal.dart` via showStyledAlertDialog, async onConfirm — guide: onAction vereist); test: rows + chips |
| S13 | Sidebar wiring + route + scaffold assembly (split view) | console | done | 6616de7: `/website-editor` route onder bestaande SectionScaffold/SideMenu (rail hergebruikt per README), StyledSplitView-assemblage, DI in bootstrap |
| S14 | i18n ARB strings (nl/en) | console | done | 30a5f7c; ~40 `we*` keys in en+nl ARB; S class regenerated; done early since UI depends on it |
| S15 | Widget + golden tests (CONFORMANCE recipe) | console | done | 9db182f; 4 goldens (1360×880) + 3 adherence-tests (hex/chrome/i18n); totaal 23 tests groen |
| S16 | Supabase `translate-content` Edge Function + translation storage migration | supabase | done | f99b0f5; `site_translations` (RLS via has_site_access, lokaal toegepast+gesmoked); function `translate-content` (DeepL + key-vrije fallback, cache op source_hash, locked skip); deno check clean |

## Run 2 queue (gestart 2026-07-23, na "go")

| # | slice | scope | status | evidence |
|---|-------|-------|--------|----------|
| S17 | `EdgeFunctionTranslationService` (invoke `translate-content`, app_errors-mapping) | console | done | 00aeb0f; +4 tests; analyze clean. Aanvulling 5f98d10: gratis provider-keten in de function — MyMemory keyless default (live geverifieerd nl→en/no), LibreTranslate self-hosted optie, DeepL alleen nog als opt-in |
| S18 | Persistentie: repository voor `site_translations`-hydratie + draft/publish naar `cms_documents` | console | done | 3c7b01e; veldmapping op echte site-JSON (cabin/main + page/home), autosave debounced, publish met versie-snapshots, sha256-hashes client=server; +7 tests (38 totaal groen) |
| S19 | Velddefinities + seed voor chalet/practical/area/contact | console | done | 8900523; kPageFields→echte document-JSON, content-card UI, +4 ARB-keys, publish/stale-scope site-breed; 42 tests groen |
| S20 | Deploy/verify | supabase | ready (deploy = user) | Lokaal: function serve → OPTIONS 200 + nette 401 ✓. Prd: `site_translations`-migratie via psql toegepast ✓. `SUPABASE_ACCESS_TOKEN` + `DEEPL_API_KEY` staan nu in hosthub-prd.env; Makefile `FUNCTION_SECRET_VARS` uitgebreid (e396d54). Ontgrendeld — uitvoeren via `make functions-deploy ENV=prd` + `make functions-secrets-set ENV=prd` (interactieve `prd`-bevestiging, dus door user). |
| S21 | Console-shell migreren naar `StyledSideMenu` (B1-adoptie) + editor live in navigatie | console | done | 63bda6d; /sites/:siteId → WebsiteEditorPage (legacy JSON-editor → /sites/:siteId/documents), settings/team-shortcuts in topbar; rail = StyledSideMenu-compositie (hardcoded strings → ARB); 47 tests groen |
| S22 | `StyledBrowserFrame` → app-lokaal (`SitePreviewFrame`) + `StyledSplitView` → `StyledWebPageScaffold`-consolidatie | beide | done | sw@3bf18be+ca6a638, console@4934032; scaffold kreeg showHeader/paneGap/fixed-left/right-fills (4 lib-tests); goldens geregenereerd |

## Run 3 queue — conformance-review vs hosthub-design (gestart 2026-07-23)

Review + fix per slice tegen CONFORMANCE.md/README.md/screenshots; P0–P2 fixen,
gemotiveerd uitstellen mag alleen met reden in de evidence-kolom.

| # | slice | scope | status | evidence |
|---|-------|-------|--------|----------|
| C1 | Sidebar/rail: items+iconen, compact 96px + pin, hover-expand, switchers (Property/Source language), footer | console (+lib) | done | f47a9a8. Bevindingen gefixt: (1) compact/pin ontbrak → SidebarModeCubit + desktop-shell met Stack/hover-flyout (diplora _DesktopShell-patroon), toggle uit de lib via onModeChanged; (2) nav-iconen conform design (language/calendar_today/show_chart/sell_outlined); (3) Source-language switcher ontbrak → SiteContextCubit (property→site-resolutie) + sites.default_locale-update + ice switcher-velden via StyledMenuOverlay (diplora-recept); (4) versie-footer toegevoegd; (5) editor brontaal/locales nu uit site-row i.p.v. hardcoded seed + live herladen bij switch. +2 tests; SDK-cache web-mismatch gerepareerd (flutter precache --web) |
| C2 | Editor bronmodus | console | done | c64ffaf. Bevindingen gefixt: highlights niet-repeatable zonder grip (design: StyledReorderableList) → drag-reorder via lib-widget, verplaatst per rij in álle talen incl. locked-status; dode 'Add highlight'-knop → voegt echt een rij toe (repo laadt dynamisch aantal rijen); fieldLabel generiek voor highlights.N. Rest (topbar/tabs/banners/save bar) al conform per bestaande tests |
| C3 | Editor vertaalmodus | console | done | Review: geen P0–P2-afwijkingen. Editing-chip (groen), editable velden, Locked/Auto-chips, source-ref+NL-tag, Reset to AI, coverage-meter (StyledMeter), stale/fresh-toolbar en shared-photos-note allemaal aanwezig én door widget-tests gedekt |
| C4 | Preview | console | done | Review: geen P0–P2-afwijkingen. Status-pill, web/mobiel-toggle, locale-switcher met AI-badges + stale-dots (StyledSegment.statusDotColor), taalbinding, warning-ribbon mét 'Preview latest'-actie (spinner) en groene draft-ribbon — conform en getest |
| C5 | Publish-modal | console | done | Review: geen P0–P2-afwijkingen. Taalbadge-rijen (NL/EN/NO), bron=Ready / targets=Re-translate, Cancel + 'Publish N languages', async publish in de dialog; confirm cleart dirty+stale, cancel laat staat intact — alles getest |
| C6 | Adherence + gedragsmodel | beide | done | Adherence-tests groen (geen hex buiten statustokens, geen chrome buiten StyledWidgets, strings via ARB); state machine volledig door cubit-tests gedekt; nieuwe C1/C2-code lib-first (StyledSideMenu/StyledMenuOverlay/StyledReorderableList) en zonder hardcoded values |

| C7 | Na-pass met vers geladen tk-* skills over C1/C2-diffs | console | done | 2 bevindingen gefixt: (P1) geen gebruikersfeedback bij save/translate/publish-fouten → BlocListener + showStyledToast per foutcode (+5 ARB-keys en/nl, conform TRANSLATION.md "degrade gracefully with a toast"); (P2) SiteContextCubit zonder DomainError-state en zonder fetch-sequencing → DomainError.from + _fetchSeq-guard (tk-feature-patroon). Analyze clean, 46 tests groen |

## Run 4 — resterende design-gaten + visuele verificatie (2026-07-24)

| # | slice | scope | status | evidence |
|---|-------|-------|--------|----------|
| D1 | Onderbroken polish-pass gestabiliseerd | beide | done | dac5dd8 (routervolgorde-fix), 582a06f (brontaal rail→Settings), 4ba8d1d (StyledToolbarButton-sweep), 39da365 (preview-infra); lib sw@54833a4 = v0.9.1 (menu-anchor isSelected, +3 tests, getagd+gepusht) |
| D2 | Profielmodal §4c: Preferences (interfacetaal + compact zijmenu) | console | done | ef8b757; StyledSelectionTile.dropdown via UserSettingsCubit (sync naar LanguageCubit verplaatst naar SessionBlocListeners), StyledSwitchTile→SidebarModeCubit (desktop-gated met page-context MediaQuery); dispose-na-await-bug in de modal gefixt; +4 widget-tests |
| D3 | Settings §5: sitegegevens, dynamische websitetalen, brontaal-switch | console+supabase | done | bfbeda0; migratie 20260724130000 (sites.source_locale_follows_ui, lokaal toegepast); SiteContextCubit: add/removeLanguage (bron niet verwijderbaar, confirm-dialog), setSourceFollowsUi, setSiteName, setBookingUrl (write-through alle site_config-docs), primaryDomain; catalogus nl..fi; autosave, geen actieknoppen; +13 tests |
| D4 | Ontkoppeling interfacetaal ↔ brontaal (expliciete gebruikersregel) | console | done | 93aecfa; interfacetaal wisselen raakt de brontaal NOOIT — follow-switch is een one-shot uitlijning bij inschakelen; followInterfaceLanguage verwijderd; regressietest bewijst dat een taalwissel de site-context niet bereikt |
| D5 | Visuele diff met referentiescreenshots (release-build, browser-pane) | console | done | Release-build (dev-env, lokale Supabase) via console-static:43112. Geverifieerd conform: mode A (banner/chip/tabs/save bar), mode B (Editing-pill, coverage, Auto-chips, srcref, draft-ribbon), compacte 96px-rail + hover-flyout + pin, mobiele preview (bezel/statusbar), publish-modal (Klaar/Opnieuw vertalen/3 talen), Settings §5, profielmodal §4c. Gevonden+gefixt: taal-tag onleesbaar (2859c21 — StyledContainer default-padding + onSurfaceVariant te licht) |

| D6 | Variant (a) brontaal + Settings-visuele review (Taco) | console+supabase | done | cc3c561. Follow-toggle → eenmalige "Overnemen van interfacetaal"-actie (disabled bij no-op); brontaal-dropdown altijd zichtbaar; bevestigingsdialoog bij elke brontaalwissel (herbaseert vertalingen); kolom+migratie source_locale_follows_ui verwijderd (was alleen lokaal). Visueel: StyledChip-taaltags, gedimd "Niet ingesteld"+chevron-regel, DS uppercase micro-label-koppen, inset-groepen; disabled-tile zonder donker theme-vlak. Besluiten vastgelegd in design_handoff_hosthub_cms/IMPLEMENTATION_NOTES.md |

| D7 | Generieke theme-pass + ConsolePageScaffold verwijderd | beide | done | sw@8e6a78f = v0.9.2 (StyledWebPageScaffoldThemeData: pane-surfaces/pageBackground/pagePadding via preset; primaryAction/isLoading/PopScope/per-pane decorate; StyledSectionThemeData.borderColorDark; +12 lib-tests, 681 groen). Console e503c71: adapter weg, 14 pagina's direct op de lib-scaffold; preset = witte bordered panes op ice, secties = witte tile-groepen zonder interne verticale padding, headers 13/w600 donkerblauw zonder caps (Taco's keuze), tiles 44px, onSurfaceVariant/outline leesbaar; editor: witte .editcol + header-in-card 18px; goldens geregenereerd; 68 app-tests groen; visueel geverifieerd (Reserveringen/Settings/editor) |

| D8 | Rail per design + scroll-through (review Taco) | beide | done | sw@cec100c = v0.9.3 (StyledSideMenuSwitcher: ice-veld met uppercase label, +4 tests); console 2f53597: railbreedte clamp 300–340, Property-switcher via lib-widget (ACCOMMODATIE-label), Settings als nav-item boven, settings-pagina's op intrinsicPaneHeight (padding als scroll-inset — kaart scrolt door de schermrand, gap alleen bij max scroll); visueel geverifieerd |

| D9 | Upgrade Flutter 3.44.8 + nieuwste dependencies (Taco: "alles het nieuwste") | beide | done | Project gepind op 3.44.8 (.fvmrc + .fvm/flutter_sdk-symlink + .vscode dart.flutterSdkPath; fvm global blijft bewust 3.35.7 voor Diplora). pub upgrade + package_info_plus ^10.2.1 (major); toastification nu 3.7.1 (mixed-summary-issue definitief weg). Bewust behouden: `onReorder`-deprecation in lib+console (vervanger `onReorderItem` bestaat niet in 3.35.7 waar Diplora op zit). Lib: 685 tests groen onder 3.44.8, geen lockfile-diff. Console: 68 tests groen (goldens ongewijzigd!), analyze 2 bekende infos, release-build + browser-smoke ok (login, Instellingen-secties, geen console-errors) |


## Run 5 — drie-schermen-handoff afmaken (2026-07-25, opdracht "alles na elkaar")

Slices uit `design_handoff_hosthub_cms/IMPLEMENTATION_PLAN.md` die na run 4 open stonden.
Rubric-fasen 0–7 per slice; analyze = `fvm flutter analyze` (baseline 2 bekende infos),
test = `fvm flutter test <pad>`. **Let op:** de repo draait op Flutter 3.44.8 via fvm — de
kale `flutter` op PATH is nog 3.35.7 en die mix bouwt test-assets met de verkeerde engine.

| # | slice | scope | status | evidence |
|---|-------|-------|--------|----------|
| E1 | Lodgify-payloadparsing naar het domein | console | done | 927 regels uit revenue + 400 uit reservations → `revenue/domain/booking_revenue.dart` (getypeerde `BookingRevenueLineKind`, labels blijven presentatie). Pagina's: reservations 3064→2206, revenue 2455→1350. Unie van beide lezers, dus reservations kent nu ook de `cleaningCost`-paden en revenue de huur/korting/borg/extra-regels. +15 tests (`booking_revenue_test.dart`), 179 groen, analyze clean |
| E2 | Website-editor §11-gaten | console | done | Vijf commits: `60328c2` (locale-switcher naar de editorheader, geen AI-badges, previewheader alleen Live preview + Web/Mobiel, Team/gear/breadcrumb-segment weg), `aa04050` (coverage-meter → `N of M fields yours`, chip ís de schakelaar met tooltip, één in-sessie undo, banners weg), `fbbffb4` (tweeregelige eerlijke statusregel + Saved/Saving-indicator, publicatiedialoog "Wat gaat live" met checkbox per taal + Nagekeken/Concept/Overgeslagen + live meetellende knoplabel), `8f137a5` (lazy vertalen bij openen van een taal + één spacing-token tussen velden), `09f50a3` (wit invoervlak i.p.v. leesgrijs). Lib: `c35e572` (`actionTextListenable`), `formFields.input.backgroundColorDark`. 51 editor-tests groen |
| E3 | Visuele verificatie van de drie schermen tegen `HostHub CMS.dc.html` | console | blocked (login) | Release-build met `hosthub-dev.env` gebouwd en geserveerd op `localhost:43112` (browser-pane staat open, viewport 1360x880). Loginpagina rendert, geen console-errors. Verder komen vraagt een ingelogde sessie — wachtwoorden invullen doe ik niet. Zodra Taco inlogt: Reserveringen (lijst + tijdlijn, beide dichtheden), Omzet (jaar, met grafiek/kanaalsplitsing/totaalrij) en Prijzen (breed + smal) naast de mock leggen |

## Run 6 — multi-property handoff (2026-07-26, opdracht "stop na elke stap voor review")

Increment op de CMS-handoff: `hosthub-design/design_handoff_hosthub_multiproperty/`
(README + CONFORMANCE). Zes stappen in vaste volgorde, elk met review-stop.
De bare `flutter` op PATH is inmiddels óók 3.44.8 (gelijk aan fvm) — de waarschuwing
onder run 5 over een engine-mix geldt niet meer.

| # | slice | scope | status | evidence |
|---|-------|-------|--------|----------|
| M1 | Domein: `booking.propertyId`, één `effectiveChannelSettings(propertyId)`, sparse overrides | console | done | zie hieronder |
| M2 | Aggregatie: gefilterde set, kosten per eigen property, bezetting ÷ `dagen × selectie` | console | done | zie M2-bewijs |
| M3 | Routing + sidebar-boom (expansie uit de route, deeplinks) | console | todo | |
| M4 | Property-filter op Boekingen + Omzet (per pagina per user, nooit leeg) | console | todo | |
| M5 | Single-property-collapse (§5) als configuratie, geen fork | console | todo | |
| M6 | Railgeometrie (§7) incl. no-movement-eis | console (+lib) | todo | |

**M1-bewijs.** Twee tiers, één merge:
- `properties/domain/booking_channel.dart` — `BookingChannel` + `bookingChannelForSource`: de
  source-string wordt nu op één plek naar een kanaal herleid.
- `account_channel_defaults.dart` — accounttier, elk veld resolved.
  `fromCommissionPercentages` overbrugt `admin_settings` (dat alleen commissie per kanaal heeft).
- `channel_overrides.dart` — propertytier, **sparse**: `null` = volgt account, en `toMap()` laat
  niet-overschreven velden weg. `overriddenFieldCount` is het getal achter de Prijzen-badge.
- `channel_settings_resolver.dart` — `effectiveChannelSettings(int propertyId)` voor *elke*
  property; er is geen tweede merge-site meer om op te greppen.
- `channel_settings.dart` — `ChannelConfig` is nu het resolved type en `settle()` gebruikt zijn
  eigen commissie; de ingespoten `commissionPercentage` (de weg waarlangs een portfolio-view alles
  met één property's tarief kon kosten) is weg. `ChannelSettings` bestaat niet meer.
- `booking.propertyId` verplicht (`Reservation`), en `fetchReservations` neemt `propertyId` (onze
  id) + `channelPropertyId` (Lodgify) apart; `LodgifyCalendarDto.toDomain(propertyId:)` tagt.
  `ReservationsState` draagt beide.
- `booking_revenue.dart`-helpers nemen `EffectiveChannelSettings` i.p.v. `PropertySummary` +
  `AdminSettings`; Omzet resolvet nu **per boeking** op `entry.propertyId`.
- Prijzen-pagina schrijft de sparse tier (leeg veld = volgt account) en de payout-preview settelt
  `override.applyTo(accountDefault)`.
- Kosttype-labels uit het domein naar ARB (`pricingCostTypePer*`, nl+en) — stonden hardcoded in
  Nederlands in `channel_settings.dart`.
- Tests: `channel_settings_resolver_test.dart` (19 checks: merge per property, propagatie van een
  accountwijziging naar niet-overschreven velden, expliciete nul ≠ afwezig, sparse round-trip,
  legacy-rij, override-counts) + `lodgify_calendar_dto_test.dart` (3× id-tagging).
  `channel_settlement_test.dart` en `payout_preview_test.dart` bijgewerkt. 228 tests groen,
  `flutter analyze` op de 2 bekende infos.

**M2-bewijs.** Nieuw `features/portfolio/domain/`:
- `property_selection.dart` — `PropertySelection` draagt *beschikbaar* én *gekozen*: nooit leeg
  (laatste uitvinken = no-op), default alles, `clampedTo` laat een verwijderde property vallen en
  laat een nieuwe meelopen als alles geselecteerd was.
- `property_ref.dart` — `PropertyRef` koppelt onze id aan de kanaal-id, zodat een portfolio-fetch
  een loop is en geen twee parallelle lijsten.
- `portfolio_aggregation.dart` — de drie regels: `bookingsForSelection`,
  `channelSettingsForBooking` (resolvet op `booking.propertyId`), `occupiedNightsInPeriod` +
  `occupancyRate/occupancyPercentage(occupiedNights, daysInPeriod, selectedPropertyCount)`.

`ReservationsCubit.loadReservations` neemt nu `List<PropertyRef>`: één request per property
(sync is per property), samengevoegd in de volgorde van de lijst. Een property die faalt komt in
`stalePropertyIds` en de rest laadt gewoon — pas als *alle* properties falen is het een error
(§9: één kapotte sync mag het portfolio niet blanken). `ReservationsState.properties` zegt welke
properties de entries dekken; daar komt de bezettingsdeler uit, dus de gesommeerde en de gedeelde
set kunnen niet uit elkaar lopen.

**Twee off-by-one-bugs onderweg gefixt** (beide lieten bezetting boven 100% uitkomen):
Boekingen telde `end - start + 1`, dus de vertrekdag als bezette nacht — twee opeenvolgende
boekingen rapporteerden 32 nachten in juli. Omzet deelde de *ongeclipte* nachten van alle
boekingen door de periodelengte, dus een boeking over de periodegrens bracht al zijn nachten mee.
Beide gaan nu door `occupiedNightsInPeriod` (half-open, geclipt).

Tests: `portfolio_aggregation_test.dart` (19 checks, per regel het benoemde falen, incl. "2 van 4 =
som van die twee alleen", "eenmaal resolven voor het scherm rekent 3% i.p.v. 3%+20%", "4 properties
≈ ¼ van de naïeve waarde"), `property_selection_test.dart` (18), `reservations_cubit_test.dart`
(9, incl. partial failure). `occupancy_test.dart` herschreven: testte zijn eigen kopie van de
formule (en dus niet de +1-bug in de pagina), test nu de echte functie. 271 tests groen,
`flutter analyze` op de 2 bekende infos.

**Bewust nog niet in M2:** er is geen UI om de selectie te veranderen — dat is M4. Beide
portfolio-schermen laden vandaag één property en de selectie dekt precies die, dus
`selectedPropertyCount` is 1 en niets verschuift; zodra M4 meerdere `PropertyRef`s meegeeft
levert dezelfde expressie N. Nachttarieven en de valuta-write-back lopen alleen bij
`state.singleProperty` — een gemengd portfolio heeft geen enkele tariefkalender of valuta.

**Open beslissing (ongewijzigd):** de accounttier heeft nog geen eigen opslag — `admin_settings` is
platformbreed en kent alleen commissie per kanaal, dus markup en kosten defaulten account-wijd naar
nul. Zodra Accountinstellingen (§4) die velden echt moet bewerken is een per-account rij nodig;
`AccountChannelDefaults.fromMap/toMap` heeft daar de vorm al voor. Niet in M1 gebouwd omdat M1
"geen UI" is.

## next_lens
RUN 6 loopt: M1 + M2 done, wacht op review. Daarna M3 (routing + sidebar-boom).
RUN 5: E1 + E2 done. E3 (visuele verificatie) is user-gated — vraagt een ingelogde sessie.

**Nog open uit §11, met reden:** de kostenbeheersing (hash-cache, één request per taal, locked
overslaan, alleen ingeschakelde talen) zit al in de Edge Function en `translateNow`; een
`autoTranslate`-instelling is bewust niet gebouwd (§11a: "a setting is a worse answer than a model
that is right by default"). De `DEBUG`-ribbon is Flutters eigen `debugShowCheckedModeBanner` (alleen
debug-builds) en de oranje `Preview mode`-balk zit in de site zelf, niet in de console.

**Let op voor de volgende sessie:** tijdens run 5 werkte een tweede sessie in dezelfde repo aan de
tabelrand (`tables.plain.borderWidth`) en de rail; hun werk stond ongecommit in de tree. Twee
chrome-goldens en `shell_responsive_test` faalden daardoor aan het eind van E2 — dat is hun werk,
niet dat van E1/E2.

RUN 4 KLAAR (D1–D9 done, 2026-07-24). Alle CONFORMANCE-secties gedekt; geen openstaande
prd-migratie meer (follow-kolom geschrapt). Open (user-gated): console-deploy naar prd. Bewuste
afwijkingen gedocumenteerd in design_handoff_hosthub_cms/IMPLEMENTATION_NOTES.md.

## Content / state-machine reference (from the prototype)
- Property: **Trysil Panorama**, source lang `nl`, locales `[nl, en, no]`.
- Seed content per language (Home page): `title` (hero headline), `sub` (subtitle),
  `h1`/`h2` (two highlights). NL is source; EN/NO derived.
- State machine (per field,language): `auto` (follows source) ⇄ `locked` (owner-edited).
  Source edit → dependent `auto` fields `stale`. Publish → re-translate all `auto`, clear stale,
  all live. "Preview translation" = optional early refresh of `auto` fields.

## Ledger (resolved findings / completed slices)
_(none yet)_
