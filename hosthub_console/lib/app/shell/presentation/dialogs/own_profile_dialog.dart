import 'package:flutter/material.dart';

import 'package:app_errors/app_errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/l10n/application/language_cubit.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/models/models.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/user_settings/application/user_settings_cubit.dart';

import '../../application/sidebar_mode_cubit.dart';

Future<void> showOwnProfileDialog(
  BuildContext context, {
  required Profile profile,
}) async {
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

  // Evaluated with the page context: inside the dialog the MediaQuery is
  // narrowed to the dialog width, so the desktop check would always fail. The
  // compact-rail preference only bites where both widths fit.
  // Same breakpoints the shell uses, so this check can never disagree with the
  // rail it is about.
  final isDesktopShell =
      StyledWidgetsTheme.of(context).sideMenu.breakpoints.of(context) ==
      StyledSideMenuLayout.expanded;

  // NOTE: the field controllers are intentionally not disposed after the
  // modal future resolves — that future completes before the dismiss
  // animation finishes, and the exit relayout would hit a disposed
  // controller. GC reclaims them (see the styled-widgets modal guide).
  await showStyledModal<void>(
    context,
    title: displayName,
    sheet: const StyledModalSheet(presentation: StyledModalPresentation.dialog),
    dismiss: const StyledModalDismiss<void>(isDismissible: false),
    sizing: const StyledModalSizing(
      dialogMinWidth: 480,
      dialogMaxWidth: 480,
      bodyMinHeight: 400,
      enableBodyScroll: true,
    ),
    steps: StyledModalSteps(
      children: [
        // ----- Root: Profile overview + menu -----
        StyledModalStep(
          builder: (ctx, flow) {
            final liveProfile =
                ctx.watch<ProfileCubit>().state.profile ?? profile;
            final chips = _buildAccountChips(ctx, liveProfile);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StyledSection(
                  isFirstSection: true,
                  inset: false,
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
                  inset: false,
                  horizontalPadding: 24,
                  children: [
                    StyledTile(
                      leading: const Icon(Icons.person_outline),
                      title: context.s.editDetailsAction,
                      subtitle: context.s.editDetailsDescription,
                      showChevron: true,
                      onTap: () => flow.goToChild(0),
                    ),
                    StyledTile(
                      leading: const Icon(Icons.key_outlined),
                      title: context.s.changePasswordTitle,
                      subtitle: context.s.changePasswordDescription,
                      showChevron: true,
                      onTap: () => flow.goToChild(1),
                    ),
                  ],
                ),
                StyledSection(
                  inset: false,
                  horizontalPadding: 24,
                  header: context.s.preferencesSectionTitle,
                  children: [
                    const _InterfaceLanguageTile(),
                    if (isDesktopShell) const _CompactSideMenuTile(),
                  ],
                ),
              ],
            );
          },
          children: [
            // ----- Child 0: Edit Details -----
            StyledModalStep(
              title: context.s.editDetailsAction,
              footerActionLabel: context.s.saveButton,
              actionResult: StyledModalStepActionResult.back,
              onActionPressed: (steps, data) async {
                if (!(editFormKey.currentState?.validate() ?? false)) {
                  throw StateError('validation failed');
                }
                if (!context.mounted) throw StateError('unmounted');

                final success = await context
                    .read<ProfileCubit>()
                    .updateOwnProfile(
                      email: emailCtrl.text.trim(),
                      username: usernameCtrl.text.trim().isEmpty
                          ? null
                          : usernameCtrl.text.trim(),
                    );
                if (!context.mounted) throw StateError('unmounted');

                if (!success) {
                  final domainError = context.read<ProfileCubit>().state.error;
                  if (domainError == null) {
                    throw StateError('save failed');
                  }
                  await showAppError(
                    context,
                    AppError.fromDomain(context, domainError),
                  );
                  throw StateError('save failed');
                }

                showStyledToast(
                  context,
                  type: ToastificationType.success,
                  description: context.s.userUpdated,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                );
              },
              builder: (ctx, flow) {
                return StyledSection(
                  isFirstSection: true,
                  inset: false,
                  horizontalPadding: 24,
                  showDividers: false,
                  children: [
                    Form(
                      key: editFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StyledTextFormField(
                            name: 'email',
                            controller: emailCtrl,
                            label: context.s.emailLabel,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return context.s.emailRequired;
                              }
                              if (!value.contains('@')) {
                                return context.s.emailInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          StyledTextFormField(
                            name: 'username',
                            controller: usernameCtrl,
                            label: context.s.usernameLabel,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // ----- Child 1: Change Password -----
            StyledModalStep(
              title: context.s.changePasswordTitle,
              onEnter: () {
                passwordCtrl.clear();
                confirmPasswordCtrl.clear();
              },
              footerActionLabel: context.s.updateButton,
              actionResult: StyledModalStepActionResult.back,
              onActionPressed: (steps, data) async {
                if (!(passwordFormKey.currentState?.validate() ?? false)) {
                  throw StateError('validation failed');
                }
                if (!context.mounted) throw StateError('unmounted');

                final success = await context
                    .read<ProfileCubit>()
                    .updateOwnPassword(passwordCtrl.text);
                if (!context.mounted) throw StateError('unmounted');

                if (!success) {
                  final domainError = context.read<ProfileCubit>().state.error;
                  if (domainError == null) {
                    throw StateError('password change failed');
                  }
                  await showAppError(
                    context,
                    AppError.fromDomain(context, domainError),
                  );
                  throw StateError('password change failed');
                }

                showStyledToast(
                  context,
                  type: ToastificationType.success,
                  description: context.s.passwordChanged,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                );
              },
              builder: (ctx, flow) {
                return StyledSection(
                  isFirstSection: true,
                  inset: false,
                  horizontalPadding: 24,
                  showDividers: false,
                  children: [
                    Form(
                      key: passwordFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StyledTextFormField(
                            name: 'new-password',
                            controller: passwordCtrl,
                            label: context.s.newPasswordLabel,
                            obscureText: true,
                            enablePasswordToggle: true,
                            validator: (value) {
                              if (value == null || value.length < 8) {
                                return context.s.passwordMinLength;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          StyledTextFormField(
                            name: 'confirm-password',
                            controller: confirmPasswordCtrl,
                            label: context.s.confirmPasswordLabel,
                            obscureText: true,
                            enablePasswordToggle: true,
                            validator: (value) {
                              if (value != passwordCtrl.text) {
                                return context.s.passwordsDoNotMatch;
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
    ),
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

/// Interface language — a per-user preference (design §4b): the language the
/// console UI renders in. Persisted through [UserSettingsCubit]; the
/// session-level listener syncs it into [LanguageCubit] app-wide, so the
/// change applies immediately regardless of which screen is open.
class _InterfaceLanguageTile extends StatelessWidget with StyledTileLike {
  const _InterfaceLanguageTile();

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LanguageCubit>().state;
    final localeNames = LocaleNames.of(context);
    final supportedLocales = S.delegate.supportedLocales;
    final selected = supportedLocales
        .firstWhere(
          (locale) => locale.languageCode == currentLocale.languageCode,
          orElse: () => supportedLocales.first,
        )
        .languageCode;

    return StyledSelectionTile<String>.dropdown(
      title: context.s.interfaceLanguageTitle,
      subtitle: context.s.interfaceLanguageDescription,
      leading: const Icon(Icons.language_outlined),
      currentValue: selected,
      options: [for (final locale in supportedLocales) locale.languageCode],
      optionLabelBuilder: (code) =>
          localeNames?.nameOf(code) ?? code.toUpperCase(),
      fieldAutoSize: true,
      onChanged: (code) {
        if (code == null || code == currentLocale.languageCode) return;
        // Interface language is strictly user scope: changing it must never
        // change the property's source language (design §4b).
        context.read<UserSettingsCubit>().changeLanguage(code);
      },
    );
  }
}

/// Compact side menu — collapses the rail to the 72px icon strip. Only shown
/// from the expanded breakpoint (1100px) up: below it the rail is already
/// compact by necessity, and in drawer mode the setting is moot.
class _CompactSideMenuTile extends StatelessWidget with StyledTileLike {
  const _CompactSideMenuTile();

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<SidebarModeCubit>().state;

    return StyledSwitchTile(
      leading: const Icon(Icons.view_sidebar_outlined),
      title: context.s.compactSideMenuTitle,
      subtitle: context.s.compactSideMenuDescription,
      value: mode == StyledSideMenuMode.compact,
      onChanged: (compact) => context.read<SidebarModeCubit>().setMode(
        compact ? StyledSideMenuMode.compact : StyledSideMenuMode.expanded,
      ),
    );
  }
}
