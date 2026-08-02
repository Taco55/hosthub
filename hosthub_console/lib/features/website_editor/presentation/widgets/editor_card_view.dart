import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';
import 'package:hosthub_console/core/widgets/layout/layout.dart';

import '../../application/site_content_cubit.dart';
import '../../domain/website_content.dart';
import '../../application/media_library_cubit.dart';
import '../website_editor_strings.dart';
import 'media_picker_modal.dart';
import 'website_field_row.dart';

/// One card from the page schema.
///
/// The renderer knows the row *types*; the schema says what a card holds. A
/// new card is a schema entry and no new widget — if a card needs code here,
/// the schema is not expressive enough yet and that is the thing to fix.
class EditorCardView extends StatelessWidget {
  const EditorCardView({super.key, required this.state, required this.card});

  final SiteContentState state;
  final EditorCard card;

  /// The card's right-hand header slot: where the copy comes from when the
  /// card is read-only, and otherwise the `N gewijzigd` rollup (§B.4) — one
  /// number per card, so a 60-field page stays scannable without reading 60
  /// per-field chips. Absent when nothing changed: a card head full of zeroes
  /// is noise.
  Widget? _headerTrailing(BuildContext context) {
    if (card.readOnly) {
      return StyledChip(
        label: context.s.weCardSourceLodgify,
        size: StyledChipSize.micro,
      );
    }
    if (state.isSourceMode) return null;
    final changed = state.changedCountForCard(state.previewLanguage, card.id);
    if (changed == 0) return null;
    return StyledChip(
      label: context.s.weLaneChanged(changed),
      size: StyledChipSize.display,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelColor: Theme.of(context).colorScheme.primary,
      borderColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      icon: cardIcon(card.id),
      title: cardTitle(context, card.id),
      subtitle: cardSubtitle(context, card.id),
      headerTrailing: _headerTrailing(context),
      children: [
        for (final row in card.rows)
          _RowView(state: state, card: card, row: row),
      ],
    );
  }
}

/// Hands a dragged row's floating proxy the editor cubit again.
///
/// A drag rebuilds the row inside the Navigator's overlay, above the route that
/// provides [SiteContentCubit] — so every row widget that reads the cubit from
/// its context (and they all do, through [WebsiteFieldRow]) would throw the
/// moment it is picked up. [cubit] is resolved by the caller, from the list's
/// own context: inside the returned builder the lookup fails for the same
/// reason it is being repaired.
Widget Function(Widget) _dragProxyScope(SiteContentCubit cubit) =>
    (child) => BlocProvider.value(value: cubit, child: child);

/// Dispatches one schema row to its shape.
class _RowView extends StatelessWidget {
  const _RowView({required this.state, required this.card, required this.row});

  final SiteContentState state;
  final EditorCard card;
  final EditorRow row;

  @override
  Widget build(BuildContext context) {
    final child = switch (row) {
      final FieldRow field => _FieldRowView(state: state, row: field),
      final ListRow list => _ListRowView(state: state, row: list),
      final PairListRow pairs => _PairListRowView(state: state, row: pairs),
      final RowListRow rows => _RowListRowView(state: state, row: rows),
      final GroupListRow groups => _GroupListRowView(state: state, row: groups),
      final MediaRow media => _MediaRowView(state: state, row: media),
      final ExternalRow external => _ExternalRowView(row: external),
    };
    return Padding(
      // §11e: field-to-field spacing inside a card is one token; the card's
      // own padding supplies the outer breathing room.
      padding: EdgeInsets.only(bottom: context.styledSpacing.lg),
      child: child,
    );
  }
}

/// A single field, plus the note that says where it lands when it is not
/// readable as text on its own page (§E).
class _FieldRowView extends StatelessWidget {
  const _FieldRowView({required this.state, required this.row});

  final SiteContentState state;
  final FieldRow row;

  @override
  Widget build(BuildContext context) {
    final field = state.fieldFor(row.key);
    if (field == null) return const SizedBox.shrink();
    return WebsiteFieldRow(
      state: state,
      field: field,
      label: fieldLabel(context, row.key),
      hint: visibilityHint(context, row.visibility),
      autofocus: row.key == 'cabin.hero.title' && state.isSourceMode,
    );
  }
}

