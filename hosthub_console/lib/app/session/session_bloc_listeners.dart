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
  @override
  void initState() {
    super.initState();
    Future.microtask(_primeSessionData);
  }

  void _primeSessionData() {
    if (!mounted) return;
    final authState = context.read<AuthBloc>().state;
    if (authState.status != AuthStatus.authenticated) return;

    final profileCubit = context.read<ProfileCubit>();
    if (profileCubit.state.status == ProfileStatus.initial) {
      profileCubit.loadProfile();
    }

    final settingsCubit = context.read<SettingsCubit>();
    if (settingsCubit.state.status == SettingsStatus.initial) {
      settingsCubit.load(forceRefresh: true);
    }

    final propertyCubit = context.read<PropertyContextCubit>();
    if (propertyCubit.state.status == PropertyContextStatus.initial) {
      propertyCubit.loadProperties();
    }

    final userSettingsCubit = context.read<UserSettingsCubit>();
    if (userSettingsCubit.state.status == UserSettingsStatus.initial) {
      final userId = context.read<CurrentUserProvider>().currentUserId;
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
              context.read<ProfileCubit>().loadProfile();
              context.read<SettingsCubit>().load(forceRefresh: true);
              context.read<PropertyContextCubit>().loadProperties();
              final userId = context.read<CurrentUserProvider>().currentUserId;
              context.read<UserSettingsCubit>().bootstrap(userId: userId);
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
