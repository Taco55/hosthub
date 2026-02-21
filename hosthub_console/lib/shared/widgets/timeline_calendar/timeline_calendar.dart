/// A month-grid calendar widget that renders date-range entries as connected
/// horizontal bars spanning multiple day-cells.
///
/// Typical use cases include property booking calendars, resource scheduling,
/// staff leave planners, or any scenario where date-range items need to be
/// visualised on a month grid.
///
/// ## Quick start
///
/// ```dart
/// TimelineCalendar(
///   focusedMonth: DateTime(2026, 3),
///   entries: [
///     TimelineCalendarEntry(
///       start: DateTime(2026, 3, 2),
///       end: DateTime(2026, 3, 7),   // exclusive (check-out day)
///       label: 'Alice',
///       color: Colors.blue.shade100,
///       leading: Icon(Icons.person, size: 14),
///     ),
///   ],
///   dayLabels: {
///     DateTime(2026, 3, 2): 'kr 5.2K',
///     DateTime(2026, 3, 3): 'kr 5.2K',
///   },
///   onMonthChanged: (month) => setState(() => _month = month),
///   onEntryTap: (entry) => showDetails(entry.data),
/// )
/// ```
///
/// ## Features
///
/// - **Connected bars** — back-to-back entries abut seamlessly; bars wrap
///   across week rows when spanning multiple weeks.
/// - **Per-day labels** — optional rate/price labels below each day cell via
///   [dayLabels].
/// - **Custom bar rendering** — supply an [entryBuilder] for full control,
///   or use the default bar which shows [TimelineCalendarEntry.leading] +
///   label with auto-contrast text colour.
/// - **Month navigation** — built-in prev/next arrows; constrain the range
///   with [rangeStart] / [rangeEnd].
/// - **Today marker** — current date shown as a filled circle.
/// - **Weekend shading** — Saturday/Sunday columns receive a subtle
///   background tint.
/// - **Locale-aware** — month names and weekday labels respect [locale]
///   (falls back to [Intl.defaultLocale]).
/// - **Fully generic** — no external dependencies beyond Flutter + intl;
///   ready to be extracted into a standalone package.
library;

export 'timeline_calendar_entry.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'timeline_calendar_entry.dart';

// ---------------------------------------------------------------------------
// Out-of-month day display mode
// ---------------------------------------------------------------------------

/// Controls how days outside the focused month are rendered.
enum OutOfMonthDisplay {
  /// Hide out-of-month days entirely (show blank cells).
  hide,

  /// Show out-of-month days only when they belong to a booking that overlaps
  /// with the focused month.
  bookedOnly,

  /// Show all out-of-month days (default grid behaviour).
  showAll,
}

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

class TimelineCalendar extends StatelessWidget {
  const TimelineCalendar({
    super.key,
    required this.focusedMonth,
    required this.entries,
    this.onMonthChanged,
    this.onEntryTap,
    this.entryBuilder,
    this.barHeight = 30.0,
    this.dayNumberHeight = 24.0,
    this.barTopPadding = 6.0,
    this.rowBottomPadding = 10.0,
    this.weekSpacing = 6.0,
    this.dayLabels,
    this.dayLabelHeight = 16.0,
    this.rangeStart,
    this.rangeEnd,
    this.locale,
    this.outOfMonthDisplay = OutOfMonthDisplay.hide,
    this.showNavigation = true,
    this.showWeekdayHeader = true,
    this.shrinkWrap = false,
  });

  /// The month to display (only year + month are used).
  final DateTime focusedMonth;

  /// Booking entries to render as horizontal bars.
  final List<TimelineCalendarEntry> entries;

  /// Called when the user navigates to a different month.
  final ValueChanged<DateTime>? onMonthChanged;

  /// Called when the user taps a booking bar.
  final ValueChanged<TimelineCalendarEntry>? onEntryTap;

  /// Optional custom builder for booking bars.  When null a default bar is
  /// rendered showing [TimelineCalendarEntry.leading] + label.
  final Widget Function(
    BuildContext,
    TimelineCalendarEntry,
    bool isFirstSegment,
    bool isLastSegment,
  )? entryBuilder;

