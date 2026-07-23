import 'package:flutter/material.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import '../../application/site_content_cubit.dart';
import '../website_editor_status_colors.dart';
import '../website_editor_strings.dart';

/// Shows the "Publish all languages" confirmation. One row per enabled
/// language: the source is Ready, targets are Re-translate. Returns true when
/// the user confirmed. [onConfirm] runs as the dialog's async action (the
/// dialog shows a loading overlay and stays open on failure).
Future<bool?> showPublishModal(
  BuildContext context, {
  required SiteContentState state,
  Future<void> Function()? onConfirm,
}) {
  final s = context.s;
  return showStyledAlertDialog(
    context,
    title: s.wePublishTitle,
    content: _PublishContent(state: state),
    dismissText: s.wePublishCancel,
    actionText: s.wePublishConfirm(state.locales.length),
    asyncAction: onConfirm != null,
    onAction: onConfirm ?? () {},
    isDismissible: true,
  );
}

class _PublishContent extends StatelessWidget {
  const _PublishContent({required this.state});
  final SiteContentState state;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final ready = WebsiteStatusColors.locked(brightness);
    final retranslate = WebsiteStatusColors.auto(brightness);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.wePublishSubtitle(languageName(context, state.sourceLanguage)),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        for (final code in state.orderedLocales)
          StyledTile(
            leading: _langBadge(context, code),
            title: code == state.sourceLanguage
                ? s.wePublishSourceRole(languageName(context, code))
                : languageName(context, code),
            subtitle: code == state.sourceLanguage
                ? s.wePublishReadyNote
                : s.wePublishRetranslateNote,
            trailing: StyledChip(
              label: code == state.sourceLanguage
                  ? s.wePublishReady
                  : s.wePublishRetranslate,
              size: StyledChipSize.display,
              leading: Icon(
                code == state.sourceLanguage
                    ? Icons.check
                    : Icons.auto_awesome,
                size: 13,
                color: code == state.sourceLanguage
                    ? ready.foreground
                    : retranslate.foreground,
              ),
              backgroundColor: code == state.sourceLanguage
                  ? ready.background
                  : retranslate.background,
              labelColor: code == state.sourceLanguage
                  ? ready.foreground
                  : retranslate.foreground,
            ),
          ),
      ],
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
