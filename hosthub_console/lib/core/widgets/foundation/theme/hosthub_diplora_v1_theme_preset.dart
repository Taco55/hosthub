import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'app_colors.dart';
import 'timeline_calendar_theme.dart';

abstract final class HosthubDiploraV1Palette {
  const HosthubDiploraV1Palette._();

  static const Color primary = Color(0xFF155DBE);
  static const Color secondary = Color(0xFF023550);
  static const Color persianBlue = Color(0xFF0369A0);
  static const Color azureDiplora = Color(0xFF0D9ADB);
  static const Color teal = Color(0xFF01857E);
  static const Color ice = Color(0xFFE2F2FD);
  static const Color backgroundWhite = Color(0xFFF8FAFC);
  static const Color softGrey = Color(0xFFE1E7EF);
  static const Color darkGrey = Color(0xFFB4B8BF);

  /// Design-system text roles (Just Organize): readable secondary text and
  /// the outline/footnote grey. `darkGrey` above is too light for text on
  /// light surfaces and stays for decorative use only.
  static const Color textVariant = Color(0xFF44474E);
  static const Color outlineGrey = Color(0xFF74777F);
  static const Color searchPlaceholder = Color(0xFF7794A7);
  static const Color success = Color(0xFF099773);
  static const Color warning = Color(0xFFF68F46);
  static const Color error = Color(0xFFEB5757);

  /// [success] darkened towards [secondary] for use as **small text**.
  ///
  /// `success` itself only reaches ~3.7:1 on white — enough for an icon or a
  /// bar (non-text contrast), short of AA for a 10-11px label. Derived rather
  /// than authored as a second hex so the two greens cannot drift apart.
  static final Color successText = Color.lerp(success, secondary, 0.35)!;

  /// [warning] darkened on the same principle as [successText].
  static final Color warningText = Color.lerp(warning, secondary, 0.4)!;
  static const Color errorSoft = Color(0x33EB5757);
  static const Color surfaceDark = Color(0xFF0C1B26);
  static const Color surfaceContainerDark = Color(0xFF132433);
  static const Color outlineDark = Color(0xFF2D3B45);
  static const Color onSurfaceDark = Color(0xFFE6EFF6);
  static const Color onSurfaceVariantDark = Color(0xFF8AA0AF);
}

abstract final class HosthubThemePreset {
  const HosthubThemePreset._();

