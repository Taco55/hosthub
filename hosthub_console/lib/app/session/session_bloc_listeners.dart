import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_errors/app_errors.dart';
import 'package:hosthub_console/core/core.dart';
import 'package:hosthub_console/features/auth/auth.dart';
import 'package:hosthub_console/features/profile/profile.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';
import 'package:hosthub_console/core/l10n/application/language_cubit.dart';

class SessionBlocListeners extends StatefulWidget {
  const SessionBlocListeners({super.key, required this.child});

  final Widget child;

  @override
  State<SessionBlocListeners> createState() => _SessionBlocListenersState();
}

class _SessionBlocListenersState extends State<SessionBlocListeners> {
  StreamSubscription<AuthSessionChange>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadSessionData(force: false));

    // The Supabase session can surface a beat after AuthBloc reports
    // authenticated — a token refresh landing during app start, for instance.
    // Loads that fire inside that gap fail with an unauthorized DomainError and
    // are never retried, leaving the shell on a permanent "loading" profile and
    // an empty property list. Re-priming on every session event closes that
    // gap: whatever is still unloaded is picked up as soon as a session exists.
    _sessionSubscription = I.get<AuthPort>().onAuthStateChange.listen((change) {
      if (change.user == null) return;
      _loadSessionData(force: false);
    });
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  /// Loads the session-scoped cubits.
  ///
  /// [force] reloads them regardless of their current state — used on a fresh
  /// sign-in. Otherwise only cubits that hold no data are (re)loaded: the ones
  /// that never started, and the ones left in error by a failed earlier attempt.
  void _loadSessionData({required bool force}) {
    if (!mounted) return;
    final authState = context.read<AuthBloc>().state;
    if (authState.status != AuthStatus.authenticated) return;

    // No usable session yet; the auth-state subscription re-primes once there
    // is one, so this is a wait rather than a failure.
    final userId = context.read<CurrentUserProvider>().currentUserIdOrNull;
    if (userId == null) return;

    final profileCubit = context.read<ProfileCubit>();
    if (force ||
        profileCubit.state.status == ProfileStatus.initial ||
        profileCubit.state.status == ProfileStatus.error) {
      profileCubit.loadProfile();
    }

    final settingsCubit = context.read<SettingsCubit>();
    if (force ||
        settingsCubit.state.status == SettingsStatus.initial ||
        settingsCubit.state.status == SettingsStatus.error) {
      settingsCubit.load(forceRefresh: true);
    }

    final propertyCubit = context.read<PropertyContextCubit>();
    if (force ||
        propertyCubit.state.status == PropertyContextStatus.initial ||
        propertyCubit.state.status == PropertyContextStatus.error) {
      propertyCubit.loadProperties();
    }

    final userSettingsCubit = context.read<UserSettingsCubit>();
    if (force ||
        userSettingsCubit.state.status == UserSettingsStatus.initial ||
        userSettingsCubit.state.status == UserSettingsStatus.error) {
      userSettingsCubit.bootstrap(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    BuildContext? navigatorContext;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              _loadSessionData(force: true);
              return;
            }

            if (state.status == AuthStatus.unauthenticated) {
              context.read<ProfileCubit>().reset();
              context.read<SettingsCubit>().reset();
              context.read<PropertyContextCubit>().reset();
              context.read<UserSettingsCubit>().reset();
              context.read<ThemeCubit>().resetToDefault();
            }
          },
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.error != current.error,
          listener: (context, state) async {
            if (state.status != ProfileStatus.error &&
                state.status != ProfileStatus.requiresSignOut) {
              return;
            }

            final error = state.error;
            if (error == null) return;

            final appError = AppError.fromDomain(context, error);
            final shouldSignOut =
                state.status == ProfileStatus.requiresSignOut ||
                appError.requiresLogout;
            if (shouldSignOut) {
              context.read<AuthBloc>().add(const AuthEvent.logout());
            }

            final ctx = navigatorContext ?? context;
            if (!ctx.mounted) return;
            await showAppError(ctx, appError);
          },
        ),
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) =>
              previous.settings?.languageCode != current.settings?.languageCode,
          listener: (context, state) {
            final languageCode = state.settings?.languageCode?.trim();
            if (languageCode == null || languageCode.isEmpty) return;
            final current = context.read<LanguageCubit>().state.languageCode;
            if (current == languageCode) return;
            context.read<LanguageCubit>().changeLang(context, languageCode);
          },
        ),
        // Keeps the live locale in sync with the per-user interface-language
        // preference, wherever it is changed (profile modal, settings page).
        BlocListener<UserSettingsCubit, UserSettingsState>(
          listenWhen: (previous, current) =>
              previous.settings?.languageCode != current.settings?.languageCode,
          listener: (context, state) {
            final languageCode = state.settings?.languageCode?.trim();
            if (languageCode == null || languageCode.isEmpty) return;
            final current = context.read<LanguageCubit>().state.languageCode;
            if (current == languageCode) return;
            context.read<LanguageCubit>().changeLang(context, languageCode);
          },
        ),
      ],
      child: Builder(
        builder: (ctx) {
          navigatorContext = ctx;
          return widget.child;
        },
      ),
    );
  }
}
