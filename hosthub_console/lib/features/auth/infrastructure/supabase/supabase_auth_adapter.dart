import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:hosthub_console/core/core.dart';

import 'package:hosthub_console/features/auth/domain/ports/auth_port.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_onboarding_adapter.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';
import 'package:app_errors/app_errors.dart';

class SupabaseAuthAdapter extends SupabaseRepository implements AuthPort {
  SupabaseAuthAdapter({required SupabaseOnboardingAdapter onboardingAdapter})
    : _userOnboardingService = onboardingAdapter,
      super(sb.Supabase.instance.client);

  final SupabaseOnboardingAdapter _userOnboardingService;

  Map<String, Object?> _context(
    String operation, [
    Map<String, Object?> extra = const {},
  ]) => {'service': 'SupabaseAuthAdapter', 'operation': operation, ...extra};

  @override
  bool get isGuestUser {
    final user = supabase.auth.currentUser;
    if (user == null) return true;
    final provider = user.appMetadata['provider'];
    return provider == 'anon' || provider == 'anonymous' || user.email == null;
  }

  @override
  Future<SignInResult> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return const SignInResult(
          isSignedIn: true,
          nextStep: AuthSignInStep.done,
        );
      }

      throw DomainErrorCode.serverError.err(
        message: 'Supabase returned a null user after signInWithPassword',
        context: _context('signIn', {'email': email}),
      );
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        context: _context('signIn', {'email': email}),
      );
    }
  }

  @override
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    try {
      final redirectTo = AppConfig.current.authRedirectUri();
      await supabase.auth.signInWithOAuth(
        _mapOAuthProvider(provider),
        redirectTo: redirectTo,
        scopes: 'openid profile email',
        queryParams: const {
          'prompt': 'select_account',
          'access_type': 'offline',
        },
      );
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        context: _context('signInWithOAuth', {'provider': provider.toString()}),
      );
    }
  }

  @override
  Stream<AuthSessionChange> get onAuthStateChange =>
      supabase.auth.onAuthStateChange.map((authState) {
        final user = authState.session?.user;
        return AuthSessionChange(
          user: user == null ? null : AuthUser(id: user.id, email: user.email),
        );
      });

  @override
  Future<SignUpResult> signUp(String email, String password) async {
    try {
      final trimmedEmail = email.trim();
      final response = await supabase.auth.signUp(
        email: trimmedEmail,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw DomainErrorCode.serverError.err(
          message: 'Supabase did not return a user after signUp',
          context: _context('signUp', {'email': trimmedEmail}),
        );
      }

      final session = response.session;
      final requiresEmailConfirmation =
          session == null && user.emailConfirmedAt == null;

      if (requiresEmailConfirmation) {
        await _userOnboardingService.sendSignUpConfirmationEmail(
          email: trimmedEmail,
        );
        return SignUpResult(
          isSignUpComplete: false,
          nextStep: AuthSignUpStep.confirmSignUp,
          userId: user.id,
        );
      }

      return SignUpResult(
        isSignUpComplete: true,
        nextStep: AuthSignUpStep.done,
        userId: user.id,
      );
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        context: _context('signUp', {'email': email}),
      );
    }
  }

  /// Refresh the session if it's expired (or almost expired)
  @override
  Future<void> refreshSessionIfNeeded() async {
    final session = supabase.auth.currentSession;
    final exp = session?.expiresAt;

    if (session != null && exp != null) {
      final expiration = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      // Add 30 seconds buffer
      if (now.isAfter(expiration.subtract(const Duration(seconds: 30)))) {
        try {
          await supabase.auth.refreshSession();
        } catch (error, stack) {
          final mapped = mapError(
            error,
            stack,
            context: _context('refreshSessionIfNeeded'),
          );
          if (mapped.isInvalidRefreshTokenError) {
            throw mapped;
          }
          // Log and ignore — this may fail if refresh_token is expired too
          log('Session refresh failed: $mapped');
        }
      }
    }
  }

  @override
  Future<SignUpResult> confirmSignUp(String email, String code) async {
    try {
      await supabase.auth.verifyOTP(
        email: email,
        token: code.trim(),
        type: sb.OtpType.signup,
      );

      return const SignUpResult(
        isSignUpComplete: true,
        nextStep: AuthSignUpStep.done,
      );
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(error, stack, context: _context('confirmSignUp'));
    }
  }

  @override
  Future<bool> resetPassword(String email) async {
    try {
      await _userOnboardingService.sendPasswordResetEmail(email: email);
      return true;
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(error, stack, context: _context('resetPassword'));
    }
  }

  @override
  Future<void> sendResetEmail(String email) async {
    await resetPassword(email);
  }

  // @override
  // Future<void> resendSignUpCode(
  //   String username,
  // ) async {
  //   try {
  //     await Amplify.Auth.resendSignUpCode(username: username);
  //   } catch (e) {
  //     return Future.error(e);
  //   }
  // }

  // @override
  // Future<bool> confirmResetPassword(
  //   String username,
  //   String code,
  //   String newPassword,
  // ) async {
  //   try {
  //     if (F.appOptions.isSimulateAuth == true) {
  //       return Future.delayed(const Duration(seconds: 3), () {
  //         return true;
  //       });
  //     }

  //     final result = await Amplify.Auth.confirmResetPassword(
  //       username: username,
  //       confirmationCode: code,
  //       newPassword: newPassword,
  //     );

  //     return result.isPasswordReset;
  //   } catch (e) {
  //     return Future.error(e);
  //   }
  // }

  @override
  bool get isLoggedIn {
    return supabase.auth.currentUser != null;
  }

  @override
  Future<bool> validateCurrentUserExists() async {
    try {
      final response = await supabase.auth.getUser();
      return response.user != null;
    } catch (_) {
      return false;
    }
  }

  @override
  AuthUser? get currentUser {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final provider = user.appMetadata['provider'];
    return AuthUser(
      id: user.id,
      email: user.email,
      phone: user.phone,
      isAnonymous: provider == 'anon' || provider == 'anonymous',
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(error, stack, context: _context('signOut'));
    }
  }

  @override
  Future<void> deleteCurrentUser() async {
    try {
      final response = await supabase.functions.invoke(
        'delete_user',
        body: jsonEncode({'user_id': currentUserId}),
        headers: const {'Content-Type': 'application/json'},
      );

      if (response.status != 200) {
        throw DomainErrorCode.serverError.err(
          reason: DomainErrorReason.cannotDeleteAllUserData,
          cause: response.data,
          context: {
            ..._context('deleteCurrentUser'),
            'function_status': response.status,
          },
        );
      }
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotDeleteAllUserData,
        context: _context('deleteCurrentUser'),
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    await deleteCurrentUser();
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final response = await supabase.functions.invoke(
        'delete_user',
        body: jsonEncode({'user_id': userId}),
        headers: const {'Content-Type': 'application/json'},
      );

      if (response.status != 200) {
        throw DomainErrorCode.serverError.err(
          reason: DomainErrorReason.cannotDeleteAllUserData,
          cause: response.data,
          context: {
            ..._context('deleteUser', {'target_user_id': userId}),
            'function_status': response.status,
          },
        );
      }
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotDeleteAllUserData,
        context: _context('deleteUser', {'target_user_id': userId}),
      );
    }
  }

  @override
  Future<String> createUser(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      final response = await supabase.auth.admin.createUser(
        sb.AdminUserAttributes(email: email, password: password),
      );

      final user = response.user;
      if (user == null) {
        throw DomainErrorCode.serverError.err(
          message: 'Supabase admin.createUser returned without a user',
          context: _context('createUser', {'email': email}),
        );
      }

      await _userOnboardingService.sendAccountCreatedEmail(
        email: email,
        name: name,
      );

      return user.id;
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        context: _context('createUser', {'email': email}),
      );
    }
  }

  @override
  Future<void> signInWithOtp(
    String email, {
    bool shouldCreateUser = true,
    String? redirectTo,
  }) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw DomainError.of(
        DomainErrorCode.validationFailed,
        reason: DomainErrorReason.invalidEmailFormat,
        message: 'Cannot send OTP without a valid email',
        context: _context('signInWithOtp', {'email': email}),
      );
    }

    final redirectUri = _userOnboardingService.resolveSignInRedirectUri(
      redirectTo,
    );

    try {
      // Leverage Supabase' built-in magic link flow so new users are onboarded automatically.
      await supabase.auth.signInWithOtp(
        email: trimmed,
        emailRedirectTo: redirectUri,
        shouldCreateUser: shouldCreateUser,
      );
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        context: _context('signInWithOtp', {
          'email': trimmed,
          'should_create_user': shouldCreateUser,
          if (redirectTo != null) 'redirect_override': redirectTo,
          'resolved_redirect': redirectUri,
        }),
      );
    }
  }

  @override
  Future<void> sendMagicLink(String email) async {
    await signInWithOtp(email);
  }

  @override
  Future<void> confirmSignInWithOtp(String email, String code) async {
    try {
      await supabase.auth.verifyOTP(
        email: email,
        token: code.trim(),
        type: sb.OtpType.magiclink,
      );
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        context: _context('confirmSignInWithOtp', {'email': email}),
      );
    }
  }

  @override
  Future<String> verifyOtp(String email, String code) async {
    try {
      final response = await supabase.auth.verifyOTP(
        email: email,
        token: code.trim(),
        type: sb.OtpType.magiclink,
      );
      final refreshToken =
          response.session?.refreshToken ??
          supabase.auth.currentSession?.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        throw DomainErrorCode.unauthorized.err(
          reason: DomainErrorReason.invalidVerificationCode,
          message: 'OTP verification did not return a refresh token',
          context: _context('verifyOtp', {'email': email}),
        );
      }
      return refreshToken;
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        context: _context('verifyOtp', {'email': email}),
      );
    }
  }

  @override
  Future<void> resendSignUpEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw DomainError.of(
        DomainErrorCode.validationFailed,
        reason: DomainErrorReason.invalidEmailFormat,
        message: 'Cannot resend confirmation without a valid email',
        context: _context('resendSignUpEmail', {'email': email}),
      );
    }

    try {
      await _userOnboardingService.sendSignUpConfirmationEmail(email: trimmed);
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        context: _context('resendSignUpEmail', {'email': trimmed}),
      );
    }
  }

  @override
  Future<void> confirmResetPasswordWithOtp(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      // Step 1: Verify the recovery OTP to establish a session.
      await supabase.auth.verifyOTP(
        email: email,
        token: code.trim(),
        type: sb.OtpType.recovery,
      );
      // Step 2: Update the user's password.
      await supabase.auth.updateUser(sb.UserAttributes(password: newPassword));
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        context: _context('confirmResetPasswordWithOtp', {'email': email}),
      );
    }
  }

  @override
  Future<void> confirmResetPassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(sb.UserAttributes(password: newPassword));
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(error, stack, context: _context('confirmResetPassword'));
    }
  }

  @override
  Future<void> refreshSessionFromRefreshToken(String refreshToken) async {
    try {
      await supabase.auth.setSession(refreshToken);
    } on DomainError {
      rethrow;
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        context: _context('refreshSessionFromRefreshToken'),
      );
    }
  }

  @override
  Future<void> refreshSessionFromToken(String refreshToken) async {
    await refreshSessionFromRefreshToken(refreshToken);
  }

  @override
  Future<void> resendSignUpCode(String username) async {
    await resendSignUpEmail(username);
  }
}

sb.OAuthProvider _mapOAuthProvider(OAuthProvider provider) {
  switch (provider) {
    case OAuthProvider.apple:
      return sb.OAuthProvider.apple;
    case OAuthProvider.azure:
      return sb.OAuthProvider.azure;
    case OAuthProvider.bitbucket:
      return sb.OAuthProvider.bitbucket;
    case OAuthProvider.discord:
      return sb.OAuthProvider.discord;
    case OAuthProvider.facebook:
      return sb.OAuthProvider.facebook;
    case OAuthProvider.github:
      return sb.OAuthProvider.github;
    case OAuthProvider.gitlab:
      return sb.OAuthProvider.gitlab;
    case OAuthProvider.google:
      return sb.OAuthProvider.google;
    case OAuthProvider.twitter:
      return sb.OAuthProvider.twitter;
  }
}
