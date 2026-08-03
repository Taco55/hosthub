import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import '../../application/site_content_cubit.dart';
import '../website_editor_status_colors.dart';
import '../website_editor_strings.dart';
import 'editor_card_view.dart';

/// The center editor column: top bar, page tabs, a state-dependent banner, the
/// content cards (Hero, Highlights) and the save bar. Renders source mode
/// (mode A) and translation mode (mode B) from the same form.
class EditorColumn extends StatelessWidget {
  const EditorColumn({
    super.key,
    required this.state,
    this.siteId,
    this.propertyName,
  });

  final SiteContentState state;

  /// When editing a real site, enables the settings/team shortcuts.
  final String? siteId;

  /// The property being edited, for the title bar. `null` falls back to the
  /// name the content state carries, so the widget stays usable without the
  /// app's property context.
  final String? propertyName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopBar(state: state, siteId: siteId, propertyName: propertyName),
        _PageTabs(state: state),
        Divider(height: 1, thickness: 1, color: context.colors.outlineVariant),
        Expanded(
          child: ListView(
            // Design `.body{padding:20px 22px 30px}`.
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
            children: [
              _Banner(state: state),
              if (!state.isSourceMode) ...[
                const SizedBox(height: 12),
                _TranslationStatusToolbar(state: state),
              ],
              const SizedBox(height: 16),
              // §B.4: with the filter on, a card without a single changed
              // field is gone entirely — the cubit decides which cards the
              // lane shows, so the count and the list cannot disagree.
              for (final card in state.visibleCards) ...[
                EditorCardView(state: state, card: card),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        EditorSaveBar(state: state),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state, this.siteId, this.propertyName});
  final SiteContentState state;
  final String? siteId;
  final String? propertyName;

  @override
  Widget build(BuildContext context) {
    // This bar lives inside the editor column (design `.editcol .top`), not in
    // the page scaffold's header band, so it composes the same title/overline
    // type the scaffold does rather than inventing its own.
    final scaffoldTheme = StyledWidgetsTheme.of(context).webPageScaffold;
    final overlineStyle =
        (context.theme.textTheme.bodySmall ?? const TextStyle())
            .copyWith(color: context.colors.outline)
            .merge(scaffoldTheme.overlineTextStyle);
    final titleStyle =
        (context.theme.textTheme.headlineLarge ?? const TextStyle())
            .copyWith(
              fontWeight: FontWeight.w700,
              height: 1.0,
              letterSpacing: 0,
              color: context.colors.secondary,
            )
            .merge(scaffoldTheme.titleTextStyle);
    // The title names what you are editing — the property — the way every
    // other page titles its subject. The page you are on ("Home") is already
    // the selected tab right below, so it is not the title.
    final resolvedName = (propertyName ?? state.propertyName).trim();
    final title = resolvedName.isEmpty
        ? pageName(context, state.template, state.pageKey)
        : resolvedName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // §11f: the tab row already says which page you are on, so
                // the breadcrumb drops the page segment.
                Text(context.s.weBreadcrumbWebsite, style: overlineStyle),
                SizedBox(height: scaffoldTheme.overlineSpacing),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle,
                ),
              ],
            ),
          ),
          // §11g: the switcher picks the language you *edit*, so it belongs
          // above the form. In the preview header it read as "what am I
          // looking at" and disappeared entirely with the preview hidden.
          EditorLocaleSwitcher(state: state),
          const SizedBox(width: 8),
          // §11d: a page-scoped toolbar holds page-scoped controls. Team is
          // property-scoped and the gear duplicated the sidebar's Settings;
          // both were removed. The preview toggle stays.
          StyledToolbarButton(
            iconData: Icons.vertical_split_outlined,
            isSelected: state.previewVisible,
            tooltip: state.previewVisible
                ? context.s.weHidePreview
                : context.s.weShowPreview,
            onPressed: () => context.read<SiteContentCubit>().togglePreview(),
          ),
        ],
      ),
    );
  }
}

