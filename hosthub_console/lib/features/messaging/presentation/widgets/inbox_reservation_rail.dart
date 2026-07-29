import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/messaging/domain/models/models.dart';
import 'package:hosthub_console/features/messaging/presentation/inbox_display.dart';
import 'package:hosthub_console/features/reservations/presentation/reservation_display.dart';

/// The right column: the booking behind the conversation, and the two actions
/// that belong to the conversation itself.
///
/// Everything here comes out of the [Reservation] the console already loaded —
/// there is nothing extra to fetch. When a thread hangs off no booking the rail
/// stays put with one line of explanation: hiding it would make the layout look
/// broken rather than make the absence understood.
class InboxReservationRail extends StatelessWidget {
  const InboxReservationRail({
    super.key,
    required this.thread,
    required this.reservation,
    required this.propertyName,
    required this.showProperty,
    required this.earlierBookingCount,
    required this.canArchiveAtSource,
    required this.canMarkReadAtSource,
    required this.sourceName,
    required this.onSnooze,
    required this.onArchive,
  });

  final MessageThread thread;
  final Reservation? reservation;
  final String propertyName;
  final bool showProperty;

  /// How many other bookings this guest already made — the one figure that says
  /// whether this is a returning guest.
  final int earlierBookingCount;

  final bool canArchiveAtSource;
  final bool canMarkReadAtSource;
  final String sourceName;

  final ValueChanged<DateTime?> onSnooze;
  final VoidCallback onArchive;

  static const double width = 264;

