import 'dart:convert';

import 'package:app_errors/app_errors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_flutter/supabase_auth_flutter.dart';

import 'package:hosthub_console/app/bootstrap/domain_errors_setup.dart';
import 'package:hosthub_console/core/errors/hosthub_error_reason.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_auth_adapter.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_onboarding_adapter.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';

/// What the console adds to `supabase_auth_flutter`'s service. The inherited
/// sign-in, session and link handling is that library's to test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _GoTrue gotrue;
  late _Mails mails;
  late SupabaseAuthRuntime runtime;
  late SupabaseAuthAdapter adapter;

  setUp(() async {
    configureDomainErrors();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    gotrue = _GoTrue();
    mails = _Mails();
    runtime = await SupabaseAuth.initialize(
      url: 'https://abcdefgh.supabase.co',
      publishableKey: 'sb_publishable_test',
      callback: const AuthCallbackLink('rentaladmin'),
      httpClient: gotrue.client,
      links: _NoLinks(),
    );
    adapter = SupabaseAuthAdapter(
      runtime,
      onboardingAdapter: SupabaseOnboardingAdapter(
        supabase: runtime.client,
        emailRepository: mails,
        settingsRepository: _NoSettings(),
        passwordResetRedirectUri: 'https://console.test/reset-password',
        signInRedirectUri: 'https://console.test/login',
      ),
    );
  });

  tearDown(() async {
    await runtime.dispose();
    DomainErrors.resetForTesting();
  });

  group("the console's own mails", () {
    test('a sign-up that still needs confirming sends the console mail '
        'after GoTrue created the account', () async {
      final result = await adapter.signUp(' host@example.com ', 'secret-pass');

      expect(result.nextStep, AuthSignUpStep.confirmSignUp);
      expect(gotrue.paths, contains('/auth/v1/signup'));
      expect(mails.sent, [
        'sign_up_confirmation host@example.com https://console.test/login',
      ]);
    });

    test(
      'the confirmation is resent as the console mail, not GoTrue\'s',
      () async {
        await adapter.resendSignUpCode('host@example.com');

        expect(gotrue.paths, isNot(contains('/auth/v1/resend')));
        expect(mails.sent, [
          'sign_up_confirmation host@example.com https://console.test/login',
        ]);
      },
    );

    test('a password reset is the console mail to its set-password page, '
        'not GoTrue\'s', () async {
      await adapter.sendResetEmail('host@example.com');

      expect(gotrue.paths, isNot(contains('/auth/v1/recover')));
      expect(mails.sent, [
        'password_reset host@example.com https://console.test/reset-password',
      ]);
    });
  });

  test('onAuthStateChange follows who is signed in', () async {
    final changes = <AuthSessionChange>[];
    final subscription = adapter.onAuthStateChange.listen(changes.add);
    addTearDown(subscription.cancel);

    await adapter.confirmSignInWithOtp('host@example.com', '123456');
    await pumpEventQueue();

    expect(changes.last.user?.id, 'user-1');
    expect(changes.last.user?.email, 'host@example.com');
  });

  group('deleting the account', () {
    test('asks delete_user for the signed-in user', () async {
      await adapter.confirmSignInWithOtp('host@example.com', '123456');

      await adapter.deleteAccount();

      final call = gotrue.calls.singleWhere(
        (call) => call.url.path == '/functions/v1/delete_user',
      );
      expect(jsonDecode(call.body), {'user_id': 'user-1'});
    });

    test('a failed delete_user names the account data it left', () async {
      await adapter.confirmSignInWithOtp('host@example.com', '123456');
      gotrue.deleteUserStatus = 500;

      await expectLater(
        adapter.deleteAccount(),
        throwsA(
          isA<DomainError>()
              .having((e) => e.code, 'code', DomainErrorCode.serverError)
              .having(
                (e) => e.reason,
                'reason',
                HosthubErrorReason.cannotDeleteAllUserData,
              ),
        ),
      );
    });

    test('delete_user answering a status other than 200 is reported once, '
        'naming the account data it left', () async {
      final reported = <DomainError>[];
      DomainError.onUnexpectedError = reported.add;
      await adapter.confirmSignInWithOtp('host@example.com', '123456');
      gotrue.deleteUserStatus = 202;

      await expectLater(
        adapter.deleteAccount(),
        throwsA(
          isA<DomainError>()
              .having((e) => e.code, 'code', DomainErrorCode.serverError)
              .having(
                (e) => e.reason,
                'reason',
                HosthubErrorReason.cannotDeleteAllUserData,
              ),
        ),
      );
      expect(reported, hasLength(1));
      expect(reported.single.context?['function_status'], 202);
    });

    test('without a session is refused, without signing anyone out', () async {
      await expectLater(
        adapter.deleteAccount(),
        throwsA(
          isA<DomainError>()
              .having((e) => e.code, 'code', DomainErrorCode.unauthorized)
              .having((e) => e.logout, 'logout', isFalse),
        ),
      );
      expect(gotrue.paths, isNot(contains('/functions/v1/delete_user')));
    });
  });
}

