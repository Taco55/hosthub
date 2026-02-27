import 'dart:convert';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/domain/ports/email_templates_port.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';
import 'package:hosthub_console/features/auth/domain/ports/onboarding_port.dart';
import 'package:app_errors/app_errors.dart';

class SupabaseOnboardingAdapter extends SupabaseRepository {
  SupabaseOnboardingAdapter({
    required SupabaseClient supabase,
    required EmailTemplatesPort emailRepository,
    required OnboardingPort settingsRepository,
    required String passwordResetRedirectUri,
    required String signInRedirectUri,
  }) : _emailRepository = emailRepository,
       _settingsRepository = settingsRepository,
       _passwordResetRedirectUri = passwordResetRedirectUri,
       _signInRedirectUri = signInRedirectUri,
       super(supabase);

  final EmailTemplatesPort _emailRepository;
  final OnboardingPort _settingsRepository;
  final String _passwordResetRedirectUri;
  final String _signInRedirectUri;

  String get signInRedirectUri => _signInRedirectUri;

  String resolveSignInRedirectUri([String? override]) =>
      _resolveRedirectUri(_signInRedirectUri, override);

  Future<void> sendAccountCreatedEmail({
    required String email,
    String? name,
    String? redirectUriOverride,
  }) async {
    final settings = await _settingsRepository.load();
    if (!settings.emailUserOnCreate) return;

    final link = await _generateResetLink(
      email: email,
      redirectUriOverride: redirectUriOverride,
    );

    await _emailRepository.sendUserCreatedEmail(
      email,
      actionLink: link.actionLink,
      name: name,
      otp: link.otp,
    );
  }

  Future<void> sendPasswordResetEmail({
    required String email,
    String? name,
    String? redirectUriOverride,
  }) async {
    final link = await _generateResetLink(
      email: email,
      redirectUriOverride: redirectUriOverride,
    );

    await _emailRepository.sendPasswordResetEmail(
      email,
      link.actionLink,
      name: name,
      otp: link.otp,
    );
  }

  Future<void> sendSignInOtpEmail({
    required String email,
    String? redirectUriOverride,
  }) async {
    final trimmedEmail = email.trim();
    final link = await _generateLink(
      functionName: 'generate_magic_link_and_otp',
      email: trimmedEmail,
      defaultRedirect: _signInRedirectUri,
      overrideRedirect: redirectUriOverride,
      operation: 'generateMagicLink',
    );

    await _emailRepository.sendLoginOtpEmail(
      trimmedEmail,
      actionLink: link.actionLink,
      otp: link.otp,
    );
  }

  Future<void> sendSignUpConfirmationEmail({
    required String email,
    String? name,
    String? redirectUriOverride,
  }) async {
    final trimmedEmail = email.trim();

    final link = await _generateLink(
      functionName: 'generate_sign_up_link_and_otp',
      email: trimmedEmail,
      defaultRedirect: _signInRedirectUri,
      overrideRedirect: redirectUriOverride,
      operation: 'generateSignUpLink',
    );

    await _emailRepository.sendSignUpConfirmationEmail(
      trimmedEmail,
      actionLink: link.actionLink,
      name: name,
      otp: link.otp,
    );
  }

  Future<_ResetLinkResult> _generateResetLink({
    required String email,
    String? redirectUriOverride,
  }) async {
    return _generateLink(
      functionName: 'generate_password_reset_link_and_otp',
      email: email,
      defaultRedirect: _passwordResetRedirectUri,
      overrideRedirect: redirectUriOverride,
      operation: 'generateResetLink',
    );
  }

  Future<_ResetLinkResult> _generateLink({
    required String functionName,
    required String email,
    required String defaultRedirect,
    required String operation,
    String? overrideRedirect,
  }) async {
    final redirectUri = _resolveRedirectUri(defaultRedirect, overrideRedirect);

    try {
      final response = await supabase.functions.invoke(
        functionName,
        body: jsonEncode({'email': email, 'redirectTo': redirectUri}),
        headers: const {'Content-Type': 'application/json'},
      );

      if (response.status != 200) {
        throw DomainError.of(
          DomainErrorCode.serverError,
          message: '$functionName failed (${response.status})',
          cause: response.data,
          context: {'email': email, 'redirect': redirectUri},
        );
      }

      final data = _ensureMap(response.data);
      final actionLink = (data['action_link'] ?? data['actionLink'])
          ?.toString();
      final otp = (data['email_otp'] ?? data['emailOtp'])?.toString();

      if (operation.contains('MagicLink')) {
        developer.log(
          'Magic link generated ($operation): $actionLink',
          name: 'SupabaseOnboardingAdapter',
        );
      }

      return _ResetLinkResult(actionLink: actionLink ?? '', otp: otp ?? '');
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        context: {'op': operation, 'email': email, 'redirect': redirectUri},
      );
    }
  }

  String _resolveRedirectUri(String defaultValue, String? override) {
    final trimmed = override?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return defaultValue;
  }

  Map<String, dynamic> _ensureMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    }
    return const {};
  }
}

class _ResetLinkResult {
  const _ResetLinkResult({required this.actionLink, required this.otp});

  final String actionLink;
  final String otp;
}
