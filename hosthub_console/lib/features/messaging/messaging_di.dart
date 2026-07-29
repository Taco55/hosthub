import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/core/di/inject.dart';
import 'package:hosthub_console/features/messaging/domain/messaging_repository.dart';
import 'package:hosthub_console/features/messaging/infrastructure/lodgify/lodgify_messaging_repository.dart';
import 'package:hosthub_console/features/messaging/infrastructure/store/supabase_message_store.dart';

/// Wiring one messaging source.
///
/// This function and the implementation it names are the only two places a
/// source appears. Adding a second one is a `MessagingRepository` and a line
/// here — nothing under `application/` or `presentation/` changes, which is the
/// claim `test/features/messaging/messaging_source_agnostic_test.dart` checks.
void registerMessagingDependencies(SupabaseClient client) {
  if (!I.isRegistered<SupabaseMessageStore>()) {
    I.registerSingleton<SupabaseMessageStore>(
      SupabaseMessageStore(supabase: client),
    );
  }

  if (!I.isRegistered<MessagingRepository>()) {
    I.registerSingleton<MessagingRepository>(
      LodgifyMessagingRepository(
        supabase: client,
        store: I.get<SupabaseMessageStore>(),
      ),
      signalsReady: true,
    );
  }
}
