import 'package:flutter/material.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: context.theme.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(value, style: context.theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
