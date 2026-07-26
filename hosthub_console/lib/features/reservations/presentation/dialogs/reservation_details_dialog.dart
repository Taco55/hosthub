import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/channel_manager/domain/models/models.dart';
import 'package:hosthub_console/features/reservations/presentation/reservation_display.dart';

/// One line of the revenue section: a label and an amount.
@immutable
class ReservationRevenueLine {
  const ReservationRevenueLine({required this.label, required this.amount});

  final String label;
  final num? amount;
}

/// What the dialog shows under "Opbrengsten".
///
/// The two screens derive these figures differently — reservations reads the
/// booking payload, revenue settles it against the channel settings — so the
/// dialog takes the result rather than the recipe. That is what lets one
/// dialog serve the list, the timeline and the revenue table.
@immutable
class ReservationRevenueSummary {
  const ReservationRevenueSummary({
    this.currency,
    this.total,
    this.net,
    this.outstanding,
    this.lines = const [],
  });

  static const ReservationRevenueSummary empty = ReservationRevenueSummary();

  final String? currency;
  final num? total;
  final num? net;
  final num? outstanding;

  /// Breakdown between gross and net (cleaning, commission, tax…).
  final List<ReservationRevenueLine> lines;

  bool get hasAnyData =>
      total != null || net != null || outstanding != null || lines.isNotEmpty;
}

/// Opens the booking detail dialog. Design §10 — the same dialog from the
/// reservations list, a timeline bar and a revenue row.
Future<void> showReservationDetailsDialog(
  BuildContext context, {
  required Reservation entry,
  required DateFormat dateFormatter,
  required DateFormat dateTimeFormatter,
  required ReservationRevenueSummary revenue,
  Future<void> Function(String reservationId, String notes)? onSaveNotes,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => ReservationDetailsDialog(
      entry: entry,
      dateFormatter: dateFormatter,
      dateTimeFormatter: dateTimeFormatter,
      revenue: revenue,
      onSaveNotes: onSaveNotes,
    ),
  );
}

/// Booking detail dialog: booker, stay, guests, revenue, notes, timestamps and
/// the raw payload.
///
/// Pass [onSaveNotes] to make the notes section an editor; without it the note
/// is shown read-only. That is the only difference between the two screens
/// that opened this dialog — the reservations screen can write notes back to
/// Lodgify, the revenue screen has no cubit for it.
class ReservationDetailsDialog extends StatefulWidget {
  const ReservationDetailsDialog({
    super.key,
    required this.entry,
    required this.dateFormatter,
    required this.dateTimeFormatter,
    this.revenue = ReservationRevenueSummary.empty,
    this.onSaveNotes,
  });

  final Reservation entry;
  final DateFormat dateFormatter;
  final DateFormat dateTimeFormatter;
  final ReservationRevenueSummary revenue;

  /// Persists an edited note. Null renders the note read-only.
  final Future<void> Function(String reservationId, String notes)? onSaveNotes;

  @override
  State<ReservationDetailsDialog> createState() =>
      _ReservationDetailsDialogState();
}

class _ReservationDetailsDialogState extends State<ReservationDetailsDialog> {
  late final TextEditingController _notesController;
  bool _isSavingNotes = false;
  bool _notesSaved = false;

