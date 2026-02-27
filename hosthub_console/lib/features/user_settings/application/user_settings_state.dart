import 'package:app_errors/app_errors.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
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
    this.missingPropertiesToConfirm,
    this.channelPropertiesToReview,
  });

  const UserSettingsState.initial()
    : settings = null,
      status = UserSettingsStatus.initial,
      errorMessage = null,
      domainError = null,
      toast = null,
      missingPropertiesToConfirm = null,
      channelPropertiesToReview = null;

  final UserSettings? settings;
  final UserSettingsStatus status;
  final String? errorMessage;
  final DomainError? domainError;
  final UserSettingsToast? toast;
  final List<ChannelProperty>? missingPropertiesToConfirm;
  final List<ChannelProperty>? channelPropertiesToReview;

  UserSettingsState copyWith({
    UserSettings? settings,
    UserSettingsStatus? status,
    String? errorMessage,
    DomainError? domainError,
    UserSettingsToast? toast,
    bool clearToast = false,
    List<ChannelProperty>? missingPropertiesToConfirm,
    List<ChannelProperty>? channelPropertiesToReview,
    bool clearMissingProperties = false,
    bool clearDomainError = false,
  }) {
    return UserSettingsState(
      settings: settings ?? this.settings,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      domainError: clearDomainError ? null : domainError ?? this.domainError,
      toast: clearToast ? null : toast ?? this.toast,
      missingPropertiesToConfirm:
          clearMissingProperties
              ? null
              : missingPropertiesToConfirm ?? this.missingPropertiesToConfirm,
      channelPropertiesToReview:
          clearMissingProperties
              ? null
              : channelPropertiesToReview ?? this.channelPropertiesToReview,
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
        'missingCount=${missingPropertiesToConfirm?.length ?? 0}, '
        'reviewCount=${channelPropertiesToReview?.length ?? 0}, '
        'toast=${toast?.message}, '
        'hasError=${domainError != null})';
  }
}
