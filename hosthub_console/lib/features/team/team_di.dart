import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/auth/domain/ports/email_templates_port.dart';
import 'package:hosthub_console/features/team/data/site_member_repository.dart';

void registerTeamDependencies(SupabaseClient client) {
  if (!I.isRegistered<SiteMemberRepository>()) {
    I.registerSingleton<SiteMemberRepository>(
      SiteMemberRepository(
        supabase: client,
        emailTemplates: I.get<EmailTemplatesPort>(),
        setPasswordRedirectUri: AppConfig.current.authRedirectUri(
          path: '/set-password',
        ),
      ),
      signalsReady: true,
    );
  }
}
