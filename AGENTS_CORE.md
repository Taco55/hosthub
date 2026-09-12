# AGENTS_CORE.md

Cross-project core rules for Taco's Flutter/Supabase projects. The canonical copy
lives at `shared/tk-skills/AGENTS_CORE.md` and is vendored into each repo.
Repo-specific facts (paths, branch policy, workspace layout) live in `AGENTS.md`
next to this file; per-topic conventions live in that repo's own skills.

Vendored on purpose: the same rules apply in the other repos, but a shared file
referenced through a machine-local path (`../../shared/...`) is not version-controlled
and breaks for anyone else — the same reason `shared/make/supabase-common.mk` is
vendored per repo. Keep changes here in sync with the other repos deliberately, not by
symlink.

## Skills first

Load the relevant skill before writing code. Skills live **in the repo they describe**,
under `.agents/skills/`, reached through a committed `.claude/skills` symlink — that
needs no install step and no version bump, so a repo-local skill beats a shared one
whenever it applies. A repo that does Flutter and Supabase work is expected to carry a
skill per topic:

| Topic | Covers |
|---|---|
| feature | cubits/blocs, repositories, models, pages, routes, DI (`I`/GetIt), DomainError |
| styledwidgets | which StyledWidgets component fits, and where the repo deviates |
| styling | theme preset, color roles, typography, tokens |
| localization | ARB files, the `S` class, regenerating translations |
| supabase | Edge Functions, migrations, RLS, secrets/env layout, deploys |
| dart-analysis | `analyze`/`dart fix`/format, test scope, analyzer config |

Name them per repo (`justorganize-feature`, `diplora-feature`). A repo without these
skills yet falls back to this file plus its own `AGENTS.md`.

Also read the component guide that ships with the UI library itself — the
`styled-widgets` skill at
`shared/libraries/styled_widgets/skills/styled-widgets/SKILL.md`, with the component
and theming reference under its `reference/`. It is more current than any copy of it.

## Tooling and workflow

- Use the pinned Flutter version from `.fvmrc`, via `fvm flutter ...` / `fvm dart ...`.
- Work from the repo root by default, unless a command explicitly needs to run inside
  an app or package.
- Prefer the repo's own script (`melos run analyze`, a Makefile target) over a command
  you compose by hand — a hand-typed scope silently skips the guards the script runs.

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
- A single `StyledSection` can be returned directly — do not wrap it in a `Column`.
  Use a `Column` only when there are multiple sections or other siblings alongside.
- No raw `showDialog` / `AlertDialog` / `Dialog` for primary product flows.

## Supabase and SQL (where used)

- Schema changes go through a migration in `supabase/migrations`, applied via the CLI
  flow (`supabase db push` / `supabase migration up`) — never by running SQL by hand.
- Migration naming: `YYYYMMDDHHMMSS_description.sql` — a 14-digit timestamp before the
  first underscore, matching the Supabase CLI's own versions.
- **Migrations must always be idempotent**, safe to re-run without errors:
  - `CREATE TABLE` → `CREATE TABLE IF NOT EXISTS`
  - `CREATE INDEX` → `CREATE INDEX IF NOT EXISTS`
  - `CREATE POLICY "name" ON table` → prepend `DROP POLICY IF EXISTS "name" ON table;`
  - `CREATE TRIGGER name ON table` → prepend `DROP TRIGGER IF EXISTS name ON table;`
  - `CREATE OR REPLACE FUNCTION/VIEW` → already idempotent
  - `ALTER TABLE ADD COLUMN` → `ADD COLUMN IF NOT EXISTS`, or wrap in
    `DO $$ BEGIN ... EXCEPTION WHEN duplicate_column THEN NULL; END $$;`
  - `ALTER TABLE ADD CONSTRAINT` → wrap in
    `DO $$ BEGIN ... EXCEPTION WHEN duplicate_object THEN NULL; END $$;`
- Edge Functions: one per directory under `supabase/functions/<name>/`, shared code in
  `supabase/functions/_shared`.
- Generated schema dumps are artifacts — do not hand-edit them.
- After changing migrations, functions or secrets, offer to deploy to staging via the
  repo's Makefile target. Never deploy to production silently; always go through the
  `confirm-remote` safeguard.
- The shared Makefile template is `shared/make/supabase-common.mk`, vendored per repo.

## User feedback

- **Never** use `ScaffoldMessenger` or `SnackBar` — always `showStyledToast()` from
  `styled_widgets`, which requires a `type` (`ToastificationType.success`, `.error`)
  and a `title`.
- Errors are not toasts. Business errors go through `showAppError`; toasts are for
  success and info.

## Validation and delivery

- Run format, analyze and tests for code changes, through the pinned toolchain
  (`fvm ...`). Prefer the repo's own script (`melos run analyze`, a Makefile target)
  over a command you compose yourself.
- Pick the smallest defensible test scope; don't default to the full suite, and don't
  skip tests because "it was only a lint". Details in the repo's dart-analysis skill.
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
