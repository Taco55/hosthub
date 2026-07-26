import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/portfolio/domain/portfolio_chrome.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/reservations/application/reservations_cubit.dart';
import 'package:hosthub_console/features/server_settings/application/server_settings_cubit.dart';
import 'package:hosthub_console/features/server_settings/domain/admin_settings.dart';

/// The account's properties as a plain list: chip, name, how many bookings, and
/// whether it follows the account or states its own channel values.
///
/// A convenience, not a step. Every property is reachable straight from the
/// sidebar tree; this page exists because the Properties group label needs
/// somewhere to lead and because "which of my properties deviate" is easier to
/// read down a column than across a rail.
class PropertiesPage extends StatelessWidget {
  const PropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return BlocBuilder<PropertyContextCubit, PropertyContextState>(
      builder: (context, state) {
        final properties = state.properties;
        final adminSettings =
            context.watch<ServerSettingsCubit>().state.settings ??
            AdminSettings.defaults();
        final channelSettings = ChannelSettingsResolver(
          accountDefaults: AccountChannelDefaults.fromCommissionPercentages(
            booking: adminSettings.bookingChannelFeePercentage,
            airbnb: adminSettings.airbnbChannelFeePercentage,
            other: adminSettings.otherChannelFeePercentage,
          ),
          overridesByPropertyId: {
            for (final property in properties)
              property.id: property.channelOverrides,
          },
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

        return StyledWebPageScaffold(
          decorateLeftPane: false,
          overline: chrome.isSingleProperty
              ? s.navGroupSingleProperty
              : s.navGroupProperties,
          title: s.propertiesListHeading,
          leftChild: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.propertiesListIntro,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: context.styledSpacing.lg),
              if (state.status == PropertyContextStatus.loading &&
                  properties.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (properties.isEmpty)
                Text(
                  s.propertiesListEmpty,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                StyledSection(
                  isFirstSection: true,
                  horizontalPadding: 0,
                  header: s.propertiesListHeading,
                  children: [
                    for (final property in properties)
                      StyledTile(
                        leading: PropertyChip(
                          abbreviation: abbreviations[property.id] ?? '??',
                          size: 32,
                        ),
                        title: property.name,
                        subtitle: _subtitleFor(
                          s: s,
                          bookingCount: bookingsByProperty[property.id] ?? 0,
                          overriddenFieldCount: channelSettings
                              .overriddenFieldCount(property.id),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(
                          ConsoleRoute.propertyRootPath(property.id),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  /// `12 boekingen · Volgt account` or `… · 2 eigen waarden`.
  String _subtitleFor({
    required S s,
    required int bookingCount,
    required int overriddenFieldCount,
  }) {
    final bookings = s.propertiesListBookingCount(bookingCount);
    final scope = overriddenFieldCount == 0
        ? s.propertiesListFollowsAccount
        : s.propertiesListOwnValues(overriddenFieldCount);
    return '$bookings · $scope';
  }
}
