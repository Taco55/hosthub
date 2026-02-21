import 'package:flutter/material.dart';

import 'icon_registry.dart';

/// Extension to easily retrieve the `iconKey` or get an `IconData` from a key.
extension IconDataExtensions on IconData? {
  /// Returns the key associated with this [IconData], if available.
  String? get iconKey =>
      this != null ? IconRegistry.getNameForIconData(this!) : null;
}
