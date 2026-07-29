import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/domain/ports/email_templates_port.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';
import 'package:hosthub_console/features/auth/domain/ports/onboarding_port.dart';

/// The onboarding mails, as the console asks for them.
///
/// It used to fetch the link and the one-time code from an Edge Function and pass
/// them on to be rendered here. It no longer sees either: it names the flow and
/// the address, and `send_auth_email` does the rest. What is left of this class
/// is the redirect-URI resolution and the one setting that decides whether a
/// newly created user is mailed at all.
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

    await _emailRepository.sendUserCreatedEmail(
      email.trim(),
      name: name,
      redirectTo: _resolveRedirectUri(
        _passwordResetRedirectUri,
        redirectUriOverride,
      ),
    );
  }

  Future<void> sendPasswordResetEmail({
    required String email,
    String? name,
    String? redirectUriOverride,
  }) => _emailRepository.sendPasswordResetEmail(
    email.trim(),
    name: name,
    redirectTo: _resolveRedirectUri(
      _passwordResetRedirectUri,
      redirectUriOverride,
    ),
  );

  Future<void> sendSignInOtpEmail({
    required String email,
    String? redirectUriOverride,
  }) => _emailRepository.sendLoginOtpEmail(
    email.trim(),
    redirectTo: _resolveRedirectUri(_signInRedirectUri, redirectUriOverride),
  );

  Future<void> sendSignUpConfirmationEmail({
    required String email,
    String? name,
    String? redirectUriOverride,
  }) => _emailRepository.sendSignUpConfirmationEmail(
    email.trim(),
    name: name,
    redirectTo: _resolveRedirectUri(_signInRedirectUri, redirectUriOverride),
  );

  String _resolveRedirectUri(String defaultValue, String? override) {
    final trimmed = override?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return defaultValue;
  }
}
