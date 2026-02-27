import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/models/models.dart';

class SettingsRepository {
  SettingsRepository(this._client);

  final SupabaseClient _client;
  Settings? _cachedSettings;

  Future<Settings> load({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedSettings != null) {
      return _cachedSettings!;
    }

    try {
      final settings = await _fetchSettings();
      _cachedSettings = settings;
      return settings;
    } catch (error, stack) {
      throw _mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: const {'op': 'load'},
      );
    }
  }

  Future<Settings> save(Settings settings) async {
    try {
      final response = await _client
          .from(Settings.tableName)
          .upsert(settings.toJson(), onConflict: 'id')
          .select()
          .maybeSingle();

      if (response == null) {
        throw StateError('No settings returned after save.');
      }

      final saved = Settings.fromJson(Map<String, dynamic>.from(response));
      _cachedSettings = saved;
      return saved;
    } catch (error, stack) {
      throw _mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: const {'op': 'save'},
      );
    }
  }

  void clearCache() {
    _cachedSettings = null;
  }

  Future<Settings> _fetchSettings() async {
    final defaultsId = Settings.defaults().id;
    final byId = await _client
        .from(Settings.tableName)
        .select()
        .eq('id', defaultsId)
        .maybeSingle();

    if (byId != null) {
      return Settings.fromJson(Map<String, dynamic>.from(byId));
    }

    final response = await _client
        .from(Settings.tableName)
        .select()
        .order('id')
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return Settings.defaults();
    }

    return Settings.fromJson(Map<String, dynamic>.from(response));
  }

  DomainError _mapError(
    Object error,
    StackTrace stack, {
    DomainErrorReason? reason,
    Map<String, Object?> context = const {},
  }) {
    final base = DomainError.from(error, stack: stack);
    final mergedContext = <String, Object?>{
      'repository': runtimeType.toString(),
      if (base.context != null) ...base.context!,
      ...context,
    };
    final resolvedReason = base.reason ?? reason;
    return base.copyWith(
      reason: resolvedReason,
      context: mergedContext.isEmpty ? base.context : mergedContext,
    );
  }
}
