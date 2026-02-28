import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/team/application/site_members_cubit.dart';
import 'package:hosthub_console/features/team/domain/site_member_role.dart';
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

Future<bool?> _showInviteDialog(
  BuildContext context, {
  String? siteName,
  required bool accountWide,
}) {
  final s = context.s;
  final title =
      accountWide ? s.teamInviteUserTitle : s.teamInviteMemberTitle;
  final cubit = context.read<SiteMembersCubit>();

  return showStyledModal<bool>(
    context,
    title: title,
    isDismissible: false,
    hideDefaultHeader: false,
    showLeading: true,
    leadingLabel: s.cancelButton,
    showAction: false,
    dialogMaxWidth: 560,
    builder: (modalContext) {
      return BlocProvider.value(
        value: cubit,
        child: _InviteMemberForm(
          siteName: siteName,
          accountWide: accountWide,
        ),
      );
    },
  );
}

class _InviteMemberForm extends StatefulWidget {
  const _InviteMemberForm({this.siteName, this.accountWide = false});

  final String? siteName;
  final bool accountWide;

  @override
  State<_InviteMemberForm> createState() => _InviteMemberFormState();
}

class _InviteMemberFormState extends State<_InviteMemberForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  SiteMemberRole _selectedRole = SiteMemberRole.editor;
  bool _isBusy = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _isBusy = true);

    final cubit = context.read<SiteMembersCubit>();
    final bool success;
    if (widget.accountWide) {
      success = await cubit.invitePartner(
        email: _emailController.text.trim(),
        role: _selectedRole,
      );
    } else {
      success = await cubit.inviteMember(
        email: _emailController.text.trim(),
        role: _selectedRole,
        siteName: widget.siteName ?? '',
      );
    }
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _isBusy = false);
      final cubitError = cubit.state.error;
      if (cubitError != null) {
        await showAppError(context, AppError.fromDomain(context, cubitError));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final roles = SiteMemberRole.assignableRoles;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.accountWide
                  ? s.teamInviteUserDescription
                  : s.teamInviteSiteDescription(widget.siteName ?? ''),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            StyledFormField(
              controller: _emailController,
              placeholder: s.teamEmailPlaceholder,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isBusy,
              validators: [
                (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return s.requiredField;
                  if (!trimmed.contains('@') || !trimmed.contains('.')) {
                    return s.enterValidEmail;
                  }
                  return null;
                },
              ],
            ),
            const SizedBox(height: 12),
            StyledSelectionTile<SiteMemberRole>.dropdown(
              title: s.teamRoleColumn,
              modalTitle: s.teamRoleColumn,
              currentValue: _selectedRole,
              options: roles,
              optionLabelBuilder: (role) => role.label,
              enabled: !_isBusy,
              defaultValue: SiteMemberRole.editor,
              onChanged: (role) {
                if (role != null) {
                  setState(() => _selectedRole = role);
                }
              },
            ),
            const SizedBox(height: 16),
            StyledButton(
              title: s.teamSendInvitation,
              enabled: !_isBusy,
              showProgressIndicatorWhenDisabled: true,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
