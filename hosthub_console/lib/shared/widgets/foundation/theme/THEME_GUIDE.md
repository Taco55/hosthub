HostHub Theme Guide
====================

This document explains how the HostHub apps construct their global themes and where to change colors, typography, and component defaults. Treat it as the canonical reference before updating anything UI-related.


Entry Point
-----------

* `lib/widgets/src/foundation/theme/app_theme_builder.dart`
* `AppThemeBuilder.build` is the single entry used by both Material and Cupertino shells (see `lib/app.dart`).
  * Every change made in `AppThemeBuilder` or the modules it calls is reflected across the entire app.


Theme Layers
------------

1. **FlexColorScheme**
   * Light and dark seeds are produced by `FlexThemeData.light`/`FlexThemeData.dark`.
   * Color schemes originate from the active `FlexScheme` (read from `ThemeCubit`). Add custom schemes by wiring `FlexSchemeData` into `FlexColor.schemes` or your theme setup.
   * Adjust global properties like `blendLevel`, `visualDensity`, or sub-theme defaults via `FlexSubThemesData`.

2. **AppColors Theme Extension**
   * File: `app_colors.dart` (definition) + `app_colors_builder.dart` (wiring) + `app_colors_defaults.dart` (light/dark fallback constants).
   * Use these when you need semantic colors that are not part of Flutter’s standard `ColorScheme`, e.g. list backgrounds, barrier overlays, or button states.
   * Update `AppColorsDefaults.light`/`dark` to redefine the baseline palette.
   * Access from widgets with:
     ```dart
     final colors = Theme.of(context).extension<AppColors>()!;
     ```

3. **Typography**
   * Current default fonts are set in `AppThemeBuilder.build`:
     * Light theme: `GoogleFonts.interTextTheme(...)`.
     * Dark theme: `ThemeData.dark().textTheme.apply(fontFamily: fontFamily)` where `fontFamily` resolves to `.SF Pro Text` on iOS and falls back elsewhere.
   * Extra text helpers live in `custom_text_theme.dart`.
   * The app-wide `TextTheme` can be swapped or extended by replacing the `textTheme:` assignment in `AppThemeBuilder.build`.

4. **Component Tweaks**
   * `FlexSubThemesData` configures common Material components.
   * For fine-grained control, extend the `baseTheme.copyWith(...)` block in `AppThemeBuilder.build`. Examples:
     * `inputDecorationTheme`, `buttonTheme`, `elevatedButtonTheme`, `chips`, etc.


Updating Colors
---------------

* Use `FlexSchemeData` (from `flex_color_scheme`) for new primary/secondary combinations:
  ```dart
  const FlexSchemeData customScheme = FlexSchemeData(
    name: 'MyScheme',
    light: FlexSchemeColor(
      primary: Color(0xFF...), // etc.
    ),
    dark: FlexSchemeColor(
      primary: Color(0xFF...),
    ),
  );
  ```
* Register the scheme in `FlexColor.schemes` when wiring the list (check `ThemeCubit` or wherever schemes are enumerated).
* For semantic colors (e.g. settings background, button states), change `AppColorsDefaults.light`/`dark`. These values cascade through `AppColorsBuilder` into the extension.


Defining a Custom TextTheme
---------------------------

1. **Create a typography helper (optional but recommended):**
   ```dart
   // packages/core/lib/src/theme/app_typography.dart
   import 'package:flutter/material.dart';
   import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

   class AppTypography {
     static TextTheme light() {
       final base = GoogleFonts.albertSansTextTheme();
       return base.copyWith(
         displayLarge: base.displayLarge?.copyWith(
           fontWeight: FontWeight.w700,
           fontSize: 36,
           height: 1,
           letterSpacing: -0.02 * 36,
         ),
         // Include additional overrides here.
       );
     }

     static TextTheme dark() {
       final base = GoogleFonts.ebGaramondTextTheme();
       return base.copyWith(
         bodyLarge: base.bodyLarge?.copyWith(
           fontWeight: FontWeight.w500,
           fontSize: 18,
           height: 1.2,
         ),
       );
     }
   }
   ```

2. **Wire the helper into `AppThemeBuilder`:**
   ```dart
   final baseTheme = isDark
       ? FlexThemeData.dark(
           scheme: scheme,
           subThemesData: subThemeData,
           textTheme: AppTypography.dark(),
           fontFamily: AppTypography.dark().bodyMedium?.fontFamily,
         )
       : FlexThemeData.light(
           scheme: scheme,
           subThemesData: subThemeData,
           textTheme: AppTypography.light(),
           fontFamily: AppTypography.light().bodyMedium?.fontFamily,
         );
   ```
   *Use `fontFamily` only if you want Flutter to fall back to that family for widgets that don’t read the text theme.*

3. **Expose custom getters in `custom_text_theme.dart`:**
   ```dart
   extension CustomTextTheme on TextTheme {
     TextStyle get h0 => displayLarge!.copyWith(
           fontSize: 48,
           fontStyle: FontStyle.italic,
           letterSpacing: -0.02 * 48,
         );
     TextStyle get buttonMedium => labelLarge!.copyWith(
           fontWeight: FontWeight.w700,
           fontSize: 16,
         );
   }
   ```

4. **Consume the theme:**
   ```dart
   final textTheme = Theme.of(context).textTheme;
   final headline = textTheme.h0;
   final hyperlink = textTheme.bodyMedium?.copyWith(
     decoration: TextDecoration.underline,
     fontWeight: FontWeight.w700,
   );
   ```


FAQ
---

* **Can I keep the default Material text styles and adjust only a few?**  
  Yes. Retrieve the current text theme (`ThemeData.light().textTheme` or similar), then use `.copyWith` for individual styles.

* **Where do platform-specific overrides go?**  
  Adjust the `fontFamily` or `textTheme` assignment inside the `isDark` conditional. You can gate on `Platform.isIOS`/`isAndroid` directly in `AppTypography`.

* **How do I add new semantic colors?**  
  Add fields to `AppColors`, update `copyWith`/`lerp`, provide light/dark defaults, and populate them in `AppColorsBuilder`.


Checklist Before Committing Theme Changes
-----------------------------------------

1. Update or create automated golden tests (if relevant UI surfaces exist).
2. Verify both light and dark modes.
3. Confirm iOS/Android fonts render correctly (pay attention to platform fallbacks).
4. Audit key flows (login, lists, settings) for contrast issues using the new palette/typography.
