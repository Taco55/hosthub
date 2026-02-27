import 'package:flutter/material.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

enum AdminAccountAction { editDetails, changePassword }

Future<AdminAccountAction?> showAdminAccountActionsDialog(
  BuildContext context, {
  required Profile profile,
}) {
  return showDialog<AdminAccountAction>(
    context: context,
    builder: (context) {
      final chips = _buildAccountChips(context, profile);
      return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: context.theme.colorScheme.primary.withValues(
                alpha: 0.1,
              ),
              child: Text(
                _profileInitial(profile),
                style: context.theme.textTheme.headlineSmall?.copyWith(
                  color: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _preferredDisplayName(profile),
              style: context.theme.textTheme.titleLarge,
            ),
            Text(
              profile.email,
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: chips),
            ],
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(context.s.editDetailsAction),
              subtitle: Text(context.s.editDetailsDescription),
              onTap: () =>
                  Navigator.of(context).pop(AdminAccountAction.editDetails),
            ),
            ListTile(
              leading: const Icon(Icons.key_outlined),
              title: Text(context.s.changePasswordTitle),
              subtitle: Text(context.s.changePasswordDescription),
              onTap: () =>
                  Navigator.of(context).pop(AdminAccountAction.changePassword),
            ),
          ],
        ),
        actions: [
          StyledButton(
            title: context.s.closeButton,
            onPressed: () => Navigator.of(context).pop(),
            minHeight: 40,
          ),
        ],
      );
    },
  );
}

List<Widget> _buildAccountChips(BuildContext context, Profile profile) {
  final chips = <Widget>[
    Chip(
      avatar: Icon(
        profile.isAdmin ? Icons.shield_moon_outlined : Icons.person_outline,
        size: 18,
      ),
      label: Text(
        profile.isAdmin ? context.s.adminRightsActive : context.s.standardUser,
      ),
    ),
  ];

  if (profile.isDevelopment) {
    chips.add(
      Chip(
        avatar: const Icon(Icons.science_outlined, size: 18),
        label: Text(context.s.developmentAccount),
      ),
    );
  }

  return chips;
}

String _profileInitial(Profile profile) {
  if (profile.email.isNotEmpty) return profile.email[0].toUpperCase();
  if (profile.username?.isNotEmpty ?? false) {
    return profile.username![0].toUpperCase();
  }
  return '?';
}

String _preferredDisplayName(Profile profile) {
  return (profile.username?.isNotEmpty ?? false)
      ? profile.username!
      : profile.email;
}
