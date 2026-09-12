# AGENTS.md

Project-specifieke overlay voor `hosthub_workspace`.
Voor deze repo is dit de bron die Codex/Claude leest.

- Kernregels: @AGENTS_CORE.md (voor Codex: `AGENTS_CORE.md`)
- Per-onderwerp conventies: de skills van deze repo, zie hieronder.

## Project skills

- `.agents/skills` is de enige bron voor repo-specifieke skills. `.claude/skills` is een symlink naar `.agents/skills`.
- Lees de relevante skill voordat je aan dat gebied begint:
  - Thema, kleuren, typografie, `HosthubThemePreset`, tokens: `.agents/skills/hosthub-styling/SKILL.md`
- Nog niet aanwezig, maar wel voorgeschreven door `AGENTS_CORE.md`: skills voor feature-architectuur,
  StyledWidgets-afwijkingen, localisatie, Supabase en dart-analysis. Schrijf er een zodra een gebied
  meer dan eenmalige uitleg nodig heeft.
- De generieke StyledWidgets-component-API staat niet in deze repo: die hoort bij de library zelf,
  als de `styled-widgets` skill.

## Alleen repo-specifiek

- Werkruimte bevat o.a. `hosthub_console` (Flutter web), `cloudflare`, `supabase`, `web` (Next.js).
- Single-package app-layout, geen Melos-monorepo: commando's draaien vanuit `hosthub_console/`.
  Codegen: `dart run build_runner build`, vertalingen: `dart run intl_utils:generate`.
- Analyzer/tests: `fvm flutter analyze` en `fvm flutter test` vanuit `hosthub_console/`.
- Shared package-paden in Flutter volgen: `../../../shared/libraries/<package_name>` met `snake_case`.
  Die libraries liggen **buiten** deze repo en worden door andere projecten gebruikt — zie de
  library-first regel in `AGENTS_CORE.md`.
- Werk direct op `main`; geen feature branches.
- **Nooit git worktrees.** Geen `git worktree add`, geen agents of achtergrondtaken in een
  eigen worktree, ook niet "even geïsoleerd". Alles gebeurt in deze checkout. Een worktree
  onder de repo is een geneste checkout die de kans loopt meegecommit te worden; daarom
  staat `**/.claude/worktrees/` ook in `.gitignore`.
