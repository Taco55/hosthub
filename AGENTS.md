# AGENTS.md

Project-specifieke overlay voor `hosthub_workspace`.
Voor deze repo is dit de bron die Codex/Claude leest.

- Kernregels: @AGENTS_CORE.md (voor Codex: `AGENTS_CORE.md`)
- Per-onderwerp conventies: de `tk-*` skills, zie de tabel in `AGENTS_CORE.md`.

## Alleen repo-specifiek

- Werkruimte bevat o.a. `hosthub_console` (Flutter web), `cloudflare`, `supabase`, `web` (Next.js).
- Single-package app-layout: kies in de `tk-*` skills de kolom "single-package", niet de Melos-kolom.
  Codegen: `dart run build_runner build`, vertalingen: `dart run intl_utils:generate`.
- Analyzer/tests: `fvm flutter analyze` en `fvm flutter test` vanuit `hosthub_console/`.
- Shared package-paden in Flutter volgen: `../../../shared/libraries/<package_name>` met `snake_case`.
  Die libraries liggen **buiten** deze repo en worden door andere projecten gebruikt — zie de
  library-first regel in `AGENTS_CORE.md`.
- Werk direct op `main`; geen feature branches.
