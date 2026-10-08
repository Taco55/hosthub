---
name: tk-dart-analysis
description: >
  Cross-project convention for Dart/Flutter static analysis: how to run it, which
  fixes may be applied mechanically, how to fix the rest at the root cause, and how
  wide to test afterwards. Brand-neutral and path-free — the repo's own
  `<repo>-dart-analysis` skill supplies the actual commands, analyzer config and
  guardrails. Triggers on: dart analyze, flutter analyze, dart fix, dart format,
  analyzer, lint, linter rules, strict-casts, analysis_options.yaml, ignore_for_file,
  suppression, test scope after an analyzer cleanup.
user-invocable: true
---

# Dart Static Analysis — shared convention

Run analysis through the pinned toolchain, apply only mechanical fixes, fix the rest
at the cause, verify with the narrowest defensible test scope, and report exactly what
ran. Never silence a finding you could fix.

This skill holds the convention. Commands, analyzer configuration and repo-specific
guardrails live in the repo's own dart-analysis skill — read that one too.

It is vendored: copied unchanged from `tk-skills` into each repo that follows it.
Change it there and re-vendor; never edit a copy.

## Run the repo's own script

A repo usually defines the correct scope already, and re-typing it by hand is how you
end up analyzing the wrong tree — or skipping the guards the script runs alongside the
analyzer (architecture checks, manifest checks, secret scans).

```bash
rg -n -A 3 "^  scripts:" pubspec.yaml melos.yaml   # melos scripts
rg -n "^[a-zA-Z0-9_.-]+:" Makefile                 # make targets
```

Prefer that target over an equivalent you compose yourself. Note whether it already
resolves the pinned SDK (a melos `sdkPath`, or an explicit `.fvm/flutter_sdk` path) —
if it does, do not prefix it with `fvm` as well. Narrow the scope only deliberately,
and say so in the report.

Use `flutter analyze` for packages that depend on the Flutter SDK and `dart analyze`
for pure Dart packages; `dart analyze` on a Flutter package works but can miss
Flutter-specific diagnostics.

## Shared path-dependency libraries

Packages that consume a shared library **by path** sit outside the repo, so no
analyze scope in the consumer covers them.

- After changing a library, analyze it in its own directory. The consumer's run will
  not do it, and the consumer's CI will not catch it either.
- A library change is a cross-repo change. Keep it compatible with the oldest SDK
  still pinned by a consuming repo — never clear a lint by adopting an API newer than
  that floor.
- Fix the finding in the library, never by working around it in the consumer.
  Reaching for a consumer-side shim is the tell that the fix belongs upstream.

## Fixing findings

1. Start from the exact analyzer output, not from memory of the file.
2. Preview automated fixes first: `dart fix --dry-run .`
3. Apply only after reading the proposal. Reject it and fix by hand if it would touch
   generated files, introduce deprecated APIs, or change behavior rather than syntax.
4. Fix the remainder at the cause:
   - Prefer typed parsing, explicit casts at the boundary and model helpers over
     propagating `dynamic` inward.
   - Keep layer boundaries intact. Never silence an error by calling a repository
     from a widget, or by moving business logic into the UI.
   - Keep repository error handling in the existing mapping pattern
     (`mapError()` → `DomainError`); don't swallow or re-throw raw driver errors.
   - When a signature changes, update every call site in the same change — no
     overload shims, no `@Deprecated` bridges.
   - Import cycles and upward dependencies are architecture violations, not lint
     cleanup: move the declaration down to the shared layer, move presentation
     extensions up, or split the barrel that hides the cycle.
5. Format the changed files or the affected package scope.
6. Rerun the analyzer, then the tests.

## Guardrails

- **Never** hand-edit generated output (`*.g.dart`, `*.freezed.dart`,
  `lib/generated/**`). Fix the source and regenerate.
- Keep `analyzer: exclude:` limited to generated and vendored trees. Excluding real
  source to reach green is hiding a defect.
- Suppression (`// ignore:`, `// ignore_for_file:`) is for genuine false positives
  only, with the reason obvious from nearby code. Prefer a line-level ignore over a
  file-level one; never reach for `// ignore_for_file: type=lint`.
- Analyzer and linter **configuration** changes are codebase-wide changes: keep them
  narrow, justify them, and re-analyze the affected scope. Enabling a rule repo-wide
  to fix one file is the wrong lever.
- Don't add compatibility shims or `@Deprecated` markers to appease the analyzer in a
  pre-production repo — change the callers.
- Don't run repo-wide codegen as part of an analyzer cleanup unless the findings are
  genuinely stale generated code; it buries the real diff.

## Test scope

Don't default to the full suite, and don't skip tests because "it was only a lint".

- Narrow change → the owning package's test file(s).
- Behavior changed, or a regression risk surfaced → add or update a regression test.
- Broader local gate → the repo's changed-packages target, where it defines one.
- Full gate → broad refactors, regenerated models, cross-package contract changes,
  release confidence, or unclear blast radius.

Golden tests are sensitive to theme and layout edits: when a fix touches widget
structure or theming, run that package's goldens rather than assuming they are
unaffected.

## Delivery

Report the analyzer command and its scope plus the remaining finding count, the
`dart fix --dry-run` outcome and whether `--apply` was used, the formatter and test
commands with **which** scope was chosen, and any check skipped with the reason.
