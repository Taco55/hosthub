import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/navigation/console_route.dart';
import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/sites/sites.dart';
import 'package:hosthub_console/features/website_editor/website_editor.dart';

/// The four property-scoped screens, behind the one route that names a property.
///
/// Two jobs, both about scope rather than about any screen:
///
/// * **The property comes from the route.** Overzicht and Prijzen are handed the
///   id, so they cannot read a different property than the one the sidebar shows
///   expanded — not even for the frame after a navigation.
/// * **The open property is clamped to one that exists.** Remove, archive, or
///   lose access to the property in the path and this lands on the first one
///   instead of on a screen that loads nothing. Without the clamp the sidebar
///   shows property A while the body shows B's data.
class PropertySectionPage extends StatefulWidget {
  const PropertySectionPage({
    super.key,
    required this.propertyId,
    required this.section,
  });

  final int propertyId;
  final PropertySection section;

  @override
  State<PropertySectionPage> createState() => _PropertySectionPageState();
}

class _PropertySectionPageState extends State<PropertySectionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPropertyContext());
  }

  @override
  void didUpdateWidget(covariant PropertySectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.propertyId != widget.propertyId) _syncPropertyContext();
  }

  /// Point the property-scoped machinery at the route's property.
  ///
  /// Website and Site-instellingen reach their content through the site that
  /// belongs to a property, and that resolution hangs off the selected property.
  /// The route selects it here, in one place, rather than each screen deciding
  /// for itself.
  void _syncPropertyContext() {
    if (!mounted) return;
    final cubit = context.read<PropertyContextCubit>();
    final property = cubit.state.properties
        .where((candidate) => candidate.id == widget.propertyId)
        .firstOrNull;
    if (property == null) return;
    cubit.selectProperty(property);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyContextCubit, PropertyContextState>(
      listener: (context, state) => _clampToExistingProperty(context, state),
      builder: (context, state) {
        if (state.status == PropertyContextStatus.initial ||
            state.status == PropertyContextStatus.loading) {
          return _scaffold(
            context,
            const Center(child: CircularProgressIndicator()),
          );
        }

        final property = state.properties
            .where((candidate) => candidate.id == widget.propertyId)
            .firstOrNull;
        if (property == null) {
          // The clamp in the listener is on its way; until it lands, say nothing
          // rather than showing another property's data under this one's name.
          return _scaffold(
            context,
            const Center(child: CircularProgressIndicator()),
          );
        }

        switch (widget.section) {
          case PropertySection.overview:
            return PropertyDetailsPage(propertyId: property.id);
          case PropertySection.pricing:
            return PropertyPricingPage(propertyId: property.id);
          case PropertySection.website:
            return _siteScreen(
              context,
              (siteId) => WebsiteEditorPage(siteId: siteId),
            );
          case PropertySection.settings:
            return _siteScreen(
              context,
              (siteId) => SiteSettingsPage(siteId: siteId),
            );
        }
      },
    );
  }

  /// A property that no longer exists gives way to the first one that does.
  void _clampToExistingProperty(
    BuildContext context,
    PropertyContextState state,
  ) {
    if (state.status != PropertyContextStatus.loaded) return;

    final existing = [for (final property in state.properties) property.id];
    final clamped = ConsoleRoute.property(
      widget.propertyId,
      widget.section,
    ).clampedTo(existing);
    if (clamped.propertyId == widget.propertyId) return;

    context.go(clamped.path);
  }

  /// The two screens that act on the property's *site* rather than on the
  /// property row, once that site is known.
  Widget _siteScreen(
    BuildContext context,
    Widget Function(String siteId) builder,
  ) {
    return BlocBuilder<SiteContextCubit, SiteContextState>(
      builder: (context, state) {
        final siteId = state.site?.id;
        if (siteId == null) {
          return _scaffold(
            context,
            state.status == SiteContextStatus.error
                ? Text(context.s.propertyDetailsEmpty)
                : const Center(child: CircularProgressIndicator()),
          );
        }
        return builder(siteId);
      },
    );
  }

  Widget _scaffold(BuildContext context, Widget child) {
    return StyledWebPageScaffold(
      decorateLeftPane: false,
      overline: _overlineFor(context, widget.section),
      title: _titleFor(context, widget.section),
      leftChild: child,
    );
  }

  String _overlineFor(BuildContext context, PropertySection section) {
    switch (section) {
      case PropertySection.overview:
        return context.s.navPropertyOverview;
      case PropertySection.website:
        return context.s.navPropertyWebsite;
      case PropertySection.pricing:
        return context.s.menuPricing;
      case PropertySection.settings:
        return context.s.navPropertySiteSettings;
    }
  }

  String _titleFor(BuildContext context, PropertySection section) =>
      _overlineFor(context, section);
}
