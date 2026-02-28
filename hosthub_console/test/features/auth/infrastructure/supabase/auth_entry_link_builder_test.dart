import 'package:flutter_test/flutter_test.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/auth_entry_link_builder.dart';

void main() {
  group('AuthEntryLinkBuilder', () {
    test('builds safe set-password link from recovery verify link', () {
      const actionLink =
          'https://example.supabase.co/auth/v1/verify?token=abc&type=recovery&redirect_to=http%3A%2F%2Flocalhost%3A43002%2Freset-password';

      final result = AuthEntryLinkBuilder.build(
        actionLink: actionLink,
        email: 'test@example.com',
        otp: '123456',
      );

      final uri = Uri.parse(result);
      expect(uri.origin, 'http://localhost:43002');
      expect(uri.path, '/set-password');
      expect(uri.queryParameters['email'], 'test@example.com');
      expect(uri.queryParameters['otp'], '123456');
      expect(uri.queryParameters['otp_type'], 'recovery');
    });

    test('preserves invite otp type', () {
      const actionLink =
          'https://example.supabase.co/auth/v1/verify?token=abc&type=invite&redirect_to=http%3A%2F%2Flocalhost%3A43002%2Fset-password';

      final result = AuthEntryLinkBuilder.build(
        actionLink: actionLink,
        email: 'test@example.com',
        otp: '654321',
      );

      final uri = Uri.parse(result);
      expect(uri.origin, 'http://localhost:43002');
      expect(uri.path, '/set-password');
      expect(uri.queryParameters['email'], 'test@example.com');
      expect(uri.queryParameters['otp'], '654321');
      expect(uri.queryParameters['otp_type'], 'invite');
    });

    test('keeps nested path prefix for redirect path', () {
      const actionLink =
          'https://example.supabase.co/auth/v1/verify?token=abc&type=recovery&redirect_to=https%3A%2F%2Fadmin.example.com%2Fauth%2Freset-password';

      final result = AuthEntryLinkBuilder.build(
        actionLink: actionLink,
        email: 'test@example.com',
      );

      final uri = Uri.parse(result);
      expect(uri.origin, 'https://admin.example.com');
      expect(uri.path, '/auth/set-password');
      expect(uri.queryParameters['email'], 'test@example.com');
      expect(uri.queryParameters['otp_type'], 'recovery');
      expect(uri.queryParameters.containsKey('otp'), isFalse);
    });

    test('falls back to original link when redirect_to is missing', () {
      const actionLink =
          'https://example.supabase.co/auth/v1/verify?token=abc&type=recovery';

      final result = AuthEntryLinkBuilder.build(
        actionLink: actionLink,
        email: 'test@example.com',
        otp: '123456',
      );

      expect(result, actionLink);
    });
  });
}
