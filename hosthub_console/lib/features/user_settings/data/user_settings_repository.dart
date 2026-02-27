import 'package:hosthub_console/core/models/models.dart';

abstract class UserSettingsRepository {
  Future<UserSettings?> fetch(String profileId);
  Future<UserSettings> loadOrCreateDefaults(
    String profileId, {
    bool forceRefresh = false,
  });
  Future<UserSettings> save(UserSettings settings);
}
