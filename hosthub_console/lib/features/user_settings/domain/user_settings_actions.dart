enum UserSettingsToastType { success, error, info }

/// What the settings screen has to say out loud.
///
/// Only the three the cubit actually emits: everything that goes wrong travels
/// as a [DomainError] and is shown with `showAppError`, so the failure variants
/// this enum used to carry were rendered by an exhaustive switch and emitted by
/// nothing.
enum UserSettingsToastMessage {
  settingsSaved,
  lodgifyApiKeyRequired,
  lodgifyConnectSuccess,
}

class UserSettingsToast {
  const UserSettingsToast({required this.type, required this.message});

  final UserSettingsToastType type;
  final UserSettingsToastMessage message;
}
