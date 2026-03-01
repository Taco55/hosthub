import 'package:dio/dio.dart';
import 'package:hosthub_console/core/services/api_services/api_parsing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LodgifyService {
  LodgifyService();

  Future<List<LodgifyPropertySummary>> fetchProperties({
    Map<String, String> queryParameters = const {},
  }) async {
    final response = await Supabase.instance.client.functions.invoke(
      'lodgify-properties',
      method: HttpMethod.get,
      queryParameters: queryParameters,
    );

    final status = response.status;
    if (status != 200 && status != 201 && status != 202) {
      final requestOptions = RequestOptions(path: 'lodgify-properties');
      throw DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: status,
          data: response.data,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    final decoded = (response.data as Object?).asDecodedJsonOrSelf();
    final list = decoded.extractList(
      fallbackKeys: const ['properties', 'items', 'data', 'results'],
    );

    return list
        .whereType<Map<String, dynamic>>()
        .map(LodgifyPropertySummary.fromMap)
        .toList();
  }

  Future<LodgifyPropertyDetails> fetchPropertyDetails(
    String propertyId, {
    Map<String, String> queryParameters = const {},
  }) async {
    final params = <String, String>{
      ...queryParameters,
      'property_id': propertyId.trim(),
    };

    final response = await Supabase.instance.client.functions.invoke(
      'lodgify-properties',
      method: HttpMethod.get,
      queryParameters: params,
    );

    final status = response.status;
    if (status != 200 && status != 201 && status != 202) {
      final requestOptions = RequestOptions(path: 'lodgify-properties');
      throw DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: status,
          data: response.data,
        ),
        type: DioExceptionType.badResponse,
      );
    }

    final decoded = (response.data as Object?).asDecodedJsonOrSelf();
    final map = decoded.extractMap(fallbackKeys: const ['property', 'data']);
    return LodgifyPropertyDetails.fromMap(map);
  }

  Future<List<LodgifyCalendarEntry>> fetchCalendar(
    String propertyId, {
    DateTime? start,
    DateTime? end,
    Map<String, String> queryParameters = const {},
  }) async {
    // V2 does not support date-range filtering; it uses stayFilter instead.
    // Date narrowing happens in the repository layer.
    return _fetchBookingsV2(propertyId, queryParameters: queryParameters);
  }

  /// Updates the internal notes for a reservation via the Lodgify V2 API.
  Future<void> updateReservationNotes(
    String reservationId,
    String notes,
  ) async {
    final response = await Supabase.instance.client.functions.invoke(
      'lodgify-reservations',
      method: HttpMethod.patch,
      queryParameters: {'reservationId': reservationId},
      body: {'internalNotes': notes},
    );

    final status = response.status;
    if (status != 200 && status != 204) {
      final requestOptions = RequestOptions(path: 'lodgify-reservations');
      throw DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: status,
          data: response.data,
        ),
        type: DioExceptionType.badResponse,
      );
    }
  }

  /// Fetches nightly rates for a property.
  ///
  /// Returns a record with a list of rate-period maps and the optional
  /// currency code from the channel manager's rate settings.
  Future<({List<Map<String, dynamic>> periods, String? currency})> fetchRates(
    String propertyId, {
    DateTime? start,
    DateTime? end,
  }) async {
    final params = <String, String>{'property_id': propertyId.trim()};
    if (start != null) {
      params['start'] = start.toIso8601String().split('T').first;
    }
    if (end != null) {
      params['end'] = end.toIso8601String().split('T').first;
    }

    final response = await Supabase.instance.client.functions.invoke(
      'lodgify-rates',
      method: HttpMethod.get,
      queryParameters: params,
    );

    final status = response.status;
    if (status != 200 && status != 201) {
      return (periods: const <Map<String, dynamic>>[], currency: null);
    }

    final decoded = (response.data as Object?).asDecodedJsonOrSelf();

    // Extract currency from rate_settings if present.
    String? currency;
    if (decoded is Map<String, dynamic>) {
      final settings = decoded['rate_settings'];
      if (settings is Map<String, dynamic>) {
        currency = settings['currency_code']?.toString();
      }
    }

    final periods = _extractRatePeriods(decoded);
    return (periods: periods, currency: currency);
  }

  /// Keys that commonly hold nested period arrays inside a room-type or
  /// availability wrapper object.
  static const _periodKeys = [
    'periods',
    'items',
    'data',
    'results',
    'availability',
    'rates',
    'calendar_items',
    'calendarItems',
  ];

  /// Keys whose presence signals that an object is a room-type / unit
  /// wrapper rather than a rate-period itself.
  static const _wrapperSignalKeys = [
    'room_type_id',
    'roomTypeId',
    'room_id',
    'roomId',
    'property_id',
    'propertyId',
  ];

  /// Extracts a flat list of rate-period maps from the decoded Lodgify
  /// availability response, handling nested room-type wrappers
  /// transparently.
  static List<Map<String, dynamic>> _extractRatePeriods(Object? decoded) {
    // Case C: already a flat list.
    if (decoded is List) {
      final maps = decoded.whereType<Map<String, dynamic>>().toList();
      if (maps.isEmpty) return const [];

      // Detect room-type wrappers (Case A) by checking whether the
      // first element has a wrapper-signal key AND a nested periods list.
      final first = maps.first;
      final looksLikeWrapper = _wrapperSignalKeys.any(first.containsKey);

      if (looksLikeWrapper) {
        return _flattenPeriodsFromWrappers(maps);
      }

      return maps;
    }

    // Case B: a map with a nested list under a known key.
    if (decoded is Map<String, dynamic>) {
      for (final key in _periodKeys) {
        final nested = decoded[key];
        if (nested is List) {
          // Recurse — the nested list may itself contain wrappers.
          return _extractRatePeriods(nested);
        }
      }
      // Single-object response (uncommon) — wrap as a list.
      return [decoded];
    }

    return const [];
  }

  /// Collects all nested period maps from a list of room-type wrapper
  /// objects into a single flat list.
  static List<Map<String, dynamic>> _flattenPeriodsFromWrappers(
    List<Map<String, dynamic>> wrappers,
  ) {
    final allPeriods = <Map<String, dynamic>>[];
    for (final wrapper in wrappers) {
      for (final key in _periodKeys) {
        final nested = wrapper[key];
        if (nested is List) {
          allPeriods.addAll(nested.whereType<Map<String, dynamic>>());
          break; // Found the periods list; move to next wrapper.
        }
      }
    }
    // If no nested periods were found, fall back to returning the
    // wrappers themselves — they may actually be the periods.
    if (allPeriods.isEmpty) return wrappers;
    return allPeriods;
  }

  void dispose() {
    // No-op: requests are delegated to Supabase Edge Functions.
  }

  /// Fetches bookings from the Lodgify V2 reservations endpoint.
  ///
  /// The Lodgify `/v2/reservations/bookings` API does **not** support
  /// server-side date-range filtering.  Instead, [stayFilter] controls
  /// which bookings are returned:
  ///
  ///  - `All`     — every booking (including past/completed).
  ///  - `Current` — only stays that overlap with today (default API
  ///                behaviour when omitted).
  ///
  /// Any date-range narrowing must therefore happen client-side (see
  /// [LodgifyChannelManagerRepository]).
  ///
  /// Results are fetched page-by-page (`page` / `size` parameters) and
  /// concatenated before returning.
  Future<List<LodgifyCalendarEntry>> _fetchBookingsV2(
    String propertyId, {
    Map<String, String> queryParameters = const {},
  }) async {
    final params = <String, String>{...queryParameters};
    final trimmedPropertyId = propertyId.trim();
    if (trimmedPropertyId.isNotEmpty && !params.containsKey('property_id')) {
      params['property_id'] = trimmedPropertyId;
    }
    params.putIfAbsent('stayFilter', () => 'All');
    params.putIfAbsent('includeCount', () => 'true');

    const pageSize = 50;
    var page = 1;
    final allEntries = <LodgifyCalendarEntry>[];

    while (true) {
      params['page'] = page.toString();
      params['size'] = pageSize.toString();

      final response = await Supabase.instance.client.functions.invoke(
        'lodgify-reservations',
        method: HttpMethod.get,
        queryParameters: params,
      );

      final status = response.status;
      if (status != 200 && status != 201 && status != 202) {
        final requestOptions = RequestOptions(path: 'lodgify-reservations');
        throw DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: status,
            data: response.data,
          ),
          type: DioExceptionType.badResponse,
        );
      }

      final decoded = (response.data as Object?).asDecodedJsonOrSelf();
      final list = decoded.extractList(
        fallbackKeys: const [
          'bookings',
          'items',
          'data',
          'results',
          'reservations',
        ],
      );

      final pageEntries = list
          .whereType<Map<String, dynamic>>()
          .map(LodgifyCalendarEntry.fromMap)
          .toList();

      allEntries.addAll(pageEntries);

      if (pageEntries.length < pageSize) break;
      page++;
    }

    return allEntries;
  }
}

