import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

/// What a [StatusPill] says about the thing it labels.
enum StatusPillTone {
  /// Confirmed, active, connected — the state you want.
  positive,

  /// Provisional: awaiting a decision or an action.
  caution,

  /// Cancelled, failed, disconnected.
  negative,

  /// A state with no verdict attached.
  neutral,
}

/// Design `.stat`: a state as a tinted pill sized for a dense row — a status
/// column, a connection row — rather than the 28-high display chip a tile uses.
///
/// One definition for every such pill in the console, so a booking's "Booked"
/// and a connection's "Active" cannot end up in two different greens.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = StatusPillTone.neutral,
    this.icon,
  });

  final String label;
  final StatusPillTone tone;

  /// Optional leading glyph inside the pill (the design draws a check on the
  /// "Active" pill).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (Color background, Color foreground) = switch (tone) {
      StatusPillTone.positive => (
        HosthubDiploraV1Palette.success.withValues(alpha: 0.14),
        HosthubDiploraV1Palette.successText,
      ),
      StatusPillTone.caution => (
        HosthubDiploraV1Palette.warning.withValues(alpha: 0.16),
        HosthubDiploraV1Palette.warningText,
      ),
      StatusPillTone.negative => (
        HosthubDiploraV1Palette.error.withValues(alpha: 0.12),
        HosthubDiploraV1Palette.error,
      ),
      StatusPillTone.neutral => (
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurfaceVariant,
      ),
    };

    return StyledChip(
      label: label,
      leading: icon == null
          ? null
          : Icon(icon, size: 11, color: foreground),
      backgroundColor: background,
      labelColor: foreground,
      borderColor: Colors.transparent,
      // `.stat{padding:3px 9px;font:600 10.5px}` — a pill sized for a dense
      // row, not the display chip used on tiles.
      minHeight: 22,
      cornerRadius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    );
  }
}