  static ColorScheme materialColorScheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return ColorScheme.fromSeed(
      seedColor: HosthubDiploraV1Palette.primary,
      brightness: brightness,
    ).copyWith(
      primary: HosthubDiploraV1Palette.primary,
      onPrimary: Colors.white,
      primaryContainer: HosthubDiploraV1Palette.ice,
      onPrimaryContainer: HosthubDiploraV1Palette.secondary,
      secondary: HosthubDiploraV1Palette.secondary,
      onSecondary: Colors.white,
      secondaryContainer: HosthubDiploraV1Palette.persianBlue,
      onSecondaryContainer: Colors.white,
      tertiary: HosthubDiploraV1Palette.teal,
      onTertiary: Colors.white,
      tertiaryContainer: HosthubDiploraV1Palette.azureDiplora,
      onTertiaryContainer: Colors.white,
      // `--jo-surface` is #FFFFFF: the card and page plane. Ice is
      // `primaryContainer` — the sidebar and active states — not the surface.
      // Anything that falls back to `surface` (table rows, stat tiles, plain
      // containers) was inheriting the sidebar tint while this said ice.
      surface: isLight ? Colors.white : HosthubDiploraV1Palette.surfaceDark,
      onSurface: isLight ? HosthubDiploraV1Palette.secondary : Colors.white,
      surfaceContainerHighest: isLight
          ? HosthubDiploraV1Palette.backgroundWhite
          : HosthubDiploraV1Palette.surfaceContainerDark,
      outlineVariant: isLight
          ? HosthubDiploraV1Palette.softGrey
          : HosthubDiploraV1Palette.outlineDark,
      onSurfaceVariant: isLight
          ? HosthubDiploraV1Palette.textVariant
          : HosthubDiploraV1Palette.onSurfaceVariantDark,
      outline: isLight
          ? HosthubDiploraV1Palette.outlineGrey
          : HosthubDiploraV1Palette.onSurfaceVariantDark,
      error: HosthubDiploraV1Palette.error,
      onError: Colors.white,
      errorContainer: HosthubDiploraV1Palette.errorSoft,
      onErrorContainer: HosthubDiploraV1Palette.error,
    );
  }

  static ThemeData applyMaterialTheme({
    required ThemeData baseTheme,
    required Brightness brightness,
  }) {
    final colorScheme = materialColorScheme(brightness);
    return baseTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? Colors.white
          : colorScheme.surface,
      canvasColor: colorScheme.surface,
      dividerColor: colorScheme.outlineVariant,
      iconTheme: baseTheme.iconTheme.copyWith(size: 24),
      extensions: [
        ...baseTheme.extensions.values,
        // `TimelineCalendar` is app-local, so its density and past-booking
        // treatment have no `styled_widgets` preset group to live in. Reading
        // them from here is what keeps them out of `reservations_page.dart`.
        TimelineCalendarTheme.standard,
      ],
    );
  }

  static AppColors appColorsForTheme({
    required ThemeData theme,
    required bool isDark,
  }) {
    final colorScheme = theme.colorScheme;
    if (isDark) {
      return AppColors(
        settingsBackgroundColor: HosthubDiploraV1Palette.surfaceDark,
        themedBackgroundColor: colorScheme.primary,
        onThemedBackgroundColor: colorScheme.onPrimary,
        settingsSectionHeaderAndFooterColor:
            HosthubDiploraV1Palette.onSurfaceVariantDark,
        settingsTileBackgroundColor:
            HosthubDiploraV1Palette.surfaceContainerDark,
        contrastBackgroundSoft: HosthubDiploraV1Palette.surfaceContainerDark,
        contrastBackgroundMedium: HosthubDiploraV1Palette.outlineDark,
        contrastBackgroundHard: HosthubDiploraV1Palette.surfaceDark,
        onContrastBackgroundSoft: HosthubDiploraV1Palette.onSurfaceDark,
        onContrastBackgroundMedium: HosthubDiploraV1Palette.onSurfaceDark,
        onContrastBackgroundHard: HosthubDiploraV1Palette.onSurfaceDark,
        disabledTextColor: const Color(0x80E6EFF6),
        activeButtonColor: HosthubDiploraV1Palette.primary,
        neutralButtonColor: HosthubDiploraV1Palette.onSurfaceVariantDark,
        barrierColor: const Color(0x73000000),
        themedTextFieldBackgroundColor:
            HosthubDiploraV1Palette.surfaceContainerDark,
        onThemedTextFieldBackgroundColor: HosthubDiploraV1Palette.onSurfaceDark,
        bottomAppBarColor: HosthubDiploraV1Palette.surfaceContainerDark,
        itemTileBackground: HosthubDiploraV1Palette.surfaceContainerDark,
        placeholderText: HosthubDiploraV1Palette.onSurfaceVariantDark,
        systemRed: HosthubDiploraV1Palette.error,
        secondaryLabel: HosthubDiploraV1Palette.onSurfaceVariantDark,
        buttonBackground: HosthubDiploraV1Palette.surfaceContainerDark,
        deselectedButtonColor: HosthubDiploraV1Palette.outlineDark,
        buttonPrimary: colorScheme.primary,
        onButtonPrimary: colorScheme.onPrimary,
        buttonDisabled: HosthubDiploraV1Palette.outlineDark,
        onButtonDisabled: const Color(0x80E6EFF6),
      );
    }

    return AppColors(
      settingsBackgroundColor: HosthubDiploraV1Palette.ice,
      themedBackgroundColor: colorScheme.primary,
      onThemedBackgroundColor: colorScheme.onPrimary,
      settingsSectionHeaderAndFooterColor: HosthubDiploraV1Palette.darkGrey,
      settingsTileBackgroundColor: HosthubDiploraV1Palette.backgroundWhite,
      contrastBackgroundSoft: HosthubDiploraV1Palette.backgroundWhite,
      contrastBackgroundMedium: HosthubDiploraV1Palette.softGrey,
      contrastBackgroundHard: HosthubDiploraV1Palette.ice,
      onContrastBackgroundSoft: HosthubDiploraV1Palette.secondary,
      onContrastBackgroundMedium: HosthubDiploraV1Palette.secondary,
      onContrastBackgroundHard: HosthubDiploraV1Palette.secondary,
      disabledTextColor: const Color(0x61023550),
      activeButtonColor: HosthubDiploraV1Palette.primary,
      neutralButtonColor: HosthubDiploraV1Palette.darkGrey,
      barrierColor: const Color(0x26023550),
      themedTextFieldBackgroundColor: HosthubDiploraV1Palette.backgroundWhite,
      onThemedTextFieldBackgroundColor: HosthubDiploraV1Palette.secondary,
      bottomAppBarColor: HosthubDiploraV1Palette.backgroundWhite,
      itemTileBackground: HosthubDiploraV1Palette.backgroundWhite,
      placeholderText: HosthubDiploraV1Palette.searchPlaceholder,
      systemRed: HosthubDiploraV1Palette.error,
      secondaryLabel: HosthubDiploraV1Palette.darkGrey,
      buttonBackground: HosthubDiploraV1Palette.backgroundWhite,
      deselectedButtonColor: HosthubDiploraV1Palette.softGrey,
      buttonPrimary: colorScheme.primary,
      onButtonPrimary: colorScheme.onPrimary,
      buttonDisabled: HosthubDiploraV1Palette.softGrey,
      onButtonDisabled: const Color(0x61023550),
    );
  }

  static StyledWidgetsThemeData styledTheme({
    required ThemeData lightMaterialTheme,
  }) {
    final baseColumnHeaderTextStyle =
        lightMaterialTheme.textTheme.titleSmall ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

    return StyledWidgetsThemeData.defaultsWith(
      sharedComponentColors: (t) =>
          t.copyWith(accent: HosthubDiploraV1Palette.primary),
      sharedLayout: (t) => t.copyWith(
        horizontalPadding: 24,
        surfaceRadius: const BorderRadius.all(Radius.circular(10)),
        fieldRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      // The design's 4px scale (`--jo-space-*`). Stated explicitly even though
      // it matches the library defaults: screens read gaps from here via
      // `context.styledSpacing`, so this is the one place the rhythm is set.
      // Nothing off the scale — `6`, `10` and `14` round to a neighbouring
      // step. Widget-internal geometry tuned to something other than page
      // layout belongs in that widget's own group, not here.
      spacing: (t) => t.copyWith(xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32),
      // Design (Just Organize) tile groups: a white bordered card that hugs
      // its rows — no internal vertical padding — with a compact dark-blue
      // sentence-case header and a muted footnote. Content cards (e.g. the
      // editor's Hero/Highlights) opt into their own padding per instance.
      sections: (t) => t.copyWith(
        innerPadding: const EdgeInsets.symmetric(horizontal: 16),
        topPadding: 24,
        firstTopPadding: 0,
        insetBackgroundColor: Colors.white,
        insetBackgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        borderColor: HosthubDiploraV1Palette.softGrey,
        borderColorDark: HosthubDiploraV1Palette.outlineDark,
        borderWidth: 1,
        headerTextColor: HosthubDiploraV1Palette.secondary,
        headerTextStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headerSpacing: 8,
        footerTextColor: HosthubDiploraV1Palette.outlineGrey,
        headerInsideTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15.5,
          height: 1.2,
          letterSpacing: 0,
          fontWeight: FontWeight.w700,
          color: HosthubDiploraV1Palette.secondary,
        ),
        uppercaseHeader: false,
        uppercaseInsideHeader: false,
      ),
      tiles: (t) => t.copyWith(
        minHeight: 44,
        defaultPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
      // Design `.set-card` page chrome: every page pane is a white bordered
      // card on the white page surface (`--jo-surface`, the design `.frame`
      // background — ice blue is the sidebar only); panes carry 24px inner
      // padding.
      webPageScaffold: (t) => t.copyWith(
        decoratePanes: true,
        paneBackgroundColor: Colors.white,
        paneBackgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        paneBorderColor: HosthubDiploraV1Palette.softGrey,
        paneBorderColorDark: HosthubDiploraV1Palette.outlineDark,
        paneBorderRadius: const BorderRadius.all(Radius.circular(12)),
        panePadding: const EdgeInsets.all(24),
        pageBackgroundColor: Colors.white,
        pageBackgroundColorDark: HosthubDiploraV1Palette.surfaceDark,
        // Design `.set-body{padding:26px 30px 40px}` — the previous 64px sides
        // were roughly double the design and read as a huge gap next to the
        // sidebar.
        pagePadding: const EdgeInsets.fromLTRB(30, 26, 30, 40),
        // Design `.set-wide{max-width:1040px;margin:0 auto}`: wide pages centre
        // their content instead of stretching a table across a 27" monitor.
        contentMaxWidth: 1040,
      ),
      // Navigation rail (design §5 + §"Responsieve strategie"): the full menu
      // from 1100px, the pinned icon rail down to 600px — no hamburger, so
      // navigation stays visible — and only below that the hamburger drawer.
      // The design draws the rail at 96px (`.sb2.compact`), but 96 costs the
      // page content ~24px between 600 and 1100px and only buys empty space
      // around the 48px rows — a deliberate deviation, reviewed against the
      // design on 2026-07-24.
      sideMenu: (t) => t.copyWith(
        breakpoints: const StyledSideMenuBreakpoints(
          expandedMin: 1100,
          railMin: 600,
        ),
        expandedWidth: 284,
        railWidth: 72,
        // Labels sit beside the icon on the rail (design §"Label-toegang"), not
        // below it where they would collide with the next row.
        compactLabels: StyledSideMenuCompactLabels.flyout,
      ),
      // Design `.dt th` / `.dt tfoot td`: a **light** header band with a muted
      // grey label — not white-on-primary. A saturated band would become the
      // loudest element on every page and collide with the ice sidebar and ice
      // active states, which are where `primary`/`ice` earn their emphasis; a
      // light band reads as chrome, which is what a header is. Applied here so
      // all four tables in the console change together (reservations, revenue,
      // team, listings) — never per call site.
      //
      // The design uppercases at 10px; we keep sentence case (the preset and
      // every call site already do) and take the design's other header size,
      // `.trow .th` at 600 11.5px, which is legible where 10px caps are not.
      tables: (t) => t.copyWith(
        uppercaseColumnHeaderLabels: false,
        // `.tbl-wrap{border-radius:14px}` — larger than the shared 10px surface
        // radius, which the design reserves for controls.
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        headerBackgroundColor: HosthubDiploraV1Palette.backgroundWhite,
        headerBackgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        columnHeaderTextColorDark: HosthubDiploraV1Palette.onSurfaceVariantDark,
        columnHeaderTextStyle: baseColumnHeaderTextStyle.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: HosthubDiploraV1Palette.outlineGrey,
        ),
        trinaColumnTextStyle: baseColumnHeaderTextStyle.copyWith(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: HosthubDiploraV1Palette.outlineGrey,
          letterSpacing: 0.1,
        ),
      ),
      // Design `.tbtn`: 40x36, radius 10, hairline border, and ice + primary
      // when the control carries an active filter/toggle (`.tbtn.on`) — the
      // same pairing the sidebar uses, and ice in both brightnesses.
      //
      toolbarButton: (t) => t.copyWith(
        buttonWidth: 40,
        buttonHeight: 36,
        iconSize: 20,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderWidth: 1,
        backgroundColor: Colors.white,
        borderColor: HosthubDiploraV1Palette.softGrey,
        iconColor: HosthubDiploraV1Palette.secondary,
        backgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        borderColorDark: HosthubDiploraV1Palette.outlineDark,
        iconColorDark: HosthubDiploraV1Palette.onSurfaceDark,
        selectedBackgroundColor: HosthubDiploraV1Palette.ice,
        selectedBorderColor: HosthubDiploraV1Palette.ice,
        selectedIconColor: HosthubDiploraV1Palette.primary,
      ),
      // Design `.kpi`. Only two values need stating: the label, value and
      // caption styles already resolve to this design's tokens
      // (`outline` / `onSurface` / `onSurfaceVariant`, at 9.5/18/10.5), the
      // surface follows the inset-section card, and the border follows
      // `dividerColor` — all of which are correct in both brightnesses.
      statTiles: (t) => t.copyWith(
        // `.kpi{border-radius:14px}`
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        // `.kpi .kl svg` #b3c2d4 — decorative, which is exactly what
        // `darkGrey` is reserved for, and it reads on light and dark alike.
        iconColor: HosthubDiploraV1Palette.darkGrey,
        // A positive caption is 10.5px text, so it takes the darkened green.
        positiveColor: HosthubDiploraV1Palette.successText,
      ),
      formFields: (t) => t.copyWith(
        input: t.input.copyWith(contentPadding: const EdgeInsets.all(16)),
      ),
      searchFields: (t) => t.copyWith(
        placeholderColor: HosthubDiploraV1Palette.searchPlaceholder,
      ),
      // Also the home of menu-overlay styling, which dropdowns and
      // `StyledToolbarButton.menu` share — hence the check colours for the
      // Filter / Kolommen / Weergave menus living here rather than on
      // `toolbarButton`, so dropdown menus get them too.
      //
      // The green is `Palette.success`, not the prototype's #1F8A4C: it sits in
      // the same cool family as `primary`, it is already the toast success
      // colour, and `BookingSourceIcon`'s Website pastel is a tint of it. A
      // check mark is a graphic, so `success` itself is fine here; small text
      // takes `successText`. Section-header styling needs no override — it
      // resolves to 9.5/w600/0.5 in `outline`, which is the design's `.mhd`.
      dropdowns: (t) => t.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minHeight: 40,
        menuCheckedColor: HosthubDiploraV1Palette.success,
        menuUncheckedColor: HosthubDiploraV1Palette.softGrey,
        menuCheckDisabledColor: HosthubDiploraV1Palette.darkGrey,
      ),
      buttons: (t) => t.copyWith(
        cornerRadius: 12,
        destructiveBackgroundColor: HosthubDiploraV1Palette.errorSoft,
        destructiveBorderColor: HosthubDiploraV1Palette.error,
        destructiveLabelColor: HosthubDiploraV1Palette.error,
      ),
      segmentedControls: (t) => t.copyWith(cornerRadius: 10),
      dialogs: (t) => t.copyWith(
        backgroundColor: HosthubDiploraV1Palette.backgroundWhite,
        backgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        buttonsLayout: DialogButtonsLayout.horizontal,
        buttonAlignment: DialogButtonAlignment.right,
      ),
      toasts: (t) => t.copyWith(
        successBackgroundColor: HosthubDiploraV1Palette.success,
        warningBackgroundColor: HosthubDiploraV1Palette.warning,
        errorBackgroundColor: HosthubDiploraV1Palette.error,
        infoBackgroundColor: HosthubDiploraV1Palette.azureDiplora,
      ),
    );
  }
}