class LodgifyPropertySummary {
  const LodgifyPropertySummary({
    required this.id,
    required this.name,
    required this.raw,
  });

  final String? id;
  final String? name;
  final Map<String, dynamic> raw;

  factory LodgifyPropertySummary.fromMap(Map<String, dynamic> map) {
    return LodgifyPropertySummary(
      id: map.readString(const ['id', 'property_id', 'propertyId']),
      name: map.readString(const ['name', 'property_name', 'title']),
      raw: map,
    );
  }
}

class LodgifyPropertyDetails {
  const LodgifyPropertyDetails({
    required this.id,
    required this.name,
    required this.raw,
  });

  final String? id;
  final String? name;
  final Map<String, dynamic> raw;

  factory LodgifyPropertyDetails.fromMap(Map<String, dynamic> map) {
    return LodgifyPropertyDetails(
      id: map.readString(const ['id', 'property_id', 'propertyId']),
      name: map.readString(const ['name', 'property_name', 'title']),
      raw: map,
    );
  }
}

class LodgifyCalendarEntry {
  const LodgifyCalendarEntry({
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.reservationId,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.guestCount,
    required this.adultCount,
    required this.childCount,
    required this.infantCount,
    required this.source,
    required this.notes,
    required this.totalAmount,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    required this.raw,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final String? reservationId;
  final String? guestName;
  final String? guestEmail;
  final String? guestPhone;
  final int? guestCount;
  final int? adultCount;
  final int? childCount;
  final int? infantCount;
  final String? source;
  final String? notes;
  final num? totalAmount;
  final String? currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> raw;

  factory LodgifyCalendarEntry.fromMap(Map<String, dynamic> map) {
    final startDate =
        map.readDateTime(const [
          'start_date',
          'startDate',
          'start',
          'arrival',
          'arrivalDate',
          'arrival_date',
          'arrivalDateUtc',
          'arrival_date_utc',
          'arrivalUtc',
          'arrival_utc',
          'checkIn',
          'check_in',
          'checkInDate',
          'check_in_date',
          'checkin',
          'checkinDate',
          'dateFrom',
          'date_from',
          'from',
          'date',
        ]) ??
        _readFirstDateTime(map, const [
          ['dates', 'start'],
          ['dates', 'from'],
          ['dateRange', 'start'],
          ['dateRange', 'from'],
          ['period', 'start'],
          ['period', 'from'],
          ['reservation', 'arrival'],
          ['reservation', 'arrivalDate'],
          ['reservation', 'arrival_date'],
          ['reservation', 'startDate'],
          ['booking', 'arrival'],
          ['booking', 'arrivalDate'],
          ['booking', 'arrival_date'],
          ['booking', 'startDate'],
        ]);
    final endDate =
        map.readDateTime(const [
          'end_date',
          'endDate',
          'end',
          'departure',
          'departureDate',
          'departure_date',
          'departureDateUtc',
          'departure_date_utc',
          'departureUtc',
          'departure_utc',
          'checkOut',
          'check_out',
          'checkOutDate',
          'check_out_date',
          'checkout',
          'checkoutDate',
          'dateTo',
          'date_to',
          'to',
        ]) ??
        _readFirstDateTime(map, const [
          ['dates', 'end'],
          ['dates', 'to'],
          ['dateRange', 'end'],
          ['dateRange', 'to'],
          ['period', 'end'],
          ['period', 'to'],
          ['reservation', 'departure'],
          ['reservation', 'departureDate'],
          ['reservation', 'departure_date'],
          ['reservation', 'endDate'],
          ['booking', 'departure'],
          ['booking', 'departureDate'],
          ['booking', 'departure_date'],
          ['booking', 'endDate'],
        ]);
    final status =
        map.readString(const [
          'status',
          'state',
          'availability',
          'booking_status',
          'reservation_status',
          'bookingStatus',
          'reservationStatus',
          'bookingState',
          'reservationState',
          'statusName',
        ]) ??
        _readFirstString(map, const [
          ['booking', 'status'],
          ['booking', 'statusName'],
          ['booking', 'state'],
          ['reservation', 'status'],
          ['reservation', 'statusName'],
          ['reservation', 'state'],
        ]);

    final adults = _readFirstInt(map, const [
      ['adults'],
      ['adultCount'],
      ['guestBreakdown', 'adults'],
      ['guest_breakdown', 'adults'],
      ['occupancy', 'adults'],
      ['guest', 'adults'],
      ['reservation', 'adults'],
      ['booking', 'adults'],
    ]);
    final children = _readFirstInt(map, const [
      ['children'],
      ['childCount'],
      ['guestBreakdown', 'children'],
      ['guest_breakdown', 'children'],
      ['occupancy', 'children'],
      ['guest', 'children'],
      ['reservation', 'children'],
      ['booking', 'children'],
    ]);
    final infants = _readFirstInt(map, const [
      ['infants'],
      ['infantCount'],
      ['guestBreakdown', 'infants'],
      ['guest_breakdown', 'infants'],
      ['occupancy', 'infants'],
      ['guest', 'infants'],
      ['reservation', 'infants'],
      ['booking', 'infants'],
    ]);

    var guestCount = _readFirstInt(map, const [
      ['guests'],
      ['guestCount'],
      ['guestsCount'],
      ['numberOfGuests'],
      ['totalGuests'],
      ['occupancy'],
      ['occupancy', 'total'],
      ['reservation', 'guests'],
      ['reservation', 'guestCount'],
      ['booking', 'guests'],
      ['booking', 'guestCount'],
    ]);

    if (guestCount == null) {
      final parts = [adults, children, infants].whereType<int>().toList();
      if (parts.isNotEmpty) {
        guestCount = parts.fold<int>(0, (sum, value) => sum + value);
      }
    }

    return LodgifyCalendarEntry(
      startDate: startDate,
      endDate: endDate,
      status: status,
      reservationId: _readFirstString(map, const [
        ['reservationId'],
        ['reservation_id'],
        ['reservationCode'],
        ['reservation_code'],
        ['bookingId'],
        ['booking_id'],
        ['bookingCode'],
        ['booking_code'],
        ['externalId'],
        ['external_id'],
        ['id'],
        ['code'],
        ['reference'],
        ['reservation', 'id'],
        ['reservation', 'code'],
        ['booking', 'id'],
        ['booking', 'code'],
      ]),
      guestName: _readGuestName(map),
      guestEmail: _readFirstString(map, const [
        ['guestEmail'],
        ['guest_email'],
        ['email'],
        ['guest', 'email'],
        ['customer', 'email'],
        ['booker', 'email'],
        ['reservation', 'guestEmail'],
        ['booking', 'guestEmail'],
      ]),
      guestPhone: _readFirstString(map, const [
        ['guestPhone'],
        ['guest_phone'],
        ['phone'],
        ['phoneNumber'],
        ['guest', 'phone'],
        ['customer', 'phone'],
        ['booker', 'phone'],
      ]),
      guestCount: guestCount,
      adultCount: adults,
      childCount: children,
      infantCount: infants,
      source: _readFirstString(map, const [
        ['source'],
        ['sourceName'],
        ['source_name'],
        ['channel'],
        ['channelName'],
        ['channel_name'],
        ['bookingSource'],
        ['booking_source'],
        ['origin'],
        ['reservation', 'source'],
        ['reservation', 'channel'],
        ['booking', 'source'],
        ['booking', 'channel'],
      ]),
      notes: _readFirstString(map, const [
        ['notes'],
        ['note'],
        ['internalNotes'],
        ['comment'],
        ['remarks'],
        ['specialRequests'],
        ['reservation', 'notes'],
      ]),
      totalAmount: _readFirstNum(map, const [
        ['totalAmount'],
        ['total_amount'],
        ['total'],
        ['amount'],
        ['price'],
        ['pricing', 'total'],
        ['quote', 'total'],
        ['reservation', 'totalAmount'],
      ]),
      currency: _readFirstString(map, const [
        ['currency'],
        ['currencyCode'],
        ['currency_code'],
        ['pricing', 'currency'],
        ['quote', 'currency'],
      ]),
      createdAt: _readFirstDateTime(map, const [
        ['createdAt'],
        ['created_at'],
        ['bookingDate'],
        ['bookedAt'],
        ['reservation', 'createdAt'],
      ]),
      updatedAt: _readFirstDateTime(map, const [
        ['updatedAt'],
        ['updated_at'],
        ['modifiedAt'],
        ['reservation', 'updatedAt'],
      ]),
      raw: map,
    );
  }
}

String? _readGuestName(Map<String, dynamic> map) {
  final direct = _readFirstString(map, const [
    ['guestName'],
    ['guest_name'],
    ['customerName'],
    ['bookerName'],
    ['guest', 'name'],
    ['guest', 'fullName'],
    ['customer', 'name'],
    ['booker', 'name'],
    ['leadGuest', 'name'],
    ['reservation', 'guestName'],
    ['booking', 'guestName'],
  ]);
  if (direct != null && direct.isNotEmpty) return direct;

  final firstName = _readFirstString(map, const [
    ['guest', 'firstName'],
    ['guest', 'first_name'],
    ['customer', 'firstName'],
    ['booker', 'firstName'],
    ['firstName'],
  ]);
  final lastName = _readFirstString(map, const [
    ['guest', 'lastName'],
    ['guest', 'last_name'],
    ['customer', 'lastName'],
    ['booker', 'lastName'],
    ['lastName'],
  ]);
  if (firstName == null && lastName == null) return null;
  return [firstName, lastName]
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join(' ');
}

String? _readFirstString(Map<String, dynamic> map, List<List<String>> paths) {
  for (final path in paths) {
    final value = _readByPath(map, path);
    final parsed = _coerceString(value);
    if (parsed != null && parsed.isNotEmpty) return parsed;
  }
  return null;
}

int? _readFirstInt(Map<String, dynamic> map, List<List<String>> paths) {
  for (final path in paths) {
    final value = _readByPath(map, path);
    final parsed = _coerceInt(value);
    if (parsed != null) return parsed;
  }
  return null;
}

num? _readFirstNum(Map<String, dynamic> map, List<List<String>> paths) {
  for (final path in paths) {
    final value = _readByPath(map, path);
    final parsed = _coerceNum(value);
    if (parsed != null) return parsed;
  }
  return null;
}

DateTime? _readFirstDateTime(
  Map<String, dynamic> map,
  List<List<String>> paths,
) {
  for (final path in paths) {
    final value = _readByPath(map, path);
    final parsed = _coerceDateTime(value);
    if (parsed != null) return parsed;
  }
  return null;
}

Object? _readByPath(Map<String, dynamic> map, List<String> path) {
  Object? current = map;
  for (final segment in path) {
    final currentMap = _asMap(current);
    if (currentMap == null) return null;
    current = _readCaseInsensitive(currentMap, segment);
    if (current == null) return null;
  }
  return current;
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      result[entry.key.toString()] = entry.value;
    }
    return result;
  }
  return null;
}

Object? _readCaseInsensitive(Map<String, dynamic> map, String key) {
  if (map.containsKey(key)) return map[key];
  final lower = key.toLowerCase();
  for (final entry in map.entries) {
    if (entry.key.toLowerCase() == lower) return entry.value;
  }
  return null;
}

String? _coerceString(Object? value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is num || value is bool) return value.toString();
  return null;
}

int? _coerceInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final direct = int.tryParse(trimmed);
    if (direct != null) return direct;
    final numeric = num.tryParse(trimmed.replaceAll(',', '.'));
    return numeric?.toInt();
  }
  return null;
}

num? _coerceNum(Object? value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return num.tryParse(trimmed.replaceAll(',', '.'));
  }
  return null;
}

DateTime? _coerceDateTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) {
    final millis = value > 100000000000 ? value : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }
  return null;
}
