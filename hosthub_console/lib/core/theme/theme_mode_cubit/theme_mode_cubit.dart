import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hosthub_console/shared/l10n/l10n.dart';

class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit({ThemeMode? themeMode}) : super(themeMode ?? ThemeMode.system);

  void toggleThemeMode() async {
    var newThemeMode = state == ThemeMode.light
        ? ThemeMode.dark
        : state == ThemeMode.dark
        ? ThemeMode.system
        : ThemeMode.light;

    emit(newThemeMode);

    // Update SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', newThemeMode.toString());
  }

  void updateWithThemeMode(ThemeMode themeMode) async {
    if (themeMode != state) {
      emit(themeMode);

      // Update SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('themeMode', themeMode.toString());
    }
  }

  void changeInitialThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeMode = prefs.getString('themeMode');
    if (themeMode != null) {
      ThemeMode newThemeMode;
      switch (themeMode) {
        case "ThemeMode.light":
          newThemeMode = ThemeMode.light;
          break;
        case "ThemeMode.dark":
          newThemeMode = ThemeMode.dark;
          break;
        default:
          newThemeMode = ThemeMode.system;
      }
      emit(newThemeMode);
    } else {
      emit(ThemeMode.system);
    }
  }

  String get localizedName => state.localizedName;
}

extension ThemeModeExtension on ThemeMode {
  String get localizedName {
    switch (this) {
      case ThemeMode.light:
        return S.current.lightMode;
      case ThemeMode.dark:
        return S.current.darkMode;
      case ThemeMode.system:
        return S.current.systemSetting;
    }
  }

  IconData icon(Brightness platformBrightness) {
    switch (this) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return platformBrightness == Brightness.light
            ? Icons.light_mode
            : Icons.dark_mode;
    }
  }
}
