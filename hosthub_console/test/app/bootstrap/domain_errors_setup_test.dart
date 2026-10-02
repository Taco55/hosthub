import 'package:app_errors/app_errors.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hosthub_console/app/bootstrap/domain_errors_setup.dart';

/// The console's own HTTP calls (Lodgify, the API client) go through Dio and
/// lean on the Dio adapter the library builds in. Configuring the Supabase
/// adapter must keep it.
void main() {
  setUp(configureDomainErrors);
  tearDown(DomainErrors.resetForTesting);

  final request = RequestOptions(path: '/v1/properties');

  DioException responded(int status) => DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(requestOptions: request, statusCode: status),
  );

  test('a Dio request that never reached the server is a network failure', () {
    final error = DomainError.from(
      DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
      ),
      stack: StackTrace.current,
      operation: DomainOperation.load,
    );

    expect(error.code, DomainErrorCode.network);
    expect(error.isNetworkError, isTrue);
    expect(error.operation, DomainOperation.load);
  });

  test('a Dio 403 is a refusal, a 500 a server error', () {
    expect(
      DomainError.from(responded(403), stack: StackTrace.current).code,
      DomainErrorCode.permissionDenied,
    );
    expect(
      DomainError.from(responded(500), stack: StackTrace.current).code,
      DomainErrorCode.serverError,
    );
  });

  test('a Dio error that carries a converted failure is that failure', () {
    final converted = DomainErrorCode.notFound.err(message: 'gone');

    final error = DomainError.from(
      DioException(requestOptions: request, error: converted),
      stack: StackTrace.current,
    );

    expect(error, same(converted));
  });

  test('a Supabase failure still goes through the Supabase adapter', () {
    final error = DomainError.from(
      const PostgrestException(message: 'permission denied', code: '42501'),
      stack: StackTrace.current,
      operation: DomainOperation.save,
    );

    expect(error.code, DomainErrorCode.permissionDenied);
    expect(error.operation, DomainOperation.save);
  });
}
