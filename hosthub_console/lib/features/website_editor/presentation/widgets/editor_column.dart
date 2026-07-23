import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import '../../application/site_content_cubit.dart';
import '../../domain/website_content.dart';
import '../website_editor_status_colors.dart';
import '../website_editor_strings.dart';
import 'website_field_row.dart';

/// The center editor column: top bar, page tabs, a state-dependent banner, the
/// content cards (Hero, Highlights) and the save bar. Renders source mode
/// (mode A) and translation mode (mode B) from the same form.
class EditorColumn extends StatelessWidget {
  const EditorColumn({super.key, required this.state});

  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopBar(state: state),
        _PageTabs(state: state),
        Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
            children: [
              _Banner(state: state),
              if (!state.isSourceMode) ...[
                const SizedBox(height: 12),
                _TranslationStatusToolbar(state: state),
              ],
              const SizedBox(height: 16),
              if (state.pageKey == 'home') ...[
                _HeroCard(state: state),
                const SizedBox(height: 16),
                _HighlightsCard(state: state),
              ] else
                _ContentCard(state: state),
            ],
          ),
        ),
        _SaveBar(state: state),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.s.weBreadcrumbWebsite} · ${pageName(context, state.pageKey)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pageName(context, state.pageKey),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _ModeChip(state: state),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final short = languageShort(state.previewLanguage);
    if (state.isSourceMode) {
      return StyledChip(
        label: context.s.weSourceChip(short),
        size: StyledChipSize.display,
        leading: Icon(Icons.auto_awesome, size: 13, color: scheme.primary),
        backgroundColor: scheme.surface,
        borderColor: scheme.primary.withValues(alpha: 0.35),
        labelColor: scheme.primary,
      );
    }
    final tokens = WebsiteStatusColors.locked(Theme.of(context).brightness);
    return StyledChip(
      label: context.s.weEditingChip(short),
      size: StyledChipSize.display,
      leading: Icon(Icons.edit_outlined, size: 13, color: tokens.foreground),
      backgroundColor: tokens.background,
      labelColor: tokens.foreground,
    );
  }
}

class _PageTabs extends StatelessWidget {
  const _PageTabs({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final selected = kWebsitePages.indexOf(state.pageKey);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: StyledSegmentedControl(
          variant: StyledSegmentedControlVariant.plain,
          segments: [
            for (final page in kWebsitePages)
              StyledSegment(label: pageName(context, page)),
          ],
          selectedIndex: selected < 0 ? 0 : selected,
          onChanged: (i) => cubit.selectPage(kWebsitePages[i]),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final s = context.s;
    final sourceName = languageName(context, state.sourceLanguage);

    if (state.isSourceMode) {
      if (!state.dirty) {
        return StyledNotice(
          icon: Icons.edit_note,
          child: _bannerBody(
            context,
            s.weBannerWritingTitle(sourceName),
            s.weBannerWritingBody,
          ),
        );
      }
      final staleList = state.targetLanguages
          .map((l) => languageName(context, l))
          .join(' & ');
      return StyledNotice(
        icon: Icons.edit_note,
        trailing: StyledButton(
          title: s.wePreviewTranslation,
          showLeftIcon: true,
          leftIconData: Icons.auto_awesome,
          onPressed: () => cubit.translateNow(state.targetLanguages),
        ),
        child: _bannerBody(
          context,
          s.weBannerUnpublishedTitle,
          s.weBannerUnpublishedBody(staleList),
        ),
      );
    }

    final lang = languageName(context, state.previewLanguage);
    return StyledNotice(
      icon: Icons.translate,
      trailing: StyledMeter(
        value: state.coverage(state.previewLanguage),
        label: '${(state.coverage(state.previewLanguage) * 100).round()}%',
      ),
      child: _bannerBody(
        context,
        s.weBannerEditingTitle(lang),
        s.weBannerEditingBody(sourceName),
      ),
    );
  }

  Widget _bannerBody(BuildContext context, String title, String body) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w700, color: scheme.primary),
        ),
        const SizedBox(height: 2),
        Text(
          body,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.primary),
        ),
      ],
    );
  }
}

