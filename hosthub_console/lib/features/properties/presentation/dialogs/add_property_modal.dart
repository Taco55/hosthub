import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/properties/application/property_context_cubit.dart';
import 'package:hosthub_console/features/user_settings/application/user_settings_cubit.dart';

/// Adding a property: one action, two routes.
///
/// Lodgify first, because that is where a property normally comes from; the
/// manual route exists for building a website before Lodgify is ready. They are
/// two steps of one flow rather than two places, which is what stops a fresh
/// account from being handed a page with two competing offers — and it is the
/// same flow the empty state of Properties opens.
///
/// The Lodgify route hands off instead of reporting here: it triggers the sync
/// and closes, and the page that owns the plan opens the result modal. One
/// screen for "this is what Lodgify has", wherever the sync was started.
Future<void> showAddPropertyModal(BuildContext context) async {
  final settingsCubit = context.read<UserSettingsCubit>();
  final propertyContext = context.read<PropertyContextCubit>();
  final isConnected = settingsCubit.state.settings?.lodgifyConnected ?? false;

  /// The typed name, read by the manual step's footer action.
  var name = '';

  await showStyledModal<void>(
    context,
    title: context.s.propertiesListAdd,
    sizing: const StyledModalSizing(dialogMaxWidth: 520),
    steps: StyledModalSteps(
      children: [
        StyledModalStep(
          // The two routes are a StyledSection, which owns its padding.
          contentPadding: EdgeInsets.zero,
          builder: (context, modal) => StyledSection(
            isFirstSection: true,
            footer: context.s.addPropertyFooter,
            children: [
              StyledTile(
                leading: StyledIconBadge.monogram(
                  'LG',
                  size: 34,
                  borderRadius: 10,
                  backgroundColor: context.colors.secondary,
                  iconColor: context.colors.onSecondary,
                ),
                title: context.s.addPropertyFromLodgifyTitle,
                subtitle: isConnected
                    ? context.s.addPropertyFromLodgifyBody
                    : context.s.addPropertyLodgifyNotConnected,
                enabled: isConnected,
                // An action, not a destination — so no chevron.
                onTap: isConnected
                    ? () {
                        modal.closeWithoutResult();
                        settingsCubit.syncLodgify();
                      }
                    : null,
              ),
              StyledTile(
                leading: Icon(
                  Icons.add_home_outlined,
                  color: context.colors.onSurfaceVariant,
                ),
                title: context.s.addPropertyManualTitle,
                subtitle: context.s.addPropertyManualBody,
                showChevron: true,
                onTap: () => modal.steps?.goToChild(0),
              ),
            ],
          ),
          children: [
            StyledModalStep(
              title: context.s.addPropertyManualTitle,
              footerActionLabel: context.s.addPropertyManualAction,
              // Nothing to create until there is a name.
              actionEnabled: false,
              actionResult: StyledModalStepActionResult.close,
              onActionPressed: (controller, data) async {
                final trimmed = name.trim();
                if (trimmed.isEmpty) return;
                final created = await propertyContext.createProperty(trimmed);
                // Throwing keeps the modal on this step; the page's listener
                // shows the DomainError the cubit put in state.
                if (created == null) {
                  throw propertyContext.state.error ??
                      StateError('createProperty returned no property');
                }
              },
              builder: (context, modal) => _ManualNameField(
                onChanged: (value) {
                  name = value;
                  final steps = modal.steps;
                  if (steps == null) return;
                  steps.setActionEnabled(value.trim().isNotEmpty);
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Just a name: everything else about a property comes from Lodgify or from the
/// website editor, so asking for more here would be asking for data we would
/// then have to reconcile.
class _ManualNameField extends StatefulWidget {
  const _ManualNameField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<_ManualNameField> createState() => _ManualNameFieldState();
}

class _ManualNameFieldState extends State<_ManualNameField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StyledTextFormField(
      controller: _controller,
      label: context.s.addPropertyNameLabel,
      placeholder: context.s.addPropertyNameLabel,
      autofocus: true,
      textInputAction: TextInputAction.done,
      onChanged: widget.onChanged,
    );
  }
}
