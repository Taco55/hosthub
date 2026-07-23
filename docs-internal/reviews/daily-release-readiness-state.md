# Daily release-readiness state — HostHub CMS website editor

Source of truth for the `/build-loop` implementing the design handoff at
`hosthub-design/design_handoff_hosthub_cms/`. Rubric: `../review-prompts/release-readiness-review.md`.

- **branch:** `fix/lodgify-connection-and-preview-routes` (current)
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

## next_lens
S17 — EdgeFunctionTranslationService met injecteerbare invoke voor tests.

## Content / state-machine reference (from the prototype)
- Property: **Trysil Panorama**, source lang `nl`, locales `[nl, en, no]`.
- Seed content per language (Home page): `title` (hero headline), `sub` (subtitle),
  `h1`/`h2` (two highlights). NL is source; EN/NO derived.
- State machine (per field,language): `auto` (follows source) ⇄ `locked` (owner-edited).
  Source edit → dependent `auto` fields `stale`. Publish → re-translate all `auto`, clear stale,
  all live. "Preview translation" = optional early refresh of `auto` fields.

## Ledger (resolved findings / completed slices)
_(none yet)_