/// A repeatable list of single-value rows (README §B.1).
class _ListRowView extends StatelessWidget {
  const _ListRowView({required this.state, required this.row});

  final SiteContentState state;
  final ListRow row;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final fields = state.fieldsOfList(row.listKey);
    final structureLocked = !state.isSourceMode;
    final itemLabel = listItemLabel(context, row.listKey);

    return StyledFieldList<EditorField>(
      title: listTitle(context, row.listKey),
      counter: context.s.weListCounter(fields.length, row.maxItems ?? 0),
      items: fields,
      itemLabel: itemLabel,
      itemKey: (field) => field.key,
      itemBuilder: (context, field, index) =>
          WebsiteFieldRow(state: state, field: field, label: null),
      dragProxyBuilder: _dragProxyScope(cubit),
      onReorder: row.repeatable
          ? (from, to) => cubit.moveRow(row.listKey, from, to)
          : null,
      onDelete: row.repeatable
          ? (index) => cubit.removeRow(row.listKey, index)
          : null,
      onAdd: row.repeatable ? () => cubit.addRow(row.listKey) : null,
      addLabel: context.s.weListAdd(itemLabel),
      minItems: row.minItems,
      maxItems: row.maxItems,
      minReachedReason: context.s.weListMinReason(row.minItems),
      maxReachedLabel: context.s.weListMaxReached(row.maxItems ?? 0),
      maxReachedReason: context.s.weListMaxReason,
      emptyTitle: context.s.weListEmptyTitle(itemLabel),
      emptyMessage: context.s.weListEmptyMessage,
      structureLocked: structureLocked,
      structureLockedReason: context.s.weStructureLocked(
        languageName(context, state.sourceLanguage),
      ),
      undoMessage: state.pendingRowDelete?.listKey == row.listKey
          ? context.s.weRowDeleted
          : null,
      undoActionLabel: context.s.weUndo,
      onUndo: cubit.undoRowDelete,
    );
  }
}

/// Label + value pairs, one row per pair (README §B.2). A pair carries one
/// chip, on the label: in practice the owner locks the pair, not half of it.
class _PairListRowView extends StatelessWidget {
  const _PairListRowView({required this.state, required this.row});

  final SiteContentState state;
  final PairListRow row;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final structureLocked = !state.isSourceMode;
    final itemLabel = listItemLabel(context, row.listKey);
    final fixedRows = row.fixedRows;

    // Fixed rows are values on their own paths; their label is a system fact
    // and renders as the row title.
    final rows = fixedRows != null
        ? [
            for (final key in fixedRows)
              if (row.fixedRowsAreValues)
                // The label is a system fact: it is the row's title.
                (
                  rowId: key,
                  label: null,
                  value: state.fieldFor(key),
                  title: fieldLabel(context, key),
                )
              else
                // A fixed slot: both fields are the owner's copy, and the
                // row's title names which form field it is.
                (
                  rowId: key,
                  label: state.fieldFor('$key.${row.labelSub}'),
                  value: state.fieldFor('$key.${row.valueSub}'),
                  title: fieldLabel(context, key),
                ),
          ]
        : [
            for (final rowId in state.rowIdsOfList(row.listKey))
              (
                rowId: rowId,
                label: state.fieldFor(
                  listFieldKey(row.listKey, rowId, row.labelSub),
                ),
                value: state.fieldFor(
                  listFieldKey(row.listKey, rowId, row.valueSub),
                ),
                title: null,
              ),
          ];

