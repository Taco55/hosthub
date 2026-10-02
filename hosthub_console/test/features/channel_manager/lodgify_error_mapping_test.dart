import 'package:app_errors/app_errors.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/core/services/lodgify_service.dart';
import 'package:hosthub_console/features/channel_manager/infrastructure/lodgify/lodgify_channel_manager_repository.dart';

/// The repository that wraps [LodgifyService] used to let raw `DioException`s
/// through to the cubits, so a Lodgify rate limit arrived as an unrecognisable
/// failure instead of something the UI could name.
///
/// These pin the mapping the repository now relies on. It maps with
/// `DomainError.from`, which reads the HTTP status out of the exception — so
/// what has to hold is that a 429 comes out as `tooManyRequests` +
/// `rateLimited`, and that the ordinary failures stay distinguishable from it.
DioException _lodgifyFailure(int status, {Object? data}) {
  final requestOptions = RequestOptions(path: 'lodgify-rates');
  return DioException(
    requestOptions: requestOptions,
    response: Response(
      requestOptions: requestOptions,
      statusCode: status,
      data: data,
    ),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  group('Lodgify failures become DomainErrors', () {
    test('a 429 is a rate limit, not a generic server error', () {
      final error = DomainError.from(
        _lodgifyFailure(429, data: {'error': 'Lodgify rate limit reached.'}),
        stack: StackTrace.current,
      );

      expect(error.code, DomainErrorCode.tooManyRequests);
      expect(error.reason, DomainErrorReason.rateLimited);
    });

    test('a 500 stays a server error', () {
      final error = DomainError.from(
        _lodgifyFailure(500),
        stack: StackTrace.current,
      );

      expect(error.code, DomainErrorCode.serverError);
      expect(error.reason, isNot(DomainErrorReason.rateLimited));
    });

    test('a 400 stays a bad request', () {
      final error = DomainError.from(
        _lodgifyFailure(400),
        stack: StackTrace.current,
      );

      expect(error.code, DomainErrorCode.badRequest);
      expect(error.reason, isNot(DomainErrorReason.rateLimited));
    });

    test('the report carries the repository\'s context', () async {
      final reported = <DomainError>[];
      DomainError.onUnexpectedError = reported.add;
      addTearDown(DomainErrors.resetForTesting);
      final repository = LodgifyChannelManagerRepository(
        lodgifyService: _FailingLodgifyService(_lodgifyFailure(500)),
      );

      await expectLater(
        repository.fetchProperties(),
        throwsA(
          isA<DomainError>()
              .having((e) => e.code, 'code', DomainErrorCode.serverError)
              .having((e) => e.context?['op'], 'op', 'fetchProperties'),
        ),
      );
      expect(reported, hasLength(1));
      expect(
        reported.single.context,
        allOf(
          containsPair('repository', 'LodgifyChannelManagerRepository'),
          containsPair('op', 'fetchProperties'),
        ),
      );
    });
  });
}

/// A service whose property list fails with [failure]; nothing reaches
/// Supabase.
class _FailingLodgifyService extends LodgifyService {
  _FailingLodgifyService(this.failure);

  final Object failure;

  @override
  Future<List<LodgifyPropertySummary>> fetchProperties({
    Map<String, String> queryParameters = const {},
  }) async => throw failure;
}
