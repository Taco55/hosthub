import 'dart:convert';

import 'package:app_errors/supabase_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/errors/hosthub_error_reason.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_auth_mail_adapter.dart';

/// A mail that `send_auth_email` could not send names its flow, so the user
/// reads which mail did not go out.
void main() {
  setUp(() => DomainErrors.configure(adapters: const [supabaseAdapter]));
  tearDown(DomainErrors.resetForTesting);

  SupabaseAuthMailAdapter adapterFailingWith(int status) =>
      SupabaseAuthMailAdapter(
        client: SupabaseClient(
          'http://localhost:7011',
          'sb_publishable_test',
          httpClient: MockClient(
            (_) async => http.Response(
              jsonEncode({'error': 'mail_provider_unavailable'}),
              status,
              headers: const {'content-type': 'application/json'},
            ),
          ),
        ),
      );

  Matcher failsWith(HosthubErrorReason reason) => throwsA(
    isA<DomainError>().having((e) => e.reason, 'reason', reason),
  );

  test('each mail flow fails with its own reason', () async {
    final adapter = adapterFailingWith(500);

    await expectLater(
      adapter.sendLoginOtpEmail('host@example.com'),
      failsWith(HosthubErrorReason.loginOtpEmailFailed),
    );
    await expectLater(
      adapter.sendSignUpConfirmationEmail('host@example.com'),
      failsWith(HosthubErrorReason.signUpConfirmationEmailFailed),
    );
    await expectLater(
      adapter.sendUserCreatedEmail('host@example.com'),
      failsWith(HosthubErrorReason.userCreatedEmailFailed),
    );
    await expectLater(
      adapter.sendPasswordResetEmail('host@example.com'),
      failsWith(HosthubErrorReason.passwordResetEmailFailed),
    );
  });

  test('the conversion keeps what the function said', () async {
    await expectLater(
      adapterFailingWith(500).sendLoginOtpEmail('host@example.com'),
      throwsA(
        isA<DomainError>()
            .having((e) => e.code, 'code', DomainErrorCode.serverError)
            .having(
              (e) => e.context?['repository'],
              'repository',
              'SupabaseAuthMailAdapter',
            )
            .having((e) => e.context?['kind'], 'kind', 'login_otp'),
      ),
    );
  });
}