    return StyledFieldList<
      ({String rowId, EditorField? label, EditorField? value, String? title})
    >(
      title: listTitle(context, row.listKey),
      counter: context.s.weListCounter(
        rows.length,
        row.maxItems ?? rows.length,
      ),
      meta: row.sharedValue ? context.s.weSharedValueMeta : null,
      items: rows,
      itemLabel: itemLabel,
      itemKey: (pair) => pair.rowId,
      rowTitleBuilder: fixedRows == null
          ? null
          : (pair, index) => pair.title ?? '$itemLabel ${index + 1}',
      itemBuilder: (context, pair, index) => _PairFields(
        state: state,
        label: pair.label,
        value: pair.value,
        labelText: pair.title == null
            ? pairLabelLabel(context, row.listKey)
            : null,
        valueText: pairValueLabel(context, row.listKey),
        sharedValue: row.sharedValue,
        wideValue: row.wideValue,
      ),
      dragProxyBuilder: _dragProxyScope(cubit),
      onReorder: row.repeatable
          ? (from, to) => cubit.moveRow(row.listKey, from, to)
          : null,
      onDelete: row.repeatable
          ? (index) => cubit.removeRow(row.listKey, index)
          : null,
      onAdd: row.repeatable ? () => cubit.addRow(row.listKey) : null,
      addLabel: context.s.weListAdd(itemLabel),
      minItems: row.minItems,
      maxItems: row.maxItems,
      minReachedReason: context.s.weListMinReason(row.minItems),
      maxReachedLabel: context.s.weListMaxReached(row.maxItems ?? 0),
      maxReachedReason: context.s.weListMaxReason,
      emptyTitle: context.s.weListEmptyTitle(itemLabel),
      emptyMessage: context.s.weListEmptyMessage,
      structureLocked: structureLocked && row.repeatable,
      structureLockedReason: context.s.weStructureLocked(
        languageName(context, state.sourceLanguage),
      ),
    );
  }
}

/// The two inputs of one pair. The value sits right, right-aligned and
/// tabular, unless it is a sentence.
class _PairFields extends StatelessWidget {
  const _PairFields({
    required this.state,
    required this.label,
    required this.value,
    required this.labelText,
    required this.valueText,
    required this.sharedValue,
    required this.wideValue,
  });

  final SiteContentState state;
  final EditorField? label;
  final EditorField? value;
  final String? labelText;
  final String valueText;
  final bool sharedValue;
  final bool wideValue;

  @override
  Widget build(BuildContext context) {
    final valueField = value == null
        ? const SizedBox.shrink()
        : WebsiteFieldRow(
            state: state,
            field: value!,
            label: valueText,
            numeric: sharedValue && !wideValue,
            // One chip per pair, on the label: two chips side by side double
            // the noise without adding information.
            showStatusChip: labelText == null,
          );

    if (label == null || labelText == null) return valueField;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: WebsiteFieldRow(state: state, field: label!, label: labelText),
        ),
        SizedBox(width: context.styledSpacing.sm),
        if (wideValue)
          Expanded(child: valueField)
        else
          SizedBox(width: 128, child: valueField),
      ],
    );
  }
}

/// A repeatable list whose rows hold several fields, optionally one image.
class _RowListRowView extends StatelessWidget {
  const _RowListRowView({required this.state, required this.row});

  final SiteContentState state;
  final RowListRow row;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final structureLocked = !state.isSourceMode;
    final itemLabel = listItemLabel(context, row.listKey);
    final rowIds = state.rowIdsOfList(row.listKey);

    return StyledFieldList<String>(
      title: listTitle(context, row.listKey),
      counter: context.s.weListCounter(rowIds.length, row.maxItems ?? 0),
      items: rowIds,
      itemLabel: itemLabel,
      itemKey: (rowId) => rowId,
      itemBuilder: (context, rowId, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final sub in row.subs)
            Padding(
              padding: EdgeInsets.only(bottom: context.styledSpacing.sm),
              child: _SubField(
                state: state,
                fieldKey: listFieldKey(row.listKey, rowId, sub.sub),
                label: subFieldLabel(context, row.listKey, sub.sub),
              ),
            ),
          if (row.media)
            _RowMedia(
              state: state,
              rowLabel: '$itemLabel ${index + 1}',
              imageFieldKey: listFieldKey(row.listKey, rowId, 'image'),
              altFieldKey: listFieldKey(row.listKey, rowId, 'alt'),
            ),
        ],
      ),
      dragProxyBuilder: _dragProxyScope(cubit),
      onReorder: row.repeatable
          ? (from, to) => cubit.moveRow(row.listKey, from, to)
          : null,
      onDelete: row.repeatable
          ? (index) => cubit.removeRow(row.listKey, index)
          : null,
      onAdd: row.repeatable ? () => cubit.addRow(row.listKey) : null,
      addLabel: context.s.weListAdd(itemLabel),
      minItems: row.minItems,
      maxItems: row.maxItems,
      minReachedReason: context.s.weListMinReason(row.minItems),
      maxReachedLabel: context.s.weListMaxReached(row.maxItems ?? 0),
      maxReachedReason: context.s.weListMaxReason,
      emptyTitle: context.s.weListEmptyTitle(itemLabel),
      emptyMessage: context.s.weListEmptyMessage,
      structureLocked: structureLocked,
      structureLockedReason: context.s.weStructureLocked(
        languageName(context, state.sourceLanguage),
      ),
      undoMessage: state.pendingRowDelete?.listKey == row.listKey
          ? context.s.weRowDeleted
          : null,
      undoActionLabel: context.s.weUndo,
      onUndo: cubit.undoRowDelete,
    );
  }
}

