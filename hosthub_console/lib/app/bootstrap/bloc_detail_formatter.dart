/// Extracts human-readable detail from bloc states and events for compact
/// console logging.
///
/// Ported from diplora-clients' `BlocDetailFormatter`, tailored to HostHub
/// state/event shapes. All field access is best-effort via `dynamic` — missing
/// fields are silently skipped, so the formatter works with any state without
/// coupling to concrete types.
///
/// HostHub twist: most states expose a curated, already-compact `toString()`
/// (e.g. `ReservationsState(status=loaded, entries=20, statusCounts={...})`).
/// When that representation is short we reuse it verbatim; only when a state
/// falls back to Equatable's default `toString()` and dumps a large collection
/// (the nightly-rates map) do we switch to field extraction.
abstract final class BlocDetailFormatter {
  /// Above this length a state's `toString()` is considered "not curated"
  /// (e.g. a dumped map) and we field-extract instead.
  static const _curatedToStringLimit = 180;

  /// Returns a short status string from a state object.
  ///
  /// Tries `state.status` first (stripping the enum prefix), then falls back to
  /// a truncated toString.
  static String shortStatus(Object? state, {int maxLength = 30}) {
    if (state == null) return 'null';
    final dynamic d = state;

    try {
      final status = d.status;
      if (status != null) return _stripEnumPrefix('$status');
    } catch (_) {}

    return shortString(state, maxLength: maxLength);
  }

  /// Builds a one-line detail string from a state.
  ///
  /// Prefers the state's own curated `toString()` (minus the redundant leading
  /// `status=` we already print in the transition line). Falls back to field
  /// extraction when the `toString()` is oversized (a raw collection dump).
  static String stateDetail(Object? state) {
    if (state == null) return '';

    final inner = _unwrapToString(state.toString());
    if (inner != null && inner.length <= _curatedToStringLimit) {
      final trimmed = _stripLeadingStatus(inner);
      return trimmed.isEmpty ? '' : trimmed;
    }

    return _extractFields(state);
  }

  /// Builds a detail string from an event: which entity is being acted upon.
  static String eventDetail(Object? event) {
    if (event == null) return '';
    final dynamic e = event;
    final parts = <String>[];

    for (final field in _eventIdentifierFields) {
      try {
        final value = _dynamicEventGet(e, field);
        if (value == null) continue;
        final label = _objectLabel(value);
        if (label != null && label.isNotEmpty) parts.add('$field: $label');
      } catch (_) {}
    }

    return parts.join(', ');
  }

  /// Truncates an object's string representation.
  static String shortString(Object? value, {int maxLength = 120}) {
    if (value == null) return 'null';
    final text = value.toString();
    if (text.startsWith('Instance of')) return value.runtimeType.toString();
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }

  // ---------------------------------------------------------------------------
  // Field extraction (fallback for non-curated toString)
  // ---------------------------------------------------------------------------

  static String _extractFields(Object? state) {
    final dynamic d = state;
    final parts = <String>[];

    for (final field in _countFields) {
      try {
        final value = _dynamicGet(d, field);
        final length = _collectionLength(value);
        if (length != null && length > 0) parts.add('#$field: $length');
      } catch (_) {}
    }

    for (final field in _contextFields) {
      try {
        final value = _dynamicGet(d, field);
        if (value != null) {
          final text = _stripEnumPrefix('$value');
          if (text.length <= 40) parts.add('$field: $text');
        }
      } catch (_) {}
    }

    try {
      final error = d.error;
      if (error != null) parts.add('error: ${shortString(error, maxLength: 60)}');
    } catch (_) {}

    return parts.join(', ');
  }

  static int? _collectionLength(Object? value) {
    if (value is Iterable) return value.length;
    if (value is Map) return value.length;
    return null;
  }

  // ---------------------------------------------------------------------------
  // toString helpers
  // ---------------------------------------------------------------------------

  /// Strips `RuntimeType(...)` → the inner `...`. Returns null when the shape
  /// isn't a single wrapping pair of parentheses.
  static String? _unwrapToString(String text) {
    final open = text.indexOf('(');
    if (open <= 0 || !text.endsWith(')')) return null;
    return text.substring(open + 1, text.length - 1).trim();
  }

  /// Drops a leading `status=<value>, ` (or trailing `status=<value>`) segment,
  /// since the transition line already shows the status.
  static String _stripLeadingStatus(String inner) {
    if (!inner.startsWith('status=')) return inner;
    final comma = inner.indexOf(', ');
    if (comma < 0) return '';
    return inner.substring(comma + 2);
  }

  /// Strips `EnumType.value` → `value`.
  static String _stripEnumPrefix(String text) {
    final dot = text.indexOf('.');
    if (dot >= 0 && dot < text.length - 1 && !text.contains(' ')) {
      return text.substring(dot + 1);
    }
    return text;
  }

  static String? _objectLabel(dynamic obj) {
    if (obj is String) {
      return obj.length <= 40 ? obj : '${obj.substring(0, 37)}…';
    }
    if (obj is num || obj is bool) return '$obj';

    for (final prop in ['name', 'title', 'id']) {
      try {
        final value = _dynamicLabelGet(obj, prop);
        if (value != null && value is String && value.isNotEmpty) {
          return value.length <= 40 ? value : '${value.substring(0, 37)}…';
        }
      } catch (_) {}
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Dynamic field access — explicit allowlists keep output focused and stable.
  // ---------------------------------------------------------------------------

  static const _countFields = [
    'entries',
    'properties',
    'documents',
    'versions',
    'rates',
    'dirtyContent',
    'savingDocuments',
    'publishingDocuments',
    'missingPropertiesToConfirm',
    'channelPropertiesToReview',
  ];

  static const _contextFields = [
    'propertyId',
    'selectedLocale',
    'primaryDomain',
    'rateCurrency',
    'versionHistoryDocId',
  ];

  static const _eventIdentifierFields = [
    'email',
    'name',
    'propertyId',
    'siteId',
    'id',
  ];

  static dynamic _dynamicGet(dynamic obj, String field) {
    switch (field) {
      case 'entries':
        return obj.entries;
      case 'properties':
        return obj.properties;
      case 'documents':
        return obj.documents;
      case 'versions':
        return obj.versions;
      case 'rates':
        return obj.rates;
      case 'dirtyContent':
        return obj.dirtyContent;
      case 'savingDocuments':
        return obj.savingDocuments;
      case 'publishingDocuments':
        return obj.publishingDocuments;
      case 'missingPropertiesToConfirm':
        return obj.missingPropertiesToConfirm;
      case 'channelPropertiesToReview':
        return obj.channelPropertiesToReview;
      case 'propertyId':
        return obj.propertyId;
      case 'selectedLocale':
        return obj.selectedLocale;
      case 'primaryDomain':
        return obj.primaryDomain;
      case 'rateCurrency':
        return obj.rateCurrency;
      case 'versionHistoryDocId':
        return obj.versionHistoryDocId;
      default:
        return null;
    }
  }

  static dynamic _dynamicEventGet(dynamic obj, String field) {
    switch (field) {
      case 'email':
        return obj.email;
      case 'name':
        return obj.name;
      case 'propertyId':
        return obj.propertyId;
      case 'siteId':
        return obj.siteId;
      case 'id':
        return obj.id;
      default:
        return null;
    }
  }

  static dynamic _dynamicLabelGet(dynamic obj, String prop) {
    switch (prop) {
      case 'name':
        return obj.name;
      case 'title':
        return obj.title;
      case 'id':
        return obj.id;
      default:
        return null;
    }
  }
}
