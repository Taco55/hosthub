import 'package:flutter/foundation.dart';

/// The two portfolio destinations: about the whole account, filterable.
enum PortfolioSection { bookings, revenue }

/// The four destinations that are about exactly one property.
enum PropertySection { overview, website, pricing, settings }

/// Where the console is, in the terms the sidebar needs.
///
/// The sidebar is the scope selector, and which property it shows expanded is
/// **derived from here** — there is no separate "open property" state to keep in
/// step with the route. That is what makes a deep link to
/// `/properties/3/pricing` render property 3 expanded with Prijzen active
/// without anyone having navigated there.
@immutable
class ConsoleRoute {
  const ConsoleRoute._({
    this.portfolioSection,
    this.propertyId,
    this.propertySection,
    this.isPropertiesList = false,
    this.isAccount = false,
  });

  const ConsoleRoute.portfolio(PortfolioSection section)
    : this._(portfolioSection: section);

  const ConsoleRoute.propertiesList() : this._(isPropertiesList: true);

  const ConsoleRoute.property(int propertyId, PropertySection section)
    : this._(propertyId: propertyId, propertySection: section);

  const ConsoleRoute.account() : this._(isAccount: true);

  /// Anywhere the tree does not describe — the admin pages, the legacy site
  /// routes. Nothing is selected and no property is expanded, which is correct:
  /// the user is not in the tree.
  static const ConsoleRoute elsewhere = ConsoleRoute._();

  final PortfolioSection? portfolioSection;

  /// The property this route is about, or null for a portfolio or account
  /// destination. The one property the sidebar renders expanded.
  final int? propertyId;

  final PropertySection? propertySection;
  final bool isPropertiesList;
  final bool isAccount;

  /// Whether a property is open — exactly one, ever, because a route carries one
  /// property id.
  bool get hasOpenProperty => propertyId != null;

  static const String bookingsPath = '/bookings';
  static const String revenuePath = '/revenue';
  static const String propertiesPath = '/properties';
  static const String accountPath = '/account';

  /// The path of one property's section.
  static String propertyPath(int propertyId, PropertySection section) =>
      '$propertiesPath/$propertyId/${propertySectionSegment(section)}';

  /// Opening a property lands on its Overzicht — one click, no index page.
  static String propertyRootPath(int propertyId) =>
      propertyPath(propertyId, PropertySection.overview);

  static String propertySectionSegment(PropertySection section) {
    switch (section) {
      case PropertySection.overview:
        return 'overview';
      case PropertySection.website:
        return 'website';
      case PropertySection.pricing:
        return 'pricing';
      case PropertySection.settings:
        return 'settings';
    }
  }

  static PropertySection? propertySectionFromSegment(String segment) {
    for (final section in PropertySection.values) {
      if (propertySectionSegment(section) == segment) return section;
    }
    return null;
  }

  /// Read a location back into the tree's terms.
  ///
  /// Unrecognised paths return [elsewhere] rather than guessing: a wrong guess
  /// would highlight a destination the user is not on.
  factory ConsoleRoute.parse(String location) {
    final path = location.split('?').first.split('#').first;
    final segments = path
        .split('/')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);

    if (segments.isEmpty) return elsewhere;

    switch (segments.first) {
      case 'bookings':
        return const ConsoleRoute.portfolio(PortfolioSection.bookings);
      case 'revenue':
        return const ConsoleRoute.portfolio(PortfolioSection.revenue);
      case 'account':
        return const ConsoleRoute.account();
      case 'properties':
        if (segments.length == 1) return const ConsoleRoute.propertiesList();
        final propertyId = int.tryParse(segments[1]);
        if (propertyId == null) return const ConsoleRoute.propertiesList();
        final section = segments.length > 2
            ? propertySectionFromSegment(segments[2])
            : PropertySection.overview;
        // A property path without a section, or with one that does not exist, is
        // still that property — its Overzicht.
        return ConsoleRoute.property(
          propertyId,
          section ?? PropertySection.overview,
        );
      default:
        return elsewhere;
    }
  }

  /// The path this route describes.
  String get path {
    final section = portfolioSection;
    if (section != null) {
      return section == PortfolioSection.bookings ? bookingsPath : revenuePath;
    }
    final propertyId = this.propertyId;
    if (propertyId != null) {
      return propertyPath(
        propertyId,
        propertySection ?? PropertySection.overview,
      );
    }
    if (isPropertiesList) return propertiesPath;
    if (isAccount) return accountPath;
    return '';
  }

  /// The same route against the properties that currently exist.
  ///
  /// A property that was removed, archived, or fell outside the account is
  /// replaced by the first one; an account with no properties falls back to the
  /// list. Without this the sidebar shows property A while the body loads
  /// property B's data — found in review, hence the clamp rather than a guard at
  /// each screen.
  ConsoleRoute clampedTo(List<int> existingPropertyIds) {
    final propertyId = this.propertyId;
    if (propertyId == null) return this;
    if (existingPropertyIds.contains(propertyId)) return this;
    if (existingPropertyIds.isEmpty) return const ConsoleRoute.propertiesList();
    return ConsoleRoute.property(
      existingPropertyIds.first,
      propertySection ?? PropertySection.overview,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsoleRoute &&
          runtimeType == other.runtimeType &&
          portfolioSection == other.portfolioSection &&
          propertyId == other.propertyId &&
          propertySection == other.propertySection &&
          isPropertiesList == other.isPropertiesList &&
          isAccount == other.isAccount;

  @override
  int get hashCode => Object.hash(
    portfolioSection,
    propertyId,
    propertySection,
    isPropertiesList,
    isAccount,
  );

  @override
  String toString() => 'ConsoleRoute(${path.isEmpty ? 'elsewhere' : path})';
}
