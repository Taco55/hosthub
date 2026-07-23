import 'package:app_errors/app_errors.dart';

bool isLodgifyCredentialError(DomainError error) {
  final normalized = _flattenError(error).toLowerCase();
  if (normalized.isEmpty) return false;

  return normalized.contains('missing x-apikey') ||
      normalized.contains('missing lodgify api key') ||
      normalized.contains('failed to resolve lodgify credentials') ||
      normalized.contains('add one in settings');
}

String _flattenError(DomainError error) {
  final parts = <String>[
    _flattenValue(error.message),
    _flattenValue(error.debugMessage),
    _flattenValue(error.context),
    _flattenValue(error.cause),
  ]..removeWhere((value) => value.isEmpty);

  return parts.join(' ');
}

String _flattenValue(Object? value) {
  if (value == null) return '';
  if (value is Map) {
    return value.entries
        .map((entry) => '${entry.key} ${_flattenValue(entry.value)}')
        .where((part) => part.trim().isNotEmpty)
        .join(' ');
  }
  if (value is Iterable) {
    return value
        .map(_flattenValue)
        .where((part) => part.trim().isNotEmpty)
        .join(' ');
  }
  return value.toString();
}
