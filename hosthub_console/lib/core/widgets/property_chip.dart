import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

// One widget for every place a property has to be recognised at a glance — the
// sidebar tree, the properties list, the filter menu, a table's property column.
// The chip is an identifier, so it has to look the same in all of them; drawn per
// call site it drifts, and then the same property reads as two.

/// The design's sidebar chip: 26×26 with a 7px radius (§7).
const double kPropertyChipSize = 26;
const double kPropertyChipRadius = 7;

/// A property's two-letter code, as a chip.
///
/// One widget for every place a property has to be recognised at a glance, so the
/// same property never reads as two.
class PropertyChip extends StatelessWidget {
  const PropertyChip({
    super.key,
    required this.abbreviation,
    this.size = kPropertyChipSize,
    this.borderRadius = kPropertyChipRadius,
    this.filled = false,
  });

  final String abbreviation;

  /// Side of the (square) chip. The design's sidebar chip is 26×26; a table cell
  /// takes a smaller one, and the properties list a larger one.
  final double size;

  /// Corner radius. Scaled by callers that scale [size], so a bigger chip does
  /// not read as a rounder one.
  final double borderRadius;

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
        borderRadius: BorderRadius.circular(borderRadius),
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
