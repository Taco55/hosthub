import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

/// A property's two-letter code, as a chip.
///
/// One widget for every place a property has to be recognised at a glance — the
/// sidebar tree, the properties list, the filter menu, a table's property column.
/// The chip is an identifier, so it has to look the same in all of them; drawn
/// per call site it drifts, and then the same property reads as two.
class PropertyChip extends StatelessWidget {
  const PropertyChip({
    super.key,
    required this.abbreviation,
    this.size = 26,
    this.filled = false,
  });

  final String abbreviation;

  /// Side of the (square) chip. The sidebar's rail sets its own; a table cell
  /// and the filter menu take the default.
  final double size;

  /// Primary fill with white text, for the property that is currently open.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // On the rail the chip sits on the menu's tint, so it takes the menu's own
    // foreground; anywhere else it takes the page's.
    final scope = StyledSideMenuScope.maybeOf(context);
    final onSurface = scope?.foregroundColor ?? scheme.primary;
    final background = scope == null
        ? scheme.primaryContainer
        : onSurface.withValues(alpha: 0.10);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? scheme.primary : background,
        borderRadius: BorderRadius.circular(size / 3.7),
      ),
      child: Text(
        abbreviation,
        maxLines: 1,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: filled ? scheme.onPrimary : onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
