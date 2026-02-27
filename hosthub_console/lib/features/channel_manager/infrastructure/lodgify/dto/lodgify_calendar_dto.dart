import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';

/// Lodgify-specific DTO for calendar/reservation data.
///
/// Handles all the flexible key-name variations from Lodgify's API
/// (V1 calendar and V2 bookings) and maps to the channel-agnostic
/// [Reservation] domain model.
class LodgifyCalendarDto {
  const LodgifyCalendarDto({
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

  factory LodgifyCalendarDto.fromMap(Map<String, dynamic> map) {
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

    var adults = _readFirstInt(map, const [
      ['adults'],
      ['adultCount'],
      ['adult_count'],
      ['people', 'adults'],
      ['guestBreakdown', 'adults'],
      ['guest_breakdown', 'adults'],
      ['occupancy', 'adults'],
      ['guest', 'adults'],
      ['reservation', 'adults'],
      ['booking', 'adults'],
    ]);
    var children = _readFirstInt(map, const [
      ['children'],
      ['childCount'],
      ['child_count'],
      ['people', 'children'],
      ['guestBreakdown', 'children'],
      ['guest_breakdown', 'children'],
      ['occupancy', 'children'],
      ['guest', 'children'],
      ['reservation', 'children'],
      ['booking', 'children'],
    ]);
    var infants = _readFirstInt(map, const [
      ['infants'],
      ['infantCount'],
      ['infant_count'],
      ['babies'],
      ['babyCount'],
      ['baby_count'],
      ['people', 'infants'],
      ['people', 'babies'],
      ['guestBreakdown', 'infants'],
      ['guest_breakdown', 'infants'],
      ['occupancy', 'infants'],
      ['guest', 'infants'],
      ['reservation', 'infants'],
      ['booking', 'infants'],
    ]);

    // Try extracting from room_types[]/rooms[].people if not found yet.
    if (adults == null && children == null && infants == null) {
      final roomList = _readByPath(map, const ['room_types']) ??
          _readByPath(map, const ['roomTypes']) ??
          _readByPath(map, const ['rooms']);
      if (roomList is List && roomList.isNotEmpty) {
        // Sum across all rooms (multiple rooms may each have people).
        var sumAdults = 0;
        var sumChildren = 0;
        var sumInfants = 0;
        var found = false;
        for (final room in roomList) {
          final roomMap = _asMap(room);
          if (roomMap == null) continue;
          final people = _asMap(
            _readByPath(roomMap, const ['people']) ??
                _readByPath(roomMap, const ['occupancy']),
          );
          if (people == null) continue;
          found = true;
          sumAdults += _readFirstInt(people, const [
                ['adults'],
                ['numberOfAdults'],
                ['number_of_adults'],
              ]) ??
              0;
          sumChildren += _readFirstInt(people, const [
                ['children'],
                ['numberOfChildren'],
                ['number_of_children'],
              ]) ??
              0;
          sumInfants += _readFirstInt(people, const [
                ['infants'],
                ['babies'],
                ['numberOfInfants'],
                ['number_of_infants'],
              ]) ??
              0;
        }
        if (found) {
          adults = sumAdults;
          children = sumChildren;
          infants = sumInfants;
        }
      }
    }

    var guestCount = _readFirstInt(map, const [
      ['guests'],
      ['guestCount'],
      ['guest_count'],
      ['guestsCount'],
      ['numberOfGuests'],
      ['number_of_guests'],
      ['totalGuests'],
      ['total_guests'],
      ['people', 'total'],
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

    return LodgifyCalendarDto(
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

  Reservation toDomain() {
    return Reservation(
      reservationId: reservationId,
      startDate: startDate,
      endDate: endDate,
      status: status,
      guestName: guestName,
      guestEmail: guestEmail,
      guestPhone: guestPhone,
      guestCount: guestCount,
      adultCount: adultCount,
      childCount: childCount,
      infantCount: infantCount,
      source: source,
      notes: notes,
      totalAmount: totalAmount,
      currency: currency,
      createdAt: createdAt,
      updatedAt: updatedAt,
      raw: raw,
    );
  }
}

// ---------------------------------------------------------------------------
// Flexible JSON parsing helpers (Lodgify-specific)
// ---------------------------------------------------------------------------

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

/// Extension on Map to read flexible field names (used by DTOs).
extension _MapReadExtension on Map<String, dynamic> {
  DateTime? readDateTime(List<String> keys) {
    for (final key in keys) {
      final value = this[key];
      final parsed = _coerceDateTime(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  String? readString(List<String> keys) {
    for (final key in keys) {
      final value = this[key];
      final parsed = _coerceString(value);
      if (parsed != null) return parsed;
    }
    return null;
  }
}
