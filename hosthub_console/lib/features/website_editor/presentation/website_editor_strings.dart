import 'package:flutter/material.dart';

import 'package:hosthub_console/core/widgets/foundation/foundation.dart';

import '../domain/website_content.dart';

/// Localized display name for a language code (falls back to the code).
String languageName(BuildContext context, String code) {
  switch (code) {
    case 'nl':
      return context.s.weLangDutch;
    case 'en':
      return context.s.weLangEnglish;
    case 'no':
      return context.s.weLangNorwegian;
    default:
      return code.toUpperCase();
  }
}

/// Short uppercase tag for a language code (NL / EN / NO).
String languageShort(String code) =>
    WebsiteSeed.languageShort[code] ?? code.toUpperCase();

/// What a page, a photo set and a list are called — each from the thing
/// itself. These were four switches keyed on a page key, a media key or a list
/// key, every one of them answering the raw key for something it did not know.
String pageName(BuildContext context, WebsiteTemplate template, String key) =>
    template.pageOf(key)?.label?.call(context.s) ?? key;

String mediaTitle(BuildContext context, MediaRow row) =>
    row.title?.call(context.s) ?? context.s.weMediaTitleRowImage;

/// A list's own name and the noun for one of its rows.
///
/// A nested list (a group's items) has no row of its own — it is addressed
/// through its group — so those keep the suffix rule they always had.
String listTitle(BuildContext context, String listKey) {
  if (listKey.endsWith('.items') || listKey.endsWith('.bullets')) {
    return context.s.weListLines;
  }
  final row = kDefaultTemplate.rowForList(listKey);
  return _listTitleOf(row)?.call(context.s) ?? listKey;
}

String listItemLabel(BuildContext context, String listKey) {
  if (listKey.endsWith('.items') || listKey.endsWith('.bullets')) {
    return context.s.weItemLine;
  }
  final row = kDefaultTemplate.rowForList(listKey);
  return _itemLabelOf(row)?.call(context.s) ?? context.s.weItemLine;
}

LabelRef? _listTitleOf(EditorRow? row) => switch (row) {
  ListRow(:final title) ||
  PairListRow(:final title) ||
  RowListRow(:final title) ||
  GroupListRow(:final title) => title,
  _ => null,
};

LabelRef? _itemLabelOf(EditorRow? row) => switch (row) {
  ListRow(:final itemLabel) ||
  PairListRow(:final itemLabel) ||
  RowListRow(:final itemLabel) ||
  GroupListRow(:final itemLabel) => itemLabel,
  _ => null,
};

/// What a card is called, from the card itself.
///
/// These used to be three switches on the card id, each answering something
/// generic for an id it did not know — so a second template's cards would all
/// have read "Content" and nothing would have said so. The card declares them.
String cardTitle(BuildContext context, EditorCard card) =>
    card.title?.call(context.s) ?? context.s.weCardContent;

String? cardSubtitle(BuildContext context, EditorCard card) =>
    card.subtitle?.call(context.s);

IconData cardIcon(EditorCard card) => card.icon ?? Icons.notes_outlined;

/// What a field is called, from the field itself.
///
/// This was a forty-case switch on the field key that answered the *key* for
/// anything it did not recognise — a machine name in the UI, and what every
/// field of a second template would have shown.
String fieldLabel(BuildContext context, String fieldKey) {
  final label = kDefaultTemplate.fieldLabelOf(fieldKey);
  return label?.call(context.s) ?? fieldKey;
}

/// The note a field carries when it is not readable as text on its own page
/// (README §E). Null for a normal field: the preview marks its section.
String? visibilityHint(BuildContext context, FieldVisibility visibility) {
  switch (visibility) {
    case FieldVisibility.inPage:
      return null;
    case FieldVisibility.seo:
      return context.s.weHintSeo;
    case FieldVisibility.map:
      return context.s.weHintMap;
    case FieldVisibility.stateSuccess:
      return context.s.weHintStateSuccess;
    case FieldVisibility.stateError:
      return context.s.weHintStateError;
  }
}

/// The nouns and column headers a list row declares for itself.
///
/// Four more switches keyed on a list key (and, for the subfields, on the sub
/// name) that each answered generic wording for anything they did not know.
String subListItemLabel(BuildContext context, String listKey) {
  final row = kDefaultTemplate.rowForList(listKey);
  final label = row is GroupListRow ? row.subItemLabel : null;
  return label?.call(context.s) ?? context.s.weItemLine;
}

String pairLabelLabel(BuildContext context, String listKey) {
  final row = kDefaultTemplate.rowForList(listKey);
  final label = row is PairListRow ? row.labelLabel : null;
  return label?.call(context.s) ?? context.s.wePairLabel;
}

String pairValueLabel(BuildContext context, String listKey) {
  final row = kDefaultTemplate.rowForList(listKey);
  final label = row is PairListRow ? row.valueLabel : null;
  return label?.call(context.s) ?? context.s.wePairValue;
}

String subFieldLabel(BuildContext context, String listKey, String sub) {
  final row = kDefaultTemplate.rowForList(listKey);
  if (row is RowListRow) {
    for (final entry in row.subs) {
      if (entry.sub == sub) return entry.label?.call(context.s) ?? sub;
    }
  }
  // A media row's alt text is not one of `subs`; it is the row's own field.
  if (sub == RowListRow.altSub) return context.s.weFieldAlt;
  return sub;
}

/// The fixed title of a group in a fixed-title group list
/// (`practical.transport.columns`), by position — a fixed group cannot move.
String fixedGroupTitle(BuildContext context, GroupListRow row, int index) {
  // The row names its own fixed groups; this only picks the one at [index] and
  // falls back to a numbered item label when a row declares none.
  final labels = row.fixedTitleLabels;
  if (labels != null && index < labels.length) {
    return labels[index](context.s);
  }
  return '${listItemLabel(context, row.listKey)} ${index + 1}';
}
