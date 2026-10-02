import 'dart:convert';

import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/core/errors/hosthub_error_reason.dart';
import 'package:supabase_auth_flutter/supabase_auth_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:hosthub_console/features/auth/domain/ports/auth_port.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_onboarding_adapter.dart';

/// The console's auth on GoTrue: `supabase_auth_flutter`'s service, plus what
/// only the console does.
///
/// Signing in (password, magic link, code), signing up, the session, its
/// refresh and the exchange of a sign-in link the console was opened with come
/// from [SupabaseAuthService]. What stays here:
///
/// - the console's own mails: the sign-up confirmation, its resend and the
///   password reset go out through `send_auth_email`, whose links open the
///   console's set-password page with the code — a mail scanner cannot use
///   that up the way it does GoTrue's one-time link;
/// - the codes those mails carry ([verifyOtp], [confirmResetPasswordWithOtp])
///   and setting the password once one is verified ([confirmResetPassword]);
/// - deleting the account through the `delete_user` function;
/// - [onAuthStateChange], for the console's own session listeners.
///
/// The console's own calls throw [DomainError]s, as the rest of the console
/// does; the inherited ones throw `auth_ui_flutter`'s `AuthError`s, which the
/// auth screens render by kind.
class SupabaseAuthAdapter extends SupabaseAuthService implements AuthPort {
  SupabaseAuthAdapter(
    super.runtime, {
    required SupabaseOnboardingAdapter onboardingAdapter,
  }) : _onboarding = onboardingAdapter;

  final SupabaseOnboardingAdapter _onboarding;

  @override
  Stream<AuthSessionChange> get onAuthStateChange =>
      auth.onAuthStateChange.map((state) {
        final user = state.session?.user;
        return AuthSessionChange(
          user: user == null ? null : AuthUser(id: user.id, email: user.email),
        );
      });

  // ── The console's mails ──────────────────────────────────────────────

  /// GoTrue's sign-up, followed by the console's confirmation mail while the
  /// address still has to be confirmed.
  @override
  Future<SignUpResult> signUp(String username, String password) async {
    final result = await super.signUp(username, password);
    if (result.nextStep == AuthSignUpStep.confirmSignUp) {
      await _mailSignUpConfirmation(username);
    }
    return result;
  }

  /// The confirmation mail again — the console's, like the first. Signing in
  /// to an unconfirmed account sends it through here too.
  @override
  Future<void> resendSignUpCode(String username) =>
      _mailSignUpConfirmation(username);

  /// The console's reset mail instead of GoTrue's; [redirectTo] overrides the
  /// console's set-password page as its destination.
  @override
  Future<void> sendResetEmail(String email, {Uri? redirectTo}) => _domain(
    'sendResetEmail',
    {'email': email},
    () => _onboarding.sendPasswordResetEmail(
      email: email,
      redirectUriOverride: redirectTo?.toString(),
    ),
  );

