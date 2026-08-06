# Daily release-readiness state — HostHub CMS website editor

Source of truth for the `/build-loop` implementing the design handoff at
`hosthub-design/design_handoff_hosthub_cms/`. Rubric: `../review-prompts/cms-website-editor-review.md`.

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
| S20 | Deploy/verify | supabase | done | Lokaal: function serve → OPTIONS 200 + nette 401 ✓. Prd: `site_translations`-migratie via psql toegepast ✓. `SUPABASE_ACCESS_TOKEN` + `DEEPL_API_KEY` staan nu in hosthub-prd.env; Makefile `FUNCTION_SECRET_VARS` uitgebreid (e396d54). **Uitgevoerd 2026-08-03:** `make functions-deploy ENV=prd` + `make functions-secrets-set ENV=prd` gedraaid; de edge functions (incl. `manage_site_domain`) staan op prd met hun secrets. |
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
| M3 | Routing + sidebar-boom (expansie uit de route, deeplinks) | console (+lib) | done | zie M3-bewijs |
| M4 | Property-filter op Boekingen + Omzet (per pagina per user, nooit leeg) | console (+lib+supabase) | done | zie M4-bewijs |
| M5 | Single-property-collapse (§5) als configuratie, geen fork | console | done | zie M5-bewijs |
| M6 | Railgeometrie (§7) incl. no-movement-eis | console (+lib) | done | zie M6-bewijs |

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

**M3-bewijs.** Lib eerst (`styled_widgets` 01b846f, 3205ccb, 97e8def): `StyledSideMenu` kan nu een
boom zijn — `StyledNavGroup` (label, count-pil, label als eigen bestemming), `StyledNavEntry`
sealed met `StyledNavItem` (+`badge`) en `StyledNavBranch` (leading-chip, children, caret),
`StyledSideMenuTileDepth` voor de drie rijhoogtes, `StyledSideMenuGroupLabel` en
`StyledSideMenuBadge`. **Expansie zit niet in de widget**: `StyledNavBranch.expanded` komt van de
host, zodat het menu nooit uit de pas kan lopen met waar de app is. Compact: labels faden maar
houden hun box, children blijven icoonrijen, count-pil houdt zijn hoogte en geeft zijn breedte op
(weglaten maakte de labelrij korter dan de pil → alles eronder schoof omhoog; breedte houden liep
buiten de rail). +15 lib-tests, 852 groen.

Console:
- `app/navigation/console_route.dart` — `ConsoleRoute.parse/path/clampedTo`. Dit is de plek waar
  "expansie is afgeleid van de route" waar wordt: één `propertyId`-veld, dus er kan er nooit meer
  dan één open zijn. `clampedTo` vangt §6: een verwijderde property valt terug op de eerste (zelfde
  sectie), een leeg account op de lijst.
- Routes: `/bookings`, `/revenue`, `/properties`, `/properties/:id`(→overview),
  `/properties/:id/{overview,website,pricing,settings}`, `/account`. `/reservations` en `/settings`
  redirecten, dus bestaande links en bookmarks landen nog. Homepad is nu `/bookings`.
- `console_nav_tree.dart` — PORTFOLIO / PROPERTIES [n] / ACCOUNT, chip per property, badge op
  Prijzen (afwezig bij nul), groepslabel linkt naar `/properties`. Property-switcher uit de rail
  verwijderd: de boom *is* de scope-selector.
- `property_abbreviation.dart` — 2-letter chip, per account samen toegekend zodat er nooit twee
  hetzelfde zijn (het is een identifier in de UI).
- `PropertySectionPage` — de vier property-schermen achter de route; geeft de id expliciet door aan
  Overzicht en Prijzen (die lazen `currentProperty`), en doet de clamp.
- `PropertiesPage` — de lijst uit §2 (chip, naam, boekingen, Volgt account / n eigen waarden,
  chevron) + de introtekst uit §8. 17 nieuwe ARB-keys (nl+en), incl. de designcopy `Boekingen`,
  `Overzicht`, `Site-instellingen`, `Accountinstellingen`.
- Tests: `console_route_test.dart` (20), `nav_tree_test.dart` (11: deeplink `/properties/3/pricing`
  rendert Geilo uitgeklapt met Prijzen actief, precies één uitgeklapt, Boekingen/Omzet blijven
  zichtbaar, niets disabled, badge-count, distincte chips), `property_abbreviation_test.dart` (14).
  Shell-harness uitgebreid (route + properties + ServerSettings), rail-goldens hergenereerd.
  313 tests groen, analyze op de 2 bekende infos.

**M4-bewijs.** Lib: `StyledToolbarButton`/`StyledIconButton` kunnen zichzelf benoemen
(`label` + `trailingIconData`); met een label meet de knop zich naar zijn inhoud i.p.v. vierkant te
blijven — dezelfde control, breder (sw@6cadc3d, +7 tests, 859 groen).

**Beslissing (START_HERE vraagt erom): de selectie staat server-side**, in
`user_settings.portfolio_scope` (jsonb, migratie `20260726150000`, lokaal toegepast en gecontroleerd:
kolom is `jsonb`). Dus "per user" letterlijk — hij volgt de gebruiker, niet het apparaat — naast
`export_columns`, dat exact dezelfde soort viewvoorkeur is. Vorm: `{"bookings":[1,3],"revenue":[...]}`;
een afwezige pagina = alle properties, dus de default kost geen write. `UserSettingsCubit` blijft de
enige schrijver van die rij (`changePortfolioScope`, stil — een filter is geen toast waard).

- `portfolio/domain/portfolio_page.dart` — `PortfolioPage` + `propertySelectionFor` /
  `storedScopeWith`: leest de bewaarde keuze, clamped op de properties die nu bestaan, en valt op
  alles terug als er niets van overblijft.
- `portfolio/presentation/widgets/property_filter_button.dart` — de kop-control. Het label zégt de
  scope (`Alle properties` / de propertynaam / `2 van 4 properties`) i.p.v. "Filter", zodat je de
  scope kunt lézen zonder het menu te openen. Laatste uitvinken is een no-op.
