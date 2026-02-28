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
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return AlertDialog(
        title: Text(accountWide ? 'Gebruiker uitnodigen' : 'Lid uitnodigen'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _InviteMemberForm(
            siteName: siteName,
            accountWide: accountWide,
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 12, right: 20),
        actions: [
          StyledButton(
            title: context.s.cancelButton,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            minHeight: 40,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            labelColor: theme.colorScheme.onSurface,
          ),
        ],
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
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
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
        final cubitError = context.read<SiteMembersCubit>().state.error;
        setState(() {
          _isBusy = false;
          _errorMessage = cubitError?.message ?? 'Uitnodiging mislukt';
        });
      }
    } catch (error, stack) {
      final domainError = DomainError.from(error, stack: stack);
      final message = AppError.fromDomain(context, domainError).alert;
      setState(() {
        _isBusy = false;
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.accountWide
                ? 'Nodig een gebruiker uit om samen je properties te beheren.'
                : 'Nodig iemand uit om samen te werken aan "${widget.siteName}".',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          StyledFormField(
            controller: _emailController,
            placeholder: 'E-mailadres',
            keyboardType: TextInputType.emailAddress,
            enabled: !_isBusy,
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
          Text(
            'Rol',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<SiteMemberRole>(
            segments: SiteMemberRole.assignableRoles
                .map(
                  (role) => ButtonSegment(
                    value: role,
                    label: Text(role.label),
                  ),
                )
                .toList(),
            selected: {_selectedRole},
            onSelectionChanged: _isBusy
                ? null
                : (selection) {
                    setState(() => _selectedRole = selection.first);
                  },
          ),
          const SizedBox(height: 16),
          StyledButton(
            title: 'Uitnodiging versturen',
            enabled: !_isBusy,
            showProgressIndicatorWhenDisabled: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