  /// Height of each booking bar.
  final double barHeight;

  /// Height reserved for day-number labels at the top of each week row.
  final double dayNumberHeight;

  /// Padding between day numbers and the booking bar.
  final double barTopPadding;

  /// Padding below the last element in each week row.
  final double rowBottomPadding;

  /// Vertical spacing between week rows.
  final double weekSpacing;

  /// Per-day labels shown below the booking bar (e.g. nightly rates).
  /// Keys must be date-only (midnight) [DateTime] values.
  final Map<DateTime, String>? dayLabels;

  /// Height of the day-label area below the booking bar.  Only used when
  /// [dayLabels] is non-null and non-empty.
  final double dayLabelHeight;

  /// Earliest month the user can navigate to.
  final DateTime? rangeStart;

  /// Latest month the user can navigate to.
  final DateTime? rangeEnd;

  /// Locale for month/weekday formatting.  Falls back to [Intl.defaultLocale].
  final String? locale;

  /// How to display days that fall outside the focused month.
  final OutOfMonthDisplay outOfMonthDisplay;

  /// Whether to show the month navigation (prev/next arrows + month label).
  final bool showNavigation;

  /// Whether to show the weekday header row (Mo Tu We…).
  final bool showWeekdayHeader;

  /// When true, the widget sizes itself to its content instead of expanding.
  /// Useful when placing multiple calendars in a scrollable column.
  final bool shrinkWrap;

  // ---- helpers ----

  bool get _hasLabels => dayLabels != null && dayLabels!.isNotEmpty;

  double get _rowHeight =>
      dayNumberHeight +
      barTopPadding +
      barHeight +
      (_hasLabels ? dayLabelHeight : 0) +
      rowBottomPadding;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLocale = locale ?? Intl.defaultLocale ?? 'en';

    // Grid geometry
    final firstOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastOfMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    // ISO weekday: 1 = Monday … 7 = Sunday
    final startOfGrid =
        firstOfMonth.subtract(Duration(days: firstOfMonth.weekday - 1));
    final totalCells = (firstOfMonth.weekday - 1) + lastOfMonth.day;
    final weekCount = (totalCells / 7).ceil();

    // Navigation constraints
    final canGoBack = rangeStart == null ||
        DateTime(focusedMonth.year, focusedMonth.month - 1)
            .isAfter(DateTime(rangeStart!.year, rangeStart!.month - 1));
    final canGoForward = rangeEnd == null ||
        DateTime(focusedMonth.year, focusedMonth.month + 1)
            .isBefore(DateTime(rangeEnd!.year, rangeEnd!.month + 1));

