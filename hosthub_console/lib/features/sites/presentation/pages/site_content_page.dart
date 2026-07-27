import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:styled_widgets/styled_widgets.dart';
import 'package:web/web.dart' as web;

import 'package:hosthub_console/features/cms/cms.dart';
import 'package:hosthub_console/features/properties/properties.dart';
import 'package:hosthub_console/features/sites/presentation/widgets/content_section_renderer.dart';
import 'package:hosthub_console/core/widgets/widgets.dart';

class SiteContentPage extends StatefulWidget {
  const SiteContentPage({super.key, required this.siteId});

  final String siteId;

  @override
  State<SiteContentPage> createState() => _SiteContentPageState();
}

class _SiteContentPageState extends State<SiteContentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CmsCubit>().loadSiteContent(siteId: widget.siteId);
    });
  }

  @override
  void didUpdateWidget(covariant SiteContentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.siteId == widget.siteId) return;
    context.read<CmsCubit>().loadSiteContent(siteId: widget.siteId);
  }

  @override
  Widget build(BuildContext context) {
    return const _SiteContentBody();
  }
}

class _SiteContentBody extends StatelessWidget {
  const _SiteContentBody();

  String _resolvePageTitle(BuildContext context, CmsState state) {
    final propertyName = context
        .read<PropertyContextCubit>()
        .state
        .currentProperty
        ?.name
        .trim();
    if (propertyName != null && propertyName.isNotEmpty) {
      return propertyName;
    }

    final siteConfigName = _resolveSiteConfigName(state);
    if (siteConfigName != null) {
      return siteConfigName;
    }

    final siteName = state.site?.name.trim();
    if (siteName != null && siteName.isNotEmpty) {
      return siteName;
    }

    return context.s.cmsContentTitle;
  }