/// GoTrue and the functions endpoint, as far as these tests reach them: every
/// call is recorded, a sign-up leaves the address to be confirmed and a
/// verified code signs `user-1` in.
class _GoTrue {
  final calls = <http.Request>[];

  /// What `delete_user` answers.
  int deleteUserStatus = 200;

  late final http.Client client = MockClient((request) async {
    calls.add(request);
    return switch (request.url.path) {
      '/auth/v1/signup' => _json(_user(confirmed: false)),
      '/auth/v1/verify' => _json(_session()),
      '/functions/v1/delete_user' => _json(
        const <String, Object?>{},
        status: deleteUserStatus,
      ),
      _ => _json(const <String, Object?>{}),
    };
  });

  Iterable<String> get paths => calls.map((call) => call.url.path);

  static http.Response _json(Object body, {int status = 200}) => http.Response(
    jsonEncode(body),
    status,
    headers: const {'content-type': 'application/json'},
  );

  static Map<String, Object?> _user({bool confirmed = true}) => {
    'id': 'user-1',
    'aud': 'authenticated',
    'email': 'host@example.com',
    'phone': '',
    'app_metadata': {'provider': 'email'},
    'user_metadata': <String, Object?>{},
    'created_at': '2026-09-26T10:00:00Z',
    if (confirmed) 'email_confirmed_at': '2026-09-26T10:00:00Z',
    'identities': [
      {
        'id': 'user-1',
        'user_id': 'user-1',
        'identity_id': 'identity-user-1',
        'provider': 'email',
        'identity_data': {'email': 'host@example.com', 'sub': 'user-1'},
      },
    ],
  };

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
      'user': _user(),
    };
  }
}

/// Records each console mail as `kind address redirect`.
class _Mails implements EmailTemplatesPort {
  final sent = <String>[];

  @override
  Future<void> sendSignUpConfirmationEmail(
    String to, {
    String? name,
    String? redirectTo,
  }) async => sent.add('sign_up_confirmation $to $redirectTo');

  @override
  Future<void> sendPasswordResetEmail(
    String to, {
    String? name,
    String? redirectTo,
  }) async => sent.add('password_reset $to $redirectTo');

  @override
  Future<void> sendUserCreatedEmail(
    String to, {
    String? name,
    String? redirectTo,
  }) async => sent.add('user_created $to $redirectTo');

  @override
  Future<void> sendLoginOtpEmail(String to, {String? redirectTo}) async =>
      sent.add('login_otp $to $redirectTo');
}

/// Only the staff mail reads the settings, and none is sent here.
class _NoSettings implements OnboardingPort {
  @override
  Future<AdminSettings> load({bool forceRefresh = false}) =>
      throw UnimplementedError('no staff mail in these tests');
}

/// A console that was not opened from a link and receives none.
class _NoLinks implements AuthLinkSource {
  @override
  Stream<Uri> get links => const Stream.empty();

  @override
  Future<Uri?> get initialLink async => null;
}
