import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'token_response.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class TokenResponse {
  @JsonKey(name: 'auth_token')
  final String? accessToken;
  final String? refreshToken;
  @JsonKey(name: 'user_id')
  final String? userId;

  TokenResponse({this.refreshToken, required this.accessToken, this.userId});

  factory TokenResponse.fromRawJson(String str) =>
      TokenResponse.fromJson(json.decode(str) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);
}
