import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'app_colors.dart';

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
  static const Color searchPlaceholder = Color(0xFF7794A7);
  static const Color success = Color(0xFF099773);
  static const Color warning = Color(0xFFF68F46);
  static const Color error = Color(0xFFEB5757);
  static const Color errorSoft = Color(0x33EB5757);
  static const Color surfaceDark = Color(0xFF0C1B26);
  static const Color surfaceContainerDark = Color(0xFF132433);
  static const Color outlineDark = Color(0xFF2D3B45);
  static const Color onSurfaceDark = Color(0xFFE6EFF6);
  static const Color onSurfaceVariantDark = Color(0xFF8AA0AF);
}

abstract final class HosthubDiploraV1ThemePreset {
  const HosthubDiploraV1ThemePreset._();

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
      surface: isLight
          ? HosthubDiploraV1Palette.ice
          : HosthubDiploraV1Palette.surfaceDark,
      onSurface: isLight
          ? HosthubDiploraV1Palette.secondary
          : HosthubDiploraV1Palette.onSurfaceDark,
      surfaceContainerHighest: isLight
          ? HosthubDiploraV1Palette.backgroundWhite
          : HosthubDiploraV1Palette.surfaceContainerDark,
      outlineVariant: isLight
          ? HosthubDiploraV1Palette.softGrey
          : HosthubDiploraV1Palette.outlineDark,
      onSurfaceVariant: isLight
          ? HosthubDiploraV1Palette.darkGrey
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
    final onPrimary = lightMaterialTheme.colorScheme.onPrimary;
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
      sections: (t) => t.copyWith(
        innerPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        topPadding: 20,
        firstTopPadding: 16,
        backgroundColor: HosthubDiploraV1Palette.backgroundWhite,
        backgroundColorDark: HosthubDiploraV1Palette.surfaceContainerDark,
        headerTextColor: HosthubDiploraV1Palette.secondary,
        headerInsideTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          height: 1,
          letterSpacing: 0,
          fontWeight: FontWeight.w600,
          color: HosthubDiploraV1Palette.secondary,
        ),
        uppercaseHeader: false,
        uppercaseInsideHeader: false,
      ),
      tables: (t) => t.copyWith(
        uppercaseColumnHeaderLabels: false,
        columnHeaderTextStyle: baseColumnHeaderTextStyle.copyWith(
          fontWeight: FontWeight.w600,
          color: onPrimary,
        ),
        trinaColumnTextStyle: baseColumnHeaderTextStyle.copyWith(
          fontWeight: FontWeight.w700,
          color: onPrimary,
          letterSpacing: 0.1,
        ),
      ),
      fields: (t) => t.copyWith(
        contentPadding: const EdgeInsets.all(16),
        dropdownContentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        dropdownHeight: 40,
        searchFieldPlaceholderColor: HosthubDiploraV1Palette.searchPlaceholder,
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
