// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
  id: json['id'] as String,
  maintenanceModeEnabled: json['maintenance_mode_enabled'] as bool? ?? false,
  emailUserOnCreate: json['email_user_on_create'] as bool? ?? true,
  lodgifyApiKey: json['lodgify_api_key'] as String?,
  lodgifyConnected: json['lodgify_connected'] as bool? ?? false,
  lodgifyConnectedAt: json['lodgify_connected_at'] == null
      ? null
      : DateTime.parse(json['lodgify_connected_at'] as String),
  lodgifyLastSyncedAt: json['lodgify_last_synced_at'] == null
      ? null
      : DateTime.parse(json['lodgify_last_synced_at'] as String),
);

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
  'id': instance.id,
  'maintenance_mode_enabled': instance.maintenanceModeEnabled,
  'email_user_on_create': instance.emailUserOnCreate,
  'lodgify_api_key': instance.lodgifyApiKey,
  'lodgify_connected': instance.lodgifyConnected,
  'lodgify_connected_at': instance.lodgifyConnectedAt?.toIso8601String(),
  'lodgify_last_synced_at': instance.lodgifyLastSyncedAt?.toIso8601String(),
};