  Future<void> _mailSignUpConfirmation(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw DomainError.of(
        DomainErrorCode.validationFailed,
        reason: DomainErrorReason.invalidEmailFormat,
        message: 'Cannot send a sign-up confirmation without an email',
        context: _context('mailSignUpConfirmation'),
      );
    }
    return _domain(
      'mailSignUpConfirmation',
      {'email': trimmed},
      () => _onboarding.sendSignUpConfirmationEmail(email: trimmed),
    );
  }

  // ── The codes in those mails ─────────────────────────────────────────

  /// Verifies the code a console mail carries and returns the session's
  /// refresh token.
  ///
  /// The page it lands on does not always know which kind of code it holds,
  /// so the type named in the link is tried first and the other kinds a
  /// console mail can carry after it. A rate limit or a server error ends the
  /// search: another type would only be refused the same way.
  @override
  Future<String> verifyOtp(String email, String code) async {
    final normalizedEmail = email.trim();
    final normalizedCode = code.trim();

    try {
      await _clearMismatchedLocalSessionForOtp(normalizedEmail);

      sb.AuthException? lastAuthError;
      StackTrace? lastAuthStack;

      for (final otpType in _otpTypesForVerification()) {
        try {
          final response = await auth.verifyOTP(
            email: normalizedEmail,
            token: normalizedCode,
            type: otpType,
          );
          final refreshToken =
              response.session?.refreshToken ??
              auth.currentSession?.refreshToken;
          if (refreshToken == null || refreshToken.isEmpty) {
            throw DomainErrorCode.unauthorized.err(
              reason: DomainErrorReason.invalidVerificationCode,
              message: 'OTP verification did not return a refresh token',
              context: _context('verifyOtp', {
                'email': normalizedEmail,
                'otp_type': otpType.name,
              }),
            );
          }
          return refreshToken;
        } on sb.AuthException catch (error, stack) {
          lastAuthError = error;
          lastAuthStack = stack;
          if (!_shouldTryNextOtpType(error)) {
            throw _mapError(error, stack, 'verifyOtp', {
              'email': normalizedEmail,
              'otp_type': otpType.name,
            });
          }
        }
      }

      if (lastAuthError != null) {
        throw _mapError(
          lastAuthError,
          lastAuthStack ?? StackTrace.current,
          'verifyOtp',
          {'email': normalizedEmail},
        );
      }

      throw DomainErrorCode.unauthorized.err(
        reason: DomainErrorReason.invalidVerificationCode,
        message: 'OTP verification failed for all known OTP types',
        context: _context('verifyOtp', {'email': normalizedEmail}),
      );
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw _mapError(error, stack, 'verifyOtp', {'email': normalizedEmail});
    }
  }

  /// Verifies a recovery code, which signs in, then sets the new password.
  @override
  Future<void> confirmResetPasswordWithOtp(
    String email,
    String code,
    String newPassword,
  ) => _domain('confirmResetPasswordWithOtp', {'email': email}, () async {
    await auth.verifyOTP(
      email: email,
      token: code.trim(),
      type: sb.OtpType.recovery,
    );
    await auth.updateUser(sb.UserAttributes(password: newPassword));
  });

  /// Sets the password of the session a verified code or link established.
  @override
  Future<void> confirmResetPassword(String newPassword) => _domain(
    'confirmResetPassword',
    const {},
    () => auth.updateUser(sb.UserAttributes(password: newPassword)),
  );

  // ── The account ──────────────────────────────────────────────────────

  /// Deletes the signed-in account and its data through `delete_user`.
  @override
  Future<AccountDeletionResult> deleteAccount() async {
    final userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      // logout: false — a missing client-side session is a local
      // precondition, not proof that the session was revoked.
      throw DomainErrorCode.unauthorized.err(
        message: 'User not logged in',
        logout: false,
        context: _context('deleteAccount'),
      );
    }
    try {
      final response = await runtime.client.functions.invoke(
        'delete_user',
        body: jsonEncode({'user_id': userId}),
        headers: const {'Content-Type': 'application/json'},
      );
      if (response.status != 200) {
        throw DomainError.from(
          DomainErrorCode.serverError.anomaly(
            reason: HosthubErrorReason.cannotDeleteAllUserData,
            message: 'delete_user answered ${response.status}',
            cause: response.data,
            context: {
              ..._context('deleteAccount'),
              'function_status': response.status,
            },
          ),
        );
      }
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw _mapError(
        error,
        stack,
        'deleteAccount',
        const {},
        HosthubErrorReason.cannotDeleteAllUserData,
      );
    }
    return const AccountDeletionResult.accountDeleted();
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  /// A code for another address than the one signed in here would otherwise
  /// verify into the wrong session; signing out first is best effort.
  Future<void> _clearMismatchedLocalSessionForOtp(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return;

    final currentEmail = auth.currentUser?.email?.trim().toLowerCase();
    if (currentEmail == null || currentEmail.isEmpty) return;
    if (currentEmail == normalizedEmail) return;

    try {
      await auth.signOut();
    } catch (_) {
      // Best effort only: the verified code replaces this session anyway.
      // ignore: app_errors_check/swallowed_caught_error
    }
  }

  List<sb.OtpType> _otpTypesForVerification() => {
    ?_otpTypeFromQuery(),
    sb.OtpType.magiclink,
    sb.OtpType.recovery,
    sb.OtpType.invite,
  }.toList();

  sb.OtpType? _otpTypeFromQuery() {
    final params = Uri.base.queryParameters;
    final raw = params['otp_type'] ?? params['type'];
    return switch (raw?.trim().toLowerCase()) {
      'magiclink' => sb.OtpType.magiclink,
      'recovery' => sb.OtpType.recovery,
      'invite' => sb.OtpType.invite,
      'signup' => sb.OtpType.signup,
      'email' => sb.OtpType.email,
      _ => null,
    };
  }

  bool _shouldTryNextOtpType(sb.AuthException error) {
    final status = int.tryParse(error.statusCode ?? '');
    if (status == 429 || (status != null && status >= 500)) return false;
    return !error.message.toLowerCase().contains('rate limit');
  }

  Future<void> _domain(
    String operation,
    Map<String, Object?> extra,
    Future<void> Function() call,
  ) async {
    try {
      await call();
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw _mapError(error, stack, operation, extra);
    }
  }

  DomainError _mapError(
    Object error,
    StackTrace stack,
    String operation, [
    Map<String, Object?> extra = const {},
    ErrorReason? reason,
  ]) => DomainError.from(
    error,
    stack: stack,
    reason: reason,
    context: _context(operation, extra),
  );

  Map<String, Object?> _context(
    String operation, [
    Map<String, Object?> extra = const {},
  ]) => {'service': 'SupabaseAuthAdapter', 'operation': operation, ...extra};
}