class _TranslationStatusToolbar extends StatelessWidget {
  const _TranslationStatusToolbar({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final lang = state.previewLanguage;
    final brightness = Theme.of(context).brightness;
    final stale = state.isLanguageStale(lang);
    final tokens = stale
        ? WebsiteStatusColors.auto(brightness)
        : WebsiteStatusColors.locked(brightness);
    return Row(
      children: [
        Icon(
          stale ? Icons.schedule : Icons.check_circle,
          size: 16,
          color: tokens.foreground,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            stale ? context.s.weStaleNotice : context.s.weFreshNotice,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: tokens.foreground),
          ),
        ),
        if (stale)
          StyledButton(
            title: context.s.wePreviewLatest,
            showLeftIcon: true,
            leftIconData: Icons.auto_awesome,
            onPressed: () => cubit.previewTranslation(lang),
          ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.icon,
    required this.title,
    required this.children,
  });
  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return StyledSection(
      inset: true,
      header: Row(
        children: [
          StyledIconBadge(icon: icon, size: 34),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      showDividers: false,
      children: children,
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final heroFields =
        state.fields.where((f) => f.card == EditorCard.hero).toList();
    return _CardShell(
      icon: Icons.auto_awesome,
      title: s.weCardHero,
      children: [
        for (final field in heroFields) ...[
          WebsiteFieldRow(
            state: state,
            field: field,
            label: fieldLabel(context, field.key),
            autofocus: field.key == 'hero.headline' && state.isSourceMode,
          ),
          const SizedBox(height: 14),
        ],
        _HeroPhotos(state: state),
      ],
    );
  }
}

class _HeroPhotos extends StatelessWidget {
  const _HeroPhotos({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    final label = Text(
      s.weFieldHeroPhotos,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(fontWeight: FontWeight.w600, color: scheme.onSurface),
    );

    if (!state.isSourceMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          const SizedBox(height: 6),
          StyledNotice(
            tone: StyledNoticeTone.neutral,
            icon: Icons.photo_library_outlined,
            message: s.weSharedPhotosNote,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label,
        const SizedBox(height: 8),
        SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                _photoTile(scheme),
                const SizedBox(width: 8),
              ],
              _addPhotoTile(context, scheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoTile(ColorScheme scheme) => StyledContainer(
        borderRadius: BorderRadius.circular(11),
        backgroundColor: scheme.surfaceContainerHighest,
        padding: EdgeInsets.zero,
        child: const SizedBox(width: 88, height: 64),
      );

  Widget _addPhotoTile(BuildContext context, ColorScheme scheme) =>
      StyledContainer(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: scheme.outlineVariant),
        backgroundColor: scheme.surface,
        padding: EdgeInsets.zero,
        child: SizedBox(
          width: 88,
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: scheme.primary, size: 20),
              Text(
                context.s.weAddPhoto,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: scheme.primary),
              ),
            ],
          ),
        ),
      );
}

class _HighlightsCard extends StatelessWidget {
  const _HighlightsCard({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final highlightFields =
        state.fields.where((f) => f.card == EditorCard.highlights).toList();
    return _CardShell(
      icon: Icons.star_outline,
      title: s.weCardHighlights,
      children: [
        for (final field in highlightFields) ...[
          WebsiteFieldRow(
            state: state,
            field: field,
            label: fieldLabel(context, field.key),
          ),
          const SizedBox(height: 14),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: StyledTextButton(
            title: s.weAddHighlight,
            showLeftIcon: true,
            leftIconData: Icons.add,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

/// Generic card for pages without a bespoke design (chalet, practical, area,
/// contact): all of the page's fields in one StyledSection.
class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      icon: Icons.notes_outlined,
      title: context.s.weCardContent,
      children: [
        for (final field in state.fields) ...[
          WebsiteFieldRow(
            state: state,
            field: field,
            label: fieldLabel(context, field.key),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final dotColor = state.dirty
        ? WebsiteStatusColors.auto(brightness).foreground
        : WebsiteStatusColors.locked(brightness).foreground;
    final statusText = state.dirty
        ? context.s.weSaveDirty
        : context.s.weSavePublished;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                statusText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            StyledButton(
              title: context.s.wePublishAll,
              showLeftIcon: true,
              leftIconData: Icons.publish_outlined,
              minHeight: 40,
              onPressed: cubit.openPublish,
            ),
          ],
        ),
      ),
    );
  }
}
