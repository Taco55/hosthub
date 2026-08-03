import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import '../../application/site_content_cubit.dart';
import '../website_editor_status_colors.dart';
import '../website_editor_strings.dart';

/// Shows the "What goes live" confirmation — the last checkpoint before
/// publishing (§11a).
///
/// One row per enabled language. The source always ships; every target carries
/// a checkbox, so leaving one out is a visible choice rather than a second
/// button with an abstract label. Each row states whether its draft was
/// reviewed, and the confirm button counts what is actually going out.
///
/// [onConfirm] receives the languages the user unchecked and runs as the
/// dialog's async action (loading overlay, stays open on failure).
Future<bool?> showPublishModal(
  BuildContext context, {
  required SiteContentState state,
  Future<void> Function(Set<String> skipLanguages)? onConfirm,
  void Function(String language, String page)? onOpenReview,
}) {
  final skipped = <String>{};
  // The confirm label counts what is actually going out, so it has to follow
  // the checkboxes while the dialog is open.
  final actionLabel = ValueNotifier<String>(
    publishConfirmLabel(context, state, skipped),
  );

  return showStyledAlertDialog(
    context,
    title: context.s.wePublishModalTitle,
    content: StatefulBuilder(
      builder: (context, setState) => _PublishContent(
        state: state,
        skipped: skipped,
        onOpenReview: onOpenReview,
        onToggle: (code, include) => setState(() {
          if (include) {
            skipped.remove(code);
          } else {
            skipped.add(code);
          }
          actionLabel.value = publishConfirmLabel(context, state, skipped);
        }),
      ),
    ),
    dismissText: context.s.wePublishCancel,
    // Built in one place, so a count of 1 can never render as
    // "Publish 1 languages".
    actionTextListenable: actionLabel,
    asyncAction: onConfirm != null,
    onAction: onConfirm == null ? () {} : () => onConfirm(skipped),
    isDismissible: true,
  ).whenComplete(actionLabel.dispose);
}

/// `Publish N languages`, or `Publish <source> only` when the source is all
/// that is going out.
String publishConfirmLabel(
  BuildContext context,
  SiteContentState state,
  Set<String> skipped,
) {
  final count =
      1 + state.targetLanguages.where((code) => !skipped.contains(code)).length;
  if (count == 1) {
    return context.s.wePublishSourceOnly(
      languageName(context, state.sourceLanguage),
    );
  }
  return context.s.wePublishConfirm(count);
}

class _PublishContent extends StatefulWidget {
  const _PublishContent({
    required this.state,
    required this.skipped,
    required this.onToggle,
    this.onOpenReview,
  });

  final SiteContentState state;
  final Set<String> skipped;
  final void Function(String code, bool include) onToggle;
  final void Function(String language, String page)? onOpenReview;

  @override
  State<_PublishContent> createState() => _PublishContentState();
}

class _PublishContentState extends State<_PublishContent> {
  /// Languages whose per-page breakdown is open. Collapsed by default: the
  /// dialog answers "what goes live" first, and the detail is one tap away.
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.s.wePublishSubtitle(
            languageName(context, state.sourceLanguage),
          ),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: context.styledSpacing.md),
        for (final code in state.orderedLocales) ...[
          _LanguageRow(
            state: state,
            code: code,
            included: !widget.skipped.contains(code),
            onToggle: widget.onToggle,
            expanded: _expanded.contains(code),
            onToggleExpanded: () => setState(() {
              if (!_expanded.remove(code)) _expanded.add(code);
            }),
          ),
          // §D.2: the breakdown lists only pages that have changes — a page
          // with nothing to review is not a row worth reading.
          if (_expanded.contains(code))
            for (final page in state.changedPages(code))
              _PageRow(
                state: state,
                language: code,
                page: page,
                onOpenReview: widget.onOpenReview,
              ),
        ],
        SizedBox(height: context.styledSpacing.sm),
        // The promise the whole model rests on, repeated where it is acted on.
        Text(
          context.s.wePublishFooter(
            state.changedFieldCount(
              state.targetLanguages.isEmpty
                  ? state.sourceLanguage
                  : state.targetLanguages.first,
            ),
          ),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.colors.outline),
        ),
      ],
    );
  }
}

