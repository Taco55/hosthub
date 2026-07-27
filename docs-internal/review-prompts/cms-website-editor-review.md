# Release-readiness review — HostHub CMS website editor

This build-loop implements the **HostHub CMS website-editor** design handoff at
`/Users/taco/Documents/projects/HostHub/hosthub-design/design_handoff_hosthub_cms/`.

The authoritative rubric is the handoff itself. For each slice, review the implemented
code + its committed diff against:

- `README.md` — screens, modes A/B, preview, publish modal, the source-language /
  auto-translate-unless-locked state machine (the single most important concept).
- `STYLED_WIDGETS_MAPPING.md` — **hard requirement**: build everything from
  `styled_widgets`; new capability lands as optional, tested, theme-driven lib additions
  (B1 `StyledSideMenu`, B2 `StyledSplitView`, B3 `StyledBrowserFrame`, B4 field
  labelTrailing/footer, B5 `StyledNotice` trailing + warning tone, B6 `StyledSegment`
  status dot, B7 `StyledMeter`). No raw `Container(decoration:)` / hardcoded `Color(0xFF…)`
  in the screen; colours from `ColorScheme`.
- `CONFORMANCE.md` — the checklist + the widget/bloc/golden test recipe (Definition of Done).
- `TRANSLATION.md` — auto-unless-locked model; translate on publish + optional preview;
  per-field `{value,status,source_hash,translated_at}`; provider behind an Edge Function.

## Review dimensions per slice (phases)
0. **Spec conformance** — matches the handoff for that slice (layout, states, behaviour).
1. **StyledWidgets adherence** — no bespoke chrome; lib additions optional + theme-driven.
2. **Correctness / state machine** — auto→locked→stale→publish transitions behave exactly.
3. **Data integrity** — per-field status + source_hash preserved; locked never overwritten.
4. **Error handling** — translation async/cancellable/debounced; graceful degrade + toast.
5. **i18n** — user-facing strings via `S`/ARB, not literals.
6. **Tests** — widget + bloc + golden coverage per CONFORMANCE; lib additions have tests.
7. **Analyze clean** — `flutter analyze` (scoped) with no new issues.

## Effective config (this repo)
- `analyze_cmd` (console): `flutter analyze` — baseline = 1 pre-existing info issue
  (`bootstrap.dart` anonKey deprecation); do not regress beyond that.
- `analyze_cmd` (styled_widgets): `flutter analyze lib test` — baseline clean
  (`themebuilder/` sub-package has pre-existing errors, out of scope).
- `test_cmd` (console): `flutter test <path>`
- `test_cmd` (styled_widgets): `flutter test test/<file>`
- Flutter 3.35.7 stable (direct `flutter`, not fvm here).
