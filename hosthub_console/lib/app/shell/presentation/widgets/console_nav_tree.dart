import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/features/properties/properties.dart';

/// One property as the tree renders it.
@immutable
class ConsoleNavProperty {
  const ConsoleNavProperty({
    required this.id,
    required this.name,
    required this.abbreviation,
    this.overriddenFieldCount = 0,
  });

  final int id;
  final String name;

  /// The two-letter chip. An identifier in the interface, so it is assigned
  /// across the account rather than derived per property — see
  /// [uniquePropertyAbbreviations].
  final String abbreviation;

  /// How many channel fields this property states itself. The `[2]` badge on
  /// Prijzen, and the only at-a-glance signal of which properties deviate from
  /// the account — absent at zero, not a zero.
  final int overriddenFieldCount;
}

/// The console's navigation, as one tree.
///
/// The sidebar *is* the scope selector: there is no global property switcher and
/// no "you are now in property X" mode. Which property renders expanded comes
/// from [route] — deep-linking a property's Prijzen therefore arrives with that
/// property open and Prijzen active, without anything having navigated.
///
/// Two rules the design states outright, and this builder keeps:
/// the portfolio entries stay visible and tappable while a property is open, and
/// nothing is ever disabled. Every destination is always reachable.
List<StyledNavGroup> buildConsoleNavGroups({
  required S s,
  required ConsoleRoute route,
  required List<ConsoleNavProperty> properties,
  required void Function(String path) onNavigate,
}) {
  final openPropertyId = route.propertyId;

  return [
    StyledNavGroup(
      label: s.navGroupPortfolio,
      entries: [
        StyledNavItem(
          icon: Icons.calendar_month_outlined,
          label: s.navBookings,
          selected: route.portfolioSection == PortfolioSection.bookings,
          onTap: () => onNavigate(ConsoleRoute.bookingsPath),
        ),
        StyledNavItem(
          icon: Icons.bar_chart,
          label: s.menuRevenue,
          selected: route.portfolioSection == PortfolioSection.revenue,
          onTap: () => onNavigate(ConsoleRoute.revenuePath),
        ),
      ],
    ),
    StyledNavGroup(
      label: s.navGroupProperties,
      count: properties.length.toString(),
      // The group label is a destination of its own: a plain list of the
      // properties. A convenience, never a step you must pass through.
      onLabelTap: () => onNavigate(ConsoleRoute.propertiesPath),
      labelSelected: route.isPropertiesList,
      entries: [
        for (final property in properties)
          _propertyBranch(
            s: s,
            property: property,
            route: route,
            isOpen: property.id == openPropertyId,
            onNavigate: onNavigate,
          ),
      ],
    ),
    StyledNavGroup(
      label: s.navGroupAccount,
      entries: [
        StyledNavItem(
          icon: Icons.dashboard_outlined,
          label: s.navAccountSettings,
          selected: route.isAccount,
          onTap: () => onNavigate(ConsoleRoute.accountPath),
        ),
      ],
    ),
  ];
}

StyledNavBranch _propertyBranch({
  required S s,
  required ConsoleNavProperty property,
  required ConsoleRoute route,
  required bool isOpen,
  required void Function(String path) onNavigate,
}) {
  return StyledNavBranch(
    label: property.name,
    leading: _PropertyChip(abbreviation: property.abbreviation, open: isOpen),
    // Exactly one property is expanded: the one in the route. Nothing else can
    // be, because a route carries one property id.
    expanded: isOpen,
    selected: isOpen,
    tooltip: property.name,
    // One click opens a property: it navigates to its Overzicht *and* expands.
    // Clicking the open one again collapses it, which means going back to the
    // list — the only place that is not inside a property.
    onTap: () => onNavigate(
      isOpen
          ? ConsoleRoute.propertiesPath
          : ConsoleRoute.propertyRootPath(property.id),
    ),
    children: [
      _propertySection(
        s: s,
        property: property,
        route: route,
        section: PropertySection.overview,
        icon: Icons.home_work_outlined,
        label: s.navPropertyOverview,
        onNavigate: onNavigate,
      ),
      _propertySection(
        s: s,
        property: property,
        route: route,
        section: PropertySection.website,
        icon: Icons.language,
        label: s.navPropertyWebsite,
        onNavigate: onNavigate,
      ),
      _propertySection(
        s: s,
        property: property,
        route: route,
        section: PropertySection.pricing,
        icon: Icons.sell_outlined,
        label: s.menuPricing,
        onNavigate: onNavigate,
        // Absent at zero rather than a `0`: the badge exists to point out the
        // properties that deviate.
        badge: property.overriddenFieldCount > 0
            ? property.overriddenFieldCount.toString()
            : null,
      ),
      _propertySection(
        s: s,
        property: property,
        route: route,
        section: PropertySection.settings,
        icon: Icons.settings_outlined,
        label: s.navPropertySiteSettings,
        onNavigate: onNavigate,
      ),
    ],
  );
}

StyledNavItem _propertySection({
  required S s,
  required ConsoleNavProperty property,
  required ConsoleRoute route,
  required PropertySection section,
  required IconData icon,
  required String label,
  required void Function(String path) onNavigate,
  String? badge,
}) {
  return StyledNavItem(
    icon: icon,
    label: label,
    selected:
        route.propertyId == property.id && route.propertySection == section,
    onTap: () => onNavigate(ConsoleRoute.propertyPath(property.id, section)),
    badge: badge,
  );
}

/// The two-letter property chip: the account's tint normally, the primary fill
/// while that property is open.
class _PropertyChip extends StatelessWidget {
  const _PropertyChip({required this.abbreviation, required this.open});

  final String abbreviation;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scope = StyledSideMenuScope.maybeOf(context);
    final baseFg = scope?.foregroundColor ?? scheme.onPrimaryContainer;

    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: open ? scheme.primary : baseFg.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        abbreviation,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: open ? scheme.onPrimary : baseFg,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// The tree's properties, from the account's property rows.
///
/// The abbreviations are assigned together so no two properties share one, and
/// the override counts come from the one settings resolver.
List<ConsoleNavProperty> consoleNavProperties({
  required List<PropertySummary> properties,
  required ChannelSettingsResolver channelSettings,
}) {
  final abbreviations = uniquePropertyAbbreviations([
    for (final property in properties) (id: property.id, name: property.name),
  ]);

  return [
    for (final property in properties)
      ConsoleNavProperty(
        id: property.id,
        name: property.name,
        abbreviation: abbreviations[property.id] ?? '??',
        overriddenFieldCount: channelSettings.overriddenFieldCount(property.id),
      ),
  ];
}