/// Groups, each a title plus its own list (README §B.3). Two levels is the
/// maximum: a list in a list in a list is a document, not a form.
class _GroupListRowView extends StatelessWidget {
  const _GroupListRowView({required this.state, required this.row});

  final SiteContentState state;
  final GroupListRow row;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final structureLocked = !state.isSourceMode;
    final groupIds = state.rowIdsOfList(row.listKey);
    final groupLabel = listItemLabel(context, row.listKey);
    final itemLabel = subListItemLabel(context, row.listKey);
    final lockedReason = context.s.weStructureLocked(
      languageName(context, state.sourceLanguage),
    );

    return StyledFieldList<String>(
      title: listTitle(context, row.listKey),
      counter: context.s.weListCounter(groupIds.length, row.maxItems ?? 0),
      meta: row.fixedTitles ? context.s.weFixedColumnsMeta : null,
      items: groupIds,
      itemLabel: groupLabel,
      itemKey: (groupId) => groupId,
      addStyle: StyledFieldListAddStyle.dashedBlock,
      // A group is its own block, so it replaces the row chrome.
      rowBuilder: (context, groupId, index) => _GroupBlock(
        state: state,
        row: row,
        groupId: groupId,
        index: index,
        groupLabel: groupLabel,
        itemLabel: itemLabel,
        structureLocked: structureLocked,
        lockedReason: lockedReason,
      ),
      itemBuilder: (context, groupId, index) => const SizedBox.shrink(),
      dragProxyBuilder: _dragProxyScope(cubit),
      onReorder: row.repeatable && !row.fixedTitles
          ? (from, to) => cubit.moveRow(row.listKey, from, to)
          : null,
      onAdd: row.repeatable && !row.fixedTitles
          ? () => cubit.addRow(row.listKey)
          : null,
      addLabel: context.s.weListAdd(groupLabel),
      maxItems: row.maxItems,
      maxReachedLabel: context.s.weListMaxReached(row.maxItems ?? 0),
      maxReachedReason: context.s.weListMaxReason,
      emptyTitle: context.s.weListEmptyTitle(groupLabel),
      emptyMessage: context.s.weListEmptyMessage,
      structureLocked: structureLocked && !row.fixedTitles,
      structureLockedReason: lockedReason,
    );
  }
}

class _GroupBlock extends StatelessWidget {
  const _GroupBlock({
    required this.state,
    required this.row,
    required this.groupId,
    required this.index,
    required this.groupLabel,
    required this.itemLabel,
    required this.structureLocked,
    required this.lockedReason,
  });

  final SiteContentState state;
  final GroupListRow row;
  final String groupId;
  final int index;
  final String groupLabel;
  final String itemLabel;
  final bool structureLocked;
  final String lockedReason;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SiteContentCubit>();
    final itemsKey = groupItemsListKey(row.listKey, groupId, row.itemsListKey);
    final itemFields = state.fieldsOfList(itemsKey);
    final introKey = row.introSub == null
        ? null
        : listFieldKey(row.listKey, groupId, row.introSub!);

