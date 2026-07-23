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
| S1 | B6 `StyledSegment.statusDotColor` | styled_widgets | todo | |
| S2 | B5 `StyledNotice` trailing slot + `warning` tone | styled_widgets | todo | |
| S3 | B4 field `labelTrailing` + `footer` slots | styled_widgets | todo | |
| S4 | B7 `StyledMeter` | styled_widgets | todo | |
| S5 | B3 `StyledBrowserFrame` (desktop + mobile) | styled_widgets | todo | |
| S6 | B2 `StyledSplitView` | styled_widgets | todo | |
| S7 | B1 `StyledSideMenu` | styled_widgets | todo | |
| S8 | `SiteContentCubit` + models + repository + DI (state machine) | console | todo | |
| S9 | Editor mode A (source editor: bar, tabs, banner, Hero, Highlights, save bar) | console | todo | |
| S10 | Editor mode B (translation: chips, source-ref, Reset to AI, coverage, stale/fresh) | console | todo | |
| S11 | Preview pane (browser/mobile frame, toolbar, locale switch, rendered site, ribbons) | console | todo | |
| S12 | Publish modal | console | todo | |
| S13 | Sidebar wiring + route + scaffold assembly (split view) | console | todo | |
| S14 | i18n ARB strings (nl/en) | console | todo | |
| S15 | Widget + golden tests (CONFORMANCE recipe) | console | todo | |
| S16 | Supabase `translate-content` Edge Function + translation storage migration | supabase | todo | |

## next_lens
S1 — `StyledSegment.statusDotColor` (smallest, self-contained lib addition; unblocks locale switcher).

## Content / state-machine reference (from the prototype)
- Property: **Trysil Panorama**, source lang `nl`, locales `[nl, en, no]`.
- Seed content per language (Home page): `title` (hero headline), `sub` (subtitle),
  `h1`/`h2` (two highlights). NL is source; EN/NO derived.
- State machine (per field,language): `auto` (follows source) ⇄ `locked` (owner-edited).
  Source edit → dependent `auto` fields `stale`. Publish → re-translate all `auto`, clear stale,
  all live. "Preview translation" = optional early refresh of `auto` fields.

## Ledger (resolved findings / completed slices)
_(none yet)_