/// One page of one language: how much changed, and a way straight into it.
class _PageRow extends StatelessWidget {
  const _PageRow({
    required this.state,
    required this.language,
    required this.page,
    this.onOpenReview,
  });

  final SiteContentState state;
  final String language;
  final String page;
  final void Function(String language, String page)? onOpenReview;

  @override
  Widget build(BuildContext context) {
    final changed = state.changedFieldsOnPage(language, page).length;
    final seen = state.reviewedPages[language]?.contains(page) ?? false;

    return StyledTile(
      nested: true,
      title: pageName(context, state.template, page),
      subtitle: seen
          ? context.s.wePublishPageSeen(changed)
          : context.s.wePublishPageUnseen(changed),
      trailing: onOpenReview == null
          ? null
          : StyledTextButton(
              title: context.s.wePublishOpen,
              onPressed: () => onOpenReview!(language, page),
            ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.state,
    required this.code,
    required this.included,
    required this.onToggle,
    required this.expanded,
    required this.onToggleExpanded,
  });

  final SiteContentState state;
  final String code;
  final bool included;
  final void Function(String code, bool include) onToggle;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final isSource = code == state.sourceLanguage;
    final changedPages = state.changedPages(code);
    final changedFields = state.changedFieldCount(code);
    final reviewed = state.isLanguageReviewed(code);
    final seenPages = state.reviewedChangedPageCount(code);
    // §D.1: the note is the delta, not the total — "what is there to review".
    final note = !included
        ? context.s.wePublishSkippedNote
        : isSource
        ? context.s.wePublishSourceDelta(state.changedFieldCount(code))
        : context.s.wePublishTargetDelta(changedFields, changedPages.length);

    final tokens = included && (isSource || reviewed)
        ? WebsiteStatusColors.locked(context.theme.brightness)
        : WebsiteStatusColors.auto(context.theme.brightness);

    // §D.2: four states, and no coverage percentage — a partially reviewed
    // language says how far it got, because that is the number that decides
    // whether the owner wants to go back in.
    final String status;
    if (!included) {
      status = context.s.wePublishSkipped;
    } else if (isSource) {
      status = context.s.wePublishReady;
    } else if (changedPages.isEmpty) {
      status = context.s.wePublishNothingChanged;
    } else if (reviewed) {
      status = context.s.wePublishSeen;
    } else if (seenPages > 0) {
      status = context.s.wePublishPartlySeen(seenPages, changedPages.length);
    } else {
      status = context.s.wePublishNotSeen;
    }

    return StyledTile(
      leading: _langBadge(context, code),
      title: isSource
          ? context.s.wePublishSourceRole(languageName(context, code))
          : languageName(context, code),
      subtitle: note,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isSource && changedPages.isNotEmpty) ...[
            StyledTextButton(
              title: context.s.wePublishPerPage,
              onPressed: onToggleExpanded,
              showRightIcon: true,
              rightIconData: expanded ? Icons.expand_less : Icons.expand_more,
            ),
            SizedBox(width: context.styledSpacing.sm),
          ],
          StyledChip(
            label: status,
            size: StyledChipSize.display,
            backgroundColor: tokens.background,
            labelColor: tokens.foreground,
          ),
          // The source is not optional; every target is.
          if (!isSource) ...[
            SizedBox(width: context.styledSpacing.sm),
            StyledCheckbox(
              value: included,
              onChanged: (value) => onToggle(code, value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _langBadge(BuildContext context, String code) {
    return StyledContainer(
      backgroundColor: context.colors.primaryContainer,
      borderRadius: BorderRadius.circular(10),
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            languageShort(code),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
