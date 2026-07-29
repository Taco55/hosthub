import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/team/data/site_member_repository.dart';

void registerTeamDependencies(SupabaseClient client) {
  if (!I.isRegistered<SiteMemberRepository>()) {
    I.registerSingleton<SiteMemberRepository>(
      SiteMemberRepository(
        supabase: client,
        setPasswordRedirectUri: AppConfig.current.authRedirectUri(
          path: '/set-password',
        ),
      ),
      signalsReady: true,
    );
  }
}
