import 'package:flutter/material.dart';

/// The four geometry values that make up one `TimelineCalendar` density.
///
/// `TimelineCalendar` already takes these as parameters; grouping them means a
/// screen switches density by naming one, instead of spreading four
/// `isCompact ? a : b` ternaries across two call sites.
@immutable
class TimelineCalendarDensity {
  const TimelineCalendarDensity({
    required this.barHeight,
    required this.dayNumberHeight,
    required this.barTopPadding,
    required this.rowBottomPadding,
    required this.showDayLabels,
    required this.leadingIconSize,
  });

  /// Height of a booking bar.
  final double barHeight;

  /// Height of the day-number row above the bars.
  final double dayNumberHeight;

  /// Gap between the day number and the first bar.
  final double barTopPadding;

  /// Gap below the last bar in a week row.
  final double rowBottomPadding;

  /// Whether per-day labels (the nightly rate line) are shown. Off in compact,
  /// where there is no room for them.
  final bool showDayLabels;

  /// Size of the channel logo on a bar.
  final double leadingIconSize;

  static TimelineCalendarDensity lerp(
    TimelineCalendarDensity a,
    TimelineCalendarDensity b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return TimelineCalendarDensity(
      barHeight: lerpDouble(a.barHeight, b.barHeight, t),
      dayNumberHeight: lerpDouble(a.dayNumberHeight, b.dayNumberHeight, t),
      barTopPadding: lerpDouble(a.barTopPadding, b.barTopPadding, t),
      rowBottomPadding: lerpDouble(a.rowBottomPadding, b.rowBottomPadding, t),
      showDayLabels: t < 0.5 ? a.showDayLabels : b.showDayLabels,
      leadingIconSize: lerpDouble(a.leadingIconSize, b.leadingIconSize, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineCalendarDensity &&
          runtimeType == other.runtimeType &&
          barHeight == other.barHeight &&
          dayNumberHeight == other.dayNumberHeight &&
          barTopPadding == other.barTopPadding &&
          rowBottomPadding == other.rowBottomPadding &&
          showDayLabels == other.showDayLabels &&
          leadingIconSize == other.leadingIconSize;

  @override
  int get hashCode => Object.hash(
    barHeight,
    dayNumberHeight,
    barTopPadding,
    rowBottomPadding,
    showDayLabels,
    leadingIconSize,
  );
}

/// Theme for the app-local `TimelineCalendar`: the two densities and the
/// treatment of bookings that are already in the past.
///
/// `TimelineCalendar` lives in `core/widgets/timeline_calendar/` rather than in
/// `styled_widgets`, so its tuning has no preset group to sit in. This
/// extension is that home — the point being that the numbers stop being magic
/// values at the `reservations_page.dart` call sites, per the handoff's
/// `THEME_PRESET.md` §5, which allows either promoting the widget to the shared
/// library or keeping it local and moving its literals into the theme.
///
/// The bar/padding values are internal widget geometry tuned to the bar height,
/// not page layout, which is why they legitimately sit off the 4px spacing
/// scale (`3`, `6`, `10`).
@immutable
class TimelineCalendarTheme extends ThemeExtension<TimelineCalendarTheme> {
  const TimelineCalendarTheme({
    required this.comfortable,
    required this.compact,
    required this.pastEntryBlend,
    required this.pastEntryBlendColor,
    required this.pastEntryTextColor,
    required this.pastEntryLeadingOpacity,
  });

  /// Roomy density: day labels on, 30px bars.
  final TimelineCalendarDensity comfortable;

  /// Dense density: day labels off, 22px bars, so more weeks fit on screen.
  final TimelineCalendarDensity compact;

  /// How far a past booking's bar colour is blended towards
  /// [pastEntryBlendColor]. `0` leaves it untouched, `1` replaces it.
  final double pastEntryBlend;

  /// The grey a past booking's channel colour fades towards.
  final Color pastEntryBlendColor;

  /// Label colour on a past booking's bar.
  final Color pastEntryTextColor;

  /// Opacity of the channel logo on a past booking's bar.
  final double pastEntryLeadingOpacity;

  /// The values the reservations page used before they had a home here.
  ///
  /// The greys are carried over exactly as they were rather than snapped to
  /// `HosthubDiploraV1Palette` — moving them is meant to be behaviour
  /// preserving; aligning them to palette tokens is a separate, visible change.
  static const TimelineCalendarTheme standard = TimelineCalendarTheme(
    comfortable: TimelineCalendarDensity(
      barHeight: 30,
      dayNumberHeight: 24,
      barTopPadding: 6,
      rowBottomPadding: 10,
      showDayLabels: true,
      leadingIconSize: 18,
    ),
    compact: TimelineCalendarDensity(
      barHeight: 22,
      dayNumberHeight: 18,
      barTopPadding: 3,
      rowBottomPadding: 4,
      showDayLabels: false,
      leadingIconSize: 14,
    ),
    pastEntryBlend: 0.55,
    pastEntryBlendColor: Color(0xFFE0E0E0),
    pastEntryTextColor: Color(0xFF9E9E9E),
    pastEntryLeadingOpacity: 0.45,
  );

  @override
  TimelineCalendarTheme copyWith({
    TimelineCalendarDensity? comfortable,
    TimelineCalendarDensity? compact,
    double? pastEntryBlend,
    Color? pastEntryBlendColor,
    Color? pastEntryTextColor,
    double? pastEntryLeadingOpacity,
  }) {
    return TimelineCalendarTheme(
      comfortable: comfortable ?? this.comfortable,
      compact: compact ?? this.compact,
      pastEntryBlend: pastEntryBlend ?? this.pastEntryBlend,
      pastEntryBlendColor: pastEntryBlendColor ?? this.pastEntryBlendColor,
      pastEntryTextColor: pastEntryTextColor ?? this.pastEntryTextColor,
      pastEntryLeadingOpacity:
          pastEntryLeadingOpacity ?? this.pastEntryLeadingOpacity,
    );
  }

  @override
  TimelineCalendarTheme lerp(
    ThemeExtension<TimelineCalendarTheme>? other,
    double t,
  ) {
    if (other is! TimelineCalendarTheme) return this;
    return TimelineCalendarTheme(
      comfortable: TimelineCalendarDensity.lerp(
        comfortable,
        other.comfortable,
        t,
      ),
      compact: TimelineCalendarDensity.lerp(compact, other.compact, t),
      pastEntryBlend:
          TimelineCalendarDensity.lerpDouble(
            pastEntryBlend,
            other.pastEntryBlend,
            t,
          ),
      pastEntryBlendColor:
          Color.lerp(pastEntryBlendColor, other.pastEntryBlendColor, t) ??
          pastEntryBlendColor,
      pastEntryTextColor:
          Color.lerp(pastEntryTextColor, other.pastEntryTextColor, t) ??
          pastEntryTextColor,
      pastEntryLeadingOpacity: TimelineCalendarDensity.lerpDouble(
        pastEntryLeadingOpacity,
        other.pastEntryLeadingOpacity,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineCalendarTheme &&
          runtimeType == other.runtimeType &&
          comfortable == other.comfortable &&
          compact == other.compact &&
          pastEntryBlend == other.pastEntryBlend &&
          pastEntryBlendColor == other.pastEntryBlendColor &&
          pastEntryTextColor == other.pastEntryTextColor &&
          pastEntryLeadingOpacity == other.pastEntryLeadingOpacity;

  @override
  int get hashCode => Object.hash(
    comfortable,
    compact,
    pastEntryBlend,
    pastEntryBlendColor,
    pastEntryTextColor,
    pastEntryLeadingOpacity,
  );
}

extension TimelineCalendarThemeExtension on ThemeData {
  /// The timeline-calendar theme, falling back to [
  /// TimelineCalendarTheme.standard] so a bare `ThemeData` (in a test, say)
  /// still renders — mirroring how `appColors` behaves.
  TimelineCalendarTheme get timelineCalendar =>
      extension<TimelineCalendarTheme>() ?? TimelineCalendarTheme.standard;
}