- **Beide portfolio-schermen laden nu het hele account** (`portfolioPropertyRefs`) en het filter
  versmalt een set die er al is: toggelen kost geen request en dus ook geen 429 bij Lodgify.
  Dit is ook wat het prototype doet (`PORTFOLIO_BOOKINGS` → `bookings`).
- Koppen kloppen nu met het design: crumb `Portfolio`, titel `Boekingen` / `Omzet` — een
  portfolio-scherm noemt geen enkele property meer in zijn titel.
- §3.4: property-kolom in beide tabellen, alleen bij >1 geselecteerd. Boekingen chip + naam (direct
  na de kanaal-icon, zoals het design), Omzet alleen de chip (dichte tabel). Niet handmatig te
  verbergen: het is scope-informatie, geen boekingskolom.
- Eén `PropertyChip` in `core/widgets` voor rail, lijst, filtermenu en tabelcellen — hij is een
  identifier, dus hij moet er overal hetzelfde uitzien.
- Nachttarieven/valuta-write-back blijven aan één property hangen (`state.singleProperty`): een
  gemengd portfolio heeft geen enkele tariefkalender.
- Tests: `portfolio_page_scope_test.dart` (13: per pagina, nooit leeg, clamp, round-trip, andere
  pagina blijft ongemoeid), `property_filter_button_test.dart` (7: de drie labelvormen, checkstate,
  verbreden, alles selecteren, laatste uitvinken = no-op). 334 tests groen, analyze op de 2 bekende
  infos. Rail-goldens hergenereerd (chip is nu de gedeelde widget).

**M5-bewijs.** `portfolio/domain/portfolio_chrome.dart` — `PortfolioChrome` ís de tabel uit §5,
regel voor regel: `isSingleProperty`, `showsPropertyFilter`, `showsPropertyNode`,
`showsPropertyCount`, `showsPropertiesList`. Één plek die zegt wát er inklapt, gelezen door de rail,
beide portfolio-schermen en de propertylijst — zodat ze niet los van elkaar kunnen beslissen hoe een
account met één property eruitziet. De count is die van het *account*, niet van de selectie: vier
properties gefilterd naar één houdt zijn filter.

Wat er verandert bij één property:
- Eerste groepslabel `Verhuur` i.p.v. `Portfolio` — óók de crumb van Boekingen, Omzet en de
  propertylijst (het prototype gebruikt daar hetzelfde `ptGroupLabel`).
- Tweede groepslabel = de propertynaam; geen count-pil, geen link naar de lijst.
- Geen property-node: geen chip-rij, geen caret. De vier secties staan **plat op topniveau en zijn
  altijd zichtbaar** (prototype: `expanded: isSingle || …`), op dezelfde as als Boekingen.
- Geen property-filter in de kop van Boekingen/Omzet.
- Geen property-kolom (volgde al uit `selection.isSingle`).
- `/properties` blijft als route bestaan, maar de nav leidt er niet meer naartoe.

**Geen fork:** één `buildConsoleNavGroups`, dezelfde `StyledNavItem`s met dezelfde handlers en
dezelfde routes; alleen wáár ze gerenderd worden verschilt. `_propertySections` is de gedeelde lijst
die zowel onder een branch als plat gebruikt wordt. Een test vergelijkt de widgettypes van beide
vormen en eist dat ze gelijk zijn.

Tests: `portfolio_chrome_test.dart` (8, §5 regel voor regel), `single_property_nav_test.dart` (15:
labels, geen node/chip/caret, platte secties op de Boekingen-as, altijd zichtbaar, routes en badge
intact, niets disabled, geen fork, en een tweede property brengt alles terug). 357 tests groen,
analyze op de 2 bekende infos. Rail-goldens hergenereerd — de harness rendert één property, dus die
goldens *zijn* nu het visuele bewijs van de ingeklapte vorm (structuur nagekeken: 7-letter label,
2 rijen, naamlabel, 4 platte rijen zonder indent, Account-groep).

**M6-bewijs.** Eerst de referentie **gemeten** i.p.v. de spec overgetypt: prototype in de
browser-pane, `.sb2` met en zonder `.compact`, alle rijen en labels uitgelezen. Uitkomst: rail
72 / menu 284, `.sb2-nav` padding `6px 12px`, icoonbox 44 → **icooncentrum 34px** in *beide* standen,
`.nav2` 48, `.nav3` 42 (**óók collapsed 42, niet 46**), `.nav4` 36 met `margin-left:16` en `ib3` 32,
`.navtree.flat .nav4` 44 met `ib3` 44 en geen indent, `.navgrp` 32 hoog met padding `12px 22px 4px`,
`600 10px`, ls .7, uppercase, `#7f97ae`; count-pil 11.5/600; badge 10/700; hover-expand met
`transition-delay .35s`.

Console-tokens nu letterlijk §7 (`side_menu.dart`): `kSidebarIconBox` 48 → **44**,
`kSidebarSideInset` **12** (expliciet, niet meer afgeleid uit de railbreedte), rijhoogtes 48/42/36,
sub-item indent 16 + icoonbox 32, platte sub-items 44/44 bij één property,
`kSidebarHoverIntentDelay` 350ms. Chip 26×26 radius 7 expliciet (`kPropertyChipSize/Radius`), met
meegeschaalde radius op de kleinere tabelchips.

Lib (sw@160d8be): groepslabels worden door het menu **uppercase** gezet (micro-label is een
treatment; de host levert zijn eigen vertalingen in natuurlijke case, en `uppercaseLabel: false` voor
een eigennaam zoals de propertynaam bij één property). Hover-intent-delay was een private constante
en is nu een parameter — het is een designbesluit over hoe lang een paneel wacht voordat het over je
werk schuift.

