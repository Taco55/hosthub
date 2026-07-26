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
}) {
  final skipped = <String>{};
  final s = context.s;
  // The confirm label counts what is actually going out, so it has to follow
  // the checkboxes while the dialog is open.
  final actionLabel = ValueNotifier<String>(
    publishConfirmLabel(context, state, skipped),
  );

  return showStyledAlertDialog(
    context,
    title: s.wePublishModalTitle,
    content: StatefulBuilder(
      builder: (context, setState) => _PublishContent(
        state: state,
        skipped: skipped,
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
    dismissText: s.wePublishCancel,
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

class _PublishContent extends StatelessWidget {
  const _PublishContent({
    required this.state,
    required this.skipped,
    required this.onToggle,
  });

  final SiteContentState state;
  final Set<String> skipped;
  final void Function(String code, bool include) onToggle;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.wePublishSubtitle(languageName(context, state.sourceLanguage)),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        SizedBox(height: context.styledSpacing.md),
        for (final code in state.orderedLocales)
          _LanguageRow(
            state: state,
            code: code,
            included: !skipped.contains(code),
            onToggle: onToggle,
          ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.state,
    required this.code,
    required this.included,
    required this.onToggle,
  });

  final SiteContentState state;
  final String code;
  final bool included;
  final void Function(String code, bool include) onToggle;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final brightness = Theme.of(context).brightness;
    final isSource = code == state.sourceLanguage;
    final reviewed = state.reviewedLanguages.contains(code);
    final tokens = included && (isSource || reviewed)
        ? WebsiteStatusColors.locked(brightness)
        : WebsiteStatusColors.auto(brightness);

    final String status;
    if (!included) {
      status = s.wePublishSkipped;
    } else if (isSource) {
      status = s.wePublishReadyNote;
    } else {
      // §11a: a language the owner never opened is translated *at publish*, so
      // the row has to say both things — it was not reviewed, and it is about
      // to be written. Shipping unreviewed output stays a visible choice.
      status = reviewed ? s.wePublishReviewed : s.wePublishDraftTranslatesNow;
    }

    return StyledTile(
      leading: _langBadge(context, code),
      title: isSource
          ? s.wePublishSourceRole(languageName(context, code))
          : languageName(context, code),
      subtitle: status,
      // The source is not optional; every target is.
      trailing: isSource
          ? StyledChip(
              label: s.wePublishReady,
              size: StyledChipSize.display,
              leading: Icon(Icons.check, size: 13, color: tokens.foreground),
              backgroundColor: tokens.background,
              labelColor: tokens.foreground,
            )
          : StyledCheckbox(
              value: included,
              onChanged: (value) => onToggle(code, value),
            ),
    );
  }

  Widget _langBadge(BuildContext context, String code) {
    final scheme = Theme.of(context).colorScheme;
    return StyledContainer(
      backgroundColor: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(10),
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            languageShort(code),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
