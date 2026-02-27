import 'dart:async';
import 'dart:io' show HttpException, SocketException;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/core/services/interceptors/simplified_dio_interceptor.dart';
import 'package:hosthub_console/core/services/local_storage_manager.dart';
import 'package:uuid/uuid.dart';

class ApiClient {
  final Dio api = Dio();

  static const _connectTimeout = Duration(seconds: 10);
  static const _receiveTimeout = Duration(seconds: 10);
  static const _sendTimeout = Duration(seconds: 10);
  static const _retryableErrorPhrases = <String>[
    'Connection closed before full header was received',
    'Connection reset by peer',
    'Software caused connection abort',
    'Connection error while receiving data',
  ];
  static const _maxRetryAttempts = 1;
  static const _retryBaseDelay = Duration(milliseconds: 150);

  final Set<CancelToken> _activeCancelTokens = <CancelToken>{};
  bool _forceCloseNextRequest = false;
  Future<void>? _pendingUnauthorizedLogout;
  final String? _defaultApiVersion;

  ApiClient({required String baseUrl, String? apiVersion})
      : _defaultApiVersion = apiVersion?.trim().replaceAll('/', '') {
    api.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
    );
  }

  void init() {
    if (AppConfig.current.enableApiLogger) {
      api.interceptors.add(
        SimplifiedDioInterceptor(
          logRequestBody: true,
          logResponseBody: AppConfig.current.enableApiLogger,
        ),
      );
    }

    addAuthInterceptor();
  }

  Future<void> _prepareRetry(int attempt) async {
    _resetAdapterAndForceCloseNextRequest();
    if (attempt <= 0) return;
    final delay = Duration(
      milliseconds: _retryBaseDelay.inMilliseconds * attempt,
    );
    await Future.delayed(delay);
  }

  void _resetAdapterAndForceCloseNextRequest() {
    _forceCloseNextRequest = true;
    final currentAdapter = api.httpClientAdapter;
    try {
      currentAdapter.close(force: true);
    } catch (_) {}
    api.httpClientAdapter = Dio().httpClientAdapter;
  }

  bool _shouldRetry(DioException error) {
    if (error.type == DioExceptionType.cancel) {
      return false;
    }

    final message = error.message ?? '';
    if (_matchesRetryablePhrase(message)) {
      return true;
    }
    final cause = error.error;
    if (cause != null) {
      final causeMessage = cause.toString();
      if (_matchesRetryablePhrase(causeMessage)) {
        return true;
      }
      if (cause is HttpException && _matchesRetryablePhrase(cause.message)) {
        return true;
      }
      if (cause is SocketException) {
        if (_matchesRetryablePhrase(cause.message)) {
          return true;
        }
        final osErrorMessage = cause.osError?.message;
        if (_matchesRetryablePhrase(osErrorMessage)) {
          return true;
        }
      }
    }

    if (error.type == DioExceptionType.connectionError) {
      return true;
    }

    return false;
  }

  bool _matchesRetryablePhrase(String? message) {
    if (message == null || message.isEmpty) return false;
    return _retryableErrorPhrases.any((needle) => message.contains(needle));
  }

  String? _resolveBaseUrl(String? baseUrl, String? apiVersion) {
    final candidate = baseUrl ?? api.options.baseUrl;
    if (candidate.isEmpty) return null;
    if (apiVersion == null || apiVersion.isEmpty) {
      return candidate;
    }
    return _applyApiVersion(candidate, apiVersion);
  }

  String _applyApiVersion(String baseUrl, String apiVersion) {
    final version = apiVersion.replaceAll('/', '').trim();
    if (version.isEmpty) return baseUrl;
    final uri = Uri.parse(baseUrl);
    final segments = List<String>.from(uri.pathSegments);
    if (segments.isNotEmpty && segments.last.isEmpty) {
      segments.removeLast();
    }
    if (segments.isNotEmpty && segments.last == version) {
      return uri.toString();
    }
    final updated = uri.replace(pathSegments: [...segments, version]);
    return updated.toString();
  }

  String _normalizeEndPoint(String endPoint, String? baseUrl) {
    if (endPoint.startsWith('http://') || endPoint.startsWith('https://')) {
      return endPoint;
    }
    if (baseUrl == null || baseUrl.isEmpty) return endPoint;
    if (endPoint.startsWith('/')) return endPoint;
    if (baseUrl.endsWith('/')) return endPoint;
    return '/$endPoint';
  }

  Future<Map<String, String>> _buildHeaders({
    required bool useAccesstoken,
    Map<String, String>? extraHeaders,
  }) async {
    final uuid = const Uuid();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'request_id': uuid.v4(),
    };

    if (useAccesstoken) {
      final token = await LocalStorageManager.getToken();
      final accessToken = token?.accessToken;
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    if (extraHeaders != null && extraHeaders.isNotEmpty) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  CancelToken _trackCancelToken([CancelToken? candidate]) {
    final token = candidate ?? CancelToken();
    if (_activeCancelTokens.contains(token)) {
      return token;
    }
    _activeCancelTokens.add(token);
    token.whenCancel.then((_) => _activeCancelTokens.remove(token));
    return token;
  }

  void cancelActiveRequests([String reason = 'cancelled_by_app_lifecycle']) {
    for (final token in _activeCancelTokens.toList()) {
      if (!token.isCancelled) {
        token.cancel(reason);
      }
    }
    _activeCancelTokens.clear();
  }

  void markResume() => _resetAdapterAndForceCloseNextRequest();

  Future<Response<dynamic>> _send({
    required String method,
    required String endPoint,
    bool useAccesstoken = false,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    String? baseUrl,
    String? apiVersion,
    Map<String, String>? extraHeaders,
  }) async {
    final cancelToken = _trackCancelToken();
    var retries = 0;
    final resolvedBaseUrl = _resolveBaseUrl(
      baseUrl,
      apiVersion ?? _defaultApiVersion,
    );
    final resolvedEndPoint = _normalizeEndPoint(
      endPoint,
      resolvedBaseUrl,
    );

    try {
      while (true) {
        final headers = await _buildHeaders(
          useAccesstoken: useAccesstoken,
          extraHeaders: extraHeaders,
        );
        if (_forceCloseNextRequest) {
          if (!kIsWeb) {
            headers['Connection'] = 'close';
          }
          _forceCloseNextRequest = false;
        }

        final options = Options(
          method: method,
          headers: headers,
          responseType: ResponseType.json,
        );

        final requestOptions = options.compose(
          api.options,
          resolvedEndPoint,
          queryParameters: queryParameters,
          data: data,
        );

        if (resolvedBaseUrl != null && resolvedBaseUrl.isNotEmpty) {
          requestOptions.baseUrl = resolvedBaseUrl;
        }

        if (kIsWeb && data == null) {
          requestOptions.sendTimeout = null;
        }

        requestOptions.cancelToken = cancelToken;

        try {
          return await api.fetch(requestOptions);
        } on DioException catch (error) {
          final canRetry = retries < _maxRetryAttempts && _shouldRetry(error);
          if (!canRetry) {
            Error.throwWithStackTrace(error, error.stackTrace);
          }

          retries += 1;
          await _prepareRetry(retries);
        }
      }
    } finally {
      _activeCancelTokens.remove(cancelToken);
    }
  }

  void addAuthInterceptor() {
    api.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final status = error.response?.statusCode;
          final request = error.requestOptions;
          final hasAuthHeader = request.headers['Authorization'] != null;

          if (request.uri.path.startsWith('/auth/')) {
            handler.next(error);
            return;
          }

          if (status == 401 && hasAuthHeader) {
            if (hasAuthHeader) {
              unawaited(_debouncedUnauthorizedLogout());
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<void> _debouncedUnauthorizedLogout() {
    final existing = _pendingUnauthorizedLogout;
    if (existing != null) return existing;

    final op = () async {
      try {
        cancelActiveRequests('unauthorized');
        await LocalStorageManager.clearToken();
      } finally {
        _pendingUnauthorizedLogout = null;
      }
    }();
    _pendingUnauthorizedLogout = op;
    return op;
  }

  Future<T> getRequest<T>({
    required String endPoint,
    bool useAccesstoken = true,
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
    String? apiVersion,
    Map<String, String>? extraHeaders,
    required T Function(dynamic) dataConstructor,
  }) async {
    final response = await _send(
      method: 'GET',
      endPoint: endPoint,
      baseUrl: baseUrl,
      apiVersion: apiVersion,
      useAccesstoken: useAccesstoken,
      queryParameters: queryParameters,
      extraHeaders: extraHeaders,
    );

    return _mapResponse(
      response: response,
      method: 'GET',
      endPoint: endPoint,
      dataConstructor: dataConstructor,
    );
  }

  Future<T> postRequest<T>({
    required String endPoint,
    bool useAccesstoken = true,
    Map<String, dynamic>? queryParameters,
    dynamic postBody,
    String? baseUrl,
    String? apiVersion,
    Map<String, String>? extraHeaders,
    required T Function(dynamic) dataConstructor,
  }) async {
    final response = await _send(
      method: 'POST',
      endPoint: endPoint,
      baseUrl: baseUrl,
      apiVersion: apiVersion,
      useAccesstoken: useAccesstoken,
      queryParameters: queryParameters,
      data: postBody,
      extraHeaders: extraHeaders,
    );
    return _mapResponse(
      response: response,
      method: 'POST',
      endPoint: endPoint,
      dataConstructor: dataConstructor,
    );
  }

  Future<T> putRequest<T>({
    required String endPoint,
    bool useAccesstoken = true,
    Map<String, dynamic>? queryParameters,
    dynamic postBody,
    String? baseUrl,
    String? apiVersion,
    Map<String, String>? extraHeaders,
    required T Function(dynamic) dataConstructor,
  }) async {
    final response = await _send(
      method: 'PUT',
      endPoint: endPoint,
      baseUrl: baseUrl,
      apiVersion: apiVersion,
      useAccesstoken: useAccesstoken,
      queryParameters: queryParameters,
      data: postBody,
      extraHeaders: extraHeaders,
    );
    return _mapResponse(
      response: response,
      method: 'PUT',
      endPoint: endPoint,
      dataConstructor: dataConstructor,
    );
  }

  Future<T> deleteRequest<T>({
    required String endPoint,
    bool useAccesstoken = true,
    Map<String, dynamic>? queryParameters,
    dynamic postBody,
    String? baseUrl,
    String? apiVersion,
    Map<String, String>? extraHeaders,
    required T Function(dynamic) dataConstructor,
  }) async {
    final response = await _send(
      method: 'DELETE',
      endPoint: endPoint,
      baseUrl: baseUrl,
      apiVersion: apiVersion,
      useAccesstoken: useAccesstoken,
      queryParameters: queryParameters,
      data: postBody,
      extraHeaders: extraHeaders,
    );
    return _mapResponse(
      response: response,
      method: 'DELETE',
      endPoint: endPoint,
      dataConstructor: dataConstructor,
    );
  }

  T _mapResponse<T>({
    required Response response,
    required String method,
    required String endPoint,
    required T Function(dynamic data) dataConstructor,
  }) {
    final status = response.statusCode;
    if (status == 200 || status == 201 || status == 202) {
      return dataConstructor(response.data);
    }
    if (status == 204) {
      return dataConstructor(null);
    }

    throw Exception('HTTP ${status ?? 'unknown'} at $endPoint ($method)');
  }
}
