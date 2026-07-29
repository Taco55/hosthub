import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/domain/ports/email_templates_port.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';
import 'package:app_errors/app_errors.dart';

/// Sends the transactional auth mails through the `send_auth_email` function.
///
/// This used to be 450 lines: five HTML templates, the placeholder rendering and
/// the set-password entry-link rewriting all lived here, because the console
/// fetched the action link and the one-time code and composed the mail itself.
/// All of that is server-side now — the credential must not reach the client —
/// so what is left is the request.
class SupabaseAuthMailAdapter extends SupabaseRepository
    implements EmailTemplatesPort {
  SupabaseAuthMailAdapter({required SupabaseClient client}) : super(client);

  static const _functionName = 'send_auth_email';

  @override
  Future<void> sendLoginOtpEmail(String to, {String? redirectTo}) =>
      _send(kind: 'login_otp', to: to, redirectTo: redirectTo);

  @override
  Future<void> sendSignUpConfirmationEmail(
    String to, {
    String? name,
    String? redirectTo,
  }) => _send(
    kind: 'sign_up_confirmation',
    to: to,
    name: name,
    redirectTo: redirectTo,
  );

  @override
  Future<void> sendUserCreatedEmail(
    String to, {
    String? name,
    String? redirectTo,
  }) =>
      _send(kind: 'user_created', to: to, name: name, redirectTo: redirectTo);

  @override
  Future<void> sendPasswordResetEmail(
    String to, {
    String? name,
    String? redirectTo,
  }) =>
      _send(kind: 'password_reset', to: to, name: name, redirectTo: redirectTo);

  Future<void> _send({
    required String kind,
    required String to,
    String? name,
    String? redirectTo,
  }) async {
    final trimmed = to.trim();
    try {
      // No status check: a non-2xx from an Edge Function arrives as an
      // exception, which the catch below maps.
      await supabase.functions.invoke(
        _functionName,
        body: {
          'kind': kind,
          'email': trimmed,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
          if (redirectTo != null && redirectTo.trim().isNotEmpty)
            'redirectTo': redirectTo.trim(),
        },
      );
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.emailSendFailed,
        context: {'op': 'sendAuthEmail', 'kind': kind, 'email': trimmed},
      );
    }
  }
}
