---
name: tk-styling
description: >
  Cross-project convention for theming: the palette → ColorScheme → ThemeData →
  StyledWidgets preset pipeline, Material 3 colour roles, typography through the
  TextTheme, and how to read the theme in a widget. Brand-neutral and path-free — the
  repo's own `<repo>-styling` skill supplies the palette and preset files, the
  semantic colours and the named text styles. Triggers on: theming, theme preset,
  ThemeData, ColorScheme, colorScheme, TextTheme, brightness, dark mode, light mode,
  palette, M3 color roles, design tokens, StyledWidgetsTheme.of, context.colors,
  context.theme, Theme.of(context).
user-invocable: true
---

# Styling & Theming — shared convention

Themes are built **once**, at the app shell, from a palette of named constants.
Widgets consume the result through `BuildContext`. No widget builds its own
`ThemeData`, and no widget hardcodes a hex value.

This skill holds the convention. The palette file, the preset entry point, the
repo's semantic colours and its named text styles live in the repo's own styling
skill — read that one too.

It is vendored: copied unchanged from `tk-skills` into each repo that follows it.
Change it there and re-vendor; never edit a copy.

## The pipeline

```
Palette (named hex constants)
  → ColorScheme per Brightness
    → ThemeData (Material)          ─┐
    → StyledWidgetsThemeData         ├─ one preset builder, both brightnesses
    → semantic colour accessors     ─┘
      → app shell (theme mode, optional per-entity preset) → pages
```

The preset builder is the **only** place that turns palette constants into themes.
Reusable visual behaviour is added there, never in a widget.

## Reading the theme

Use the repo's `BuildContext` extensions where they exist:

```dart
context.theme       // ThemeData
context.colors      // ColorScheme — M3 roles
context.s           // localized strings
```

**Never alias the getter into a local** (`final theme = Theme.of(context);`). Call it
inline. This is about aliasing, not reuse: a derived *value* used two or more times
may stay local (`final headline = context.theme.textTheme.h3;`). Getters with no
`BuildContext` counterpart — `StyledWidgetsTheme.of(context)`, `IconTheme.of(context)`
— are not covered and may stay local.

```bash
rg -n "final \w+ = (Theme|S)\.of\(context\)" lib packages apps -g "*.dart"
```

Where a convenience getter does not exist in a repo, don't invent one mid-feature:
match the file you're in and propose adding the extension as its own change.

## Colour rules

- **Material 3 roles only.** Never the removed M2 spellings (`background`,
  `onBackground`, `surfaceVariant`).
- **No hex, `Colors.white` or `Colors.black` in a widget** — not even "just for this
  one border". It breaks dark mode silently.
- Status colours come from the palette's semantic entries (`success`, `warning`,
  `error`), never from `Colors.green`/`Colors.orange`/`Colors.red`.
- Adding a colour:
  1. Add a named constant to the palette — *semantic* (`success`, `cardSurface`,
     `placeholder`), not descriptive (`lightBlue2`).
  2. Expose it brightness-aware: a getter on the `ColorScheme` extension, or a field
     on the `ThemeExtension`, whichever the repo already uses. Where a repo has
     neither, map it onto an M3 role in the preset rather than starting a third
     mechanism.
  3. Fill in **both** brightnesses. A colour that exists only for light mode is an
     unfinished colour.
- Light/dark differences belong inside the `ColorScheme` builder, not in a widget.
  Never branch on `Theme.of(context).brightness` in a widget — push the difference
  into the scheme.

Before treating a `ThemeExtension` as the repo's mechanism, check it is actually
registered in the preset's `extensions:` **and** read somewhere. An unwired extension
class is scaffolding, not the mechanism: wire it up deliberately or delete it, but
don't half-adopt it.

## Typography

Type comes from the theme's `TextTheme`. Where a repo extends it with named getters
(`h0`–`h6`, button and link styles), use those instead of a bare `TextStyle`. If a
style is missing, add a getter so it exists once; in a repo without such an extension,
use the nearest M3 role and `copyWith` only the property that genuinely differs.

Bundle font assets with the package rather than fetching them at runtime: text then
renders identically offline, and no user IP address reaches a third-party CDN.

## Component tokens

Spacing, radii and component defaults belong to the component library, not here. Read
them from the theme (`StyledWidgetsTheme.of(context).sharedLayout.…`) instead of
repeating a value as a literal, and consult the library's own guide for what exists.

## Per-entity theming

Where each entity (a list, a site, a tenant) carries its own preset, resolve it
**without** `BuildContext` so it works in builders and isolates:

```dart
final scheme = entity.effectiveThemePreset.colorScheme(brightness);
```

## Don'ts

- No local `ThemeData` or `Theme(data: …)` wrapper to restyle one widget. Add the
  behaviour to the preset, or use a per-instance override the component already
  supports.
- No `copyWith` chains on the global theme inside a page to make one screen different.
- No new colour, radius or padding literal where a token exists.
- Don't fork a component's colours to match a design detail — check whether the
  component takes a token or an override first.

## Verification

A theme change is repo-wide by construction. Run the package's **golden tests** —
theme edits are exactly what they exist to catch; an intentional visual change means
regenerating goldens in the same change, never deleting the test. Check light **and**
dark, and a narrow window if spacing or layout tokens moved. Run the analyzer:
removed M2 roles surface there.
