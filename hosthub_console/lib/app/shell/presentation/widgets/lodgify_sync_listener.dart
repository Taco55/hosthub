import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/user_settings/user_settings.dart';

/// Shows what a Lodgify sync found, wherever it was started.
///
/// The sync is account-wide and can be triggered from two places (the Lodgify
/// row on Account, the *Uit Lodgify ophalen* route of *Property toevoegen*), so
/// the result modal hangs here — above both — instead of being wired up twice
/// and drifting apart, which is what happened to the version this replaces.
class LodgifySyncListener extends StatelessWidget {
  const LodgifySyncListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserSettingsCubit, UserSettingsState>(
      listenWhen: (previous, current) =>
          previous.syncPlan != current.syncPlan && current.syncPlan != null,
      listener: (context, state) async {
        final plan = state.syncPlan;
        if (plan == null) return;

        final apply = await showLodgifySyncModal(context, plan: plan);
        if (!context.mounted) return;

        final settingsCubit = context.read<UserSettingsCubit>();
        if (!apply) {
          settingsCubit.dismissSyncPlan();
          return;
        }

        final applied = await settingsCubit.applySyncPlan();
        if (!context.mounted) return;
        // The listings arrived as properties, so the list has to be reread
        // whatever the outcome — the rail and every portfolio screen read it.
        await context.read<PropertyContextCubit>().loadProperties();
        if (!context.mounted || applied == 0) return;

        showStyledToast(
          context,
          type: ToastificationType.success,
          description: context.s.lodgifySyncApplied(applied),
          // The result belongs to the list, not to the screen that asked for
          // the sync.
          action: ToastAction(
            label: context.s.lodgifySyncGoToProperties,
            onPressed: () => context.go(ConsoleRoute.propertiesPath),
          ),
        );
      },
      child: child,
    );
  }
}
