import 'package:flutter/foundation.dart';

/// One settled stay, reduced to what the revenue breakdowns need.
///
/// The revenue page settles a booking into a row with a dozen fields; the
/// chart and the channel split only need four of them. Keeping that shape here
/// is what makes the arithmetic testable without pumping the page.
@immutable
class RevenueBreakdownEntry {
  const RevenueBreakdownEntry({
    required this.checkIn,
    required this.gross,
    required this.net,
    required this.source,
  });

  /// First night of the stay. A stay with no check-in date cannot be placed on
  /// a month axis and is left out of [monthlyRevenue].
  final DateTime? checkIn;

  /// Booking total before commission and costs. Null when unknown.
  final double? gross;

  /// What the host keeps. Null when unknown.
  final double? net;

  /// Channel the booking came from, as the provider spells it.
  final String? source;
}

/// Gross and net for one bucket of the chart.
@immutable
class MonthRevenue {
  const MonthRevenue({required this.gross, required this.net});

  static const MonthRevenue zero = MonthRevenue(gross: 0, net: 0);

  final double gross;
  final double net;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthRevenue &&
          runtimeType == other.runtimeType &&
          gross == other.gross &&
          net == other.net;

  @override
  int get hashCode => Object.hash(gross, net);
}

/// Gross revenue attributed to one channel.
@immutable
class ChannelRevenue {
  const ChannelRevenue({
    required this.label,
    required this.source,
    required this.gross,
  });

  /// Display name of the channel.
  final String label;

  /// A source string that resolves to this channel, for its logo and colour.
  final String? source;

  final double gross;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelRevenue &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          source == other.source &&
          gross == other.gross;

  @override
  int get hashCode => Object.hash(label, source, gross);
}

/// Every month the range touches, as first-of-month dates, in order.
///
/// The end is inclusive of the month it falls in: a period ending on 31 December
/// includes December.
List<DateTime> monthsInRange(DateTime start, DateTime end) {
  if (end.isBefore(start)) return const [];
  final months = <DateTime>[];
  var cursor = DateTime(start.year, start.month);
  final last = DateTime(end.year, end.month);
  while (!cursor.isAfter(last)) {
    months.add(cursor);
    cursor = DateTime(cursor.year, cursor.month + 1);
  }
  return months;
}

/// Buckets stays by the month they start in.
///
/// A stay is counted whole in its check-in month rather than split across the
/// months it spans: that is how the booking table reads it, and the chart has
/// to agree with the table under it.
Map<DateTime, MonthRevenue> monthlyRevenue(
  Iterable<RevenueBreakdownEntry> entries,
) {
  final byMonth = <DateTime, MonthRevenue>{};
  for (final entry in entries) {
    final checkIn = entry.checkIn;
    if (checkIn == null) continue;
    final month = DateTime(checkIn.year, checkIn.month);
    final current = byMonth[month] ?? MonthRevenue.zero;
    byMonth[month] = MonthRevenue(
      gross: current.gross + (entry.gross ?? 0),
      net: current.net + (entry.net ?? 0),
    );
  }
  return byMonth;
}

/// Gross revenue per channel, largest first.
///
/// [labelOf] resolves a raw source string to a display name; two spellings of
/// the same channel therefore land in one row. Channel naming lives with the
/// channel logos, not here, which is why it is injected.
List<ChannelRevenue> channelTotals(
  Iterable<RevenueBreakdownEntry> entries, {
  required String Function(String? source) labelOf,
}) {
  final byLabel = <String, ChannelRevenue>{};
  for (final entry in entries) {
    final gross = entry.gross;
    if (gross == null) continue;
    final label = labelOf(entry.source);
    final current = byLabel[label];
    byLabel[label] = ChannelRevenue(
      label: label,
      source: current?.source ?? entry.source,
      gross: (current?.gross ?? 0) + gross,
    );
  }

  final channels = byLabel.values.toList()
    ..sort((a, b) {
      final byGross = b.gross.compareTo(a.gross);
      // Stable, readable order for equal amounts instead of map order.
      return byGross != 0 ? byGross : a.label.compareTo(b.label);
    });
  return channels;
}
