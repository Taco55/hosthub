import 'dart:convert';

import 'package:app_errors/supabase_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/messaging/infrastructure/lodgify/lodgify_messaging_repository.dart';
import 'package:hosthub_console/features/messaging/infrastructure/store/supabase_message_store.dart';

/// `messaging-sync` answering with a status the sync does not accept is the
/// function's failure: mapped from its payload, and reported once.
void main() {
  tearDown(DomainErrors.resetForTesting);

  LodgifyMessagingRepository repositoryAnswering(int status, Object body) {
    final client = SupabaseClient(
      'http://localhost:7011',
      'sb_publishable_test',
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode(body),
          status,
          headers: const {'content-type': 'application/json'},
        ),
      ),
    );
    return LodgifyMessagingRepository(
      supabase: client,
      store: SupabaseMessageStore(supabase: client),
    );
  }

  test('a sync status other than 200 is reported once, as a load', () async {
    final reported = <DomainError>[];
    DomainError.onUnexpectedError = reported.add;
    final repository = repositoryAnswering(202, {
      'error_code': 'sync_in_progress',
    });

    await expectLater(
      repository.syncThreads(propertyIds: const [1]),
      throwsA(
        isA<DomainError>()
            .having(
              (e) => e.projectErrorCode,
              'project code',
              'sync_in_progress',
            )
            .having((e) => e.operation, 'operation', DomainOperation.load),
      ),
    );
    await pumpEventQueue();
    expect(reported, hasLength(1));
  });
}