    final weekRows = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int w = 0; w < weekCount; w++) ...[
          _WeekRow(
            weekStart: startOfGrid.add(Duration(days: w * 7)),
            focusedMonth: focusedMonth.month,
            focusedYear: focusedMonth.year,
            entries: entries,
            rowHeight: _rowHeight,
            dayNumberHeight: dayNumberHeight,
            barTopPadding: barTopPadding,
            barHeight: barHeight,
            dayLabels: dayLabels,
            dayLabelHeight: _hasLabels ? dayLabelHeight : 0,
            onEntryTap: onEntryTap,
            entryBuilder: entryBuilder,
            outOfMonthDisplay: outOfMonthDisplay,
            theme: theme,
          ),
          if (w < weekCount - 1)
            SizedBox(height: weekSpacing),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (showNavigation) ...[
          _MonthNavigation(
            month: focusedMonth,
            locale: effectiveLocale,
            canGoBack: canGoBack,
            canGoForward: canGoForward,
            onPrevious: canGoBack
                ? () => onMonthChanged?.call(
                      DateTime(focusedMonth.year, focusedMonth.month - 1),
                    )
                : null,
            onNext: canGoForward
                ? () => onMonthChanged?.call(
                      DateTime(focusedMonth.year, focusedMonth.month + 1),
                    )
                : null,
          ),
          const SizedBox(height: 4),
        ],

        if (showWeekdayHeader) ...[
          _WeekdayHeader(locale: effectiveLocale, theme: theme),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
        ],

        if (shrinkWrap)
          weekRows
        else
          Expanded(
            child: SingleChildScrollView(child: weekRows),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Month navigation
// ---------------------------------------------------------------------------

class _MonthNavigation extends StatelessWidget {
  const _MonthNavigation({
    required this.month,
    required this.locale,
    required this.canGoBack,
    required this.canGoForward,
    this.onPrevious,
    this.onNext,
  });

  final DateTime month;
  final String locale;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = DateFormat('MMMM yyyy', locale).format(month);
    final dateFormatter = DateFormat('d MMM yyyy', locale);
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final rangeLabel =
        '${dateFormatter.format(monthStart)} - ${dateFormatter.format(monthEnd)}';

    return Row(
      children: [
        _buildArrowButton(
          context,
          iconData: Icons.chevron_left_rounded,
          onPressed: canGoBack ? onPrevious : null,
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(rangeLabel, style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(width: 12),
        _buildArrowButton(
          context,
          iconData: Icons.chevron_right_rounded,
          onPressed: canGoForward ? onNext : null,
        ),
      ],
    );
  }

  Widget _buildArrowButton(
    BuildContext context, {
    required IconData iconData,
    required VoidCallback? onPressed,
  }) {
    final enabled = onPressed != null;
    final colors = Theme.of(context).colorScheme;
    final iconColor = enabled
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant.withValues(alpha: 0.95);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.4,
      child: StyledButton(
        titleWidget: Icon(iconData, size: 24, color: iconColor),
        onPressed: onPressed,
        enabled: enabled,
        minWidth: 56,
        minHeight: 44,
        horizontalSpacing: 0,
        padding: EdgeInsets.zero,
        cornerRadius: 10,
        borderWidth: 1.2,
        backgroundColor: colors.primaryContainer,
        backgroundColorDisabled: colors.surfaceContainerHighest,
        borderColor: colors.primary.withValues(alpha: 0.45),
        borderColorDisabled: colors.outline.withValues(alpha: 0.85),
        enableShadow: false,
        enableShrinking: enabled,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekday header (Mo Tu We Th Fr Sa Su)
// ---------------------------------------------------------------------------

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.locale, required this.theme});

  final String locale;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Generate weekday names starting from Monday
    final formatter = DateFormat.E(locale);
    // 2024-01-01 was a Monday
    final labels = List.generate(
      7,
      (i) => formatter.format(DateTime(2024, 1, 1 + i)).substring(0, 2),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: labels.map((label) {
          return Expanded(
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week row — one horizontal stripe showing 7 day-cells + overlaid bars
// ---------------------------------------------------------------------------

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.weekStart,
    required this.focusedMonth,
    required this.focusedYear,
    required this.entries,
    required this.rowHeight,
    required this.dayNumberHeight,
    required this.barTopPadding,
    required this.barHeight,
    this.dayLabels,
    required this.dayLabelHeight,
    this.onEntryTap,
    this.entryBuilder,
    required this.outOfMonthDisplay,
    required this.theme,
  });

  final DateTime weekStart;
  final int focusedMonth;
  final int focusedYear;
  final List<TimelineCalendarEntry> entries;
  final double rowHeight;
  final double dayNumberHeight;
  final double barTopPadding;
  final double barHeight;
  final Map<DateTime, String>? dayLabels;
  final double dayLabelHeight;
  final ValueChanged<TimelineCalendarEntry>? onEntryTap;
  final Widget Function(BuildContext, TimelineCalendarEntry, bool, bool)?
      entryBuilder;
  final OutOfMonthDisplay outOfMonthDisplay;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekStart.add(const Duration(days: 7)); // exclusive
    final today = TimelineCalendar._dateOnly(DateTime.now());

    // Entries overlapping this week: entry.start < weekEnd && entry.end > weekStart
    final overlapping = entries.where((e) {
      final s = TimelineCalendar._dateOnly(e.start);
      final eEnd = TimelineCalendar._dateOnly(e.end);
      return s.isBefore(weekEnd) && eEnd.isAfter(weekStart);
    }).toList();

    return SizedBox(
      height: rowHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / 7;

          return Stack(
            children: [
              // Layer 0 – day cells (numbers + weekend bg + rate labels)
              Row(
                children: List.generate(7, (i) {
                  final day = weekStart.add(Duration(days: i));
                  final inMonth =
                      day.month == focusedMonth && day.year == focusedYear;
                  final isToday = day == today;
                  final isWeekend = day.weekday >= 6; // Sat/Sun
                  final label = dayLabels?[day];

                  // Determine if an out-of-month day should be visible.
                  var visible = true;
                  if (!inMonth &&
                      outOfMonthDisplay != OutOfMonthDisplay.showAll) {
                    if (outOfMonthDisplay == OutOfMonthDisplay.hide) {
                      visible = false;
                    } else {
                      // bookedOnly: show only if an entry covers this day
                      // AND that entry also overlaps the focused month.
                      final monthFirst =
                          DateTime(focusedYear, focusedMonth, 1);
                      final monthNext =
                          DateTime(focusedYear, focusedMonth + 1, 1);
                      visible = overlapping.any((e) {
                        final s = TimelineCalendar._dateOnly(e.start);
                        final eEnd = TimelineCalendar._dateOnly(e.end);
                        final coversDay =
                            !day.isBefore(s) && day.isBefore(eEnd);
                        final overlapsMonth =
                            s.isBefore(monthNext) && eEnd.isAfter(monthFirst);
                        return coversDay && overlapsMonth;
                      });
                    }
                  }

                  return SizedBox(
                    width: cellWidth,
                    height: rowHeight,
                    child: _DayCell(
                      day: day,
                      inMonth: inMonth,
                      isToday: isToday,
                      isWeekend: isWeekend,
                      visible: visible,
                      dayNumberHeight: dayNumberHeight,
                      barTopPadding: barTopPadding,
                      barHeight: barHeight,
                      label: label,
                      dayLabelHeight: dayLabelHeight,
                      theme: theme,
                    ),
                  );
                }),
              ),

              // Layer 1 – booking bars
              for (final entry in overlapping)
                _buildBar(context, entry, cellWidth),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBar(
    BuildContext context,
    TimelineCalendarEntry entry,
    double cellWidth,
  ) {
    final entryStart = TimelineCalendar._dateOnly(entry.start);
    final entryEnd = TimelineCalendar._dateOnly(entry.end);
    final weekEndDate = weekStart.add(const Duration(days: 7));

    // Clamp to this week
    var barStart =
        entryStart.isBefore(weekStart) ? weekStart : entryStart;
    var barEnd = entryEnd.isAfter(weekEndDate) ? weekEndDate : entryEnd;

    // Clamp or skip bars based on the out-of-month display mode.
    if (outOfMonthDisplay != OutOfMonthDisplay.showAll) {
      final monthFirst = DateTime(focusedYear, focusedMonth, 1);
      final monthNext = DateTime(focusedYear, focusedMonth + 1, 1);

      if (outOfMonthDisplay == OutOfMonthDisplay.hide) {
        // Clip bars to in-month days only.
        if (barStart.isBefore(monthFirst)) barStart = monthFirst;
        if (barEnd.isAfter(monthNext)) barEnd = monthNext;
      } else {
        // bookedOnly: skip entries that don't overlap the focused month.
        final overlapsMonth =
            entryStart.isBefore(monthNext) && entryEnd.isAfter(monthFirst);
        if (!overlapsMonth) return const SizedBox.shrink();
      }
    }

    final startCol = barStart.difference(weekStart).inDays;
    final colSpan = barEnd.difference(barStart).inDays;
    if (colSpan <= 0) return const SizedBox.shrink();

    final isFirstSegment = entryStart == barStart ||
        (entryStart.year == barStart.year &&
            entryStart.month == barStart.month &&
            entryStart.day == barStart.day);
    final isLastSegment = entryEnd == barEnd ||
        (entryEnd.year == barEnd.year &&
            entryEnd.month == barEnd.month &&
            entryEnd.day == barEnd.day);

    // Horizontal insets so back-to-back bars have a tiny visual break
    const hInset = 1.0;

    return Positioned(
      left: startCol * cellWidth + (isFirstSegment ? hInset * 2 : 0),
      top: dayNumberHeight + barTopPadding,
      width: colSpan * cellWidth -
          (isFirstSegment ? hInset * 2 : 0) -
          (isLastSegment ? hInset * 2 : 0),
      height: barHeight,
      child: _maybeTooltip(
        tooltip: entry.tooltip,
        child: GestureDetector(
          onTap: onEntryTap != null ? () => onEntryTap!(entry) : null,
          child: entryBuilder != null
              ? entryBuilder!(context, entry, isFirstSegment, isLastSegment)
              : _DefaultBookingBar(
                  entry: entry,
                  isFirstSegment: isFirstSegment,
                  isLastSegment: isLastSegment,
                  theme: theme,
                ),
        ),
      ),
    );
  }

  Widget _maybeTooltip({required String? tooltip, required Widget child}) {
    if (tooltip == null || tooltip.isEmpty) return child;
    return Tooltip(
      message: tooltip,
      preferBelow: true,
      verticalOffset: barHeight / 2 + 4,
      waitDuration: const Duration(milliseconds: 400),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Day cell — shows day number (top-right) + weekend bg + optional rate label
// ---------------------------------------------------------------------------

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isWeekend,
    this.visible = true,
    required this.dayNumberHeight,
    required this.barTopPadding,
    required this.barHeight,
    this.label,
    required this.dayLabelHeight,
    required this.theme,
  });

  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isWeekend;
  final bool visible;
  final double dayNumberHeight;
  final double barTopPadding;
  final double barHeight;
  final String? label;
  final double dayLabelHeight;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.expand();
    final dayTextStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
      color: inMonth
          ? (isToday
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withValues(alpha: 0.85))
          : theme.colorScheme.onSurface.withValues(alpha: 0.30),
    );

    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: Container(
        decoration: BoxDecoration(
          color: inMonth ? Colors.white : null,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.08),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Day number — constrained to [dayNumberHeight] so compact
            // mode doesn't overflow.
            SizedBox(
              height: dayNumberHeight,
              child: Padding(
                padding: EdgeInsets.only(
                  top: dayNumberHeight >= 24 ? 4 : 2,
                  right: dayNumberHeight >= 24 ? 6 : 4,
                ),
                child: isToday
                    ? Container(
                        width: dayNumberHeight - 4,
                        height: dayNumberHeight - 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text('${day.day}', style: dayTextStyle),
                      )
                    : Text('${day.day}', style: dayTextStyle),
              ),
            ),

            // Space for bar (barTopPadding + barHeight) — occupied by the
            // overlaid Positioned booking bar
            SizedBox(height: barTopPadding + barHeight),

            // Rate / day label
            if (label != null && dayLabelHeight > 0)
              SizedBox(
                height: dayLabelHeight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      label!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: inMonth
                            ? theme.colorScheme.onSurface
                                .withValues(alpha: 0.65)
                            : theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Default booking bar
// ---------------------------------------------------------------------------

class _DefaultBookingBar extends StatelessWidget {
  const _DefaultBookingBar({
    required this.entry,
    required this.isFirstSegment,
    required this.isLastSegment,
    required this.theme,
  });

  final TimelineCalendarEntry entry;
  final bool isFirstSegment;
  final bool isLastSegment;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(6);
    final outlined = entry.outlined;
    final borderRadius = BorderRadius.only(
      topLeft: isFirstSegment ? radius : Radius.zero,
      bottomLeft: isFirstSegment ? radius : Radius.zero,
      topRight: isLastSegment ? radius : Radius.zero,
      bottomRight: isLastSegment ? radius : Radius.zero,
    );

    final effectiveTextColor = entry.textColor ??
        (outlined
            ? entry.color
            : (ThemeData.estimateBrightnessForColor(entry.color) ==
                    Brightness.dark
                ? Colors.white
                : Colors.black87));

    return Container(
      decoration: BoxDecoration(
        color: outlined ? entry.color.withValues(alpha: 0.45) : entry.color,
        border: outlined ? Border.all(color: entry.color, width: 1.0) : null,
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          if (entry.leading != null) ...[
            entry.leading!,
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              entry.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: effectiveTextColor,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
