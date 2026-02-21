import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';
import 'package:hosthub_console/features/auth/auth.dart';

class AdminSettingsRepository implements OnboardingPort {
  AdminSettingsRepository(this._client);

  final SupabaseClient _client;
  AdminSettings? _cachedSettings;

  Future<AdminSettings> load({bool forceRefresh = false}) async {
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

  Future<AdminSettings> save(AdminSettings settings) async {
    try {
      final response = await _client
          .from(AdminSettings.tableName)
          .upsert(settings.toJson(), onConflict: 'id')
          .select()
          .maybeSingle();

      if (response == null) {
        throw StateError('No admin settings returned after save.');
      }

      final saved = AdminSettings.fromJson(
        Map<String, dynamic>.from(response),
      );
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

  Future<AdminSettings> _fetchSettings() async {
    final defaultsId = AdminSettings.defaults().id;
    final byId = await _client
        .from(AdminSettings.tableName)
        .select()
        .eq('id', defaultsId)
        .maybeSingle();

    if (byId != null) {
      return AdminSettings.fromJson(Map<String, dynamic>.from(byId));
    }

    final response = await _client
        .from(AdminSettings.tableName)
        .select()
        .order('id')
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return AdminSettings.defaults();
    }

    return AdminSettings.fromJson(Map<String, dynamic>.from(response));
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
