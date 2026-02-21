import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/app/shell/presentation/widgets/console_page_scaffold.dart';
import 'package:hosthub_console/shared/widgets/widgets.dart';

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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SiteSummary>>(
      future: _futureSites,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ConsolePageScaffold(
            title: context.s.sitesTitle,
            description: context.s.sitesDescription,
            leftChild: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return ConsolePageScaffold(
            title: context.s.sitesTitle,
            description: context.s.sitesDescription,
            leftChild: Center(
              child: Text(
                context.s.sitesLoadFailed(snapshot.error.toString()),
              ),
            ),
          );
        }

        final sites = snapshot.data ?? [];

        // Auto-redirect to the first site's content page
        if (sites.isNotEmpty && !_redirected) {
          _redirected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/sites/${sites.first.id}');
          });
          return ConsolePageScaffold(
            title: context.s.sitesTitle,
            description: context.s.sitesDescription,
            leftChild: const Center(child: CircularProgressIndicator()),
          );
        }

        // No sites – show create button
        return ConsolePageScaffold(
          title: context.s.sitesTitle,
          description: context.s.sitesDescription,
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
    );
  }
}
