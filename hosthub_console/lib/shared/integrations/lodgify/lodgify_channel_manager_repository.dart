import 'package:flutter/foundation.dart' show debugPrint;
import 'package:hosthub_console/shared/domain/channel_manager/channel_manager_repository.dart';
import 'package:hosthub_console/shared/domain/channel_manager/models/models.dart';
import 'package:hosthub_console/shared/integrations/lodgify/dto/lodgify_calendar_dto.dart';
import 'package:hosthub_console/shared/integrations/lodgify/dto/lodgify_property_dto.dart';
import 'package:hosthub_console/shared/services/lodgify_service.dart';

/// [ChannelManagerRepository] implementation backed by Lodgify.
///
/// Wraps [LodgifyService] and maps Lodgify-specific DTOs to channel-agnostic
/// domain models.
class LodgifyChannelManagerRepository implements ChannelManagerRepository {
  LodgifyChannelManagerRepository({required LodgifyService lodgifyService})
      : _lodgifyService = lodgifyService;

  final LodgifyService _lodgifyService;

  @override
  Future<List<ChannelProperty>> fetchProperties() async {
    final lodgifyProperties = await _lodgifyService.fetchProperties();
    return lodgifyProperties
        .map(
          (p) => LodgifyPropertyDto(id: p.id, name: p.name, raw: p.raw)
              .toDomain(),
        )
        .toList();
  }

  @override
  Future<List<Reservation>> fetchReservations(
    String propertyId, {
    DateTime? start,
    DateTime? end,
  }) async {
    // The Lodgify V2 bookings API does not support server-side date filtering
    // (it uses stayFilter=All to return all bookings).  We therefore fetch
    // everything and narrow by [start]/[end] client-side.
    final lodgifyEntries = await _lodgifyService.fetchCalendar(
      propertyId,
      start: start,
      end: end,
    );

    var reservations = lodgifyEntries
        .map((e) => LodgifyCalendarDto.fromMap(e.raw).toDomain())
        .toList();

    if (start != null || end != null) {
      reservations = reservations.where((r) {
        final rStart = r.startDate;
        final rEnd = r.endDate;
        // Keep entries that overlap with [start, end].
        if (rStart == null && rEnd == null) return true;
        if (end != null && rStart != null && rStart.isAfter(end)) return false;
        if (start != null && rEnd != null && rEnd.isBefore(start)) return false;
        return true;
      }).toList();
    }

    return reservations;
  }

  @override
  Future<void> updateReservationNotes(
    String reservationId,
    String notes,
  ) async {
    await _lodgifyService.updateReservationNotes(reservationId, notes);
  }

  @override
  Future<({Map<DateTime, num> rates, String? currency})> fetchNightlyRates(
    String propertyId, {
    DateTime? start,
    DateTime? end,
  }) async {
    final result = await _lodgifyService.fetchRates(
      propertyId,
      start: start,
      end: end,
    );

    final periods = result.periods;
    final currency = result.currency;

    if (periods.isEmpty) {
      debugPrint(
        '[LodgifyRates] fetchNightlyRates($propertyId): '
        'service returned 0 periods',
      );
      return (rates: const <DateTime, num>{}, currency: currency);
    }

    final rates = <DateTime, num>{};
    var skippedCount = 0;

    for (final period in periods) {
      final periodStart = _tryParseDate(
        period['date'] ??
            period['start'] ??
            period['date_start'] ??
            period['dateStart'] ??
            period['startDate'] ??
            period['start_date'],
      );
      final periodEnd = _tryParseDate(
        period['end'] ??
            period['date_end'] ??
            period['dateEnd'] ??
            period['endDate'] ??
            period['end_date'],
      );
      final rate = _extractRate(period);

      if (periodStart == null || rate == null || rate <= 0) {
        skippedCount++;
        continue;
      }

      final effectiveEnd =
          periodEnd ?? periodStart.add(const Duration(days: 1));
      var d = DateTime(periodStart.year, periodStart.month, periodStart.day);
      final endDate = DateTime(
        effectiveEnd.year,
        effectiveEnd.month,
        effectiveEnd.day,
      );

      while (d.isBefore(endDate)) {
        rates.putIfAbsent(d, () => rate);
        d = d.add(const Duration(days: 1));
      }
    }

    if (rates.isEmpty && periods.isNotEmpty) {
      // All periods were skipped — likely a parsing issue.
      final sampleKeys = periods.first.keys.take(12).toList();
      debugPrint(
        '[LodgifyRates] fetchNightlyRates($propertyId): '
        '${periods.length} periods received but 0 rates parsed. '
        'Skipped=$skippedCount. Sample keys: $sampleKeys',
      );
    } else {
      debugPrint(
        '[LodgifyRates] fetchNightlyRates($propertyId): '
        '${rates.length} day-rates from ${periods.length} periods '
        '(skipped=$skippedCount)',
      );
    }

    return (rates: rates, currency: currency);
  }

