// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenResponse _$TokenResponseFromJson(Map<String, dynamic> json) =>
    TokenResponse(
      refreshToken: json['refresh_token'] as String?,
      accessToken: json['auth_token'] as String?,
      userId: json['user_id'] as String?,
    );

Map<String, dynamic> _$TokenResponseToJson(TokenResponse instance) =>
    <String, dynamic>{
      'auth_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'user_id': instance.userId,
    };
