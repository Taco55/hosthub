import 'package:flutter/material.dart';
import 'package:app_errors/app_errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/application/site_context_cubit.dart';
import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

class SitesPage extends StatefulWidget {
  const SitesPage({super.key});

  @override
  State<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  late Future<List<SiteSummary>> _futureSites;
  bool _creating = false;
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  void _loadSites() {
    final repo = context.read<CmsRepository>();
    _futureSites = repo.fetchSites();
  }

  String _siteContentRoute(SiteSummary site) {
    final nameSegment = _toRouteSegment(site.name);
    return '/sites/$nameSegment/${site.id}';
  }

  String _toRouteSegment(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'site';
    final normalized = trimmed
        .replaceAll('/', '-')
        .replaceAll(RegExp(r'\s+'), '-');
    return Uri.encodeComponent(normalized);
  }

  /// Delegates to [SiteContextCubit.resolveSiteFor] rather than keeping a
  /// second copy: this page redirects to a site while the sidebar scopes to
  /// one, and the two disagreeing is worse than either being wrong.
  SiteSummary _resolvePreferredSite(
    List<SiteSummary> sites,
    PropertySummary? currentProperty,
  ) {
    if (sites.isEmpty) {
      throw StateError('Cannot resolve preferred site for an empty list.');
    }
    return SiteContextCubit.resolveSiteFor(sites, currentProperty);
  }

  Future<void> _createSite() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final repo = context.read<CmsRepository>();
      final propertyName = context
          .read<PropertyContextCubit>()
          .state
          .currentProperty
          ?.name;
      final name = propertyName ?? 'My Website';
      await repo.createSite(
        name: name,
        defaultLocale: 'nl',
        locales: ['nl', 'en', 'no'],
      );
      if (!mounted) return;
      // Reload and let the redirect logic handle navigation
      _redirected = false;
      setState(_loadSites);
    } catch (error, stack) {
      if (!mounted) return;
      final domainError = error is DomainError
          ? error
          : DomainError.from(error, stack: stack);
      await showAppError(context, AppError.fromDomain(context, domainError));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PropertyContextCubit, PropertyContextState>(
      listenWhen: (previous, current) =>
          previous.currentProperty?.id != current.currentProperty?.id,
      listener: (context, state) {
        _redirected = false;
        setState(_loadSites);
      },
      child: FutureBuilder<List<SiteSummary>>(
        future: _futureSites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return StyledWebPageScaffold(
              title: context.s.sitesTitle,
              leftChild: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return StyledWebPageScaffold(
              title: context.s.sitesTitle,
              leftChild: Center(
                child: Text(
                  context.s.sitesLoadFailed(snapshot.error.toString()),
                ),
              ),
            );
          }

          final sites = snapshot.data ?? [];

          // Auto-redirect to the site that best matches the selected property.
          if (sites.isNotEmpty && !_redirected) {
            final currentProperty = context
                .read<PropertyContextCubit>()
                .state
                .currentProperty;
            final preferredSite = _resolvePreferredSite(sites, currentProperty);
            _redirected = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.go(_siteContentRoute(preferredSite));
            });
            return StyledWebPageScaffold(
              title: context.s.sitesTitle,
              leftChild: const Center(child: CircularProgressIndicator()),
            );
          }

          // No sites – show create button
          return StyledWebPageScaffold(
            title: context.s.sitesTitle,
            leftChild: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.s.sitesEmpty,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  StyledButton(
                    title: context.s.sitesCreateButton,
                    onPressed: _creating ? null : _createSite,
                    minHeight: 44,
                    leftIconData: Icons.add,
                    showLeftIcon: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
