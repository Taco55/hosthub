import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

/// One KPI tile's content. The layout decides the density, so a caller states
/// what to show, not how big it is.
class MetricTileData {
  const MetricTileData({
    required this.label,
    required this.value,
    this.icon,
    this.caption,
    this.tone = StyledStatTone.neutral,
  });

  final String label;
  final String value;

  /// Design `.kpi .kl`: the reservations tiles carry an icon, the revenue
  /// tiles do not — so this is optional, not a per-page decoration choice.
  final IconData? icon;

  /// Design `.kpi .kd`: the supporting line under the figure.
  final String? caption;

  /// Colours the caption when the movement has a direction.
  final StyledStatTone tone;
}

/// Design `.kpis`: equal columns across the full content width.
///
/// Shared by Reservations and Revenue so a KPI row looks the same on both, and
/// so the narrow-screen fallback lives in one place. Below [denseBreakpoint]
/// there is no room for the full tile anatomy, so it wraps a row of dense tiles
/// with the label in a tooltip.
class MetricsGrid extends StatelessWidget {
  const MetricsGrid({
    super.key,
    required this.metrics,
    this.denseBreakpoint = 700,
  });

  final List<MetricTileData> metrics;
  final double denseBreakpoint;

  @override
  Widget build(BuildContext context) {
    final gap = context.styledSpacing.sm;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dense = constraints.maxWidth < denseBreakpoint;
        final tiles = [
          for (final metric in metrics)
            StyledStatTile(
              label: metric.label,
              value: metric.value,
              icon: metric.icon,
              caption: metric.caption,
              tone: metric.tone,
              dense: dense,
            ),
        ];

        if (dense) {
          return Wrap(spacing: gap, runSpacing: gap, children: tiles);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Expanded(child: tiles[i]),
            ],
          ],
        );
      },
    );
  }
}
