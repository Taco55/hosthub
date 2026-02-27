import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(_initialLocale()) {
    _setTimeagoLocale(state.languageCode);
  }

  static Locale _initialLocale() {
    final platformLocale = ui.PlatformDispatcher.instance.locale;
    final languageCode = platformLocale.languageCode.toLowerCase();
    return switch (languageCode) {
      'nl' => const Locale('nl'),
      _ => const Locale('en'),
    };
  }

  void _setTimeagoLocale(String languageCode) {
    switch (languageCode) {
      case 'nl':
        timeago.setLocaleMessages('nl', timeago.NlMessages());
      default:
        timeago.setLocaleMessages('en', timeago.EnMessages());
    }
  }

  // Locale get getCurrentLanguage => switch (state.languageCode) {
  //       'nl' => const Locale('nl'),
  //       _ => const Locale('en'),
  //     };

  void changeStartLang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('lang');
    if (langCode != null) {
      emit(Locale(langCode, ''));
      _setTimeagoLocale(langCode);
    }
  }

  void changeLang(context, String languageCode) async {
    emit(Locale(languageCode, ''));
    _setTimeagoLocale(languageCode);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', languageCode);
  }
}
