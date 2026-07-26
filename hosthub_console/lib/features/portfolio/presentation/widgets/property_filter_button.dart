import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/portfolio/domain/property_selection.dart';
import 'package:hosthub_console/features/properties/properties.dart';

/// A property the filter can offer.
@immutable
class PropertyFilterOption {
  const PropertyFilterOption({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  final int id;
  final String name;
  final String abbreviation;
}

/// The one control a portfolio screen's header carries: which properties count.
///
/// The button says what the scope is rather than what it does — `Alle
/// properties`, the property's own name when exactly one is picked, or `2 van 4
/// properties`. Reading the current scope off the page is the point; a button
/// labelled "Filter" would make you open it to find out.
///
/// Unchecking the last property is a no-op ([PropertySelection.toggled] holds
/// that rule), so the menu can never leave the screen showing nothing.
class PropertyFilterButton extends StatelessWidget {
  const PropertyFilterButton({
    super.key,
    required this.selection,
    required this.options,
    required this.onChanged,
  });

  final PropertySelection selection;
  final List<PropertyFilterOption> options;
  final ValueChanged<PropertySelection> onChanged;

  /// The sentinel for the "Alle properties" row, which is an action rather than
  /// one of the properties.
  static const int _selectAllValue = -1;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return StyledToolbarButton.menu<int>(
      iconData: Icons.holiday_village_outlined,
      trailingIconData: Icons.expand_more,
      label: _label(s),
      tooltip: s.portfolioFilterTooltip,
      // Applied means narrowed: all properties is the resting state, not a
      // filter the user should see highlighted.
      isSelected: !selection.isAll,
      showDividers: true,
      verticalOffset: 8,
      entries: [
        StyledMenuOverlayEntry<int>(
          value: _selectAllValue,
          label: s.portfolioFilterAll,
          checked: selection.isAll,
        ),
        for (final option in options)
          StyledMenuOverlayEntry<int>(
            value: option.id,
            label: option.name,
            leading: PropertyChip(abbreviation: option.abbreviation),
            checked: selection.contains(option.id),
          ),
      ],
      onSelected: (value) {
        onChanged(
          value == _selectAllValue
              ? selection.selectAll()
              : selection.toggled(value),
        );
      },
    );
  }

  String _label(S s) {
    if (selection.isAll || selection.isEmpty) return s.portfolioFilterAll;
    if (selection.isSingle) {
      final id = selection.selectedInOrder.first;
      for (final option in options) {
        if (option.id == id) return option.name;
      }
      return s.portfolioFilterAll;
    }
    return s.portfolioFilterSome(
      selection.selectedCount,
      selection.availableCount,
    );
  }
}

/// The account's properties as the filter offers them, chips and all.
///
/// The codes are assigned across the account by the same function the sidebar
/// uses, so a property carries one chip everywhere it appears.
List<PropertyFilterOption> portfolioFilterOptions(
  List<PropertySummary> properties,
) {
  final abbreviations = uniquePropertyAbbreviations([
    for (final property in properties) (id: property.id, name: property.name),
  ]);

  return [
    for (final property in properties)
      PropertyFilterOption(
        id: property.id,
        name: property.name,
        abbreviation: abbreviations[property.id] ?? '??',
      ),
  ];
}
