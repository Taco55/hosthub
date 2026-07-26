import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import '../../application/site_content_cubit.dart';
import '../../domain/website_content.dart';
import '../website_editor_status_colors.dart';
import '../website_editor_strings.dart';
import 'editable_content_field.dart';

/// One editable field on a card. In source mode it is a plain field; in
/// translation mode it carries a source-reference line and an `Auto`/`Locked`
/// chip that **is** the mode switch (§11g) — a separate "Reset to AI" link
/// would be a second control for the same state, explaining a mechanism the
/// chip already names.
class WebsiteFieldRow extends StatelessWidget {
  const WebsiteFieldRow({
    super.key,
    required this.state,
    required this.field,
    required this.label,
    this.autofocus = false,
  });

  final SiteContentState state;
  final EditorFieldDef field;
  final String label;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final lang = state.previewLanguage;

    if (state.isSourceMode) {
      return EditableContentField(
        value: state.valueFor(lang, field.key),
        onChanged: (v) => cubit.editSourceField(field.key, v),
        label: label,
        multiline: field.multiline,
        autofocus: autofocus,
      );
    }

    final translated = state.translatedField(lang, field.key);
    final locked = translated?.isLocked ?? false;

    return EditableContentField(
      value: state.valueFor(lang, field.key),
      onChanged: (v) => cubit.editTranslationField(lang, field.key, v),
      label: label,
      multiline: field.multiline,
      labelTrailing: _statusChip(context, cubit, locked),
      footer: _footer(context, cubit, locked),
    );
  }

  Widget _statusChip(
    BuildContext context,
    SiteContentCubit cubit,
    bool locked,
  ) {
    final brightness = Theme.of(context).brightness;
    final tokens = locked
        ? WebsiteStatusColors.locked(brightness)
        : WebsiteStatusColors.auto(brightness);
    final lang = state.previewLanguage;

    return Tooltip(
      // The tooltip states the outcome of clicking, not the current state —
      // the label already says that.
      message: locked
          ? context.s.weChipTooltipLocked
          : context.s.weChipTooltipAuto,
      child: StyledChip(
        label: locked ? context.s.weChipLocked : context.s.weChipAuto,
        size: StyledChipSize.display,
        leading: Icon(
          locked ? Icons.lock_outline : Icons.auto_awesome,
          size: 13,
          color: tokens.foreground,
        ),
        backgroundColor: tokens.background,
        labelColor: tokens.foreground,
        onTap: () => locked
            // ignore: discarded_futures — re-translating is fire-and-forget;
            // the field shows the result when it lands.
            ? cubit.resetFieldToAi(lang, field.key)
            : cubit.lockField(lang, field.key),
      ),
    );
  }

  Widget _footer(BuildContext context, SiteContentCubit cubit, bool locked) {
    final pending = state.pendingAutoSwitch;
    final showUndo =
        pending != null &&
        pending.language == state.previewLanguage &&
        pending.fieldKey == field.key;

    if (!showUndo) return _sourceReference(context, cubit, locked);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sourceReference(context, cubit, locked),
        SizedBox(height: context.styledSpacing.sm),
        StyledNotice(
          icon: Icons.undo,
          trailing: StyledTextButton(
            title: context.s.weUndo,
            enforceTextButtonConstraints: false,
            padding: EdgeInsets.zero,
            fontSize: 12.5,
            onPressed: cubit.undoAutoSwitch,
          ),
          child: Text(
            context.s.weUndoSwitchNotice(
              languageName(context, state.sourceLanguage),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _sourceReference(
    BuildContext context,
    SiteContentCubit cubit,
    bool locked,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final sourceText = state.valueFor(state.sourceLanguage, field.key);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            languageShort(state.sourceLanguage),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            sourceText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
        ),
      ],
    );
  }
}
