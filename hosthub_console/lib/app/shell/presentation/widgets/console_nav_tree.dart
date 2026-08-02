import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/core/l10n/l10n.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/portfolio/domain/portfolio_chrome.dart';
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
///
/// A one-property account gets the collapsed shape from §5 — read off
/// [PortfolioChrome], and still from this one builder: the group labels change,
/// the property node goes away and its sections move up a level, but the
/// entries, their handlers and their routes are the same ones.
List<StyledNavGroup> buildConsoleNavGroups({
  required S s,
  required ConsoleRoute route,
  required List<ConsoleNavProperty> properties,
  required void Function(String path) onNavigate,
  required VoidCallback onAddProperty,
  int unreadMessageCount = 0,
}) {
  final openPropertyId = route.propertyId;
  final chrome = PortfolioChrome(propertyCount: properties.length);
  final onlyProperty = chrome.isSingleProperty ? properties.single : null;

  return [
    StyledNavGroup(
      // "Verhuur" for one property: there is no portfolio to speak of, and
      // calling it one would promise a scope the account does not have.
      label: chrome.isSingleProperty
          ? s.navGroupSingleProperty
          : s.navGroupPortfolio,
      entries: [
        StyledNavItem(
          icon: Icons.mark_email_unread_outlined,
          label: s.inboxTitle,
          selected: route.portfolioSection == PortfolioSection.messages,
          onTap: () => onNavigate(ConsoleRoute.messagesPath),
          // A conversation waiting on the owner is the only state this screen
          // should shout about; at zero the badge is gone rather than a `0`.
          badge: unreadMessageCount > 0 ? unreadMessageCount.toString() : null,
        ),
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
    if (onlyProperty != null)
      StyledNavGroup(
        // The group label is the property's name: with one property, a heading
        // reading "Properties · 1" would head a list of one.
        label: onlyProperty.name,
        // A proper name, so it keeps its own case — the micro-label treatment is
        // for headings like PORTFOLIO, not for "Trysil Panorama".
        uppercaseLabel: false,
        // Its four screens sit flat at the top level and are always there —
        // nothing to expand, so nothing that could be collapsed.
        entries: _propertySections(
          s: s,
          property: onlyProperty,
          route: route,
          onNavigate: onNavigate,
        ),
      )
    else
      StyledNavGroup(
        label: s.navGroupProperties,
        count: properties.length.toString(),
        // The group label is a destination of its own: a plain list of the
        // properties. A convenience, never a step you must pass through.
        onLabelTap: () => onNavigate(ConsoleRoute.propertiesPath),
        labelSelected: route.isPropertiesList,
        // Adding a property is rare enough that it must not take a row of its
        // own next to Berichten and Boekingen, and general enough that it
        // should not be reachable only from the list — so it rides along with
        // the heading that already counts them. Same modal as the list's own
        // add row: one flow, two ways in.
        action: StyledNavGroupAction(
          icon: Icons.add,
          onTap: onAddProperty,
          tooltip: s.propertiesListAdd,
        ),
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
      // Two destinations, split by the question the owner actually has: does
      // this hold for all my properties, or is it about the organisation? The
      // word "accountinstellingen" is gone — it named a bucket, not a screen.
      entries: [
        StyledNavItem(
          icon: Icons.tune,
          label: s.navAccountDefaults,
          selected: route.accountSection == AccountSection.defaults,
          onTap: () => onNavigate(ConsoleRoute.accountDefaultsPath),
        ),
        StyledNavItem(
          icon: Icons.account_circle_outlined,
          label: s.navAccount,
          selected: route.accountSection == AccountSection.account,
          onTap: () => onNavigate(ConsoleRoute.accountPath),
        ),
      ],
    ),
  ];
}

/// The four screens of one property, in the order the design lists them.
///
/// The same entries whether they hang under a property node or sit flat in a
/// one-property account — only where they are rendered differs.
List<StyledNavItem> _propertySections({
  required S s,
  required ConsoleNavProperty property,
  required ConsoleRoute route,
  required void Function(String path) onNavigate,
}) {
  return [
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
    leading: PropertyChip(abbreviation: property.abbreviation, filled: isOpen),
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
    children: _propertySections(
      s: s,
      property: property,
      route: route,
      onNavigate: onNavigate,
    ),
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