    return StyledFieldGroup(
      index: index,
      titleLabel: row.fixedTitles ? fixedGroupTitle(context, row, index) : null,
      titleField: row.fixedTitles
          ? null
          : _SubField(
              state: state,
              fieldKey: listFieldKey(row.listKey, groupId, row.titleSub),
              label: null,
            ),
      onDelete: row.repeatable && !row.fixedTitles
          ? () => cubit.removeRowById(row.listKey, groupId)
          : null,
      actionsDisabledReason: structureLocked ? lockedReason : null,
      dragHandleEnabled: !structureLocked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (introKey != null) ...[
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: StyledWidgetsTheme.of(context).fieldLists.indent,
                bottom: context.styledSpacing.sm,
              ),
              child: _SubField(
                state: state,
                fieldKey: introKey,
                label: context.s.weGroupIntro(index + 1),
                multiline: true,
              ),
            ),
          ],
          StyledFieldList<EditorField>(
            items: itemFields,
            itemLabel: itemLabel,
            itemKey: (field) => field.key,
            itemBuilder: (context, field, i) =>
                WebsiteFieldRow(state: state, field: field, label: null),
            dragProxyBuilder: _dragProxyScope(cubit),
            onReorder: structureLocked
                ? null
                : (from, to) => cubit.moveRow(itemsKey, from, to),
            onDelete: structureLocked
                ? null
                : (i) => cubit.removeRow(itemsKey, i),
            onAdd: () => cubit.addRow(itemsKey),
            addLabel: context.s.weListAdd(itemLabel),
            maxItems: row.maxItemsPerGroup,
            maxReachedLabel: context.s.weListMaxReached(
              row.maxItemsPerGroup ?? 0,
            ),
            maxReachedReason: context.s.weListMaxReason,
            emptyTitle: context.s.weListEmptyTitle(itemLabel),
            emptyMessage: context.s.weListEmptyMessage,
            structureLocked: structureLocked,
            structureLockedReason: lockedReason,
          ),
        ],
      ),
    );
  }
}

/// A media set plus its one summarizing alt-text field.
///
/// The picker itself arrives with the media phase; until then the strip states
/// what it holds and the alt text — the field a translation lane cares about —
/// is fully editable.
class _MediaRowView extends StatelessWidget {
  const _MediaRowView({required this.state, required this.row});

  final SiteContentState state;
  final MediaRow row;

  Future<void> _pick(BuildContext context, MediaLibraryCubit media) async {
    final content = context.read<SiteContentCubit>();
    final chosen = await showMediaPicker(
      context,
      cubit: media,
      title: mediaTitle(context, row.mediaKey),
      mode: row.maxItems == 1
          ? MediaPickerMode.single
          : MediaPickerMode.multiple,
      initialSelection: state.mediaPathsOf(row.mediaKey),
      maxSelection: row.maxItems,
    );
    if (chosen == null) return;
    content.setMediaPaths(row.mediaKey, chosen);
  }

  @override
  Widget build(BuildContext context) {
    final altKey = row.altFieldKey;
    final altField = altKey == null ? null : state.fieldFor(altKey);
    // The library is optional: the demo/seed editor runs without a site, and
    // then there is nothing to pick from. The strip still renders what the
    // content holds, so the card is never a blank.
    final media = context.read<MediaLibraryCubit?>();
    final paths = state.mediaPathsOf(row.mediaKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StyledMediaStrip(
          itemCount: paths.length,
          imageBuilder: (context, index) => media == null
              ? const ColoredBox(color: Colors.transparent)
              : Image.network(
                  media.publicUrlOf(paths[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) =>
                      const Icon(Icons.broken_image_outlined, size: 18),
                ),
          onReorder: state.isSourceMode
              ? (from, to) => context.read<SiteContentCubit>().moveMediaPath(
                  row.mediaKey,
                  from,
                  to,
                )
              : null,
          onRemove: state.isSourceMode
              ? (index) => context.read<SiteContentCubit>().removeMediaPath(
                  row.mediaKey,
                  index,
                )
              : null,
          onAdd: state.isSourceMode && media != null
              // ignore: discarded_futures — the modal resolves into the cubit;
              // there is nothing for this callback to await.
              ? () => _pick(context, media)
              : null,
          addLabel: context.s.weMediaChoose,
          minItems: row.minItems,
          maxItems: row.maxItems,
          minReachedReason: context.s.weMediaMinReached(row.minItems),
          primaryBadgeLabel: row.primaryBadge ? context.s.weMediaFirst : null,
          footnote: state.isSourceMode
              ? context.s.weMediaFootnote(
                  paths.length,
                  row.maxItems,
                  row.minItems,
                )
              : null,
          readOnly: !state.isSourceMode,
        ),
        if (!state.isSourceMode) ...[
          SizedBox(height: context.styledSpacing.sm),
          StyledNotice(
            tone: StyledNoticeTone.neutral,
            icon: Icons.photo_library_outlined,
            // §C.4: photos in the source, alt text per language — the note
            // says both, because the field right below it *is* translated.
            message: context.s.weSharedPhotosNote,
          ),
        ],
        if (altField != null) ...[
          SizedBox(height: context.styledSpacing.sm),
          WebsiteFieldRow(
            state: state,
            field: altField,
            label: context.s.weFieldAltSummary,
          ),
        ],
      ],
    );
  }
}

