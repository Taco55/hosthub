import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'package:hosthub_console/core/core.dart';

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
      TokenResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);

  bool get isValid {
    if (accessToken == null || accessToken!.isEmpty) {
      return false;
    }
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final exp = parseJwt(token: accessToken!)['exp'];
      return exp is int ? exp * 1000 > now : false;
    } catch (_) {
      if (_isDevMode && (userId?.isNotEmpty ?? false)) {
        return true;
      }
      return false;
    }
  }

  String? get userIdFromToken {
    if (userId != null && userId!.isNotEmpty) {
      return userId;
    }
    if (accessToken == null || accessToken!.isEmpty) {
      return null;
    }
    try {
      return parseJwt(token: accessToken!)['user_id'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> parseJwt({required String token}) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    var output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }

    return utf8.decode(base64Url.decode(output));
  }
}

bool get _isDevMode {
  try {
    return AppConfig.current.isDev;
  } catch (_) {
    return false;
  }
}