  String? _resolveSiteConfigName(CmsState state) {
    final siteConfigDocs = state.documents
        .where((doc) => doc.contentType == 'site_config')
        .toList();
    if (siteConfigDocs.isEmpty) return null;

    ContentDocument? pickByLocale(String? locale) {
      if (locale == null || locale.isEmpty) return null;
      for (final doc in siteConfigDocs) {
        if (doc.locale == locale) return doc;
      }
      return null;
    }

    final preferredDoc =
        pickByLocale(state.selectedLocale) ??
        pickByLocale(state.site?.defaultLocale) ??
        siteConfigDocs.first;
    // The page title follows what the owner is editing, draft included.
    final rawName = preferredDoc.editableContent['name'];
    if (rawName is! String) return null;
    final trimmed = rawName.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PropertyContextCubit, PropertyContextState>(
          listenWhen: (previous, current) =>
              previous.currentProperty?.id != current.currentProperty?.id &&
              previous.currentProperty != null,
          listener: (context, state) {
            final currentPath = GoRouterState.of(context).uri.path;
            if (currentPath == '/sites') return;
            context.go('/sites');
          },
        ),
      ],
      child: BlocBuilder<CmsCubit, CmsState>(
        builder: (context, state) {
          final pageTitle = _resolvePageTitle(context, state);

          if (state.status == CmsStatus.initial ||
              state.status == CmsStatus.loading) {
            return StyledWebPageScaffold(
              overline: context.s.sitesTitle,
              title: pageTitle,
              leftChild: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == CmsStatus.error) {
            return StyledWebPageScaffold(
              overline: context.s.sitesTitle,
              title: pageTitle,
              leftChild: Center(
                child: Text(
                  context.s.cmsLoadFailed(state.error?.message ?? ''),
                ),
              ),
            );
          }

          final docs = state.filteredDocuments;
          final locales = state.site?.locales ?? ['en'];
          final selectedLocale = state.selectedLocale ?? locales.first;
          final localeIndex = locales
              .indexOf(selectedLocale)
              .clamp(0, locales.length - 1);

          // Group documents by content_type
          final siteConfig = docs
              .where((d) => d.contentType == 'site_config')
              .toList();
          final cabin = docs.where((d) => d.contentType == 'cabin').toList();
          final pageHome = docs
              .where((d) => d.contentType == 'page' && d.slug == 'home')
              .toList();
          final pagePractical = docs
              .where((d) => d.contentType == 'page' && d.slug == 'practical')
              .toList();
          final pageArea = docs
              .where((d) => d.contentType == 'page' && d.slug == 'area')
              .toList();
          final pagePrivacy = docs
              .where((d) => d.contentType == 'page' && d.slug == 'privacy')
              .toList();
          final contactForm = docs
              .where((d) => d.contentType == 'contact_form')
              .toList();

          final showVersionPane = state.versionHistoryDocId != null;

          return StyledWebPageScaffold(
            // Design `.top`: the section crumb over the site's own name.
            overline: context.s.sitesTitle,
            title: pageTitle,
            primaryAction: StyledWebPageAction(
              label: state.isDirty || state.isSaving
                  ? context.s.cmsSaveDraftButton
                  : context.s.savedLabel,
              icon: Icons.save_outlined,
              enabled: state.isDirty && !state.isSaving,
              inProgress: state.isSaving,
              onPressed: state.isDirty
                  ? () => context.read<CmsCubit>().saveAllDrafts()
                  : null,
            ),
            actions: [
              StyledToolbarButton(
                iconData: Icons.settings_outlined,
                tooltip: context.s.siteSettingsTitle,
                onPressed: () {
                  final siteId = context.read<CmsCubit>().state.site?.id;
                  if (siteId != null) {
                    context.push('/sites/$siteId/settings');
                  }
                },
              ),
              const SizedBox(width: 8),
              StyledToolbarButton(
                iconData: Icons.group_outlined,
                tooltip: context.s.teamTitle,
                onPressed: () {
                  final siteId = context.read<CmsCubit>().state.site?.id;
                  if (siteId != null) {
                    context.push(
                      '/sites/$siteId/team?name=${Uri.encodeComponent(pageTitle)}',
                    );
                  }
                },
              ),
              if (state.isDirty || state.isPublishing)
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: StyledButton(
                    title: context.s.cmsPublishButton,
                    onPressed: () => _confirmPublish(context, state),
                    enabled: !state.isPublishing,
                    showProgressIndicatorWhenDisabled: state.isPublishing,
                    leftIconData: Icons.publish,
                    showLeftIcon: true,
                    minHeight: 40,
                  ),
                ),
            ],
            showRightPane: showVersionPane,
            // Preserves the old adapter's fixed 380px history pane; the lib
            // default would let the right pane fill the remaining width.
            rightPaneSize: const StyledPaneSize.fixed(380),
            rightChild: showVersionPane
                ? _VersionHistoryPane(
                    versions: state.versions ?? [],
                    documentId: state.versionHistoryDocId!,
                  )
                : null,
            bottom: _BottomBar(
              locales: locales,
              selectedIndex: localeIndex,
              previewUrl: state.previewUrl,
              isDirty: state.isDirty,
              onLocaleChanged: (index) {
                _handleLocaleChange(context, state, locales, index);
              },
            ),
            leftChild: docs.isEmpty
                ? Center(child: Text(context.s.cmsNoContent))
                : ListView(
                    padding: const EdgeInsets.only(top: 8),
                    children: [
                      if (siteConfig.isNotEmpty)
                        _ContentSection(
                          title: context.s.cmsSiteConfigSection,
                          documents: siteConfig,
                          state: state,
                        ),
                      if (cabin.isNotEmpty)
                        _ContentSection(
                          title: context.s.cmsCabinSection,
                          documents: cabin,
                          state: state,
                        ),
                      if (pageHome.isNotEmpty)
                        _ContentSection(
                          title: context.s.cmsHomePageSection,
                          documents: pageHome,
                          state: state,
                        ),
                      if (pagePractical.isNotEmpty)
                        _ContentSection(
                          title: context.s.cmsPracticalPageSection,
                          documents: pagePractical,
                          state: state,
                        ),
                      if (pageArea.isNotEmpty)
                        _ContentSection(
                          title: context.s.cmsAreaPageSection,
                          documents: pageArea,
                          state: state,
                        ),
                      if (pagePrivacy.isNotEmpty)
                        _ContentSection(
                          title: context.s.cmsPrivacyPageSection,
                          documents: pagePrivacy,
                          state: state,
                        ),
                      if (contactForm.isNotEmpty)
                        _ContentSection(
                          title: context.s.cmsContactFormSection,
                          documents: contactForm,
                          state: state,
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
          );
        },
      ),
    );
  }

  void _handleLocaleChange(
    BuildContext context,
    CmsState state,
    List<String> locales,
    int index,
  ) {
    final cubit = context.read<CmsCubit>();
    if (!state.isDirty) {
      cubit.selectLocale(locales[index]);
      return;
    }
    // Show unsaved changes dialog
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.s.cmsUnsavedChangesTitle),
        content: Text(context.s.cmsUnsavedChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: Text(context.s.cmsDiscardButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: Text(context.s.cmsSaveDraftButton),
          ),
        ],
      ),
    ).then((result) {
      if (result == 'save') {
        cubit.saveAllDrafts().then((_) {
          cubit.selectLocale(locales[index]);
        });
      } else if (result == 'discard') {
        cubit.discardAllChanges();
        cubit.selectLocale(locales[index]);
      }
    });
  }

  void _confirmPublish(BuildContext context, CmsState state) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.s.cmsPublishConfirmTitle),
        content: Text(context.s.cmsPublishConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.s.cmsPublishButton),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<CmsCubit>().publishAllForLocale();
      }
    });
  }
}

