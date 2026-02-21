import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color
  settingsBackgroundColor; // -> generalBackgroundColor (light: grey, dark: black)
  final Color themedBackgroundColor;
  final Color onThemedBackgroundColor;
  final Color settingsSectionHeaderAndFooterColor;
  final Color settingsTileBackgroundColor; // light: white, dark: almost black

  final Color themedTextFieldBackgroundColor;
  final Color onThemedTextFieldBackgroundColor;

  final Color contrastBackgroundSoft;
  final Color contrastBackgroundMedium;
  final Color contrastBackgroundHard;

  final Color onContrastBackgroundSoft;
  final Color onContrastBackgroundMedium;
  final Color onContrastBackgroundHard;

  final Color disabledTextColor;
  final Color deselectedButtonColor;

  final Color activeButtonColor;
  final Color neutralButtonColor;

  final Color barrierColor;

  final Color bottomAppBarColor;

  final Color itemTileBackground;
  final Color placeholderText;

  final Color systemRed;

  final Color secondaryLabel;

  final Color buttonBackground;
  final Color buttonPrimary;
  final Color onButtonPrimary;
  final Color buttonDisabled;
  final Color onButtonDisabled;

  const AppColors({
    required this.settingsBackgroundColor,
    required this.themedBackgroundColor,
    required this.onThemedBackgroundColor,
    required this.settingsSectionHeaderAndFooterColor,
    required this.settingsTileBackgroundColor,
    required this.contrastBackgroundSoft,
    required this.contrastBackgroundMedium,
    required this.contrastBackgroundHard,
    required this.onContrastBackgroundSoft,
    required this.onContrastBackgroundMedium,
    required this.onContrastBackgroundHard,
    required this.disabledTextColor,
    required this.activeButtonColor,
    required this.neutralButtonColor,
    required this.barrierColor,
    required this.themedTextFieldBackgroundColor,
    required this.onThemedTextFieldBackgroundColor,
    required this.bottomAppBarColor,
    required this.itemTileBackground,
    required this.placeholderText,
    required this.systemRed,
    required this.secondaryLabel,
    required this.buttonBackground,
    required this.deselectedButtonColor,
    required this.buttonPrimary,
    required this.onButtonPrimary,
    required this.buttonDisabled,
    required this.onButtonDisabled,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? settingsBackgroundColor,
    Color? themedBackgroundColor,
    Color? onThemedBackgroundColor,
    Color? settingsSectionHeaderAndFooterColor,
    Color? settingsTileBackgroundColor,
    Color? contrastBackgroundSoft,
    Color? contrastBackgroundMedium,
    Color? contrastBackgroundHard,
    Color? onContrastBackgroundSoft,
    Color? onContrastBackgroundMedium,
    Color? onContrastBackgroundHard,
    Color? disabledTextColor,
    Color? activeButtonColor,
    Color? neutralButtonColor,
    Color? barrierColor,
    Color? themedTextFieldBackgroundColor,
    Color? onThemedTextFieldBackgroundColor,
    Color? bottomAppBarColor,
    Color? itemTileBackground,
    Color? placeholderText,
    Color? systemRed,
    Color? secondaryLabel,
    Color? buttonBackground,
    Color? deselectedButtonColor,
    Color? buttonPrimary,
    Color? onButtonPrimary,
    Color? buttonDisabled,
    Color? onButtonDisabled,
  }) {
    return AppColors(
      settingsBackgroundColor:
          settingsBackgroundColor ?? this.settingsBackgroundColor,
      themedBackgroundColor:
          themedBackgroundColor ?? this.themedBackgroundColor,
      onThemedBackgroundColor:
          onThemedBackgroundColor ?? this.onThemedBackgroundColor,
      settingsSectionHeaderAndFooterColor:
          settingsSectionHeaderAndFooterColor ??
          this.settingsSectionHeaderAndFooterColor,
      settingsTileBackgroundColor:
          settingsTileBackgroundColor ?? this.settingsTileBackgroundColor,
      contrastBackgroundSoft:
          contrastBackgroundSoft ?? this.contrastBackgroundSoft,
      contrastBackgroundMedium:
          contrastBackgroundMedium ?? this.contrastBackgroundMedium,
      contrastBackgroundHard:
          contrastBackgroundHard ?? this.contrastBackgroundHard,
      onContrastBackgroundSoft:
          onContrastBackgroundSoft ?? this.onContrastBackgroundSoft,
      onContrastBackgroundMedium:
          onContrastBackgroundMedium ?? this.onContrastBackgroundMedium,
      onContrastBackgroundHard:
          onContrastBackgroundHard ?? this.onContrastBackgroundHard,
      disabledTextColor: disabledTextColor ?? this.disabledTextColor,
      activeButtonColor: activeButtonColor ?? this.activeButtonColor,
      neutralButtonColor: neutralButtonColor ?? this.neutralButtonColor,
      barrierColor: barrierColor ?? this.barrierColor,
      themedTextFieldBackgroundColor:
          themedTextFieldBackgroundColor ?? this.themedTextFieldBackgroundColor,
      onThemedTextFieldBackgroundColor:
          onThemedTextFieldBackgroundColor ??
          this.onThemedTextFieldBackgroundColor,
      bottomAppBarColor: bottomAppBarColor ?? this.bottomAppBarColor,
      itemTileBackground: itemTileBackground ?? this.itemTileBackground,
      placeholderText: placeholderText ?? this.placeholderText,
      systemRed: systemRed ?? this.systemRed,
      secondaryLabel: secondaryLabel ?? this.secondaryLabel,
      buttonBackground: buttonBackground ?? this.buttonBackground,
      deselectedButtonColor:
          deselectedButtonColor ?? this.deselectedButtonColor,
      buttonPrimary: buttonPrimary ?? this.buttonPrimary,
      onButtonPrimary: onButtonPrimary ?? this.onButtonPrimary,
      buttonDisabled: buttonDisabled ?? this.buttonDisabled,
      onButtonDisabled: onButtonDisabled ?? this.onButtonDisabled,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      settingsBackgroundColor: Color.lerp(
        settingsBackgroundColor,
        other.settingsBackgroundColor,
        t,
      )!,
      themedBackgroundColor: Color.lerp(
        themedBackgroundColor,
        other.themedBackgroundColor,
        t,
      )!,
      onThemedBackgroundColor: Color.lerp(
        onThemedBackgroundColor,
        other.onThemedBackgroundColor,
        t,
      )!,
      settingsSectionHeaderAndFooterColor: Color.lerp(
        settingsSectionHeaderAndFooterColor,
        other.settingsSectionHeaderAndFooterColor,
        t,
      )!,
      settingsTileBackgroundColor: Color.lerp(
        settingsTileBackgroundColor,
        other.settingsTileBackgroundColor,
        t,
      )!,
      contrastBackgroundSoft: Color.lerp(
        contrastBackgroundSoft,
        other.contrastBackgroundSoft,
        t,
      )!,
      contrastBackgroundMedium: Color.lerp(
        contrastBackgroundMedium,
        other.contrastBackgroundMedium,
        t,
      )!,
      contrastBackgroundHard: Color.lerp(
        contrastBackgroundHard,
        other.contrastBackgroundHard,
        t,
      )!,
      onContrastBackgroundSoft: Color.lerp(
        onContrastBackgroundSoft,
        other.onContrastBackgroundSoft,
        t,
      )!,
      onContrastBackgroundMedium: Color.lerp(
        onContrastBackgroundMedium,
        other.onContrastBackgroundMedium,
        t,
      )!,
      onContrastBackgroundHard: Color.lerp(
        onContrastBackgroundHard,
        other.onContrastBackgroundHard,
        t,
      )!,
      disabledTextColor: Color.lerp(
        disabledTextColor,
        other.disabledTextColor,
        t,
      )!,
      activeButtonColor: Color.lerp(
        activeButtonColor,
        other.activeButtonColor,
        t,
      )!,
      neutralButtonColor: Color.lerp(
        neutralButtonColor,
        other.neutralButtonColor,
        t,
      )!,
      barrierColor: Color.lerp(barrierColor, other.barrierColor, t)!,
      themedTextFieldBackgroundColor: Color.lerp(
        themedTextFieldBackgroundColor,
        other.themedTextFieldBackgroundColor,
        t,
      )!,
      onThemedTextFieldBackgroundColor: Color.lerp(
        onThemedTextFieldBackgroundColor,
        other.onThemedTextFieldBackgroundColor,
        t,
      )!,
      bottomAppBarColor: Color.lerp(
        bottomAppBarColor,
        other.bottomAppBarColor,
        t,
      )!,
      itemTileBackground: Color.lerp(
        itemTileBackground,
        other.itemTileBackground,
        t,
      )!,
      placeholderText: Color.lerp(placeholderText, other.placeholderText, t)!,
      systemRed: Color.lerp(systemRed, other.systemRed, t)!,
      secondaryLabel: Color.lerp(secondaryLabel, other.secondaryLabel, t)!,
      buttonBackground: Color.lerp(
        buttonBackground,
        other.buttonBackground,
        t,
      )!,
      deselectedButtonColor: Color.lerp(
        deselectedButtonColor,
        other.deselectedButtonColor,
        t,
      )!,
      buttonPrimary: Color.lerp(buttonPrimary, other.buttonPrimary, t)!,
      onButtonPrimary: Color.lerp(onButtonPrimary, other.onButtonPrimary, t)!,
      buttonDisabled: Color.lerp(buttonDisabled, other.buttonDisabled, t)!,
      onButtonDisabled: Color.lerp(
        onButtonDisabled,
        other.onButtonDisabled,
        t,
      )!,
    );
  }

  static AppColors get light => const AppColors(
    settingsBackgroundColor: Color(0xFFFFFFFF),
    themedBackgroundColor: Color(0xFFFFFFFF),
    onThemedBackgroundColor: Color(0xFF000000),
    settingsSectionHeaderAndFooterColor: Color(0x993C3C43),
    settingsTileBackgroundColor: Color(0xFFFFFFFF),
    contrastBackgroundSoft: Color(0xFFF8F8F8),
    contrastBackgroundMedium: Color(0xFFE0E0E0),
    contrastBackgroundHard: Color(0xFFF5F5F7),
    onContrastBackgroundSoft: Color(0xFF606060),
    onContrastBackgroundMedium: Color(0xFF202020),
    onContrastBackgroundHard: Color(0xFF000000),
    activeButtonColor: Color(0xFF0066FF),
    neutralButtonColor: Color(0xFFAAAAAA),
    disabledTextColor: Color(0xFF999999),
    deselectedButtonColor: Color(0xFFE0E0E0),
    buttonBackground: Color(0xFFECECEC),
    themedTextFieldBackgroundColor: Color(0xFFF0F0F0),
    onThemedTextFieldBackgroundColor: Color(0xFF000000),
    bottomAppBarColor: Color(0xFFEEEEEE),
    itemTileBackground: Color(0xFFFFFFFF),
    placeholderText: Color(0x4C3C3C43),
    systemRed: Color(0xFFFF3B30),
    secondaryLabel: Color(0xFF8E8E93),
    barrierColor: Color(0x1F000000),
    buttonPrimary: Color(0xFF0066FF),
    onButtonPrimary: Color(0xFFFFFFFF),
    buttonDisabled: Color(0xFFE0E0E0),
    onButtonDisabled: Color(0xFF999999),
  );

  static AppColors get dark => const AppColors(
    settingsBackgroundColor: Color(0xFFFFFFFF),
    themedBackgroundColor: Color(0xFF1C1C1E),
    onThemedBackgroundColor: Color(0xFFFFFFFF),
    settingsSectionHeaderAndFooterColor: Color(0xFF8E8E93),
    settingsTileBackgroundColor: Color(0xFF2C2C2E),
    contrastBackgroundSoft: Color(0xFF1C1C1E),
    contrastBackgroundMedium: Color(0xFF2C2C2E),
    contrastBackgroundHard: Color(0xFFF5F5F7),
    onContrastBackgroundSoft: Color(0xFF8E8E93),
    onContrastBackgroundMedium: Color(0xFFCCCCCC),
    onContrastBackgroundHard: Color(0xFFFFFFFF),
    activeButtonColor: Color(0xFF0A84FF),
    neutralButtonColor: Color(0xFF636366),
    disabledTextColor: Color(0xFF5E5E5E),
    deselectedButtonColor: Color(0xFF3A3A3C),
    buttonBackground: Color(0xFF2C2C2E),
    themedTextFieldBackgroundColor: Color(0xFF3A3A3C),
    onThemedTextFieldBackgroundColor: Color(0xFFFFFFFF),
    bottomAppBarColor: Color(0xFF1C1C1E),
    itemTileBackground: Color(0xFF2C2C2E),
    placeholderText: Color(0x4CEBEBF5),
    systemRed: Color(0xFFFF453A),
    secondaryLabel: Color(0xFF8E8E93),
    barrierColor: Color(0x73000000),
    buttonPrimary: Color(0xFF0A84FF),
    onButtonPrimary: Color(0xFFFFFFFF),
    buttonDisabled: Color(0xFF3A3A3C),
    onButtonDisabled: Color(0xFF5E5E5E),
  );
}

extension AppThemeExtension on ThemeData {
  AppColors get appColors {
    final colors = extension<AppColors>();
    if (colors != null) {
      return colors;
    }
    // Fallback to avoid crashes when the theme extension is not wired yet.
    return brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  }
}