**De no-movement-eis als regressietest** (`rail_geometry_test.dart`, 12 checks): meet elk icoon, elke
chip en het logo in beide standen en eist identieke rects — bij vier properties met één open, na
heen-en-terug schakelen, en in het single-property-account; plus groepslabels houden hun hoogte, geen
rij komt buiten de 72px, de drie rijhoogtes, chipmaat/radius, de gevulde chip van de open property,
en de 34px-as.

**Die test vond direct een echte bug:** het merkteken in de header centreerde zichzelf over de
compacte rail (36) i.p.v. in de icoonkolom (34), dus het schoof 2px bij inklappen. Dat viel niet op
zolang de inset de helft van de restbreedte was ((72-44)/2 = 14 → ook 36); §7's inset van 12 maakte
het zichtbaar. Nu gebruikt het logo dezelfde icoonkolom en inset als de navrijen, in beide standen.

**Twee bewuste afwijkingen, zelf besloten (memory: bij conflict zelf kiezen):**
1. §7 zegt "property row 42 px (46 px collapsed)", maar diezelfde paragraaf stelt "**nothing may
   move**" als hard requirement — en een rij die 4px hoger wordt schuift alles eronder. De
   referentie zelf houdt 42 in beide standen (gemeten). Wij ook.
2. De oude test eiste "icoon gecentreerd in de 72px rail" (36). §7 noemt 34 twee keer expliciet
   (12 + 44/2), dus de as ligt 2px links van het railmidden. Test bijgewerkt met die reden erin.

**Niet aangeraakt:** rijafstand (design `gap:4`, lib `vertical:4`-padding → 8) en icoongrootte
(design 24/18, console 22/18). §7 specificeert de icoon*box* en de rijhoogtes, niet deze twee; ze
raken de no-movement-eis niet. 369 tests groen, analyze op de 2 bekende infos, rail-goldens
hergenereerd en visueel nagekeken (72px, alles op één as, niets buiten de rail).

**Nog open in M4-gebied:** de nachttarieven op de tijdlijn zijn per property; bij meerdere
geselecteerde properties toont de tijdlijn nog één kalender. Het design zegt niets over de tijdlijn
bij N properties — bewust niet zelf verzonnen.

**Afwijking, zelf besloten:** de route draagt de **numerieke property-id** (`/properties/3/pricing`),
niet de slug uit het prototype (`/properties/geilo/pricing`). Een afgeleide slug breekt stil bij een
naamswijziging — dan 404't een bewaarde link — en er is geen slug-kolom. De eis die eronder zit
(elke property-sectie is deeplinkbaar en de rail leidt zichzelf eruit af) is volledig gehaald.

**Nog open in M3-gebied:** Accountinstellingen wijst naar de bestaande accountpagina; de
account-defaults-editor + propertylijst met override-counts uit §4b is eigen werk en zat niet in de
zes stappen. Visuele verificatie in de app vraagt een ingelogde sessie (zelfde blokkade als E3).

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

| M7 | CONFORMANCE-pass over M1–M6 (review + fix, geen nieuwe scope) | console | done | zie M7-bewijs |

**M7-bewijs.** Checklist van `design_handoff_hosthub_multiproperty/CONFORMANCE.md` regel voor regel
nagelopen i.p.v. aangenomen. **Drie echte bugs gevonden en gefixt**, alle drie in de wiring die de
unit-tests niet raakten:

1. **P0 — de resolver dekte één property.** `_channelSettingsResolver(property)` op Omzet bouwde
   `overridesByPropertyId` uit *de geselecteerde* property. De per-boeking-lookup was dus correct maar
   kon alleen vinden wat hij meekreeg: property 2–4 werden met de accountdefaults gekost i.p.v. met
   hun eigen overrides. Exact het falen uit §3.2, één laag lager. Gefixt met
   `ChannelSettingsResolver.forProperties` + `channelOverridesOf`, en alle drie de bouwplekken (rail,
   propertylijst, Omzet) lopen nu door dezelfde factory. Regressietest erbij die precies dit
   documenteert ("built from one property, it answers defaults for the rest").
2. **P1 — valuta-write-back naar de verkeerde rij.** Beide schermen schreven `rateCurrency` naar
   `currentProperty.id`, terwijl de tarieven voor `state.singleProperty` geladen zijn. Bij een ander
   geselecteerde property herlabelde dat het geld van een andere cabin. Nu naar de property waar de
   tarieven vandaan komen.
3. **P1 — tijdlijn-tariefLabels uit het hele portfolio.** De dag-labels werden uit `state.entries`
   gebouwd; sinds M4 is dat het hele account, dus een dag kon het tarief van een *andere* property
   tonen — een getal dat autoritair oogt en van een ander huis is. Nu alleen bij één property in
   beeld, en gefilterd op die property.

Verder gecontroleerd en in orde: export/PDF/CSV krijgen `bookings` (de gefilterde set); grafiek,
kanaalsplitsing, totaalrij en de detailmodal ook; de overgebleven `state.entries`-reads zijn
laadchecks ("is er al iets binnen"), wat juist is — een filter dat alles wegfiltert hoort de
lege-periode-melding te geven, geen spinner. Extra test toegevoegd voor de CONFORMANCE-regel "2 van 4
= som van die twee alleen" in **geld** (die had ik alleen voor nachten en per boeking).
374 tests groen, analyze op de 2 bekende infos.

**prd-migratie toegepast (2026-07-26).** `20260726150000_add_user_settings_portfolio_scope.sql` staat
op prd. Aanpak en waarom:
- **Niet** via `make apply-migrations ENV=prd`: die target replayt *alle* migraties, inclusief de
  baseline (de remote-variant heeft géén baseline-skip zoals de lokale). Met `ON_ERROR_STOP=1` zou hij
  op de baseline afbreken — en in het slechtste geval iets anders doen. Alleen dit ene bestand via
  `psql` toegepast, zoals eerder bij `site_translations`.
- `SUPABASE_DB_URL` staat in `hosthub-prd-server.env` (server-secret), niet in `hosthub-prd.env`.
- Vóóraf read-only gecontroleerd: prd had 0 `portfolio_scope`-kolommen, 1 `user_settings`-rij en
  **1 property**. (Prd is dus het single-property-geval uit §5 — de ingeklapte rail is wat Trysil
  straks ziet.)
