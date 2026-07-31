import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/team/application/site_members_cubit.dart';
import 'package:hosthub_console/features/team/domain/site_member_role.dart';
import 'package:hosthub_console/features/team/presentation/site_member_role_copy.dart';
import 'package:styled_widgets/styled_widgets.dart';

Future<bool?> showInviteMemberDialog(
  BuildContext context, {
  required String siteName,
}) {
  return _showInviteDialog(context, siteName: siteName, accountWide: false);
}

Future<bool?> showInvitePartnerDialog(BuildContext context) {
  return _showInviteDialog(context, accountWide: true);
}

/// An address and a role.
///
/// The primary action is the modal's own footer action, not a button painted at
/// the bottom of the form: a form that carries its own submit button ends up
/// with two ways to finish, and the one in the body is the one that cannot show
/// the modal's busy state or be disabled with a reason.
Future<bool?> _showInviteDialog(
  BuildContext context, {
  String? siteName,
  required bool accountWide,
}) {
  final title = accountWide
      ? context.s.teamInviteUserTitle
      : context.s.teamInviteMemberTitle;
  final cubit = context.read<SiteMembersCubit>();
  final formKey = GlobalKey<_InviteMemberFormState>();

  return showStyledModal<bool>(
    context,
    title: title,
    subtitle: accountWide
        ? context.s.teamInviteUserDescription
        : context.s.teamInviteSiteDescription(siteName ?? ''),
    dismiss: const StyledModalDismiss<bool>(isDismissible: false),
    sizing: const StyledModalSizing(dialogMaxWidth: 560),
    actions: StyledModalActions.save(
      label: context.s.teamSendInvitation,
      cancelLabel: context.s.cancelButton,
      onPressed: () async => formKey.currentState?.submit(),
    ),
    // The form decides whether the invite closes the modal: a rejected address
    // keeps it open with what was typed.
    controls: const StyledModalControls<bool>(closeOnAction: false),
    builder: (modalContext, modal) {
      // The cubit lives in the shell; a modal route is not below it.
      return BlocProvider.value(
        value: cubit,
        child: _InviteMemberForm(
          key: formKey,
          accountWide: accountWide,
          siteName: siteName,
        ),
      );
    },
  );
}

class _InviteMemberForm extends StatefulWidget {
  const _InviteMemberForm({super.key, this.siteName, this.accountWide = false});

  final String? siteName;
  final bool accountWide;

  @override
  State<_InviteMemberForm> createState() => _InviteMemberFormState();
}

class _InviteMemberFormState extends State<_InviteMemberForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  SiteMemberRole _selectedRole = SiteMemberRole.editor;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Called by the modal's footer action. Throwing nothing and simply returning
  /// keeps the modal open, which is what a failed validation should do; the
  /// shell shows progress while this future is pending.
  ///
  /// The controller comes off this form's own context rather than being handed
  /// in: the intent that drives the footer takes no arguments, and the form is
  /// a descendant of the modal that owns it.
  Future<void> submit() async {
    final controller = StyledModalController.of<bool>(context);
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final cubit = context.read<SiteMembersCubit>();
    final email = _emailController.text.trim();
    final success = widget.accountWide
        ? await cubit.invitePartner(email: email, role: _selectedRole)
        : await cubit.inviteMember(
            email: email,
            role: _selectedRole,
            siteName: widget.siteName ?? '',
          );
    if (!mounted) return;

    if (success) {
      controller.close(true);
      return;
    }
    // The cubit put the DomainError in state; the page that opened this modal
    // reports it. Staying open keeps the typed address.
    final error = cubit.state.error;
    if (error != null) {
      await showAppError(context, AppError.fromDomain(context, error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StyledTextFormField(
            controller: _emailController,
            placeholder: context.s.teamEmailPlaceholder,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            validators: [
              (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return context.s.requiredField;
                if (!trimmed.contains('@') || !trimmed.contains('.')) {
                  return context.s.enterValidEmail;
                }
                return null;
              },
            ],
          ),
          const SizedBox(height: 12),
          StyledSelectionTile<SiteMemberRole>.dropdown(
            title: context.s.teamRoleColumn,
            // What the chosen role may do, so granting one does not need the
            // account page's footnote to be remembered.
            subtitle: _selectedRole.roleDescription(context),
            currentValue: _selectedRole,
            options: SiteMemberRole.assignableRoles,
            optionLabelBuilder: (role) => role.roleLabel(context),
            defaultValue: SiteMemberRole.editor,
            onChanged: (role) {
              if (role != null) setState(() => _selectedRole = role);
            },
          ),
        ],
      ),
    );
  }
}
