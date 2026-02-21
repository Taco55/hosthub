import 'package:app_errors/app_errors.dart';

Map<String, String> _parseFragmentParameters(String fragment) {
  if (fragment.isEmpty) return const <String, String>{};

  final trimmed = fragment.startsWith('/') ? fragment.substring(1) : fragment;
  final queryIndex = trimmed.indexOf('?');

  if (queryIndex != -1) {
    final query = trimmed.substring(queryIndex + 1);
    if (query.isEmpty) return const <String, String>{};

    final hashIndex = query.indexOf('#');
    if (hashIndex != -1) {
      final head = query.substring(0, hashIndex);
      final tail = query.substring(hashIndex + 1);
      final result = <String, String>{};
      if (head.isNotEmpty) {
        result.addAll(Uri.splitQueryString(head));
      }
      if (tail.isNotEmpty) {
        result.addAll(_parseFragmentParameters(tail));
      }
      return result;
    }

    return Uri.splitQueryString(query);
  }

  var candidate = trimmed;
  final hashIndex = candidate.indexOf('#');
  if (hashIndex != -1) {
    final afterHash = candidate.substring(hashIndex + 1);
    if (afterHash.contains('=')) {
      candidate = afterHash;
    } else {
      candidate = candidate.substring(0, hashIndex);
    }
  }

  if (!candidate.contains('=')) return const <String, String>{};
  return Uri.splitQueryString(candidate);
}

String _normalizePath(String candidate) {
  if (candidate.isEmpty) return '/';
  if (candidate.startsWith('/')) return candidate;
  return '/$candidate';
}

String? _extractFragmentPath(String fragment) {
  if (fragment.isEmpty) return null;

  final normalized = fragment.startsWith('/') ? fragment : '/$fragment';

  var end = normalized.length;
  final queryIndex = normalized.indexOf('?');
  if (queryIndex != -1 && queryIndex < end) {
    end = queryIndex;
  }

  final hashIndex = normalized.indexOf('#');
  if (hashIndex != -1 && hashIndex < end) {
    end = hashIndex;
  }

  if (end <= 0) return null;
  final candidate = normalized.substring(0, end);
  if (candidate.isEmpty) return null;

  final pathSegment = candidate.startsWith('/')
      ? candidate.substring(1)
      : candidate;
  if (pathSegment.contains('=')) {
    return null;
  }

  return candidate;
}

class AuthRedirectPayload {
  const AuthRedirectPayload({
    required this.path,
    required this.queryParameters,
    this.accessToken,
    this.refreshToken,
    this.error,
    this.type,
    this.domainError,
  }) : isValid =
           accessToken != null &&
           refreshToken != null &&
           error == null &&
           domainError == null,
       hasError = error != null || domainError != null;

  final String path;
  final Map<String, String> queryParameters;

  final String? accessToken;
  final String? refreshToken;
  final String? error;
  final String? type;
  final DomainError? domainError;

  final bool isValid;
  final bool hasError;

  factory AuthRedirectPayload.fromUri(Uri uri) {
    try {
      final basePath = _normalizePath(uri.path);
      final params = <String, String>{}..addAll(uri.queryParameters);

      var resolvedPath = basePath;

      final fragment = uri.fragment.trim();
      if (fragment.isNotEmpty) {
        params.addAll(_parseFragmentParameters(fragment));

        final fragmentPath = _extractFragmentPath(fragment);
        if (fragmentPath != null && fragmentPath.isNotEmpty) {
          resolvedPath = fragmentPath;
        }
      }

      final accessToken = params['access_token'];
      final refreshToken = params['refresh_token'];
      final error = params['error_description'] ?? params['error'];
      final rawType = params['type'] ?? params['flow'];
      final type = rawType?.toLowerCase();

      return AuthRedirectPayload(
        path: resolvedPath,
        queryParameters: Map.unmodifiable(params),
        accessToken: accessToken,
        refreshToken: refreshToken,
        error: error,
        type: type,
        domainError: error != null
            ? DomainError.of(DomainErrorCode.unauthorized, message: error)
            : null,
      );
    } catch (e, st) {
      final fallbackPath = _normalizePath(uri.path);
      return AuthRedirectPayload(
        path: fallbackPath,
        queryParameters: Map.unmodifiable(uri.queryParameters),
        domainError: DomainError.of(
          DomainErrorCode.validationFailed,
          reason: DomainErrorReason.invalidUrl,
          message: 'Failed to parse redirect URI',
          cause: e,
          stack: st,
        ),
      );
    }
  }

  bool get isExpired =>
      error?.toLowerCase().contains('expired') == true ||
      error?.toLowerCase().contains('invalid') == true;

  bool get hasTokens => accessToken != null && refreshToken != null;

  bool get isInvite =>
      type == 'invite' || type == 'signup' || type == 'recovery_invite';
}
