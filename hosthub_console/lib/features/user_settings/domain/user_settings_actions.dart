enum UserSettingsToastType { success, error, info }

enum UserSettingsToastMessage {
  settingsSaved,
  lodgifyApiKeyRequired,
  lodgifyApiKeySaveFailed,
  lodgifyConnectSuccess,
  lodgifyConnectFailed,
  lodgifySyncCompleted,
  lodgifySyncFailed,
  lodgifyNoNewProperties,
  userSettingsLoadFailed,
}

class UserSettingsToast {
  const UserSettingsToast({
    required this.type,
    required this.message,
  });

  final UserSettingsToastType type;
  final UserSettingsToastMessage message;
}
