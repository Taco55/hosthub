import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/features/properties/domain/lodgify_sync_plan.dart';
import 'package:hosthub_console/features/user_settings/domain/user_settings_actions.dart';

enum UserSettingsStatus {
  initial,
  loading,
  ready,
  saving,
  connecting,
  syncing,
  error,
}

class UserSettingsState {
  const UserSettingsState({
    this.settings,
    this.status = UserSettingsStatus.initial,
    this.errorMessage,
    this.domainError,
    this.toast,
    this.syncPlan,
  });

  const UserSettingsState.initial()
    : settings = null,
      status = UserSettingsStatus.initial,
      errorMessage = null,
      domainError = null,
      toast = null,
      syncPlan = null;

  final UserSettings? settings;
  final UserSettingsStatus status;
  final String? errorMessage;
  final DomainError? domainError;
  final UserSettingsToast? toast;

  /// What the last sync found, resolved against the properties that exist —
  /// non-null exactly while a screen still has to show it. One field instead of
  /// the two lists it replaces (all listings + the missing ones), because the
  /// screen had to re-derive the difference and got it wrong.
  final LodgifySyncPlan? syncPlan;

  UserSettingsState copyWith({
    UserSettings? settings,
    UserSettingsStatus? status,
    String? errorMessage,
    DomainError? domainError,
    UserSettingsToast? toast,
    bool clearToast = false,
    LodgifySyncPlan? syncPlan,
    bool clearSyncPlan = false,
    bool clearDomainError = false,
  }) {
    return UserSettingsState(
      settings: settings ?? this.settings,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      domainError: clearDomainError ? null : domainError ?? this.domainError,
      toast: clearToast ? null : toast ?? this.toast,
      syncPlan: clearSyncPlan ? null : syncPlan ?? this.syncPlan,
    );
  }

  @override
  String toString() {
    final hasApiKey = settings?.lodgifyApiKey?.trim().isNotEmpty ?? false;
    return 'UserSettingsState('
        'status=$status, '
        'hasSettings=${settings != null}, '
        'hasApiKey=$hasApiKey, '
        'lodgifyConnected=${settings?.lodgifyConnected}, '
        'syncPlan=${syncPlan ?? '-'}, '
        'toast=${toast?.message}, '
        'hasError=${domainError != null})';
  }
}
