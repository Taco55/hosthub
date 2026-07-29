import 'package:app_errors/app_errors.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('context added by the repository survives the mapping', () {
      final mapped = DomainError.from(
        _lodgifyFailure(429),
        stack: StackTrace.current,
      );
      final withContext = mapped.copyWith(
        context: {
          'repository': 'LodgifyChannelManagerRepository',
          'op': 'fetchNightlyRates',
          ...?mapped.context,
          'propertyId': '42',
        },
      );

      expect(withContext.code, DomainErrorCode.tooManyRequests);
      expect(withContext.reason, DomainErrorReason.rateLimited);
      expect(withContext.context?['op'], 'fetchNightlyRates');
      expect(withContext.context?['propertyId'], '42');
    });
  });
}
