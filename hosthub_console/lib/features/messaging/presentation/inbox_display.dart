import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/messaging/domain/models/models.dart';

/// Formatting the inbox shares between its three columns.
///
/// Kept out of the widgets so the list row, the thread header and the rail
/// cannot describe the same conversation two different ways.
abstract final class InboxDisplay {
  const InboxDisplay._();

  /// "2 uur geleden" — the list's timestamp.
  static String relativeTime(BuildContext context, DateTime? moment) {
    if (moment == null) return '';
    return timeago.format(
      moment.toLocal(),
      locale: Localizations.localeOf(context).languageCode,
    );
  }

  /// The day separator between two runs of messages.
  static String daySeparator(BuildContext context, DateTime day) {
    final today = _dateOnly(DateTime.now());
    final date = _dateOnly(day.toLocal());
    if (date == today) return context.s.dayToday;
    if (date == today.subtract(const Duration(days: 1))) {
      return context.s.dayYesterday;
    }
    return DateFormat(
      'EEEE d MMMM',
      Localizations.localeOf(context).toString(),
    ).format(date);
  }

  /// The channel as the owner names it — the same word and the same logo the
  /// booking screens use, so one guest keeps one identity across the console.
  static String channelLabel(MessageChannel channel) =>
      BookingSourceIcon.label(channel.sourceKey);

  /// The stay behind a conversation: `12 – 19 feb`, or empty when the thread
  /// hangs off no booking.
  static String stayRange(
    BuildContext context,
    DateTime? start,
    DateTime? end,
  ) {
    if (start == null && end == null) return '';
    final locale = Localizations.localeOf(context).toString();
    final short = DateFormat('d MMM', locale);
    if (start == null) return short.format(end!.toLocal());
    if (end == null) return short.format(start.toLocal());
    final sameMonth = start.year == end.year && start.month == end.month;
    final from = sameMonth
        ? DateFormat('d', locale).format(start.toLocal())
        : short.format(start.toLocal());
    return '$from – ${short.format(end.toLocal())}';
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
