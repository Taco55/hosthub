import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_auth_adapter.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_email_templates_adapter.dart';
import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_onboarding_adapter.dart';
import 'package:hosthub_console/features/server_settings/data/admin_settings_repository.dart';

void registerAuthDependencies([SupabaseClient? client]) {
  final supabaseClient = client ?? Supabase.instance.client;

  if (!I.isRegistered<OnboardingPort>()) {
    I.registerSingleton<OnboardingPort>(
      I.get<AdminSettingsRepository>(),
      signalsReady: true,
    );
  }

  if (!I.isRegistered<EmailTemplatesPort>()) {
    I.registerSingleton<EmailTemplatesPort>(
      SupabaseEmailTemplatesAdapter(client: supabaseClient),
      signalsReady: true,
    );
  }

  if (!I.isRegistered<SupabaseOnboardingAdapter>()) {
    I.registerSingleton<SupabaseOnboardingAdapter>(
      SupabaseOnboardingAdapter(
        supabase: supabaseClient,
        emailRepository: I.get<EmailTemplatesPort>(),
        settingsRepository: I.get<OnboardingPort>(),
        passwordResetRedirectUri: AppConfig.current.authRedirectUri(
          path: '/reset-password',
        ),
        signInRedirectUri: AppConfig.current.authRedirectUri(path: '/login'),
      ),
      signalsReady: true,
    );
  }

  if (!I.isRegistered<AuthPort>()) {
    I.registerSingleton<AuthPort>(
      SupabaseAuthAdapter(
        onboardingAdapter: I.get<SupabaseOnboardingAdapter>(),
      ),
      signalsReady: true,
    );
  }
}
