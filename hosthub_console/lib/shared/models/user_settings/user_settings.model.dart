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
    String? lodgifyApiKey,
    @Default(false) bool lodgifyConnected,
    DateTime? lodgifyConnectedAt,
    DateTime? lodgifyLastSyncedAt,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);

  static UserSettings defaults(String profileId) =>
      UserSettings(profileId: profileId);
}