// ---------------------------------------------------------------------------
// Bottom bar: locale selector + preview button
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.locales,
    required this.selectedIndex,
    required this.onLocaleChanged,
    required this.previewUrl,
    this.isDirty = false,
  });

  final List<String> locales;
  final int selectedIndex;
  final ValueChanged<int> onLocaleChanged;
  final String previewUrl;
  final bool isDirty;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StyledSegmentedControl(
          labels: locales.map((l) => l.toUpperCase()).toList(),
          selectedIndex: selectedIndex,
          onChanged: onLocaleChanged,
        ),
        const Spacer(),
        StyledButton(
          title: context.s.cmsPreviewButton,
          onPressed: () {
            web.window.open(previewUrl, '_blank');
          },
          leftIconData: Icons.open_in_new,
          showLeftIcon: true,
          minHeight: 40,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Collapsible content section
// ---------------------------------------------------------------------------

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.title,
    required this.documents,
    required this.state,
  });

  final String title;
  final List<ContentDocument> documents;
  final CmsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CmsCubit>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: context.theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final doc in documents) ...[
                // Dirty indicator
                if (state.dirtyContent.containsKey(doc.id))
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.edit,
                      size: 14,
                      color: context.colors.primary,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _StatusBadge(document: doc),
                ),
                // Version history button
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: StyledToolbarButton(
                    iconData: Icons.history,
                    onPressed: () => cubit.loadVersionHistory(doc.id),
                    tooltip: context.s.cmsVersionHistory,
                  ),
                ),
              ],
            ],
          ),
          initiallyExpanded: false,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 4, bottom: 8),
          children: [
            for (final doc in documents)
              ContentSectionRenderer(
                key: ValueKey('${doc.id}_${doc.updatedAt}'),
                document: doc,
                content: state.effectiveContent(doc),
                onContentChanged: (content) {
                  cubit.markDocumentDirty(doc.id, content);
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.document});
  final ContentDocument document;

  @override
  Widget build(BuildContext context) {
    // "Published" means there is nothing waiting: a document that is live but
    // carries a saved draft still has work the reader has not seen. That used
    // to be the same thing as `status`, because saving flipped the status —
    // now the draft lives in its own column, so the badge asks for both.
    final isPublished = document.status == 'published' && !document.hasDraft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isPublished
            ? context.colors.primaryContainer
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPublished ? context.s.cmsStatusPublished : context.s.cmsStatusDraft,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isPublished
              ? context.colors.onPrimaryContainer
              : context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Version history right pane
// ---------------------------------------------------------------------------

class _VersionHistoryPane extends StatelessWidget {
  const _VersionHistoryPane({required this.versions, required this.documentId});

  final List<DocumentVersion> versions;
  final String documentId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CmsCubit>();
    final dateFormat = DateFormat.yMMMd().add_Hm();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.s.cmsVersionHistory,
                  style: context.theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              StyledToolbarButton(
                iconData: Icons.close,
                onPressed: cubit.clearVersionHistory,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (versions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                context.s.cmsNoVersions,
                style: context.theme.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: versions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final v = versions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      context.s.cmsVersionLabel(v.version),
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      context.s.cmsVersionDate(
                        dateFormat.format(v.publishedAt.toLocal()),
                      ),
                      style: context.theme.textTheme.bodySmall,
                    ),
                    trailing: TextButton(
                      onPressed: () => _confirmRestore(context, cubit, v),
                      child: Text(context.s.cmsRestoreButton),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _confirmRestore(
    BuildContext context,
    CmsCubit cubit,
    DocumentVersion version,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.s.cmsRestoreConfirmTitle),
        content: Text(context.s.cmsRestoreConfirmBody(version.version)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.s.cmsRestoreButton),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        cubit.restoreVersion(documentId, version);
      }
    });
  }
}
