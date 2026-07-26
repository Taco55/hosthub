import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_settings.model.freezed.dart';
part 'user_settings.model.g.dart';

@freezed
sealed class UserSettings with _$UserSettings {
  const UserSettings._();

  static const String tableName = 'user_settings';

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserSettings({
    required String profileId,
    String? languageCode,
    String? exportLanguageCode,
    List<String>? exportColumns,
    @Default('portrait') String exportPdfOrientation,

    /// Which properties each portfolio screen is filtered to, by page key.
    ///
    /// A view preference that follows the user: Boekingen and Omzet each keep
    /// their own selection, and a page that is absent means all properties —
    /// so nothing is written until a filter is actually touched.
    Map<String, List<int>>? portfolioScope,
    String? lodgifyApiKey,
    String? lodgifyApiKeyLast4,
    @Default(false) bool lodgifyConnected,
    DateTime? lodgifyConnectedAt,
    DateTime? lodgifyLastSyncedAt,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  static UserSettings defaults(String profileId) =>
      UserSettings(profileId: profileId);
}