/// A read-only card: the content belongs to another system, and the card says
/// which one instead of pretending to be editable.
class _ExternalRowView extends StatelessWidget {
  const _ExternalRowView({required this.row});

  final ExternalRow row;

  @override
  Widget build(BuildContext context) {
    return StyledNotice(
      tone: StyledNoticeTone.neutral,
      icon: Icons.lock_outline,
      message: context.s.weExternalLodgifyNote,
    );
  }
}

/// One field inside a row or group, resolved from the state by key.
class _SubField extends StatelessWidget {
  const _SubField({
    required this.state,
    required this.fieldKey,
    required this.label,
    this.multiline = false,
  });

  final SiteContentState state;
  final String fieldKey;
  final String? label;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final field = state.fieldFor(fieldKey);
    if (field == null) return const SizedBox.shrink();
    return WebsiteFieldRow(state: state, field: field, label: label);
  }
}

/// The image of one row (a highlight) plus its per-row alt text.
class _RowMedia extends StatelessWidget {
  const _RowMedia({
    required this.state,
    required this.rowLabel,
    required this.imageFieldKey,
    required this.altFieldKey,
  });

  final SiteContentState state;
  final String rowLabel;
  final String imageFieldKey;
  final String altFieldKey;

  Future<void> _pick(BuildContext context, MediaLibraryCubit media) async {
    final content = context.read<SiteContentCubit>();
    final current = state.valueFor(state.sourceLanguage, imageFieldKey);
    final chosen = await showMediaPicker(
      context,
      cubit: media,
      title: rowLabel,
      mode: MediaPickerMode.single,
      initialSelection: current.isEmpty ? const [] : [current],
      maxSelection: 1,
    );
    if (chosen == null) return;
    content.editSourceField(imageFieldKey, chosen.isEmpty ? '' : chosen.first);
  }

  @override
  Widget build(BuildContext context) {
    // The photo is one file on the row, so it is a field holding a storage
    // path — not one of the `images.*` list slots. Picking is source-mode
    // only: a translation changes the words, never which photo is shown.
    final media = context.read<MediaLibraryCubit?>();
    final path = state.valueFor(state.sourceLanguage, imageFieldKey);
    final canPick = state.isSourceMode && media != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!state.isSourceMode)
          StyledNotice(
            tone: StyledNoticeTone.neutral,
            icon: Icons.image_outlined,
            message: context.s.weSharedPhotosNote,
          )
        else
          StyledMediaStrip(
            itemCount: path.isEmpty ? 0 : 1,
            imageBuilder: (context, _) => media == null
                ? const ColoredBox(color: Colors.transparent)
                : Image.network(
                    media.publicUrlOf(path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) =>
                        const Icon(Icons.broken_image_outlined, size: 18),
                  ),
            maxItems: 1,
            addLabel: context.s.weMediaChoose,
            onAdd: canPick ? () => _pick(context, media) : null,
            onRemove: canPick && path.isNotEmpty
                ? (_) => context.read<SiteContentCubit>().editSourceField(
                    imageFieldKey,
                    '',
                  )
                : null,
          ),
        SizedBox(height: context.styledSpacing.sm),
        _SubField(
          state: state,
          fieldKey: altFieldKey,
          label: context.s.weFieldAlt,
        ),
      ],
    );
  }
}
