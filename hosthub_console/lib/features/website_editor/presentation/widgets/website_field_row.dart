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
/// translation mode it carries a `Locked`/`Auto` status chip, a source-
/// reference line, and (for locked fields) a "Reset to AI" action.
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
      labelTrailing: _statusChip(context, locked),
      footer: _sourceReference(context, cubit, locked),
    );
  }

  Widget _statusChip(BuildContext context, bool locked) {
    final brightness = Theme.of(context).brightness;
    final tokens = locked
        ? WebsiteStatusColors.locked(brightness)
        : WebsiteStatusColors.auto(brightness);
    return StyledChip(
      label: locked ? context.s.weChipLocked : context.s.weChipAuto,
      size: StyledChipSize.display,
      leading: Icon(
        locked ? Icons.lock_outline : Icons.auto_awesome,
        size: 13,
        color: tokens.foreground,
      ),
      backgroundColor: tokens.background,
      labelColor: tokens.foreground,
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
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.outline),
          ),
        ),
        if (locked)
          StyledTextButton(
            title: context.s.weResetToAi,
            // Compact link-style action on the source-reference line; the
            // default TextButton min-constraints would overflow this row and
            // push the label outside its hit-test bounds.
            enforceTextButtonConstraints: false,
            padding: EdgeInsets.zero,
            fontSize: 12.5,
            onPressed: () =>
                cubit.resetFieldToAi(state.previewLanguage, field.key),
          ),
      ],
    );
  }
}
