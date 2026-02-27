import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.model.freezed.dart';
part 'settings.model.g.dart';

@freezed
sealed class Settings with _$Settings {
  const Settings._();

  static const String tableName = 'settings';

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Settings({
    required String id,
    @Default(false) bool maintenanceModeEnabled,
    @Default(true) bool emailUserOnCreate,
    String? lodgifyApiKey,
    @Default(false) bool lodgifyConnected,
    DateTime? lodgifyConnectedAt,
    DateTime? lodgifyLastSyncedAt,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  static Settings defaults() => const Settings(
    id: 'defaults',
    maintenanceModeEnabled: false,
    emailUserOnCreate: true,
    lodgifyApiKey: null,
    lodgifyConnected: false,
    lodgifyConnectedAt: null,
    lodgifyLastSyncedAt: null,
  );
}
