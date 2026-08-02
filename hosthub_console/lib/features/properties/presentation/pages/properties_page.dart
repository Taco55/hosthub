import 'package:app_errors/app_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/portfolio/domain/portfolio_chrome.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/reservations/application/reservations_cubit.dart';

/// The account's properties, and the one place a property is added or removed.
///
/// Properties own this list (handoff §8.5): adding one used to live on Account,
/// next to the connection that normally creates them, where an owner looking for
/// "add a home" had to go past their invoices to find it — with `ID` and
/// `Lodgify ID` columns that are internal keys.
///
/// Each row states its **origin**, because origin decides what may be done to
/// it: a synced property's name and prices belong to Lodgify and the next sync
/// overwrites them, so it can only be *unlinked*; a manual one is the owner's
/// and can really be deleted.
class PropertiesPage extends StatelessWidget {
  const PropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyContextCubit, PropertyContextState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) async {
        final error = state.error;
        if (error == null) return;
        await showAppError(context, AppError.fromDomain(context, error));
        if (!context.mounted) return;
        context.read<PropertyContextCubit>().clearError();
      },
      builder: (context, state) {
        final properties = state.properties;
        final channelSettings = ChannelSettingsResolver.forProperties(
          accountDefaults: context
              .watch<AccountChannelDefaultsCubit>()
              .state
              .defaults,
          properties: channelOverridesOf(properties),
        );
        final abbreviations = uniquePropertyAbbreviations([
          for (final property in properties)
            (id: property.id, name: property.name),
        ]);
        // Whatever is loaded, per property. The portfolio pages own the
        // authoritative counts; this is the same set, grouped.
        final bookingsByProperty = <int, int>{};
        for (final booking
            in context.watch<ReservationsCubit>().state.entries) {
          bookingsByProperty.update(
            booking.propertyId,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        }

        // §5: the route stays reachable by link, so the page keeps working for a
        // one-property account — its crumb just stops claiming a portfolio.
        final chrome = PortfolioChrome(propertyCount: properties.length);
        final isLoading =
            state.status == PropertyContextStatus.loading && properties.isEmpty;

        return StyledWebPageScaffold(
          decorateLeftPane: false,
          overline: chrome.isSingleProperty
              ? context.s.navGroupSingleProperty
              : context.s.navGroupProperties,
          title: context.s.propertiesListHeading,
          leftChild: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (properties.isEmpty)
                // The two routes of *Property toevoegen* are the empty state:
                // one offer, not a second screen that competes with it.
                StyledEmptyState(
                  iconData: Icons.add_home_outlined,
                  title: context.s.propertiesListEmpty,
                  description: context.s.propertiesEmptyBody,
                  actionLabel: context.s.propertiesListAdd,
                  onAction: () => showAddPropertyModal(context),
                )
              else
                StyledSection(
                  isFirstSection: true,
                  horizontalPadding: 0,
                  // No header: the page title already says Properties. The
                  // footnote is what the reader needs — why one row can only be
                  // unlinked and another deleted.
                  footer: context.s.propertiesListFooter,
                  children: [
                    for (final property in properties)
                      _PropertyRow(
                        property: property,
                        abbreviation: abbreviations[property.id] ?? '??',
                        bookingCount: bookingsByProperty[property.id] ?? 0,
                        overriddenFieldCount: channelSettings
                            .overriddenFieldCount(property.id),
                      ),
                    // The add affordance as the list's last row — the same
                    // pattern as `Taal toevoegen` and `Lid uitnodigen`, so
                    // "add one" always looks the same in this console.
                    StyledTile(
                      leading: Icon(Icons.add, color: context.colors.primary),
                      title: context.s.propertiesListAdd,
                      titleColor: context.colors.primary,
                      onTap: () => showAddPropertyModal(context),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PropertyRow extends StatelessWidget with StyledTileLike {
  const _PropertyRow({
    required this.property,
    required this.abbreviation,
    required this.bookingCount,
    required this.overriddenFieldCount,
  });

  final PropertySummary property;
  final String abbreviation;
  final int bookingCount;
  final int overriddenFieldCount;

  bool get _isSynced => (property.lodgifyId ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return StyledTile(
      leading: PropertyChip(
        abbreviation: abbreviation,
        size: 32,
        borderRadius: 8,
      ),
      title: property.name,
      subtitle: _subtitle(context),
      // Origin is a column, not a second list.
      value: _isSynced
          ? StatusPill(
              label: context.s.propertyOriginLodgify,
              tone: StatusPillTone.positive,
            )
          : StatusPill(label: context.s.propertyOriginManual),
      trailing: StyledToolbarButton(
        iconData: _isSynced ? Icons.link_off : Icons.delete_outline,
        destructive: true,
        tooltip: _isSynced
            ? context.s.propertyUnlinkTooltip
            : context.s.propertyDeleteTooltip,
        onPressed: () => _confirmRemoval(context),
      ),
      showChevron: true,
      onTap: () => context.go(ConsoleRoute.propertyRootPath(property.id)),
    );
  }

  /// `12 boekingen · Volgt account` or `… · 2 eigen waarden`.
  String _subtitle(BuildContext context) {
    final s = context.s;
    final bookings = s.propertiesListBookingCount(bookingCount);
    final scope = overriddenFieldCount == 0
        ? s.propertiesListFollowsAccount
        : s.propertiesListOwnValues(overriddenFieldCount);
    return '$bookings · $scope';
  }

  /// Unlink or delete — the same button, two different promises, so the dialog
  /// says which one it is keeping.
  void _confirmRemoval(BuildContext context) {
    final cubit = context.read<PropertyContextCubit>();
    showStyledAlertDialog(
      context,
      title: _isSynced
          ? context.s.propertyUnlinkTitle(property.name)
          : context.s.propertyDeleteTitle(property.name),
      message: _isSynced
          ? context.s.propertyUnlinkMessage
          : context.s.propertyDeleteMessage,
      actionText: _isSynced
          ? context.s.propertyUnlinkAction
          : context.s.deleteButton,
      dismissText: context.s.cancelButton,
      isDestructiveAction: true,
      onAction: () => _isSynced
          ? cubit.unlinkProperty(property)
          : cubit.deleteProperty(property),
    );
  }
}
