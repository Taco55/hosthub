import 'package:flutter/material.dart';

import 'package:app_errors/app_errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/users/users.dart';

Future<void> showOwnProfileDialog(
  BuildContext context, {
  required Profile profile,
}) async {
  final s = context.s;

  // --- Edit details controllers ---
  final emailCtrl = TextEditingController(text: profile.email);
  final usernameCtrl = TextEditingController(text: profile.username ?? '');
  final editFormKey = GlobalKey<FormState>();

  // --- Change password controllers ---
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final passwordFormKey = GlobalKey<FormState>();

  final displayName = (profile.username?.isNotEmpty ?? false)
      ? profile.username!
      : profile.email;

  try {
    await showStyledFlowModal<void>(
      context,
      title: displayName,
      config: const ModalFlowConfig(
        presentation: ModalFlowPresentation.dialog,
        isDismissible: false,
        bodyWidth: 480,
        bodyMinHeight: 400,
        enableBodyScroll: true,
        bodyPadding: EdgeInsets.zero,
      ),
      steps: [
        // ----- Root: Profile overview + menu -----
        ModalFlowStep(
          builder: (ctx, flow) {
            final liveProfile =
                ctx.watch<ProfileCubit>().state.profile ?? profile;
            final chips = _buildAccountChips(ctx, liveProfile);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StyledSection(
                  isFirstSection: true,
                  grouped: false,
                  horizontalPadding: 24,
                  showDividers: false,
                  children: [
                    const SizedBox(height: 8),
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: ctx.theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        _profileInitial(liveProfile),
                        style: ctx.theme.textTheme.headlineSmall?.copyWith(
                          color: ctx.theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _preferredDisplayName(liveProfile),
                      style: ctx.theme.textTheme.titleMedium,
                    ),
                    Text(
                      liveProfile.email,
                      style: ctx.theme.textTheme.bodyMedium?.copyWith(
                        color: ctx.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 8, children: chips),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
                StyledSection(
                  grouped: false,
                  horizontalPadding: 24,
                  children: [
                    StyledTile(
                      leading: const Icon(Icons.person_outline),
                      title: s.editDetailsAction,
                      subtitle: s.editDetailsDescription,
                      showChevron: true,
                      onTap: () => flow.goToChild(0),
                    ),
                    StyledTile(
                      leading: const Icon(Icons.key_outlined),
                      title: s.changePasswordTitle,
                      subtitle: s.changePasswordDescription,
                      showChevron: true,
                      onTap: () => flow.goToChild(1),
                    ),
                  ],
                ),
              ],
            );
          },
          children: [
            // ----- Child 0: Edit Details -----
            ModalFlowStep(
              title: s.editDetailsAction,
              footerActionLabel: s.saveButton,
              actionResult: ModalFlowActionResult.back,
              onActionPressed: () async {
                if (!(editFormKey.currentState?.validate() ?? false)) {
                  throw StateError('validation failed');
                }
                if (!context.mounted) throw StateError('unmounted');

                final repository = context.read<AdminUserRepository>();
                try {
                  final updated = await repository.updateProfileDetails(
                    profile.id,
                    email: emailCtrl.text.trim(),
                    username: usernameCtrl.text.trim().isEmpty
                        ? null
                        : usernameCtrl.text.trim(),
                  );
                  if (!context.mounted) throw StateError('unmounted');
                  context.read<ProfileCubit>().updateProfile(updated);
                  showStyledToast(
                    context,
                    type: ToastificationType.success,
                    description: s.userUpdated,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  );
                } catch (error, stack) {
                  if (error is StateError) rethrow;
                  if (!context.mounted) throw StateError('unmounted');
                  final domainError = error is DomainError
                      ? error
                      : DomainError.from(error, stack: stack);
                  await showAppError(
                    context,
                    AppError.fromDomain(context, domainError),
                  );
                  throw StateError('save failed');
                }
              },
              builder: (ctx, flow) {
                return StyledSection(
                  isFirstSection: true,
                  grouped: false,
                  horizontalPadding: 24,
                  showDividers: false,
                  children: [
                    Form(
                      key: editFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StyledFormField(
                            name: 'email',
                            controller: emailCtrl,
                            label: s.emailLabel,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return s.emailRequired;
                              }
                              if (!value.contains('@')) {
                                return s.emailInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          StyledFormField(
                            name: 'username',
                            controller: usernameCtrl,
                            label: s.usernameLabel,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // ----- Child 1: Change Password -----
            ModalFlowStep(
              title: s.changePasswordTitle,
              onEnter: () {
                passwordCtrl.clear();
                confirmPasswordCtrl.clear();
              },
              footerActionLabel: s.updateButton,
              actionResult: ModalFlowActionResult.back,
              onActionPressed: () async {
                if (!(passwordFormKey.currentState?.validate() ?? false)) {
                  throw StateError('validation failed');
                }
                if (!context.mounted) throw StateError('unmounted');

                final repository = context.read<AdminUserRepository>();
                try {
                  await repository.updatePassword(
                    profile.id,
                    passwordCtrl.text,
                  );
                  if (!context.mounted) throw StateError('unmounted');
                  showStyledToast(
                    context,
                    type: ToastificationType.success,
                    description: s.passwordChanged,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  );
                } catch (error, stack) {
                  if (error is StateError) rethrow;
                  if (!context.mounted) throw StateError('unmounted');
                  final domainError = error is DomainError
                      ? error
                      : DomainError.from(error, stack: stack);
                  await showAppError(
                    context,
                    AppError.fromDomain(context, domainError),
                  );
                  throw StateError('password change failed');
                }
              },
              builder: (ctx, flow) {
                return StyledSection(
                  isFirstSection: true,
                  grouped: false,
                  horizontalPadding: 24,
                  showDividers: false,
                  children: [
                    Form(
                      key: passwordFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StyledFormField(
                            name: 'new-password',
                            controller: passwordCtrl,
                            label: s.newPasswordLabel,
                            obscureText: true,
                            enablePasswordToggle: true,
                            validator: (value) {
                              if (value == null || value.length < 8) {
                                return s.passwordMinLength;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          StyledFormField(
                            name: 'confirm-password',
                            controller: confirmPasswordCtrl,
                            label: s.confirmPasswordLabel,
                            obscureText: true,
                            enablePasswordToggle: true,
                            validator: (value) {
                              if (value != passwordCtrl.text) {
                                return s.passwordsDoNotMatch;
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              if (passwordCtrl.text.trim().isNotEmpty &&
                                  confirmPasswordCtrl.text.trim().isNotEmpty) {
                                flow.goNext();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  } finally {
    emailCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
  }
}

List<Widget> _buildAccountChips(BuildContext context, Profile profile) {
  final s = context.s;
  final chips = <Widget>[
    Chip(
      avatar: Icon(
        profile.isAdmin ? Icons.shield_moon_outlined : Icons.person_outline,
        size: 18,
      ),
      label: Text(profile.isAdmin ? s.adminRightsActive : s.standardUser),
    ),
  ];

  if (profile.isDevelopment) {
    chips.add(
      Chip(
        avatar: const Icon(Icons.science_outlined, size: 18),
        label: Text(s.developmentAccount),
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
