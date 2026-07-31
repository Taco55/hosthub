import 'package:app_errors/app_errors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/website_editor/website_editor.dart';

EdgeFunctionTranslationService buildService(EdgeFunctionInvoke invoke) {
  // The SupabaseClient is only used to build the default invoke; tests always
  // inject their own, so a lightweight client with dummy config suffices.
  return EdgeFunctionTranslationService(
    supabase: SupabaseClient('http://localhost:7011', 'sb_publishable_test'),
    siteId: 'site-1',
    page: 'home',
    invoke: invoke,
  );
}

void main() {
  test(
    'sends the TRANSLATION.md payload shape and maps the response',
    () async {
      late String calledName;
      late Map<String, dynamic> calledBody;
      final service = buildService((name, {body}) async {
        calledName = name;
        calledBody = body!;
        return FunctionResponse(
          status: 200,
          data: {
            'translations': [
              {'key': 'hero.headline', 'language': 'en', 'value': 'Your home'},
              {
                'key': 'hero.subtitle',
                'language': 'en',
                'value': 'Ski-in luxury',
              },
              // Other-language rows must be ignored.
              {'key': 'hero.headline', 'language': 'no', 'value': 'Ditt hjem'},
            ],
          },
        );
      });

      final result = await service.translateFields(
        sourceLanguage: 'nl',
        targetLanguage: 'en',
        sourceFields: {
          'hero.headline': 'Jouw bergwoning',
          'hero.subtitle': 'Ski-in luxe',
        },
      );

      expect(calledName, 'translate-content');
      expect(calledBody['siteId'], 'site-1');
      expect(calledBody['page'], 'home');
      expect(calledBody['sourceLanguage'], 'nl');
      expect(calledBody['targetLanguages'], ['en']);
      expect(calledBody['fields'], [
        {'key': 'hero.headline', 'sourceText': 'Jouw bergwoning'},
        {'key': 'hero.subtitle', 'sourceText': 'Ski-in luxe'},
      ]);
      expect(result, {
        'hero.headline': 'Your home',
        'hero.subtitle': 'Ski-in luxury',
      });
    },
  );

  test('returns empty without calling the function for empty input', () async {
    var called = false;
    final service = buildService((name, {body}) async {
      called = true;
      return FunctionResponse(status: 200, data: {'translations': <dynamic>[]});
    });

    final result = await service.translateFields(
      sourceLanguage: 'nl',
      targetLanguage: 'en',
      sourceFields: const {},
    );

    expect(result, isEmpty);
    expect(called, isFalse);
  });

  test('wraps function failures in a DomainError', () async {
    final service = buildService((name, {body}) async {
      throw const FunctionException(
        status: 403,
        details: {'error': 'insufficient_permissions'},
      );
    });

    await expectLater(
      service.translateFields(
        sourceLanguage: 'nl',
        targetLanguage: 'en',
        sourceFields: {'hero.headline': 'Jouw bergwoning'},
      ),
      throwsA(isA<DomainError>()),
    );
  });

  test('rejects an unexpected response shape as DomainError', () async {
    final service = buildService(
      (name, {body}) async => FunctionResponse(status: 200, data: 'oops'),
    );

    await expectLater(
      service.translateFields(
        sourceLanguage: 'nl',
        targetLanguage: 'en',
        sourceFields: {'hero.headline': 'x'},
      ),
      throwsA(isA<DomainError>()),
    );
  });
}
