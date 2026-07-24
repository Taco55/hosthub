import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';

import 'translation_service.dart';

/// Signature of `SupabaseClient.functions.invoke` — injectable so tests can
/// fake the Edge Function without a running Supabase stack.
typedef EdgeFunctionInvoke =
    Future<FunctionResponse> Function(
      String functionName, {
      Map<String, dynamic>? body,
    });

/// [TranslationService] backed by the `translate-content` Edge Function. The
/// function holds the provider key server-side, skips locked fields and
/// source-hash cache hits, and persists results to `site_translations`
/// (see supabase/functions/translate-content/).
class EdgeFunctionTranslationService extends SupabaseRepository
    implements TranslationService {
  EdgeFunctionTranslationService({
    required SupabaseClient supabase,
    required this.siteId,
    required this.page,
    EdgeFunctionInvoke? invoke,
  }) : _invoke =
           invoke ??
           ((name, {body}) => supabase.functions.invoke(name, body: body)),
       super(supabase);

  static const String functionName = 'translate-content';

  final String siteId;
  final String page;
  final EdgeFunctionInvoke _invoke;

  @override
  Future<Map<String, String>> translateFields({
    required String sourceLanguage,
    required String targetLanguage,
    required Map<String, String> sourceFields,
  }) async {
    if (sourceFields.isEmpty) return const {};
    try {
      final response = await _invoke(
        functionName,
        body: {
          'siteId': siteId,
          'page': page,
          'sourceLanguage': sourceLanguage,
          'targetLanguages': [targetLanguage],
          'fields': [
            for (final entry in sourceFields.entries)
              {'key': entry.key, 'sourceText': entry.value},
          ],
        },
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw DomainErrorCode.dataFetchFailed.err(
          message: 'Unexpected translate-content response shape',
          context: {'data': data.runtimeType.toString()},
        );
      }
      final translations = (data['translations'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .where((t) => t['language'] == targetLanguage);
      return {
        for (final t in translations)
          if (t['key'] is String && t['value'] is String)
            t['key'] as String: t['value'] as String,
      };
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {
          'op': 'translateFields',
          'siteId': siteId,
          'page': page,
          'targetLanguage': targetLanguage,
        },
      );
    }
  }
}
