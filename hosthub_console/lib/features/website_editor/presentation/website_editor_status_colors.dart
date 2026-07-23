import 'package:flutter/material.dart';

/// Semantic status colours for the per-field translation chips.
///
/// The design mandates a green "Locked" and an amber "Auto" chip, but neither
/// the Material [ColorScheme] (seeded from blue) nor the app's `AppColors`
/// exposes a green/amber role. These two token pairs are the single, documented
/// home for those semantic colours (brightness-aware), sourced from the Just
/// Organize design tokens — kept out of the layout widgets so the screen stays
/// free of scattered hex literals.
class WebsiteStatusColors {
  const WebsiteStatusColors._();

  // Locked → success green (#1F8A4C on #E4F4EB).
  static const Color _lockedBgLight = Color(0xFFE4F4EB);
  static const Color _lockedFgLight = Color(0xFF1F8A4C);
  static const Color _lockedBgDark = Color(0xFF16311F);
  static const Color _lockedFgDark = Color(0xFF6FD59A);

  // Auto → caution amber (#9A6B00 on #FFF7E6).
  static const Color _autoBgLight = Color(0xFFFFF7E6);
  static const Color _autoFgLight = Color(0xFF9A6B00);
  static const Color _autoBgDark = Color(0xFF3A2E12);
  static const Color _autoFgDark = Color(0xFFE9C46A);

  static ({Color background, Color foreground}) locked(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return (
      background: dark ? _lockedBgDark : _lockedBgLight,
      foreground: dark ? _lockedFgDark : _lockedFgLight,
    );
  }

  static ({Color background, Color foreground}) auto(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return (
      background: dark ? _autoBgDark : _autoBgLight,
      foreground: dark ? _autoFgDark : _autoFgLight,
    );
  }
}
