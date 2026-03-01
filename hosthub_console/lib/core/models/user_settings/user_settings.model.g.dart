// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    _UserSettings(
      profileId: json['profile_id'] as String,
      languageCode: json['language_code'] as String?,
      exportLanguageCode: json['export_language_code'] as String?,
      exportColumns: (json['export_columns'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      exportPdfOrientation:
          json['export_pdf_orientation'] as String? ?? 'portrait',
      lodgifyApiKey: json['lodgify_api_key'] as String?,
      lodgifyConnected: json['lodgify_connected'] as bool? ?? false,
      lodgifyConnectedAt: json['lodgify_connected_at'] == null
          ? null
          : DateTime.parse(json['lodgify_connected_at'] as String),
      lodgifyLastSyncedAt: json['lodgify_last_synced_at'] == null
          ? null
          : DateTime.parse(json['lodgify_last_synced_at'] as String),
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'profile_id': instance.profileId,
      'language_code': instance.languageCode,
      'export_language_code': instance.exportLanguageCode,
      'export_columns': instance.exportColumns,
      'export_pdf_orientation': instance.exportPdfOrientation,
      'lodgify_api_key': instance.lodgifyApiKey,
      'lodgify_connected': instance.lodgifyConnected,
      'lodgify_connected_at': instance.lodgifyConnectedAt?.toIso8601String(),
      'lodgify_last_synced_at': instance.lodgifyLastSyncedAt?.toIso8601String(),
    };
