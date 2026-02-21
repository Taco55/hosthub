import 'package:shared_preferences/shared_preferences.dart';

import 'package:hosthub_console/shared/models/auth/token_response.dart';

class LocalStorageManager {
  static const String _hasCompletedOnboardingKey =
      'hosthub_console_has_completed_onboarding';
  static const String _isFirstLoginKey = 'hosthub_console_is_first_login';
  static const String _tokenKey = 'token';

  final SharedPreferences _prefs;

  LocalStorageManager({required SharedPreferences prefs}) : _prefs = prefs;

  bool getHasCompletedOnboarding() {
    return _prefs.getBool(_hasCompletedOnboardingKey) ?? false;
  }

  Future<void> setHasCompletedOnboarding(bool value) async {
    await _prefs.setBool(_hasCompletedOnboardingKey, value);
  }

  Future<void> setIsFirstLogin(bool value) async {
    await _prefs.setBool(_isFirstLoginKey, value);
  }

  static Future<bool> saveToken(TokenResponse token) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.setString(_tokenKey, token.toRawJson());
  }

  static Future<TokenResponse?> getToken() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final tokenJson = sharedPrefs.getString(_tokenKey);
    if (tokenJson == null) {
      return null;
    }
    return TokenResponse.fromRawJson(tokenJson);
  }

  static Future<void> clearToken() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.remove(_tokenKey);
  }
}