  bool get _hasReservationId {
    final id = widget.entry.reservationId;
    return id != null && id.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.entry.notes?.trim() ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    final reservationId = widget.entry.reservationId;
    final save = widget.onSaveNotes;
    if (save == null || reservationId == null || reservationId.isEmpty) return;

    setState(() {
      _isSavingNotes = true;
      _notesSaved = false;
    });

    try {
      await save(reservationId, _notesController.text.trim());
      if (!mounted) return;
      setState(() {
        _isSavingNotes = false;
        _notesSaved = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSavingNotes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final spacing = context.styledSpacing;
    final revenue = widget.revenue;
    final prettyRaw = const JsonEncoder.withIndent('  ').convert(entry.raw);
    final nights = stayNights(entry.startDate, entry.endDate);
    final guestName = guestDisplayName(
      entry,
      fallback: context.s.revenueUnknownBooker,
    );

    final dialogBg = context.theme.brightness == Brightness.light
        ? Colors.white
        : context.colors.surfaceContainerLow;

    return Dialog(
      backgroundColor: dialogBg,
      insetPadding: EdgeInsets.all(spacing.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.lg,
                vertical: spacing.md,
              ),
              child: Row(
                children: [
                  _CircularCloseButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: spacing.md),
                  Expanded(
                    child: Text(
                      guestName,
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.theme.dividerColor),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    StyledSection(
                      isFirstSection: true,
                      header: context.s.reservationSectionBooker,
                      children: [
                        StyledTile(
                          title: context.s.reservationName,
                          value: guestName,
                        ),
                        StyledTile(
                          title: context.s.reservationEmail,
                          value: valueOrDash(entry.guestEmail),
                        ),
                        StyledTile(
                          title: context.s.reservationPhone,
                          value: valueOrDash(entry.guestPhone),
                        ),
                      ],
                    ),
                    StyledSection(
                      header: context.s.reservationSectionStay,
                      children: [
                        StyledTile(
                          title: context.s.reservationCheckIn,
                          value:
                              formatDateTime(
                                entry.startDate,
                                widget.dateFormatter,
                              ) ??
                              '-',
                        ),
                        StyledTile(
                          title: context.s.reservationCheckOut,
                          value:
                              formatDateTime(
                                entry.endDate,
                                widget.dateFormatter,
                              ) ??
                              '-',
                        ),
                        StyledTile(
                          title: context.s.reservationNights,
                          value: nights != null ? '$nights' : '-',
                        ),
                        StyledTile(
                          title: context.s.reservationStatus,
                          value: valueOrDash(entry.status),
                        ),
                        StyledTile(
                          title: context.s.reservationSource,
                          value: valueOrDash(entry.source),
                          trailing: BookingSourceIcon(
                            source: entry.source,
                            size: 24,
                          ),
                        ),
                        if (_hasReservationId)
                          StyledTile(
                            title: context.s.reservationId,
                            value: entry.reservationId!,
                          ),
                      ],
                    ),
                    StyledSection(
                      header: context.s.reservationSectionGuests,
                      children: [
                        StyledTile(
                          title: context.s.reservationGuestTotal,
                          value: guestBreakdown(entry),
                        ),
                        StyledTile(
                          title: context.s.reservationAdults,
                          value: entry.adultCount?.toString() ?? '-',
                        ),
                        StyledTile(
                          title: context.s.reservationChildren,
                          value: entry.childCount?.toString() ?? '-',
                        ),
                        StyledTile(
                          title: context.s.reservationInfants,
                          value: entry.infantCount?.toString() ?? '-',
                        ),
                      ],
                    ),
                    if (revenue.hasAnyData)
                      StyledSection(
                        header: context.s.reservationSectionRevenue,
                        children: [
                          if (revenue.total != null)
                            StyledTile(
                              title: context.s.reservationGross,
                              value: formatAmount(
                                revenue.total,
                                revenue.currency,
                              ),
                            ),
                          for (final line in revenue.lines)
                            StyledTile(
                              title: line.label,
                              value: formatAmount(
                                line.amount,
                                revenue.currency,
                              ),
                            ),
                          if (revenue.net != null)
                            StyledTile(
                              title: context.s.reservationNet,
                              value: formatAmount(
                                revenue.net,
                                revenue.currency,
                              ),
                            ),
                          if (revenue.outstanding != null)
                            StyledTile(
                              title: context.s.reservationOutstanding,
                              value: formatAmount(
                                revenue.outstanding,
                                revenue.currency,
                              ),
                            ),
                        ],
                      ),
                    if (widget.onSaveNotes != null)
                      _buildNotesEditor(context)
                    else if (entry.notes != null &&
                        entry.notes!.trim().isNotEmpty)
                      StyledSection(
                        header: context.s.reservationNotes,
                        children: [
                          StyledTile(
                            title: context.s.reservationNotes,
                            value: entry.notes!.trim(),
                          ),
                        ],
                      ),
                    StyledSection(
                      header: context.s.reservationSectionOther,
                      children: [
                        StyledTile(
                          title: context.s.reservationCreatedAt,
                          value:
                              formatDateTime(
                                entry.createdAt,
                                widget.dateTimeFormatter,
                              ) ??
                              '-',
                        ),
                        StyledTile(
                          title: context.s.reservationUpdatedAt,
                          value:
                              formatDateTime(
                                entry.updatedAt,
                                widget.dateTimeFormatter,
                              ) ??
                              '-',
                        ),
                      ],
                    ),
                    StyledSection(
                      header: context.s.reservationSectionPayload,
                      inset: false,
                      children: [
                        StyledContainer(
                          backgroundColor: context.colors.surface,
                          border: Border.all(color: context.theme.dividerColor),
                          child: SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SelectableText(
                                prettyRaw,
                                style: context.theme.textTheme.bodySmall
                                    ?.copyWith(fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesEditor(BuildContext context) {
    final spacing = context.styledSpacing;

    return StyledSection(
      header: context.s.reservationNotes,
      inset: false,
      children: [
        StyledTextField(
          controller: _notesController,
          enabled: _hasReservationId && !_isSavingNotes,
          maxLines: 4,
          placeholder: _hasReservationId
              ? context.s.reservationNotesHint
              : context.s.reservationNotesDisabledHint,
        ),
        SizedBox(height: spacing.sm),
        Row(
          children: [
            if (_notesSaved)
              Text(
                context.s.savedLabel,
                style: context.theme.textTheme.bodySmall?.copyWith(
                  color: HosthubDiploraV1Palette.successText,
                ),
              ),
            const Spacer(),
            if (_isSavingNotes)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_hasReservationId)
              StyledTextButton(
                title: context.s.reservationNotesSave,
                showLeftIcon: true,
                leftIconData: Icons.save_outlined,
                onPressed: _saveNotes,
              ),
          ],
        ),
      ],
    );
  }
}

/// The dialog's close affordance — the same toolbar button the pages use, so
/// it carries the design's `.tbtn` geometry instead of its own.
class _CircularCloseButton extends StatelessWidget {
  const _CircularCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return StyledToolbarButton(
      iconData: Icons.close,
      tooltip: context.s.reservationCloseTooltip,
      onPressed: onPressed,
    );
  }
}
