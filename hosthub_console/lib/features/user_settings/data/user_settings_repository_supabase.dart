import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/shared/models/models.dart';
import 'package:hosthub_console/features/user_settings/data/user_settings_repository.dart';

class UserSettingsRepositorySupabase extends SupabaseRepository
    implements UserSettingsRepository {
  UserSettingsRepositorySupabase({required SupabaseClient supabase})
    : super(supabase);

  UserSettings? _cachedSettings;

  @override
  Future<UserSettings?> fetch(String profileId) async {
    try {
      final row = await maybeSingle(
        UserSettings.tableName,
        eq: {'profile_id': profileId},
      );
      return row == null ? null : UserSettings.fromJson(row);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: const {'op': 'fetch'},
      );
    }
  }

  @override
  Future<UserSettings> loadOrCreateDefaults(
    String profileId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _cachedSettings != null &&
        _cachedSettings!.profileId == profileId) {
      return _cachedSettings!;
    }

    final settings = await fetch(profileId) ?? UserSettings.defaults(profileId);
    _cachedSettings = settings;
    return settings;
  }

  @override
  Future<UserSettings> save(UserSettings settings) async {
    try {
      final response = await supabase
          .from(UserSettings.tableName)
          .upsert(settings.toJson(), onConflict: 'profile_id')
          .select()
          .maybeSingle();

      if (response == null) {
        throw StateError('No user settings returned after save.');
      }

      final saved = UserSettings.fromJson(Map<String, dynamic>.from(response));
      _cachedSettings = saved;
      return saved;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: const {'op': 'save'},
      );
    }
  }
}
