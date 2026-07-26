HostHub Console Theme Guide
===========================

How this app builds its themes and where to change colors, typography and
component defaults. Cross-project conventions (M3-only, no local `ThemeData`, no
hex in widgets) live in `AGENTS_CORE.md` and the `tk-styling` skill; this file is
only about where things are in *this* app.


Entry point
-----------

`lib/app/app.dart` builds both themes once, per brightness:

```dart
final lightTheme = HosthubThemePreset.applyMaterialTheme(
  baseTheme: ThemeData.light(),
  brightness: Brightness.light,
);
final darkTheme = HosthubThemePreset.applyMaterialTheme(
  baseTheme: ThemeData.dark(),
  brightness: Brightness.dark,
);
```

and hands them to `MaterialApp` together with `themeMode` from `ThemeModeCubit`
and the StyledWidgets theme from `HosthubThemePreset.styledTheme(...)`. Anything
you change in the preset shows up on every screen.


The pipeline
------------

```
HosthubDiploraV1Palette          hex constants, semantically named
  → HosthubThemePreset.materialColorScheme(brightness)
    → applyMaterialTheme(baseTheme:, brightness:)   ThemeData (+ theme extensions)
    → styledTheme(lightMaterialTheme:)              StyledWidgetsThemeData
```

All of it lives in `hosthub_diplora_v1_theme_preset.dart`: palette and preset in
one file, because there is one brand here.

| Layer | Where |
|---|---|
| Palette constants | `HosthubDiploraV1Palette` |
| M3 color roles per brightness | `HosthubThemePreset.materialColorScheme` |
| `ThemeData` + component defaults | `HosthubThemePreset.applyMaterialTheme` |
| StyledWidgets tokens | `HosthubThemePreset.styledTheme` |
| Text style extensions | `custom_text_theme.dart` |
| Context getters | `../utils/context_extensions.dart` |
| Timeline calendar tuning | `timeline_calendar_theme.dart` |

`flex_color_scheme` is still a dependency, but only for the `FlexScheme` enum
that `ThemeCubit` carries — it does **not** build these themes.


Reading the theme in a widget
-----------------------------

```dart
context.theme                  // ThemeData
context.colors                 // ColorScheme — M3 roles
context.theme.textTheme.h3     // CustomTextTheme getters
StyledWidgetsTheme.of(context) // StyledWidgets tokens (spacing, radii, …)
```

Never alias these into a local (`final theme = Theme.of(context)`), never build a
local `ThemeData`, and never hardcode a hex or `Colors.white` in a widget — see
`tk-styling` for the reasoning and the exceptions.


Adding a color
--------------

1. Add a named constant to `HosthubDiploraV1Palette` — semantic (`success`,
   `outlineGrey`), not descriptive (`lightBlue2`).
2. Map it onto an M3 role in `materialColorScheme`, or onto the component token
   that needs it in `applyMaterialTheme` / `styledTheme`.
3. Fill in both brightnesses. A color that only exists for light mode is
   unfinished.

For a value that belongs to one app-local widget rather than the whole app, give
that widget a `ThemeExtension` — `TimelineCalendarTheme` is the worked example,
including how to make a single field brightness-dependent while the rest of the
extension stays shared.


Typography
----------

`custom_text_theme.dart` extends `TextTheme` with the design's named styles:
`h0`–`h6`, `buttonExtraSmall/Small/Medium`, `linkMedium`, `bodyExtraLarge`. Use
those instead of a bare `TextStyle`; if one is missing, add a getter there so it
exists once.


A note on `app_colors.dart`
---------------------------

`AppColors` is a `ThemeExtension` with light/dark defaults and a
`ThemeData.appColors` getter, and `HosthubThemePreset.appColorsForTheme` can
build one — but **nothing uses either today**: `AppColors` is not registered in
`applyMaterialTheme`'s `extensions:`, and no widget reads it. Treat it as
scaffolding, not as the way to add a semantic color: use the palette + M3 roles
above, or a widget-local extension. Either wire `AppColors` up deliberately or
delete it; don't half-adopt it.


Before committing a theme change
--------------------------------

1. Run the golden tests in this package — theme edits are what they exist for. An
   intentional visual change means regenerating goldens in the same change.
2. Check light **and** dark.
3. `theme_preset_test.dart` pins the decisions that must not drift; add a case
   when you make a new one.
4. Check a narrow window if spacing or layout tokens moved.
