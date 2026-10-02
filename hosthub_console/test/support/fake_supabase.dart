import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A [SupabaseClient] whose requests [answer] serves by path. GoTrue's token
/// endpoint always hands out a session for `user-1`, so [signIn] gives the
/// client an access token without a real server.
class FakeSupabase {
  FakeSupabase(this.answer);

  /// The response to a request other than a token grant; `null` answers an
  /// empty JSON object.
  final http.Response? Function(http.Request request) answer;

  late final SupabaseClient client = SupabaseClient(
    'http://localhost:7011',
    'sb_publishable_test',
    httpClient: MockClient((request) async {
      final response = request.url.path == '/auth/v1/token'
          ? json(_session())
          : answer(request) ?? json(const <String, Object?>{});
      // PostgREST reads the request off an error response.
      return http.Response(
        response.body,
        response.statusCode,
        headers: response.headers,
        request: request,
      );
    }),
  );

  Future<void> signIn() => client.auth.signInWithPassword(
    email: 'host@example.com',
    password: 'secret-pass',
  );

  static http.Response json(Object body, {int status = 200}) => http.Response(
    jsonEncode(body),
    status,
    headers: const {'content-type': 'application/json'},
  );

  static Map<String, Object?> _session() {
    final expiresAt =
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
        1000;
    String part(Object value) =>
        base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
    final claims = {
      'sub': 'user-1',
      'email': 'host@example.com',
      'exp': expiresAt,
    };
    return {
      'access_token': '${part({'alg': 'HS256'})}.${part(claims)}.signature',
      'token_type': 'bearer',
      'expires_in': 3600,
      'expires_at': expiresAt,
      'refresh_token': 'refresh-user-1',
      'user': {
        'id': 'user-1',
        'aud': 'authenticated',
        'email': 'host@example.com',
        'app_metadata': {'provider': 'email'},
        'user_metadata': <String, Object?>{},
        'created_at': '2026-09-26T10:00:00Z',
      },
    };
  }
}