- Na de DDL `NOTIFY pgrst, 'reload schema'` — anders geeft de API PGRST202 op de nieuwe kolom
  (bekende gotcha). Geverifieerd: kolom is `jsonb`, nullable; REST-call op `select=portfolio_scope`
  geeft `http=200` (leeg door RLS met de anon-key, dus precies goed).
- `latest_prd.sql` opnieuw gedumpt; diff is exact deze kolom + comment.
- **De console-app zelf staat nog niet op prd.** De kolom is additief en nullable, en er staat geen
  `disallowUnrecognizedKeys` in het project, dus de nu draaiende console negeert het extra veld; zijn
  upsert stuurt de kolom niet mee en kan hem dus ook niet leegmaken. Geen risico voor de live app.

**Niet verifieerbaar zonder ingelogde sessie** (user-gated, zelfde blokkade als E3): de vier
behavioural checks die een echte klik vragen (klik-om-te-openen/dichtklappen, filter na reload,
verwijderde open property in de UI, nieuwe property in beide filtermenu's) — de logica erachter is
wel unit-getest.

## Run 7 — fase 2: volledig veldmodel + media (gestart 2026-07-27)

Handoff: `hosthub-design/design_handoff_hosthub_cms_fase2/` (README → STYLED_WIDGETS_MAPPING →
CONFORMANCE; prototype `HostHub CMS Fase 2.dc.html`). Voorwerk (mapping tegen prd-documenten,
B1–B15-lijst, migratieplan rij-ids) staat in `website-editor-fase2-plan.md` naast dit bestand —
opgeleverd vóór de bouw, zoals de brief eist. Fase-nummers = de brief; elke fase één commit.

**Coördinatie (2026-07-27, gecorrigeerd 21:45).** Mijn eerdere aanname — dat een tweede sessie
ongecommit werk in `website_editor/**` + `web/**` had liggen — was fout, en is door die sessie
rechtgezet: dat werk stond al op `main` (`4427f1b` live draft-preview + host-gebaseerde
site-resolutie, `e208628`/`7ab502c` load-failure), van een derde sessie. Niemand anders claimt
deze feature; F0 e.v. konden dus direct door en zijn niet op iets gewacht.
Wat die sessie wél deed: dit state-bestand en de build-loop-rubriek hernoemd
(`cms-website-editor-state.md` / `cms-website-editor-review.md`, `c5d950a`) en een
platformbrede `release-readiness-review.md` + eigen `daily-release-readiness-state.md`
toegevoegd. `.claude/build-loop.config.md` wijst naar de nieuwe paden — daar loopt deze
run op.

| # | slice | scope | status | evidence |
|---|-------|-------|--------|----------|
| F-pre | Voorwerk: mapping · B1–B15 · migratieplan | docs | done | `website-editor-fase2-plan.md`; mapping geverifieerd tegen prd (site d2744793), veldsleutels uit het prototype-SCHEMA; 2 vastgelegde afwijkingen (hero.badges zonder kaart; transport 5 vaste slots) |
| F0 | Padgebaseerde veldmapping (gedragsbehoudend; kWebsitePages → home/practical/area/gallery; Part D-schema vervangt kPageFields) | console | done | cea67db; sealed EditorRow (FieldRow/ListRow) + EditorCard-schema + één kaartrenderer; tabs home/practical/area/gallery (chalet/contact-velden → home); addRow/moveRow generiek per listKey; repo leidt lijstlengtes af via de padtabel; ARB wePageGallery/weCardContact in, chalet/contact uit; goldens geregenereerd; 415 tests groen, analyze clean. Bouwt voort op de padtabel uit 4427f1b (2e sessie) |
| F1 | Stabiele rij-ids + migratie (documenten, site_translations, highlights-fusie, web-lezers) + regressietest reorder→vertaling reist mee | console+supabase+web | done | a4bdf42; migratie `20260727150000_cms_stable_row_ids.sql` (deterministische md5-ids, idempotent, cross-locale identiek; highlights+highlightImages gefuseerd; field_key-hernoeming via de gemigreerde brontaal; dode `chalet.experience.*`-rijen weg; versie-snapshots bewust ongemoeid). Console: `RowId`-padsegmenten (lookup op id, write appendt een onbekende rij), `listOrder`/`draftListOrder` als eigen laag — `moveRow` wijzigt alléén de orde. Web: `normalize-content.ts` slikt beide vormen op de providergrens, dus de datamigratie is los deploybaar. **Geverifieerd tegen een volledige kopie van de echte prd-documenten in de lokale DB** (alle 13 lijsten van ids voorzien, idempotent, geen tekst verloren) + rij naar het eind gesleept: NL-tekst én EN-vertaling reisden mee. 418 tests groen, analyze clean, web typecheck+build clean. Lokale DB daarna teruggezet |
| F2 | Library: B3–B9 + `repeaters:`/`fieldLists:`-themegroepen, elk met test | styled_widgets | done | sw@5b7a023 = v0.10.0, gecorrigeerd door sw@207ebce = v0.10.1 (beide gepusht; SSH-key kwam uit de keychain via `ssh-add --apple-load-keychain`). StyledFieldList/StyledRepeaterRow/StyledFieldGroup/StyledSectionSubheader/StyledEmptyState.inline/StyledChipSize.micro + repeaters:/fieldLists:-themegroepen; 896 tests groen; guide + CHANGELOG bijgewerkt. **B6 teruggedraaid op review van Taco:** `sharedAcrossLocales` was geen generieke lib-capability maar vertaalmodel-vocabulaire voor iets wat `enabled` + `labelTrailing` al konden — de lib houdt alleen de micro-chipmaat en de generiek benoemde `labelTag*`-tokens, de betekenis ligt in de app (`WebsiteFieldRow._sharedTag`) |
| F3 | De kaarten als schema (README §A.1–A.4; nieuwe kaart = schemaregel, geen widget) + B2 | console | done | 7e8fe30; `domain/editor_schema.dart` (FieldRow met `visibility`, ListRow, PairListRow met shared/wide/fixedRows, RowListRow, GroupListRow met 2 niveaus, MediaRow, ExternalRow) + alle kaarten uit §A.1–A.4 in paginaorde; één renderer `editor_card_view.dart` op de F2-libwidgets; padtabel ~60 sleutels incl. twee nestingniveaus (matcher captured n segmenten, row-id óf vaste documentsleutel); cubit: removeRow/removeRowById/undoRowDelete (rij terug op oorspronkelijke positie mét vertalingen en groepsitems) en asserts dat structuuracties alleen in de brontaal kunnen; 104 ARB-keys per locale; `editor_schema_test.dart` pint 11 invarianten uit CONFORMANCE §1/§4/§8; brontaal-tag → StyledChip micro (§9-greps leeg voor deze bestanden); 429 tests groen, analyze clean, goldens hergenereerd. **Bewust doorgeschoven:** de mediakiezers zelf (stap 5 — MediaRow toont zijn set en zijn alt-tekst wél volledig bewerkbaar) en de `N gewijzigd`-rollup + `Alleen gewijzigd` (stap 4; de kaartkop-slot bestaat nu) |
| F4 | Vertaalmodus op schaal (structuur alleen in bron mét assert, `Nieuw`-badge, kaart-rollup B1, `Alleen gewijzigd` B10; tellers afgeleid uit veldpaden) | console (+lib) | done | console@b592686 + lib sw@29d3815 (v0.11.0 StyledFilterChip) en sw@69f7347 (v0.11.1 subheader-overflowfix), beide gepusht. Lane-kop met twee cijfers (site-breed), kaart-rollup via het bestaande `ContentCard.headerTrailing` (B1 vroeg geen lib-werk), filter verbergt kaarten volledig via `state.visibleCards`, `Nieuw` i.p.v. leeg `Vergrendeld`. Tellers lopen over de opgebouwde veldpaden — test met een zwerfsleutel bewijst dat een sleutel zonder veld niet meetelt. +8 tests, 437 groen, analyze clean; golden 02 hergenereerd. **Twee dingen onderweg gevonden en gefixt:** (1) lui vertalen bij het openen van een taal maakte mijn eerste testpremisse ongeldig — een bronwijziging telt pas als "gewijzigd" ná het openen van de doeltaal, en dat is ook de echte reviewflow; (2) een veld met een lége bron is niet reviewbaar (anders zit elk optioneel veld eeuwig in de teller), en de emptiness-check kijkt naar de *effectieve* bron zodat een net toegevoegde rij wél `Nieuw` toont |
| F5 | Media: B11–B13 + `MediaLibraryCubit`, `cms_media` + Storage-RLS per site; beeldsleutels repo → site_config | console+supabase+web (+lib) | done | Backend 8419890 (bucket `site-media`, pad = scope, JO-patroon met `has_site_access`; RLS-test bewijst dat élke cross-site read én write geweigerd wordt). Lib sw@c75f8b8 = v0.12.0 (StyledMediaStrip/StyledSelectableGrid/StyledDropzone+StyledUploadRow + `media:`/`uploads:`). App a8a2e37 (MediaLibraryCubit + MediaRepository, kiezer-modal met twee tabs, strip in de media-rijen, beeldsleutels in `site_config` — één set voor de hele site, publish schrijft ze naar elke locale). Web 45e86b8 (bucket-URLs via `media-url.ts`; een gevulde slot wint van de repo-lijst, een lege behoudt hem, dus verhuizen kan per slot). **Twee gaten die de RLS-test vond:** `cms_media` was publiek leesbaar en beheer was owner-only. 12 nieuwe tests |
| F6 | Publiceren: delta-tellers, per-pagina-uitklap (B14), `Openen` → taal+pagina+filter | console (+lib) | done | 9ed6796 + lib sw@7845c74 = v0.12.1 (`StyledTile.nested`). **De definitie van "gewijzigd" is verhuisd** naar *wat publiceren op de live pagina zet*: saved ≠ live, óf nieuw, óf stale (want dat wordt bij publiceren herschreven), gemeten tegen een gepubliceerde baseline die de repository per locale laadt. Daarmee kan een achtergrondvertaling de teller niet meer nullen. Reviewen is paginagranulair (`Bekeken` pas als élke gewijzigde pagina open was; `1 van 3 bekeken` zegt hoe ver), `Per pagina` klapt alleen pagina's met wijzigingen uit, `Openen` zet taal+pagina+filter en sluit de dialoog. Publiceren verschuift de baseline; een overgeslagen taal houdt de hare. +9 tests incl. de paginagranulariteitstest uit CONFORMANCE §10.6 |
| F7 | Opruimen: HouseRules mounten, voorzieningen-items uit het document, dode sleutels weg | web+supabase | done | 166bf75. Huisregels renderen nu op de homepage (inhoud én component waren er al); voorzieningen-items komen uit het document, `homeAmenities.ts` is de seed — een zelf getypt item krijgt een neutraal vinkje in plaats van een geraden icoon. Migratie 20260727220000 haalt `experience`/`layoutAndFacilities`/`accessAndTransport`/`policies` en page/home `amenities`/`location.description`/`reviews`/`faq` uit content **én** draft (een draft die er één houdt zet hem bij de volgende publicatie terug), plus de `chalet.*`-vertaalrijen. `dead_cms_keys_test.sql` draait de migratie zélf tegen prd-vormige fixtures |


## Run 8 queue — multi-template readiness (gestart 2026-08-02, na "alle verbeteren")

Architectuurreview van de website-editor op zuiverheid/DRY/genericiteit, met het oog op een
tweede website-template (andere secties, andere volgorde). De review vond één structurele
blokkade waar al het andere aan hangt: `kPageCards` is een top-level `const` en `locationOf`
is `static`, aangeroepen vanuit getters op een immutable state-object — zolang schema en
padtabel geen instanties zijn die vanuit state bereikbaar zijn, levert geen enkele andere
opschoning een tweede template op.

| # | slice | scope | status | evidence |
|---|-------|-------|--------|----------|
| G1 | Documenten op identiteit i.p.v. positie (`document: <int>` → record); unmapped-key fallback weg | console | done | 43ff4e2; `_fieldPaths` noemt `kDocCabin`…`kDocPrivacy`, `_documentFor` geeft null i.p.v. `page/home`, beide lezers guarden; ankertest pint één sleutel per document; 558 tests groen |
| G2 | Template-namen uit de generieke laag (autofocus als schemavlag, media-subs één keer benoemd, dode mock-sleutels, hardcoded domein) | console | done | 9efd814; `FieldRow.autofocus` + `RowListRow.imageSub/altSub`; schematische preview las `hero.headline`/`highlights.0` die het schema nooit had; preview-chrome toonde een echte klantdomein als placeholder → `wePreviewNoDomain`; preview-url-test pint nu de taalbinding i.p.v. de hostnaam |
| G3 | `WebsiteTemplate` als instantie: schema bereikbaar vanuit state (de structurele blokkade) | console | done | b1fd095; `WebsiteTemplate`/`TemplatePage` met geordende pagina's + `kDefaultTemplate`; `kPageCards`/`kWebsitePages`/`effectiveFieldsFor`/`kSchemaLists`/`schemaRowForList` weg, methodes op de instantie; `SiteContentState.template` (default `kDefaultTemplate`) — de getters die veldadressen oplossen zitten op de state, dus daar moest hij landen; 9 bestanden, 560 tests groen. **Padtabel volgt in G3b:** `_fieldPaths` + `locationOf` staan nog statisch op de repository |
| G3b | Padtabel + `locationOf` van statisch naar de template | console | done | 1769074; `kDoc*` + de 68-regelige tabel staan toplevel in het domein (`_kChaletFieldPaths`), `WebsiteTemplate` krijgt ze via de constructor, en `locationOf`/`listLocationOf`/`_patternPrefixOf`/`_match` zijn methodes. `EditorFieldLocation`/`RowId`/`_Slot` mee naar het domein, dus data importeert domain en niet andersom. Repository houdt statische delegates voor de aanroepers zonder repository-instantie. Test bewijst het punt: een tweede template mapt dezelfde sleutel naar een ánder document, en kent een sleutel die hij niet declareert niet. 561 tests groen |
| G4 | Labels als data op kaart/rij i.p.v. 13 switches | console | done | 9efd814 (positioneel deel) + dd4421d (de rest). **Alle id-gesleutelde switches weg**: `EditorCard.title/subtitle/icon`, `TemplatePage.label`, `MediaRow.title`, `FieldRow.label`, `title`/`itemLabel` op elke lijstrij, `PairListRow.labelLabel/valueLabel`, `GroupListRow.subItemLabel`, en een label per `RowListRow.subs`-entry. 146 declaraties. `LabelRef = String Function(S)` — getypeerd op de gegenereerde klasse, dus geen casts en codegen blijft werken. **Gevolg:** het schema is `final` i.p.v. `const` (closures zijn niet const), dus `SiteContentState.template` kreeg een nullable backing met getter. Vier switches resteren en zijn legitiem: taalcode, sealed row-type, `FieldVisibility`-enum. Tests eisen dat elke pagina en elke kaart zichzelf benoemt; 565 groen |
| G5 | Geordende pagina's incl. legal (`showAsTab: false`); heft de `kPageCards.keys`-lek in de publiceer-dialoog op | console | done | Meegelift op G3: `pages` ís de volgorde, `legal` staat laatst en `showAsTab: false`. Test pint `pageKeys` = home/practical/area/gallery/legal en dat legal nooit eerst komt of een tab is |
| G6 | Media-slot-routing uit de template i.p.v. `contentType == 'site_config'` + `split('.').last` | console | done | 2574427; `WebsiteTemplate.mediaSlots` (document + JSON-sleutel) met `mediaJsonKeyOf`; beide kanten van de repository noemden `site_config/main` en `images` in literals — twee plekken die een tweede template ook had moeten raden. `split('.').last` gaf bovendien stil een verkeerde sleutel voor een slot dat niet onder `images.` hangt; nu null en overslaan. Test dekt dat élke schema-mediasleutel tegen de template-sleutel resolvet |
| G7 | `site_translations.page` schrijft de echte pagina i.p.v. de constante `'home'` | console+supabase | done | 326d35c + migratie `20260802180000_site_translations_identity.sql` (prd toegepast, idempotent). **De unieke sleutel klopte niet:** hij bevatte `page`, dat altijd `'home'` was — de kolom beweerde iets onwaars én was een val, want de echte pagina schrijven zou de upsert-`ON CONFLICT` laten missen en een tweede rij invoegen. Eén site draait één template, dus `site_id` scopet de veldsleutel al; identiteit is nu `(site_id, field_key, language)` en `page` is informatief. `WebsiteTemplate.pageOfField` levert 'm; test dekt lijstrijen, legal en een sleutel die geen kaart claimt |
| G8 | Gegenereerd adres-manifest + conformance-check console↔web | console+web | done | 6becbe9; `web/cms-address-manifest.json` (73 adressen) uit `kDefaultTemplate`, geschreven én bewaakt door `cms_address_manifest_test.dart` (regenereren: `UPDATE_CMS_MANIFEST=1 flutter test …`). `npm run check:cms` faalt op twee richtingen: een adres dat de site gebruikt maar de console niet aanbiedt (dode luisteraar), en een `inPage`-tekstveld dat geen element markeert (focus wijst nergens heen). **De check vond meteen 15 ongemarkeerde velden** — kaarttitels op Praktisch, voorzieningen/locatie, privacy-intro, home-tagline, submit-knop — allemaal gemarkeerd. Eén gemotiveerde uitzondering in de bron (`cms-address-exempt`): de contact-subtitel is rond een mailto-link gesplitst, dus er is geen enkele tekstknoop om te patchen |
| G9 | `sites.template_id`: welke template een site gebruikt, end-to-end | console+supabase | done | migratie `20260803090000_sites_template_id.sql` (`NOT NULL DEFAULT 'chalet-v1'`, idempotent; prd én lokaal toegepast, beide sites `chalet-v1`). Registry `kTemplates` + `templateFor(id)` in het domein; `SiteSummary.templateId` en de editor-siteselect lezen de kolom; `WebsitePageContent.templateId` draagt hem naar `SiteContentCubit`, die `template: templateFor(...)` emit — daarmee is de laatste plek waar de console de template *aannam* weg. **Bewust een fallback i.p.v. falen:** een onbekende of ontbrekende id levert `kDefaultTemplate`, want een site waarvan de template hernoemd is moet nog opengaan (met de verkeerde labels) i.p.v. helemaal niet. +2 tests in `editor_schema_test.dart`; analyze clean, 567 tests groen |
| G10 | De website leest `sites.template_id` i.p.v. één ingebakken documentenlijst | web | done | `lib/site-template.ts` (registry + `siteTemplateFor` met dezelfde fallback als de console); `site_domains`-lookup haalt de template mee via de FK-embed `sites(template_id)` — één read, want twee reads is twee kansen om te verschillen; `RuntimeSiteContext.templateId` → `toSiteContentOptions` → `ContentOptions.templateId`, dus élke contentread heeft hem zonder extra plumbing. `SITE_DOCUMENTS` was een literal in `content-provider.ts`: de preview-banner meldde "missing" tegen de lijst van het chalet, ook voor een site met een andere template. `npm run check:cms` kreeg een **derde richting**: de documentenset hier moet exact de documenten zijn die de console-adressen noemen — bewezen door hem te laten falen (`page/privacy` weggehaald → exit 1, beide richtingen genoemd; schoon → exit 0, 7 documenten). Embed geverifieerd tegen prd (beide sites `chalet-v1`, to-one object); typecheck + build clean, lint ongewijzigd (24 pre-existing in booking-componenten); `hosthub-sites-test` gedeployed, test.trysilpanorama.com 200 op alle pagina's en drie talen, www ongemoeid (200/200/200). **Bewust niet gedaan:** de render-tree zelf (sectievolgorde, paginacomponenten, `content.ts`). Dat is geen blokkade meer maar werk, en een abstractie met één implementatie bouwen vóór er een tweede template ís, is precies de speculatieve genericiteit die deze review elders afkeurt |
| G11 | Eén vraag per request i.p.v. één per aanroeper | web | done | 42de914; de homepage deed **tien queries voor vijf antwoorden** — drie `site_domains`-lookups (layout, body en `generateMetadata` lossen de site elk apart op, voor een waarde die binnen één request niet kán veranderen) en zeven documentreads voor vier documenten. Nu gededupliceerd met React's `cache`; sleutel is het request, dus geen versheidsrisico, en `includeDrafts` zit in de documentsleutel zodat preview en publiek gescheiden blijven. **Gemeten, niet aangenomen:** tijdelijke teller + `wrangler tail` op de testworker → exact vier reads voor één render. Latency onveranderd (~200 ms warm): de dubbelen liepen al binnen `Promise.all`, dus de winst is Supabase-belasting. Route handlers geverifieerd (`sitemap.xml` 200 met de juiste host, `robots.txt` 200, `/api/contact` valideert met 400 i.p.v. 500) — `cache` degradeert veilig buiten een page render |
| G12 | De website krijgt een testsuite | web | done | ab8dae5; deze kant had **nul** tests tegenover 567 in de console — het bestand dat `/en` en `/no` op een 500 zette had er noch vóór noch ná de fix één. 29 tests over de zuivere grenslogica: rij-normalisatie voor élke lijst die de console kan bewerken (inclusief de gegroepeerde die de outage veroorzaakte), de adresvorm die `check:cms` uit de bron parst, mediapad-resolutie, en de fallback van de template-registry. Zonder dependency: node's eigen testrunner met type-stripping plus een resolve-hook (`web/scripts/ts-resolve.mjs`) zodat een test de app-modules kan importeren met de extensieloze relatieve paden die ze al gebruiken. Geverifieerd dat de testbestanden niet in de worker-bundle belanden. `npm test`, en `npm run verify` = typecheck + check:cms + tests. Lint zat er even niet in omdat er 25 bestaande overtredingen waren; die zijn in G13 opgelost, dus `verify` = typecheck + lint + check:cms + tests en slaagt |
| G13 | Alle 25 React-Compiler-overtredingen in de boekingsflow | web | done | De rode draad was één patroon: **antwoorden zonder de vraag die ze beantwoorden**. `availabilityLoading`/`quoteLoading`/`quoteError` waren losse vlaggen die een effect ophief bij vertrek en neerlegde bij terugkomst — dus er was altijd een venster waarin de prijs van de vórige datums onder de nieuwe stond. Nu draagt elk antwoord de sleutel van zijn vraag (`arrival|departure` voor beschikbaarheid, plus gasten en promocode voor de prijs) en is "laden" een afleiding: gevraagd, nog geen antwoord voor déze sleutel. Dezelfde vorm in `useBookingState` en `BookingWidget`. `header.tsx`: de hero-meting draagt het pad waarop ze gedaan is, dus weglopen ontkracht haar vanzelf. `DateRangeModal`: het overnemen van de datums van de pagina ging van een effect naar een vergelijking tijdens de render (React's eigen recept), zodat het paneel niet eerst één frame de vórige selectie toont. De 15 memoisatie-fouten waren allemaal één oorzaak: een dependency-array kan geen `value?.from` bevatten — de compiler kijkt niet door de optional chain heen, gaf de héle component op, en élke `useMemo` erin was stilletjes geen memo meer. Opgelost met gewone locals. **Geverifieerd in de browser tegen de échte Lodgify** (dev-server op localhost, dat is site d2744793): kalender laadt met echte bezetting → 17 aug kiezen herberekent de geldige uitcheckdatums (minimumverblijf) → 17–24 aug levert een echte offerte (huur NOK 13.328 = 1.904 × 7, korting −1.333, schoonmaak 2.200) → datum wijzigen wist de prijs meteen in plaats van de oude te laten staan, precies het venster dat dit dichtzet. Geen console-fouten. Analyze/typecheck/lint/check:cms/tests alle groen |

## next_lens
RUN 8 KLAAR: G1 t/m G10 done. **De queue is leeg.** De multi-template blokkade is aan beide
kanten opgeheven: kaarten, padtabel, media-routing, paginavolgorde, labels, *welke template een
site gebruikt* én de documentenset van de website komen uit een template, en het contract tussen
de twee codebases (adressen én documenten) wordt door `npm run check:cms` in drie richtingen
bewaakt.

Wat een tweede template nu nog vraagt is niets structureels meer, alleen werk dat pas met een
échte tweede template betekenis krijgt: eigen paginacomponenten en sectievolgorde
(`app/[locale]/…`, `content.ts`, de zes `getXContent`-functies zijn nog chalet-getypeerd). Dat is
bewust niet vooruit gebouwd — één implementatie achter een abstractie is de speculatieve
genericiteit die deze review elders afkeurt.

**Afgehandeld 2026-08-03:** `styled_widgets` gepusht (analyze clean, 1043 tests groen; alle tags
stonden al op de remote — versies 0.13 t/m 0.16.2 zijn nooit getagd, dat is een release-beslissing
voor Taco). Console gedeployed naar prd (v0.2.0, 11:36:25Z) en in de browser geverifieerd dat hij
boot en rendert — het echte risico van de `BrowserContextMenu`/`SelectionArea`-wijziging.
Werkruimte gepusht (20 commits stonden alleen lokaal). Site gedeployed naar prd; alle acht
pagina's × drie talen 200.

**Vastgelegd zodat niemand het "opruimt":** `web/lib/content.ts` is **geen** duplicaat-backup maar
de **defaultlaag** die het CMS veld-voor-veld overschrijft. `mergeSiteConfig` spreidt de hardcoded
`site` onder élk `site_config`-document, en het CMS-document draagt maar zeven velden — `imagePaths`,
`gallery`, `heroImages` en de contactgegevens komen dus uit `content.ts`. `primaryHeroImage` (de hero
op vijf pagina's) wordt er rechtstreeks uit berekend. Weggooien haalt elk veld weg dat het CMS niet
draagt. De echte weg is een migratie: die defaults naar het CMS met editor-velden erbij, dan per
groep uit `content.ts` halen — dezelfde vorm als F7. De outage-backup is `content.generated.ts`
(7 documenten × 3 talen, gegenereerd bij elke deploy); `CMS_SNAPSHOT_SITE_ID` komt via `.env.local`
in de bundle, dus die laag leeft alléén voor de chalet-site en elke andere site faalt dicht.

Nog open, user-gated: E3 (visuele verificatie vraagt een ingelogde sessie; er is geen Chrome met het
account verbonden en inloggen vraagt credentials), de merknaam + logo (wacht op de naamkeuze en een
domein), en cross-request caching — met de reads gehalveerd is de resterende winst puur
Supabase-volume, en de prijs is versheid op een live klantsite. Dat is een productbeslissing:
`s-maxage` op de HTML (weinig code, publiceren pas na de TTL zichtbaar) of OpenNext incremental
cache met tags + revalidate-bij-publiceren (geen versheidsverlies, vraagt een R2-bucket en een hook
vanuit de console).

RUN 7 (fase 2-handoff): F-pre t/m F7 done.  _(historische regel hieronder liep achter op de eigen tabel)_ Volgende was: **F4** (vertaalmodus op schaal —
`Nieuw`-badge op een rij die in de bron is bijgekomen, kaart-rollup `N gewijzigd` via de nieuwe
`ContentCard.headerTrailing`, `Alleen gewijzigd`-filter = B10 in de lib; de tellers **afgeleid**
uit de opgebouwde veldpaden), daarna F5 (media), F6 (publiceren), F7 (opruimen).

**Nog open, user-gated** _(bijgewerkt 2026-08-03 — beide punten stonden achter op de feiten)_:
1. `styled_widgets` staat **8 commits vóór `origin/main`** (niet alleen v0.10.0; v0.10.1 t/m
   v0.12.1 zitten erbij). HostHub consumeert de lib per pad, dus lokaal werkt alles; andere repos
   zien niets tot `git push origin main --tags` in
   `~/Documents/projects/shared/libraries/styled_widgets`. Pushen valt buiten deze loop.
2. ~~De migratie `20260727150000_cms_stable_row_ids.sql` staat **alleen lokaal**.~~ **Achterhaald:
   staat op prd** — geverifieerd 2026-08-03, alle 12 lijstrijen hebben hun stabiele id en de
   nieuwe console draait ervoor. Historische aanpak hieronder bewaard. Prd-aanpak zoals
   eerder: dit ene bestand via `psql "$SUPABASE_DB_URL"` uit `hosthub-prd-server.env` (niet
   `make apply-migrations ENV=prd` — die replayt de baseline), daarna `NOTIFY pgrst, 'reload
   schema'`. **Let op de orde:** deze migratie en de console/web-deploy horen samen te gaan. De
   web-kant slikt beide vormen (normalize-content), dus de site blijft renderen als de migratie
   vóór de deploy landt; de nu live console schrijft nog index-sleutels, dus draai hem niet lang
   op prd zonder de nieuwe console.
RUN 6 KLAAR: M1–M7 done (2026-07-26), elk met review-stop. Open, user-gated: visuele verificatie in
de app (vraagt een ingelogde sessie, zelfde blokkade als E3) en de **console-deploy naar prd** —
de migratie staat er wel op (zie M7). Niet gebouwd omdat het buiten de zes stappen viel: de Accountinstellingen-editor voor
account-defaults + propertylijst met override-counts (§4b), en de tijdlijn bij N properties.
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
