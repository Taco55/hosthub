import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/features/properties/properties.dart';

import 'menu_item.dart';

/// Keeps the shell body on the property-setup page until there is a property to
/// show, so a fresh account lands on the one screen that can move it forward
/// instead of on empty dashboards.
///
/// Settings stays reachable — including its admin section: that is where the
/// cause of "no properties" is fixed.
class PropertySetupGate extends StatelessWidget {
  const PropertySetupGate({
    super.key,
    required this.selectedItem,
    required this.child,
  });

  final MenuItem selectedItem;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PropertyContextCubit>().state;
    final needsSetup =
        state.status == PropertyContextStatus.loaded &&
        state.properties.isEmpty &&
        selectedItem != MenuItem.settings;

    return needsSetup ? const PropertySetupPage() : child;
  }
}
