// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  email: json['email'] as String,
  username: json['username'] as String?,
  fcmToken: json['fcm_token'] as String?,
  isDevelopment: json['is_development'] as bool? ?? false,
  isAdmin: json['is_admin'] as bool? ?? false,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'fcm_token': instance.fcmToken,
  'is_development': instance.isDevelopment,
  'is_admin': instance.isAdmin,
};