/// Design §11g: one segment per locale, the source labelled `source` and the
/// targets carrying nothing — a translation is not "AI" once the owner has
/// locked fields, and provenance is already stated per field.
/// Which language you are looking at. Shared with the legal document, so the
/// source badge and the segment behave identically in both places.
class EditorLocaleSwitcher extends StatelessWidget {
  const EditorLocaleSwitcher({super.key, required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final locales = state.orderedLocales;

    return StyledSegmentedControl.compact(
      segments: [
        for (final code in locales)
          StyledSegment(
            label: languageShort(code),
            badge: code == state.sourceLanguage
                ? context.s.weLocaleSourceBadge
                : null,
            // Which locale is the source is a fixed property of the site, not
            // something the switcher changes. A filled pill made it the
            // loudest thing in the control and read louder than the selected
            // segment, so the badge is quiet text instead.
            badgeStyle: StyledSegmentBadgeStyle.quiet,
          ),
      ],
      selectedIndex: locales.indexOf(state.previewLanguage),
      onChanged: (i) => cubit.setPreviewLanguage(locales[i]),
    );
  }
}

class _PageTabs extends StatelessWidget {
  const _PageTabs({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final tabs = state.template.tabPages;
    final selected = tabs.indexOf(state.pageKey);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: StyledSegmentedControl(
          variant: StyledSegmentedControlVariant.plain,
          segments: [
            for (final page in tabs)
              StyledSegment(label: pageName(context, state.template, page)),
          ],
          selectedIndex: selected < 0 ? 0 : selected,
          onChanged: (i) => cubit.selectPage(tabs[i]),
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
    final sourceName = languageName(context, state.sourceLanguage);

    if (state.isSourceMode) {
      // §11c: the "Unpublished changes" banner repeated the status line word
      // for word and its action duplicated the locale switcher — deleted, not
      // restyled. What is left is one line saying which language you write in.
      return Text(
        context.s.weBannerWritingTitle(sourceName),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    }

    // §D.1: two figures, two meanings — what there is to review, and how much
    // of this language the owner wrote themselves. At 250 fields the second
    // one alone said nothing about where to look, and a coverage percentage
    // said less.
    final cubit = context.read<SiteContentCubit>();
    final lang = languageName(context, state.previewLanguage);
    final locked = state.lockedFieldCount(state.previewLanguage);
    final changed = state.changedFieldCount(state.previewLanguage);
    return StyledNotice(
      icon: Icons.translate,
      // §B.4: the filter belongs in the lane header, next to the count it
      // acts on.
      trailing: StyledFilterChip(
        label: context.s.weFilterOnlyChanged,
        isSelected: state.onlyChangedFields,
        onChanged: cubit.setOnlyChangedFields,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.s.weBannerEditingTitle(lang),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: context.styledSpacing.xs),
          Text(
            '${context.s.weLaneChanged(changed)} · '
            '${context.s.weLockedCounter(locked, state.translatableFieldCount)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
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
    final stale = state.isLanguageStale(lang);
    final tokens = stale
        ? WebsiteStatusColors.auto(context.theme.brightness)
        : WebsiteStatusColors.locked(context.theme.brightness);
    // §11g: only the exception is worth a line. "Fresh draft, matches your
    // latest source" was true almost always, so it carried no information.
    if (!stale) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(Icons.schedule, size: 16, color: tokens.foreground),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.s.weStaleNotice,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.foreground),
          ),
        ),
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

// Card and row rendering lives in editor_card_view.dart.

/// The editor's status line and its two actions.
///
/// Public because the legal document under Site-instellingen runs on the same
/// save model — explicit save, discard, dimmed publish — and a second save bar
/// would be a second vocabulary for the same three states.
class EditorSaveBar extends StatelessWidget {
  const EditorSaveBar({super.key, required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final spacing = context.styledSpacing;

    // §11b: the status line says what *is*, the buttons say what *happens*.
    // Three states, not two: nothing saved yet, saved but not published, and
    // live. Saving is the owner's action now, so "unsaved" is the one the bar
    // has to name first — and it is never allowed to read "saved" while the
    // draft differs from what was written.
    final unsaved = state.unsavedChanges;
    final dotColor = switch ((unsaved, state.dirty)) {
      // Amber while there is something to save, the console's own blue once it
      // is written but not live, green when everything is published.
      (true, _) => WebsiteStatusColors.auto(
        context.theme.brightness,
      ).foreground,
      (false, true) => context.colors.primary,
      (false, false) => WebsiteStatusColors.locked(
        context.theme.brightness,
      ).foreground,
    };
    final targets = state.targetLanguages
        .map((l) => languageName(context, l))
        .join(' & ');
    final title = switch ((unsaved, state.dirty)) {
      (true, _) => context.s.weStatusUnsavedTitle,
      (false, true) => context.s.weStatusSavedTitle,
      (false, false) => context.s.weStatusCleanTitle,
    };
    final body = switch ((unsaved, state.dirty)) {
      (true, _) => context.s.weStatusUnsavedBody,
      (false, true) => context.s.weStatusSavedBody(targets),
      (false, false) => context.s.weStatusCleanBody(
        languageName(context, state.sourceLanguage),
        state.targetLanguages.length,
      ),
    };

    return StyledContainer(
      border: Border(top: BorderSide(color: context.colors.outlineVariant)),
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: spacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: spacing.xs + 1),
                child: StyledContainer(
                  backgroundColor: dotColor,
                  borderRadius: BorderRadius.circular(4),
                  padding: EdgeInsets.zero,
                  child: const SizedBox(width: 8, height: 8),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurface,
                      ),
                    ),
                    Text(
                      body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: context.colors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              // The actions keep their natural size and the status line takes
              // what is left; when even the actions do not fit — a long
              // translation in a narrow column — they share the row and their
              // labels ellipsize, rather than the bar overflowing.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (constraints.maxWidth - 8 - spacing.sm).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // §11i: while there is a draft the bar offers the two
                    // actions that resolve it. Both are the owner's — the
                    // editor neither saves nor discards on its own.
                    if (unsaved) ...[
                      Flexible(
                        child: StyledButton(
                          title: context.s.weDiscard,
                          variant: StyledButtonVariant.secondary,
                          size: StyledButtonSize.compact,
                          enabled: !state.saving,
                          onPressed: () => _confirmDiscard(context, cubit),
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      Flexible(
                        child: StyledButton(
                          title: context.s.weSave,
                          size: StyledButtonSize.compact,
                          showLeftIcon: true,
                          leftIconData: Icons.save_outlined,
                          enabled: !state.saving,
                          showProgressIndicatorWhenDisabled: state.saving,
                          keepEnabledStyleWhenDisabled: true,
                          onPressed: cubit.save,
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                    ],
                    Flexible(
                      child: Tooltip(
                        // Dimmed rather than hidden: the owner needs to see
                        // that publish is the next step, and why it is not
                        // available yet.
                        message: unsaved ? context.s.wePublishNeedsSave : '',
                        child: StyledButton(
                          // §11a: one button. A split button forced the reader
                          // to parse the difference between two options, and
                          // the difference is what *doesn't* happen — the
                          // hardest thing to put in a label.
                          title: context.s.wePublish,
                          size: StyledButtonSize.compact,
                          showLeftIcon: true,
                          leftIconData: Icons.publish_outlined,
                          enabled: !unsaved,
                          onPressed: cubit.openPublish,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Discarding throws away wording the owner typed and cannot be undone —
  /// exactly what the explicit-save model exists to protect — so it asks first.
  void _confirmDiscard(BuildContext context, SiteContentCubit cubit) {
    // ignore: discarded_futures — the dialog carries out the discard itself;
    // there is nothing for the caller to await.
    showStyledAlertDialog(
      context,
      title: context.s.weDiscardTitle,
      message: context.s.weDiscardMessage,
      actionText: context.s.weDiscardConfirm,
      dismissText: context.s.weDiscardCancel,
      isDestructiveAction: true,
      onAction: cubit.discardDraft,
    );
  }
}
