import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/cms/data/cms_repository.dart';

void registerCmsDependencies(SupabaseClient client) {
  if (!I.isRegistered<CmsRepository>()) {
    I.registerSingleton<CmsRepository>(
      CmsRepository(supabase: client),
      signalsReady: true,
    );
  }
}
