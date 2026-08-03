import 'package:app_errors/app_errors.dart';
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
                if (created == null) {
                  await _reportCreateFailure(context, propertyContext);
                }
              },
              builder: (context, modal) => _ManualNameField(
                // What was typed, not what the field happens to hold: opening
                // the error dialog over this step rebuilds it from scratch, and
                // a retry should not start by retyping the name.
                initialValue: name,
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

/// Say that creating failed, here, and keep the modal on its step.
///
/// The cubit stores the failure in its state, and Properties turns that into a
/// dialog — but this flow is opened from the `+` on the nav tree's property
/// headings too, which is reachable from every screen in the console. Opened
/// from there, nothing was listening: the button did nothing, the name stayed
/// in the field, and the only trace was a `debugPrint`. So the modal reports
/// its own action instead of borrowing whatever page happens to be behind it.
///
/// Throwing after the dialog is what keeps this step open, so the typed name
/// survives a retry. When Properties *is* behind the modal its listener fires
/// on the same error a moment later; [showAppError] recognises the repeat and
/// drops it, so either way the user gets exactly one dialog.
Future<Never> _reportCreateFailure(
  BuildContext context,
  PropertyContextCubit propertyContext,
) async {
  final error = propertyContext.state.error;
  if (error != null && context.mounted) {
    await showAppError(context, AppError.fromDomain(context, error));
    propertyContext.clearError();
  }
  throw error ?? StateError('createProperty returned no property');
}

/// Just a name: everything else about a property comes from Lodgify or from the
/// website editor, so asking for more here would be asking for data we would
/// then have to reconcile.
class _ManualNameField extends StatefulWidget {
  const _ManualNameField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_ManualNameField> createState() => _ManualNameFieldState();
}

class _ManualNameFieldState extends State<_ManualNameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

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