  /// Below this the rail folds away and the list narrows — the design's
  /// container query.
  static const double collapseBelow = 940;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final spacing = context.styledSpacing;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('d MMM yyyy', locale);
    final booking = reservation;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(left: BorderSide(color: colors.outlineVariant)),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          spacing.lg,
          spacing.lg,
          spacing.lg,
          spacing.xl,
        ),
        children: [
          _RailHeading(context.s.inboxReservationHeader),
          if (booking == null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.sm),
              child: Text(
                context.s.inboxNoReservation,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            )
          else ...[
            _RailRow(
              label: context.s.reservationStatus,
              trailing: StatusPill(
                label: valueOrDash(booking.status),
                tone: bookingStatusTone(booking.status),
              ),
            ),
            if (showProperty)
              _RailRow(
                label: context.s.propertyDetailsOverline,
                value: propertyName,
              ),
            _RailRow(
              label: context.s.reservationCheckIn,
              value: booking.startDate == null
                  ? '—'
                  : dateFormat.format(booking.startDate!.toLocal()),
            ),
            _RailRow(
              label: context.s.reservationCheckOut,
              value: booking.endDate == null
                  ? '—'
                  : dateFormat.format(booking.endDate!.toLocal()),
            ),
            _RailRow(
              label: context.s.reservationNights,
              value: _nights(booking)?.toString() ?? '—',
            ),
            _RailRow(
              label: context.s.reservationSectionGuests,
              value: booking.guestCount?.toString() ?? '—',
            ),
            _RailRow(
              label: context.s.inboxTotal,
              value: _amount(context, booking),
            ),
          ],
          SizedBox(height: spacing.lg),
          _RailHeading(context.s.reservationSectionBooker),
          _RailRow(
            label: context.s.reservationSource,
            value: InboxDisplay.channelLabel(thread.channel),
          ),
          _RailRow(
            label: context.s.inboxGuestLanguage,
            value: _languageName(context, thread.guestLocale),
          ),
          _RailRow(
            label: context.s.inboxPreviouslyBooked,
            value: context.s.inboxPreviouslyBookedValue(earlierBookingCount),
          ),
          SizedBox(height: spacing.lg),
          _SnoozeButton(thread: thread, onSnooze: onSnooze),
          SizedBox(height: spacing.sm),
          StyledButton(
            title: context.s.inboxArchive,
            size: StyledButtonSize.compact,
            variant: StyledButtonVariant.secondary,
            expand: true,
            showLeftIcon: true,
            leftIconData: Icons.archive_outlined,
            onPressed: onArchive,
          ),
          // The one state this screen should say out loud, and only while it is
          // true.
          if (thread.awaitingHost) ...[
            SizedBox(height: spacing.lg),
            StyledNotice(
              message: context.s.inboxResponseTimeNote,
              tone: StyledNoticeTone.warning,
            ),
          ],
          // Every capability the source lacks owes the reader an explanation.
          // Read, snooze and archive are the console's own here — saying so is
          // what keeps them from being mistaken for something the guest's
          // platform can see.
          if (!canMarkReadAtSource || !canArchiveAtSource) ...[
            SizedBox(height: spacing.md),
            Text(
              context.s.inboxLocalStateNote(sourceName),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static int? _nights(Reservation booking) {
    final start = booking.startDate;
    final end = booking.endDate;
    if (start == null || end == null) return null;
    return end.difference(start).inDays;
  }

  static String _amount(BuildContext context, Reservation booking) {
    final total = booking.totalAmount;
    if (total == null) return '—';
    return NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      name: booking.currency ?? 'EUR',
      decimalDigits: 0,
    ).format(total);
  }

  static String _languageName(BuildContext context, String? locale) {
    final code = locale?.trim();
    if (code == null || code.isEmpty) return '—';
    return code.toUpperCase();
  }
}

class _RailHeading extends StatelessWidget {
  const _RailHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.styledSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: context.theme.textTheme.labelSmall?.copyWith(
          color: context.colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _RailRow extends StatelessWidget {
  const _RailRow({required this.label, this.value, this.trailing});

  final String label;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(vertical: context.styledSpacing.sm),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(width: context.styledSpacing.md),
          Flexible(
            child:
                trailing ??
                Text(
                  value ?? '—',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// Snoozing is a choice of how long, so the button is a menu rather than a
/// switch that hides its own duration.
class _SnoozeButton extends StatelessWidget {
  const _SnoozeButton({required this.thread, required this.onSnooze});

  final MessageThread thread;
  final ValueChanged<DateTime?> onSnooze;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isSnoozed = thread.isSnoozed(now);

    return StyledMenuOverlay<_SnoozeOption>(
      entries: [
        StyledMenuOverlayEntry(
          value: _SnoozeOption.tomorrow,
          label: context.s.inboxSnoozeTomorrow,
          leading: const Icon(Icons.wb_twilight_outlined, size: 18),
        ),
        StyledMenuOverlayEntry(
          value: _SnoozeOption.nextWeek,
          label: context.s.inboxSnoozeNextWeek,
          leading: const Icon(Icons.event_outlined, size: 18),
        ),
        if (isSnoozed)
          StyledMenuOverlayEntry(
            value: _SnoozeOption.wake,
            label: context.s.inboxSnoozeWake,
            leading: const Icon(Icons.alarm_off_outlined, size: 18),
          ),
      ],
      onSelected: (option) => onSnooze(switch (option) {
        _SnoozeOption.tomorrow => DateTime(now.year, now.month, now.day + 1, 8),
        _SnoozeOption.nextWeek => DateTime(now.year, now.month, now.day + 7, 8),
        _SnoozeOption.wake => null,
      }),
      child: StyledButton(
        title: isSnoozed
            ? context.s.inboxSnoozedUntil(
                DateFormat(
                  'd MMM',
                  Localizations.localeOf(context).toString(),
                ).format(thread.snoozedUntil!.toLocal()),
              )
            : context.s.inboxSnooze,
        size: StyledButtonSize.compact,
        variant: StyledButtonVariant.secondary,
        expand: true,
        showLeftIcon: true,
        leftIconData: Icons.snooze_outlined,
      ),
    );
  }
}

enum _SnoozeOption { tomorrow, nextWeek, wake }
