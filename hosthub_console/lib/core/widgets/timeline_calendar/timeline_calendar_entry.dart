import 'package:flutter/material.dart';

/// A single booking entry to display in the [TimelineCalendar].
///
/// [start] is the check-in date, [end] is the check-out date (exclusive —
/// the bar visually covers nights from [start] up to, but not including,
/// [end]).  Back-to-back entries whose [end]/[start] coincide will abut
/// seamlessly.
class TimelineCalendarEntry {
  const TimelineCalendarEntry({
    required this.start,
    required this.end,
    required this.label,
    this.color = const Color(0xFFCBDAEE),
    this.textColor,
    this.outlined = false,
    this.leading,
    this.tooltip,
    this.data,
  });

  /// Check-in date (inclusive).
  final DateTime start;

  /// Check-out date (exclusive — bar ends at the start of this day).
  final DateTime end;

  /// Display label shown on the bar (e.g. guest name).
  final String label;

  /// Background colour of the booking bar.  When [outlined] is true, this
  /// colour is used for the border instead.
  final Color color;

  /// Text colour on the bar.  Falls back to a contrast colour derived from
  /// [color] when null.
  final Color? textColor;

  /// When true the bar renders as an outline (border only, no fill).
  /// Useful for visually de-emphasising historical / past entries.
  final bool outlined;

  /// Optional leading widget inside the bar (e.g. source logo/badge).
  final Widget? leading;

  /// Optional tooltip text shown on hover.
  final String? tooltip;

  /// Arbitrary payload returned in callbacks (e.g. the original reservation
  /// object).
  final Object? data;
}
