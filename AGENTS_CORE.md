# AGENTS_CORE.md

Cross-project core rules for Taco's Flutter/Supabase projects, vendored into this
repo. Repo-specific facts (paths, branch policy, workspace layout) live in
`AGENTS.md` next to this file; per-topic conventions live in the `tk-*` skills.

Vendored on purpose: the same rules apply in the other repos, but a shared file
referenced through a machine-local path (`../../shared/...`) is not version-controlled
and breaks for anyone else — the same reason `supabase-common.mk` is vendored per repo.
Keep changes here in sync with the other repos deliberately, not by symlink.

## Skills first

Load the relevant skill before writing code — they are the canonical, brand-neutral
description of these conventions, written per **repo layout** (Melos monorepo vs
single-package app):

| Skill | For |
|---|---|
| `tk-feature` | cubits/blocs, repositories, models, pages, routes, DI (`I`/GetIt), DomainError |
| `tk-styledwidgets` | which StyledWidgets component fits |
| `tk-styling` | theme preset, color roles, typography, tokens |
| `tk-localization` | ARB files, the `S` class, regenerating translations |
| `tk-supabase` | Edge Functions, migrations, RLS, secrets/env layout, deploys |
| `tk-dart-analysis` | `analyze`/`dart fix`/format, test scope, analyzer config |

Also read the component guide that ships with the UI library itself
(`styled_widgets/.claude/skills/styled-widgets-guide/SKILL.md`) — it is more current
than any copy of it.

## Language and collaboration

- Communicate in Dutch by default, unless English is explicitly requested.
- Write all code comments, doc comments and commit messages in English.
- Work directly: implement what was asked. Do not ask whether to do something that is
  logically obvious. When a change is reversible, has one sensible reading, and stays
  in scope, do it and state the assumption in one line.
- A broad instruction ("fix everything", "alles fixen", "ga door") authorizes the whole
  list. Work through every in-scope item; never end a turn by asking whether to
  continue with remaining in-scope work. Deferring an in-scope item needs a blocking
  reason — irreversible, genuinely ambiguous, or out of scope — never convenience.
- Ask first only when the decision is genuinely blocking: destructive or irreversible
  actions, real product/UX ambiguity, or scope clearly larger than requested.

## Non-negotiable core rules

- **Always pure code.** No shortcuts. Prefer one mechanical refactor over a config
  flag, shared-state hack, or "we'll clean it up later" intermediate step. Reject your
  own proposal when it contains "config flag", "for now", "intermediate step", "we'll
  move this later", or "let's just duplicate", and present the clean alternative.
- **Pre-production cleanup beats compatibility.** Remove legacy APIs, compatibility
  shims, fallback readers/writers and deprecated wrappers instead of carrying them
  forward. Do not add `@Deprecated` APIs or `deprecated_member_use` suppressions unless
  an external compatibility contract requires it — and then document the removal plan
  in the same change.
- **Library-first.** A generic UI or infrastructure capability belongs in the shared
  library (optional/disableable), not app-local. A change to a shared library is a
  cross-repo change: keep it compatible with every consuming repo, and remember some
  repos consume it by path and others by git tag.
- View/UI never calls the data layer directly. Feature actions go through the state
  layer; callbacks and side effects live in the cubit/bloc, not the widget.
- Business errors flow `Supabase error → mapError() → DomainError → state → AppError`
  and are shown with `showAppError(...)`. Only field-level validation errors render
  inline. No `try/catch` in view code for feature actions.
- When an API signature changes, update every call site in the same change.
- Do not reinterpret user intent in an unintended layer, and do not revert or modify
  user changes outside the requested scope.

## Dart/Flutter

- Follow the existing folder structure and naming per feature.
- No brand names in shared code; keep names descriptive and portable.
- Material 3 only. Use M3 color roles; never the removed M2 spellings (`background`,
  `onBackground`, `surfaceVariant`). Never build a local `ThemeData` in a widget.
- Don't create cubits/blocs in `build()`; use `initState` or a route-level provider.
  Always `close()` page-local cubits, and never register them as DI singletons.
- All user-facing text goes through ARB. No hardcoded strings in widgets, and no inline
  locale branching (`isNl`, `switch (lang)`) for labels.
- Never hand-edit generated output: `*.g.dart`, `*.freezed.dart`, `lib/generated/**`.
- Use the UI library for product UI. Deviate only when a needed capability is
  demonstrably missing, and keep the deviation minimal and local.

## Modals and dialogs

- Confirmations (yes/no, continue/cancel, destructive): `showStyledAlertDialog`, with
  `isDestructiveAction: true` where it destroys something. Never `showStyledModal` for
  a simple confirmation.
- Content (forms, details, single-step): `showStyledModal`.
- Multi-step flows: `showStyledModal<T>(... steps: StyledModalSteps(...))`. Step-level
  `action` / `isDirty` / `onActionPressed` override the modal level.
- Close button only when the modal needs one, and then leading (left); the primary
  action sits right or in the footer. Close via `controller.close(result)` — never
  `Navigator.pop(context)` from a modal body.
- Don't set `contentPadding` unless the content is full-bleed or needs a deliberate
  rhythm; the preset default is correct for both section-based and custom content.
- Boolean choice → `StyledSwitchTile`. Three or more options → `StyledSelectionTile`,
  preferring the `.dropdown` constructor. Segmented choice → `StyledSegmentedControl`.
- No raw `showDialog` / `AlertDialog` / `Dialog` for primary product flows.

## Validation and delivery

- Run format, analyze and tests for code changes, through the pinned toolchain
  (`fvm ...`). Prefer the repo's own script (`melos run analyze`, a Makefile target)
  over a command you compose yourself.
- Pick the smallest defensible test scope; don't default to the full suite, and don't
  skip tests because "it was only a lint". Details in `tk-dart-analysis`.
- Add or update a test in the same change as a behavior change. Before closing a bug
  fix, decide whether a regression test can pin the broken behavior — and make it fail
  without the fix where feasible.
- **Failing tests are work, not findings.** Fix what you run into, including
  pre-existing failures and flakes, unless another session is actively working that
  area — then hand it off with your diagnosis. "Out of scope" is not a reason.
- Report outcome first, then changed files, which validations ran, which did **not**
  and why, and open risks. Never claim a check you didn't run.
- Propose one commit message for the combined changeset (`git diff --stat` +
  `git diff --cached --stat`), in English, imperative — not one per edit, and not while
  work is unfinished. Check fresh `git log` first: a parallel session may already have
  committed the substantive change.
