import 'package:flutter/material.dart';

import 'package:hosthub_console/shared/widgets/widgets.dart';
import 'package:styled_widgets/styled_widgets.dart';

import '../../data/property_repository.dart';

Future<PropertySummary?> showSwitchPropertyDialog(
  BuildContext context, {
  required List<PropertySummary> properties,
  PropertySummary? current,
}) {
  return showDialog<PropertySummary>(
    context: context,
    builder: (context) {
      return _SwitchPropertyDialog(properties: properties, current: current);
    },
  );
}

class _SwitchPropertyDialog extends StatelessWidget {
  const _SwitchPropertyDialog({required this.properties, this.current});

  final List<PropertySummary> properties;
  final PropertySummary? current;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select property'),
      content: SizedBox(
        width: 420,
        child: properties.isEmpty
            ? const Text('No properties available.')
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: properties.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    final isSelected = current?.id == property.id;
                    return ListTile(
                      title: Text(property.name),
                      trailing:
                          isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                      onTap: () => Navigator.of(context).pop(property),
                    );
                  },
                ),
              ),
      ),
      actions: [
        StyledButton(
          title: context.s.closeButton,
          onPressed: () => Navigator.of(context).pop(),
          minHeight: 40,
        ),
      ],
    );
  }
}