  /// Extracts a nightly rate from a period map.
  ///
  /// Handles both flat values (`"price": 1500`) and nested objects
  /// (`"price": {"nightly": 1500, "currency": "NOK"}`).
  static num? _extractRate(Map<String, dynamic> period) {
    // Lodgify rates calendar format:
    // {"date": "…", "prices": [{"price_per_day": 3300, …}]}
    final prices = period['prices'];
    if (prices is List && prices.isNotEmpty) {
      final first = prices.first;
      if (first is Map<String, dynamic>) {
        final ppd = _tryParseNum(
          first['price_per_day'] ?? first['pricePerDay'] ?? first['price'],
        );
        if (ppd != null && ppd > 0) return ppd;
      }
    }

    const flatKeys = [
      'price_per_day',
      'pricePerDay',
      'amount',
      'rate',
      'price',
      'nightly_rate',
      'nightlyRate',
      'nightly',
      'rateAmount',
      'rate_amount',
      'pricePerNight',
      'price_per_night',
    ];

    for (final key in flatKeys) {
      final value = period[key];
      if (value == null) continue;

      // If the value is a number or numeric string, use it directly.
      final parsed = _tryParseNum(value);
      if (parsed != null && parsed > 0) return parsed;

      // If the value is a nested map, extract the rate from it.
      if (value is Map<String, dynamic>) {
        final nested = _extractRateFromMap(value);
        if (nested != null && nested > 0) return nested;
      }
    }

    // Try nested paths (e.g. period['pricing']['nightly']).
    const nestedPaths = [
      ['pricing', 'nightly'],
      ['pricing', 'nightlyRate'],
      ['pricing', 'amount'],
      ['pricing', 'rate'],
      ['rate_plan', 'price'],
      ['ratePlan', 'price'],
    ];
    for (final path in nestedPaths) {
      Object? current = period;
      for (final segment in path) {
        if (current is! Map<String, dynamic>) {
          current = null;
          break;
        }
        current = current[segment];
      }
      final parsed = _tryParseNum(current);
      if (parsed != null && parsed > 0) return parsed;
    }

    return null;
  }

  /// Extracts a rate from a nested map like
  /// `{"nightly": 1500, "currency": "NOK"}`.
  static num? _extractRateFromMap(Map<String, dynamic> map) {
    const keys = [
      'nightly',
      'nightlyRate',
      'nightly_rate',
      'amount',
      'rate',
      'value',
      'price',
      'per_night',
      'perNight',
    ];
    for (final key in keys) {
      final parsed = _tryParseNum(map[key]);
      if (parsed != null && parsed > 0) return parsed;
    }
    return null;
  }

  static DateTime? _tryParseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static num? _tryParseNum(Object? value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value.replaceAll(',', '.'));
    return null;
  }

  @override
  Future<void> testConnection() async {
    await _lodgifyService.fetchProperties();
  }
}
