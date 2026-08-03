import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';

/// Why a field is not readable as text on its own page.
///
/// Every field must be pointable at in the preview (README §E). A field the
/// reader cannot find in the rendered page needs a note saying where it lands
/// and why — or it does not belong in the editor. [inPage] fields need none:
/// the preview marks the section they land in.
enum FieldVisibility {
  /// Readable as text on its own page; the preview marks its section.
  inPage,

  /// Not on the page: the browser-tab title and the Google listing.
  seo,

  /// Not text: it decides where the map pin sits.
  map,

  /// Only visible after the form was submitted successfully.
  stateSuccess,

  /// Only visible after the form failed.
  stateError,
}

/// A path segment addressing a repeatable-list row by its stable id.
///
/// The array index is display order; the id is identity. Reads and writes
/// resolve the row by scanning the array for `row['id'] == value`, so a row
/// keeps its translations and its content when the owner drags it elsewhere.
class RowId {
  const RowId(this.value);

  final String value;

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) => other is RowId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Where an editor field lives in the site's content: which document, and the
/// path inside that document's JSON (object keys as String, row ids as
/// [RowId], list indices as int).
class EditorFieldLocation {
  const EditorFieldLocation({
    required this.contentType,
    required this.slug,
    required this.path,
  });

  final String contentType;
  final String slug;
  final List<Object> path;

  /// The field's address as the website knows it, e.g.
  /// `cabin/main:hero.title` or `page/home:highlights.0.description`.
  ///
  /// The live preview speaks this: the console sends values keyed by address,
  /// and the rendered page carries the same address on the element the value is
  /// bound to. Neither side needs to know the other's field names.
  String get address => '$contentType/$slug:${path.join('.')}';
}

/// Marks a position in a path template where a captured segment lands.
///
/// [_rowId] captures a stable row id (resolved against a list); [_key]
/// captures a fixed object key (a form field's slot, a document's own key).
/// A pattern may carry several of both — a nested group list captures the
/// group's id and then the item's.
enum _Slot { rowId, key }

const _rowId = _Slot.rowId;
const _key = _Slot.key;

/// A label the editor shows, resolved against the app's localizations.
///
/// Takes [S] rather than a key string: `intl_utils` generates members, so a
/// lookup by name would not survive codegen. Wrapping the access is what lets
/// a label be *declared* where the thing it names is declared, instead of
/// being looked up by id in a switch far away.
typedef LabelRef = String Function(S s);

/// One row in a card's schema (the handoff's Part D vocabulary).
///
/// The schema is data, read by one renderer: what a card *is* lives here, how
/// it looks lives in the widget layer. A new card is a schema entry and no new
/// widget — that is the test of whether this is built right. Labels are not
/// part of the schema: they are localized content and resolve through the ARB
/// layer (`website_editor_strings.dart`).
sealed class EditorRow {
  const EditorRow();
}

/// A single field bound to one field key.
class FieldRow extends EditorRow {
  const FieldRow(
    this.key, {
    this.label,
    this.multiline = false,
    this.visibility = FieldVisibility.inPage,
    this.autofocus = false,
  });

  /// Stable field key, e.g. `cabin.hero.title`.
  final String key;

  /// What the field is called. Declared here rather than looked up by key in a
  /// switch that answered the raw key — a machine name in the UI — for a key
  /// it did not know.
  final LabelRef? label;
  final bool multiline;

  /// Where this field surfaces. Anything but [FieldVisibility.inPage] carries
  /// a note in the UI; the schema test refuses a field without one.
  final FieldVisibility visibility;

  /// Whether the cursor starts here when the editor opens in source mode.
  ///
  /// A property of the schema, not of the renderer: which field a template
  /// wants the cursor in is the template's business, and the widget layer
  /// naming one field key was the last such literal it carried.
  final bool autofocus;
}

/// A repeatable list of single-value rows, keyed `<listKey>.<rowId>.<sub>`.
///
/// Which rows exist — and in what order — comes from the content, never from
/// the schema: the row id is identity, the array index is display order.
class ListRow extends EditorRow {
  const ListRow(
    this.listKey, {
    this.title,
    this.itemLabel,
    this.sub,
    this.multiline = false,
    this.repeatable = false,
    this.minItems = 1,
    this.maxItems,
  });

  /// Prefix of the row keys (`cabin.description` →
  /// `cabin.description.<id>.text`).
  final String listKey;

  /// What this list is called, and the noun for one of its rows (`Regel 3`).
  ///
  /// Declared here rather than looked up by list key in a switch, which
  /// answered the raw key for a list it did not know.
  final LabelRef? title;
  final LabelRef? itemLabel;

  /// The row's editable subfield (`text`, `description`); appended to the
  /// field key. Null when the row itself is the value.
  final String? sub;
  final bool multiline;

  /// Whether the owner can add, delete and reorder rows.
  final bool repeatable;

  /// Below this count the delete action dims with its reason.
  final int minItems;

  /// At this count the add action dims with its reason.
  final int? maxItems;
}

/// A list of label + value pairs, one row per pair (README §B.2).
class PairListRow extends EditorRow {
  const PairListRow(
    this.listKey, {
    this.title,
    this.itemLabel,
    this.labelLabel,
    this.valueLabel,
    required this.labelSub,
    required this.valueSub,
    this.repeatable = true,
    this.minItems = 1,
    this.maxItems,
    this.sharedValue = false,
    this.wideValue = false,
    this.fixedRows,
    this.fixedRowsAreValues = false,
  });

  final String listKey;

  /// What this list is called, and the noun for one of its rows (`Regel 3`).
  ///
  /// Declared here rather than looked up by list key in a switch, which
  /// answered the raw key for a list it did not know.
  final LabelRef? title;
  final LabelRef? itemLabel;

  /// Subfield holding the label and the value (`label` / `value`).
  final String labelSub;
  final String valueSub;

  /// The headers above the two columns. Null takes the generic pair wording.
  final LabelRef? labelLabel;
  final LabelRef? valueLabel;
  final bool repeatable;
  final int minItems;
  final int? maxItems;

  /// Whether the value is language-independent (`8–9`, `800 m`, `17:00`).
  ///
  /// A schema flag and not pattern recognition: "7 minuten lopen" is a value
  /// too and must be translated. Shared values are read-only in a target
  /// language, carry the `gedeeld` micro chip, and stay out of the
  /// translation request.
  final bool sharedValue;

  /// Values that are sentences (the form placeholders) get the full width
  /// instead of the narrow numeric column.
  final bool wideValue;

  /// Rows the owner cannot add, delete or reorder — they were never theirs to
  /// restructure. Each entry is a key; what it addresses depends on
  /// [fixedRowsAreValues].
  final List<String>? fixedRows;

  /// Whether a [fixedRows] entry *is* the value's field key (`checkIn`), with
  /// the label a system fact that renders as the row title. False means the
  /// entry is a slot and the row has two fields, `<slot>.<labelSub>` and
  /// `<slot>.<valueSub>` — the contact form, whose four slots are fixed by a
  /// backend contract but whose copy is the owner's.
  final bool fixedRowsAreValues;
}

/// A repeatable list whose rows hold several fields (a highlight: title,
/// subline, image, alt).
class RowListRow extends EditorRow {
  const RowListRow(
    this.listKey, {
    this.title,
    this.itemLabel,
    required this.subs,
    this.repeatable = true,
    this.minItems = 1,
    this.maxItems,
    this.media = false,
  });

  final String listKey;

  /// What this list is called, and the noun for one of its rows (`Regel 3`).
  ///
  /// Declared here rather than looked up by list key in a switch, which
  /// answered the raw key for a list it did not know.
  final LabelRef? title;
  final LabelRef? itemLabel;

  /// The row's editable subfields, in order: `(sub, multiline)`.
  final List<({String sub, bool multiline, LabelRef? label})> subs;
  final bool repeatable;
  final int minItems;
  final int? maxItems;

  /// Whether each row carries one image (chosen through the media picker).
  final bool media;

  /// The subfields a media row adds: the picture and the words read out in
  /// its place. Named once here — the schema expansion, the renderer and the
  /// cubit's new-row keys all used to spell them independently.
  static const String imageSub = 'image';
  static const String altSub = 'alt';
}

/// A list of groups, each a title plus its own list of items (README §B.3).
class GroupListRow extends EditorRow {
  const GroupListRow(
    this.listKey, {
    this.title,
    this.itemLabel,
    required this.titleSub,
    required this.itemsListKey,
    required this.itemsSub,
    this.introSub,
    this.repeatable = true,
    this.maxItems,
    this.maxItemsPerGroup,
    this.subItemLabel,
    this.fixedTitles = false,
    this.fixedTitleLabels,
  });

  final String listKey;

  /// What this list is called, and the noun for one of its rows (`Regel 3`).
  ///
  /// Declared here rather than looked up by list key in a switch, which
  /// answered the raw key for a list it did not know.
  final LabelRef? title;
  final LabelRef? itemLabel;

  /// Subfield holding the group's own title.
  final String titleSub;

  /// Suffix of the nested list inside a group (`bullets`, `items`); the full
  /// key is `<listKey>.<groupId>.<itemsListKey>.<itemId>.<itemsSub>`.
  final String itemsListKey;
  final String itemsSub;

  /// Subfield holding the group's introduction, when it has one
  /// (`area.sections`, `practical.layout.sections`).
  final String? introSub;
  final bool repeatable;
  final int? maxItems;
  final int? maxItemsPerGroup;

  /// The noun for one item *inside* a group. Null takes the generic line.
  final LabelRef? subItemLabel;

  /// Whether the group titles are fixed (`practical.transport.columns`): the
  /// title renders as a label and the group cannot be added, deleted or
  /// reordered.
  final bool fixedTitles;

  /// The labels for [fixedTitles] groups, in order.
  ///
  /// Declared here because they belong to this row. They used to live in a
  /// switch keyed on the list key and then on the array *index* — a label
  /// resolved by position, which is the one thing the row ids exist to avoid,
  /// and the last place the presentation layer decided what a template's
  /// sections are called.
  final List<LabelRef>? fixedTitleLabels;
}

/// A set of images, optionally with one summarizing alt-text field (§C).
class MediaRow extends EditorRow {
  const MediaRow(
    this.mediaKey, {
    this.title,
    this.altFieldKey,
    required this.minItems,
    required this.maxItems,
    this.grid = false,
    this.primaryBadge = false,
  });

  /// Where the file keys live in `site_config` (`images.heroPhotos`).
  final String mediaKey;

  /// The picker's own heading for this set.
  final LabelRef? title;

  /// A summarizing alt text — a sentence that gets read out, so content, so
  /// per language (§C.4).
  ///
  /// Null when the site does not render one. All three sets are null today:
  /// the hero's alt comes from `cabin.meta.name`, and both galleries caption
  /// per image rather than per set, so a summarising field wrote text nothing
  /// could ever read.
  final String? altFieldKey;
  final int minItems;
  final int maxItems;

  /// Renders as a grid rather than a strip (the gallery sets).
  final bool grid;

  /// Whether the first tile carries the `Eerste` badge and is the share image.
  final bool primaryBadge;
}

/// A read-only card whose content comes from elsewhere (§A.2, Lodgify).
class ExternalRow extends EditorRow {
  const ExternalRow({required this.source, required this.lineCount});

  /// The system that owns this content (`lodgify`).
  final String source;

  /// How many summary lines the card shows.
  final int lineCount;
}

/// One card in the editor: an identity (icon + localized title resolve through
/// the presentation layer) and the rows it holds.
class EditorCard {
  const EditorCard({
    required this.id,
    required this.rows,
    this.title,
    this.subtitle,
    this.icon,
    this.readOnly = false,
  });

  /// Stable card id. Keys the per-card counters and the `Alleen gewijzigd`
  /// filter — no longer the title, which the card now carries itself.
  final String id;

  /// What the card is called, and the line under it where the design has one.
  ///
  /// Declared here rather than looked up by id in a switch: a switch answers
  /// a generic title for an id it does not know, so a second template's cards
  /// would all be called "Content" and nothing would say so.
  final LabelRef? title;
  final LabelRef? subtitle;
  final IconData? icon;
  final List<EditorRow> rows;

  /// Whether the card is a read-only surface (the section renders disabled
  /// and states its source).
  final bool readOnly;
}

/// Every document this editor may write, by identity rather than position.
///
/// `_fieldPaths` used to address these by index into a list. Inserting an
/// entry in the middle silently repointed every later pattern at the wrong
/// document — and because a missing path reads as an empty string, that
/// showed up as a blank editor and a save into someone else's document
/// rather than as an error.
const kDocCabin = (contentType: 'cabin', slug: 'main');
const kDocHome = (contentType: 'page', slug: 'home');
const kDocPractical = (contentType: 'page', slug: 'practical');
const kDocArea = (contentType: 'page', slug: 'area');
const kDocContactForm = (contentType: 'contact_form', slug: 'main');
const kDocGallery = (contentType: 'page', slug: 'gallery');

/// Photo choices: one set for the whole site, so they live in site_config
/// rather than in a locale's page (README §C.4 — the photo is
/// language-independent, its alt text is not).
const kDocSiteConfig = (contentType: 'site_config', slug: 'main');

/// Privacy. A route on the site, but not a tab in the editor: it is a legal
/// document with a different author and a yearly rhythm, so it is edited
/// under Site-instellingen → Juridisch (§A.6).
const kDocPrivacy = (contentType: 'page', slug: 'privacy');

// -- field <-> document JSON mapping ------------------------------------

/// Resolves an editor field key to the document and the JSON path inside it.
///
/// One table, one lookup: adding a field is a line here plus its row in
/// the page schema ([WebsiteTemplate]), not a branch in a read function and a
/// matching branch in a write function. `{id}` in a pattern captures a
/// stable row id and lands in the path at the [_rowId] position.
const List<
  ({
    String pattern,
    ({String contentType, String slug}) document,
    List<Object> path,
  })
>
_kChaletFieldPaths = [
  // -- Home: hero (README §A.1 card 1) --
  (pattern: 'cabin.hero.title', document: kDocCabin, path: ['hero', 'title']),
  (
    pattern: 'cabin.hero.subtitle',
    document: kDocCabin,
    path: ['hero', 'subtitle'],
  ),
  (
    pattern: 'cabin.meta.locationShort',
    document: kDocCabin,
    path: ['meta', 'locationShort'],
  ),
  (pattern: 'cabin.meta.name', document: kDocCabin, path: ['meta', 'name']),

  // -- Home: key facts (card 2) --
  (
    pattern: 'home.keyFacts.{id}.label',
    document: kDocHome,
    path: ['keyFacts', _rowId, 'label'],
  ),
  (
    pattern: 'home.keyFacts.{id}.value',
    document: kDocHome,
    path: ['keyFacts', _rowId, 'value'],
  ),

  // -- Home: description (card 3) --
  (
    pattern: 'cabin.description.{id}.text',
    document: kDocCabin,
    path: ['description', _rowId, 'text'],
  ),

  // -- Home: gallery selection (card 4) --

  // -- Home: amenities (card 5) — two nesting levels, the maximum --
  (
    pattern: 'cabin.amenities.title',
    document: kDocCabin,
    path: ['amenities', 'title'],
  ),
  (
    pattern: 'cabin.amenities.groups.{id}.title',
    document: kDocCabin,
    path: ['amenities', 'groups', _rowId, 'title'],
  ),
  (
    pattern: 'cabin.amenities.groups.{id}.items.{id}.text',
    document: kDocCabin,
    path: ['amenities', 'groups', _rowId, 'items', _rowId, 'text'],
  ),

  // -- Home: location & distances (card 6) --
  (
    pattern: 'cabin.location.title',
    document: kDocCabin,
    path: ['location', 'title'],
  ),
  (
    pattern: 'cabin.location.distances.{id}.label',
    document: kDocCabin,
    path: ['location', 'distances', _rowId, 'label'],
  ),
  (
    pattern: 'cabin.location.distances.{id}.value',
    document: kDocCabin,
    path: ['location', 'distances', _rowId, 'value'],
  ),
  // Site-wide chrome, in site_config: rendered on every page, one set for
  // the whole site, per language where the text is language-dependent.
  (
    pattern: 'site.mapEmbedUrl',
    document: kDocSiteConfig,
    path: ['mapEmbedUrl'],
  ),
  (pattern: 'site.mapLinkUrl', document: kDocSiteConfig, path: ['mapLinkUrl']),
  (pattern: 'site.name', document: kDocSiteConfig, path: ['name']),
  (pattern: 'site.location', document: kDocSiteConfig, path: ['location']),

  // -- Home: highlights (card 7) --
  (
    pattern: 'home.highlights.{id}.title',
    document: kDocHome,
    path: ['highlights', _rowId, 'title'],
  ),
  (
    pattern: 'home.highlights.{id}.description',
    document: kDocHome,
    path: ['highlights', _rowId, 'description'],
  ),
  (
    pattern: 'home.highlights.{id}.alt',
    document: kDocHome,
    path: ['highlights', _rowId, 'alt'],
  ),
  // One storage path per row — the highlight's own photo, which the grid
  // renders beside the title. Not an `images.*` slot: those are ordered
  // lists for a whole section, this is a single file bound to one row.
  (
    pattern: 'home.highlights.{id}.image',
    document: kDocHome,
    path: ['highlights', _rowId, 'image'],
  ),

  // -- Home: house rules (card 8) — the section the page did not render --
  (
    pattern: 'cabin.rules.title',
    document: kDocCabin,
    path: ['houseRules', 'title'],
  ),
  (
    pattern: 'cabin.rules.bullets.{id}.text',
    document: kDocCabin,
    path: ['houseRules', 'bullets', _rowId, 'text'],
  ),
  (
    pattern: 'cabin.rules.checkIn',
    document: kDocCabin,
    path: ['houseRules', 'checkIn'],
  ),
  (
    pattern: 'cabin.rules.checkOut',
    document: kDocCabin,
    path: ['houseRules', 'checkOut'],
  ),
  (
    pattern: 'cabin.rules.cleaningNote',
    document: kDocCabin,
    path: ['houseRules', 'cleaningNote'],
  ),
  (
    pattern: 'cabin.rules.wifiNote',
    document: kDocCabin,
    path: ['houseRules', 'wifiNote'],
  ),

  // -- Home: contact form (card 9). The four fields are fixed — the form
  // has a backend contract — so the slot is a document key, not a row id.
  (pattern: 'contact.title', document: kDocContactForm, path: ['title']),
  (pattern: 'contact.subtitle', document: kDocContactForm, path: ['subtitle']),
  (
    pattern: 'contact.form.fields.{id}.label',
    document: kDocContactForm,
    path: ['form', _key, 'label'],
  ),
  (
    pattern: 'contact.form.fields.{id}.placeholder',
    document: kDocContactForm,
    path: ['form', _key, 'placeholder'],
  ),
  (
    pattern: 'contact.form.submit',
    document: kDocContactForm,
    path: ['form', 'submit'],
  ),
  (
    pattern: 'contact.form.success',
    document: kDocContactForm,
    path: ['form', 'success'],
  ),
  (
    pattern: 'contact.form.error',
    document: kDocContactForm,
    path: ['form', 'error'],
  ),

  // -- Practical (§A.2) --
  (
    pattern: 'practical.header.title',
    document: kDocPractical,
    path: ['header', 'title'],
  ),
  (
    pattern: 'practical.header.subtitle',
    document: kDocPractical,
    path: ['header', 'subtitle'],
  ),
  (
    pattern: 'practical.quickFacts.{id}.label',
    document: kDocPractical,
    path: ['quickFacts', _rowId, 'label'],
  ),
  (
    pattern: 'practical.quickFacts.{id}.value',
    document: kDocPractical,
    path: ['quickFacts', _rowId, 'value'],
  ),
  (
    pattern: 'practical.arrival.title',
    document: kDocPractical,
    path: ['arrivalAccess', 'title'],
  ),
  // The label is content the Practical page renders, not a system fact, so
  // it is a field of its own. The document spells it `checkInLabel` beside
  // `checkIn` rather than nesting, hence four explicit entries instead of
  // one `{id}` pattern.
  (
    pattern: 'practical.arrival.checkIn.label',
    document: kDocPractical,
    path: ['arrivalAccess', 'checkInLabel'],
  ),
  (
    pattern: 'practical.arrival.checkIn.value',
    document: kDocPractical,
    path: ['arrivalAccess', 'checkIn'],
  ),
  (
    pattern: 'practical.arrival.checkOut.label',
    document: kDocPractical,
    path: ['arrivalAccess', 'checkOutLabel'],
  ),
  (
    pattern: 'practical.arrival.checkOut.value',
    document: kDocPractical,
    path: ['arrivalAccess', 'checkOut'],
  ),
  (
    pattern: 'practical.arrival.bullets.{id}.text',
    document: kDocPractical,
    path: ['arrivalAccess', 'bullets', _rowId, 'text'],
  ),
  (
    pattern: 'practical.parking.title',
    document: kDocPractical,
    path: ['parkingCharging', 'title'],
  ),
  (
    pattern: 'practical.parking.callout',
    document: kDocPractical,
    path: ['parkingCharging', 'callout'],
  ),
  (
    pattern: 'practical.parking.bullets.{id}.text',
    document: kDocPractical,
    path: ['parkingCharging', 'bullets', _rowId, 'text'],
  ),
  (
    pattern: 'practical.layout.title',
    document: kDocPractical,
    path: ['layoutFacilities', 'title'],
  ),
  (
    pattern: 'practical.layout.sections.{id}.title',
    document: kDocPractical,
    path: ['layoutFacilities', 'sections', _rowId, 'title'],
  ),
  (
    pattern: 'practical.layout.sections.{id}.intro',
    document: kDocPractical,
    path: ['layoutFacilities', 'sections', _rowId, 'intro'],
  ),
  (
    pattern: 'practical.layout.sections.{id}.bullets.{id}.text',
    document: kDocPractical,
    path: ['layoutFacilities', 'sections', _rowId, 'bullets', _rowId, 'text'],
  ),
  (
    pattern: 'practical.transport.title',
    document: kDocPractical,
    path: ['transport', 'title'],
  ),
  (
    pattern: 'practical.agreements.title',
    document: kDocPractical,
    path: ['agreementsAndPayment', 'title'],
  ),
  (
    pattern: 'practical.agreements.blocks.{id}.title',
    document: kDocPractical,
    path: ['agreementsAndPayment', 'blocks', _rowId, 'title'],
  ),
  (
    pattern: 'practical.agreements.blocks.{id}.items.{id}.text',
    document: kDocPractical,
    path: ['agreementsAndPayment', 'blocks', _rowId, 'items', _rowId, 'text'],
  ),
  (
    pattern: 'practical.transport.columns.{id}.title',
    document: kDocPractical,
    path: ['transport', 'columns', _rowId, 'title'],
  ),
  (
    pattern: 'practical.transport.columns.{id}.bullets.{id}.text',
    document: kDocPractical,
    path: ['transport', 'columns', _rowId, 'bullets', _rowId, 'text'],
  ),
  (
    pattern: 'practical.goodToKnow.title',
    document: kDocPractical,
    path: ['goodToKnow', 'title'],
  ),
  (
    pattern: 'practical.goodToKnow.bullets.{id}.text',
    document: kDocPractical,
    path: ['goodToKnow', 'bullets', _rowId, 'text'],
  ),
  (
    pattern: 'practical.contactHelp.title',
    document: kDocPractical,
    path: ['contactHelp', 'title'],
  ),
  (
    pattern: 'practical.contactHelp.bullets.{id}.text',
    document: kDocPractical,
    path: ['contactHelp', 'bullets', _rowId, 'text'],
  ),

  // -- Area (§A.3). The intro of a section is spelled `description` in this
  // document and `intro` on Practical; the path table is where that lives.
  (pattern: 'area.intro', document: kDocArea, path: ['intro']),
  (
    pattern: 'area.sections.{id}.title',
    document: kDocArea,
    path: ['sections', _rowId, 'title'],
  ),
  (
    pattern: 'area.sections.{id}.intro',
    document: kDocArea,
    path: ['sections', _rowId, 'description'],
  ),
  (
    pattern: 'area.sections.{id}.bullets.{id}.text',
    document: kDocArea,
    path: ['sections', _rowId, 'bullets', _rowId, 'text'],
  ),

  // -- Gallery (§A.4). The tagline lands on more than one page; its hint
  // says so, because a field that surfaces twice must not be a surprise.
  (pattern: 'home.tagline', document: kDocHome, path: ['tagline']),

  // -- Legal: privacy (§A.6), edited under Site-instellingen --
  (pattern: 'legal.privacy.intro', document: kDocPrivacy, path: ['intro']),
  (
    pattern: 'legal.privacy.bullets.{id}.text',
    document: kDocPrivacy,
    path: ['bullets', _rowId, 'text'],
  ),
];

/// One page of a website template: its cards, in the order the page renders
/// them, and whether the editor offers it as a tab.
class TemplatePage {
  const TemplatePage({
    required this.key,
    required this.cards,
    this.showAsTab = true,
    this.label,
  });

  final String key;

  /// What the tab and the publish dialog call this page.
  final LabelRef? label;
  final List<EditorCard> cards;

  /// Whether this page is one of the editor's tabs.
  ///
  /// Legal is false: it is a page of the site but not a tab of the editor. A
  /// fifth tab invites editing exactly what you do not want casually edited,
  /// so it is reached through Site-instellingen instead — while running
  /// through the same schema, the same translation model and the same
  /// explicit save as everything else.
  final bool showAsTab;
}

/// What one website template offers the editor: its pages, in order.
///
/// An instance rather than a set of globals. The schema used to be top-level
/// consts read straight from the cubit, the repository, two widgets and the
/// tests, so a second template — different sections, a different order — had
/// nowhere to exist. Order is the list: the tabs, the publish dialog's
/// per-page breakdown and the field enumeration all read the same one, which
/// is why `legal` no longer arrives first anywhere.
class WebsiteTemplate {
  const WebsiteTemplate({
    required this.id,
    required this.pages,
    required this.fieldPaths,
    this.mediaSlots = const (document: kDocSiteConfig, jsonKey: 'images'),
  });

  final String id;
  final List<TemplatePage> pages;

  /// Where each field key lives: which document, and the path inside its JSON.
  ///
  /// Per template, not global. The cards say what the editor offers; this says
  /// where each of those values is stored, and a second template answers both
  /// differently.
  final List<
    ({
      String pattern,
      ({String contentType, String slug}) document,
      List<Object> path,
    })
  >
  fieldPaths;

  /// Where the photo slots live: one document for the whole site, and the JSON
  /// key they sit under.
  ///
  /// A photo choice is language-independent, so it cannot live in a locale's
  /// page. Both sides of the repository used to name `site_config/main` and
  /// `images` in literals, which is two more places a second template would
  /// have had to agree with.
  final ({({String contentType, String slug}) document, String jsonKey})
  mediaSlots;

  /// The document JSON key a media key addresses (`images.heroPhotos` →
  /// `heroPhotos`), or null when the key is not one of this template's slots.
  String? mediaJsonKeyOf(String mediaKey) {
    final prefix = '${mediaSlots.jsonKey}.';
    return mediaKey.startsWith(prefix)
        ? mediaKey.substring(prefix.length)
        : null;
  }

  /// Page keys in template order, tabs only.
  List<String> get tabPages => [
    for (final page in pages)
      if (page.showAsTab) page.key,
  ];

  /// Every page key in template order, tabs and the rest.
  List<String> get pageKeys => [for (final page in pages) page.key];

  /// The page with this key, or null when the template has none.
  TemplatePage? pageOf(String pageKey) {
    for (final page in pages) {
      if (page.key == pageKey) return page;
    }
    return null;
  }

  List<EditorCard> cardsOf(String pageKey) {
    for (final page in pages) {
      if (page.key == pageKey) return page.cards;
    }
    return const [];
  }

  /// The fields of one page, with its repeatable lists expanded against the
  /// row ids the content actually holds.
  List<EditorField> fieldsFor(
    String pageKey,
    Map<String, List<String>> listOrder,
  ) {
    final fields = <EditorField>[];
    for (final card in cardsOf(pageKey)) {
      for (final row in card.rows) {
        fields.addAll(_fieldsOfRow(row, card.id, listOrder));
      }
    }
    return fields;
  }

  /// Every repeatable list in the template, with the row type that owns it —
  /// what the repository enumerates to learn which lists to read row ids for.
  List<({String listKey, String? itemsListKey})> get lists => [
    for (final page in pages)
      for (final card in page.cards)
        for (final row in card.rows)
          ...switch (row) {
            ListRow(:final listKey) => [(listKey: listKey, itemsListKey: null)],
            PairListRow(:final listKey, :final fixedRows) =>
              fixedRows == null ? [(listKey: listKey, itemsListKey: null)] : [],
            RowListRow(:final listKey) => [
              (listKey: listKey, itemsListKey: null),
            ],
            GroupListRow(:final listKey, :final itemsListKey) => [
              (listKey: listKey, itemsListKey: itemsListKey),
            ],
            FieldRow() || MediaRow() || ExternalRow() => const [],
          },
  ];

  /// Where one editor field lives: which document, and the path within its JSON.
  /// Path segments are object keys (String), row-id lookups ([RowId]) or plain
  /// list indices (int).
  EditorFieldLocation? locationOf(String fieldKey) {
    for (final entry in fieldPaths) {
      final captures = _match(entry.pattern, fieldKey);
      if (captures == null) continue;
      final document = entry.document;
      var next = 0;
      return EditorFieldLocation(
        contentType: document.contentType,
        slug: document.slug,
        path: [
          // Each slot in the table takes the next captured segment, in order.
          for (final segment in entry.path)
            if (segment == _rowId)
              RowId(captures[next++])
            else if (segment == _key)
              captures[next++]
            else
              segment,
        ],
      );
    }
    return null;
  }

  /// The document and array path a repeatable list lives at, from the same
  /// table. [listKey] is a field-key prefix ending right before the row id;
  /// for a nested list the enclosing ids are supplied in [enclosingIds], in
  /// order, and land at their slots. Null for an unknown list.
  ({({String contentType, String slug}) document, List<Object> arrayPath})?
  listLocationOf(String listKey, {List<String> enclosingIds = const []}) {
    for (final entry in fieldPaths) {
      final prefix = _patternPrefixOf(entry.pattern, enclosingIds.length);
      if (prefix != listKey) continue;
      // The array sits at the path up to the slot that takes the row id.
      var seen = 0;
      var arrayEnd = -1;
      for (var i = 0; i < entry.path.length; i++) {
        if (entry.path[i] != _rowId && entry.path[i] != _key) continue;
        if (seen == enclosingIds.length) {
          arrayEnd = i;
          break;
        }
        seen++;
      }
      if (arrayEnd < 0) continue;
      var next = 0;
      return (
        document: entry.document,
        arrayPath: [
          for (final segment in entry.path.sublist(0, arrayEnd))
            if (segment == _rowId)
              RowId(enclosingIds[next++])
            else if (segment == _key)
              enclosingIds[next++]
            else
              segment,
        ],
      );
    }
    return null;
  }

  /// The literal part of a pattern up to (but excluding) placeholder
  /// number [placeholderIndex] — `cabin.amenities.groups.{id}.items.{id}.text`
  /// with 1 gives `cabin.amenities.groups.{id}.items`, with the earlier
  /// placeholders left in place so a caller can compare against a list key it
  /// built from real ids.
  String _patternPrefixOf(String pattern, int placeholderIndex) {
    var from = 0;
    for (var i = 0; i < placeholderIndex; i++) {
      final next = pattern.indexOf('{id}', from);
      if (next == -1) return pattern;
      from = next + '{id}'.length;
    }
    final placeholder = pattern.indexOf('{id}', from);
    if (placeholder == -1) return pattern;
    // Strip the '.' before the placeholder.
    return pattern.substring(0, placeholder - 1);
  }

  /// Matches a field key against a pattern, returning the captured segments in
  /// order, or null when it does not match. `{id}` captures one dot-free
  /// segment (a row id or a fixed slot key).
  List<String>? _match(String pattern, String fieldKey) {
    final parts = pattern.split('{id}');
    if (parts.length == 1) return pattern == fieldKey ? const [] : null;

    final captures = <String>[];
    var cursor = 0;
    for (var i = 0; i < parts.length; i++) {
      final literal = parts[i];
      if (!fieldKey.startsWith(literal, cursor)) return null;
      cursor += literal.length;
      if (i == parts.length - 1) break;

      // The capture runs to the next '.' — segments are dot-free.
      final end = fieldKey.indexOf('.', cursor);
      final stop = end == -1 ? fieldKey.length : end;
      final capture = fieldKey.substring(cursor, stop);
      if (capture.isEmpty) return null;
      captures.add(capture);
      cursor = stop;
    }
    return cursor == fieldKey.length ? captures : null;
  }

  /// What a field key is called, or null when no row declares it.
  LabelRef? fieldLabelOf(String fieldKey) {
    for (final page in pages) {
      for (final card in page.cards) {
        for (final row in card.rows) {
          if (row is FieldRow && row.key == fieldKey) return row.label;
        }
      }
    }
    return null;
  }

  /// The page a field key belongs to, or null when no card claims it.
  ///
  /// Used for the informational `page` column on a translation row. It used to
  /// be the constant 'home' for every field of every page.
  String? pageOfField(String fieldKey) {
    for (final page in pages) {
      for (final card in page.cards) {
        for (final row in card.rows) {
          if (_rowClaimsField(row, fieldKey)) return page.key;
        }
      }
    }
    return null;
  }

  /// The row that owns a list key, or null when it is unknown.
  EditorRow? rowForList(String listKey) {
    for (final page in pages) {
      for (final card in page.cards) {
        for (final row in card.rows) {
          if (_rowOwnsList(row, listKey)) return row;
        }
      }
    }
    return null;
  }
}

// The transport section's fixed column names. Free functions rather than
// closures so the schema stays a `const`.
// A media row's subfields: generic editor vocabulary, shared by any template.
String _subTitle(S s) => s.weFieldTitle;
String _subSubline(S s) => s.weFieldSubline;

String _columnCar(S s) => s.weColumnCar;
String _columnAirports(S s) => s.weColumnAirports;
String _columnPublicTransport(S s) => s.weColumnPublicTransport;
String _columnParking(S s) => s.weColumnParking;
String _columnNotes(S s) => s.weColumnNotes;

/// The legal document's page key.
const String kLegalPage = 'legal';

/// Every template the console can render, by id.
///
/// One entry today. It exists so `sites.template_id` resolves to something —
/// the column records which template a site is built from, and this is what
/// turns that string back into a schema.
Map<String, WebsiteTemplate> get kTemplates => {
  kDefaultTemplate.id: kDefaultTemplate,
};

/// The template with this id, or the default when the id is unknown.
///
/// Falls back rather than failing: a site whose template was renamed should
/// still open, with the wrong labels, instead of showing nothing at all.
WebsiteTemplate templateFor(String? id) =>
    (id == null ? null : kTemplates[id]) ?? kDefaultTemplate;

/// The one template today: the chalet site this editor was built for.
final WebsiteTemplate kDefaultTemplate = WebsiteTemplate(
  id: 'chalet-v1',
  fieldPaths: _kChaletFieldPaths,
  pages: [
    TemplatePage(key: 'home', cards: _homeCards, label: (s) => s.wePageHome),
    TemplatePage(
      key: 'practical',
      cards: _practicalCards,
      label: (s) => s.wePagePractical,
    ),
    TemplatePage(key: 'area', cards: _areaCards, label: (s) => s.wePageArea),
    TemplatePage(
      key: 'gallery',
      cards: _galleryCards,
      label: (s) => s.wePageGallery,
    ),
    // Last, and not a tab: see TemplatePage.showAsTab.
    TemplatePage(
      key: kLegalPage,
      cards: _legalCards,
      showAsTab: false,
      label: (s) => s.wePageLegal,
    ),
  ],
);

final List<EditorCard> _legalCards = [
  EditorCard(
    id: 'privacy',
    title: (s) => s.weCardPrivacy,
    rows: [
      FieldRow(
        'legal.privacy.intro',
        label: (s) => s.weFieldPrivacyIntro,
        multiline: true,
      ),
      ListRow(
        'legal.privacy.bullets',
        title: (s) => s.weListLines,
        sub: 'text',
        multiline: true,
        repeatable: true,
        minItems: 1,
      ),
    ],
  ),
];

final List<EditorCard> _homeCards = [
  // Site chrome: the name in the header, tab title and share card, and the
  // line beside it in the footer. It sits on Home because that is where the
  // owner meets the header first, but it is one set for the whole site —
  // every page renders it.
  EditorCard(
    id: 'siteChrome',
    title: (s) => s.weCardSiteChrome,
    subtitle: (s) => s.weCardSiteChromeSub,
    icon: Icons.public,
    rows: [
      FieldRow('site.name', label: (s) => s.weFieldSiteName),
      FieldRow('site.location', label: (s) => s.weFieldSiteLocation),
    ],
  ),
  EditorCard(
    id: 'hero',
    title: (s) => s.weCardHero,
    subtitle: (s) => s.weCardHeroSub,
    icon: Icons.auto_awesome,
    rows: [
      FieldRow(
        'cabin.hero.title',
        label: (s) => s.weFieldHeadline,
        autofocus: true,
      ),
      FieldRow('cabin.meta.locationShort', label: (s) => s.weFieldLocationLine),
      MediaRow(
        // The media key IS the document path: the repository writes
        // `images[key.split('.').last]` and reads back `images.<key>`, and
        // the website reads `images.heroPhotos`. A short name like
        // `hero.photos` lands on `images.photos`, which nothing reads, and
        // never matches on the way back — so the picker stays empty and
        // saving is a no-op.
        'images.heroPhotos',
        title: (s) => s.weMediaTitleHero,
        minItems: 1,
        maxItems: 5,
        primaryBadge: true,
      ),
      FieldRow(
        'cabin.hero.subtitle',
        label: (s) => s.weFieldSubtitle,
        multiline: true,
        visibility: FieldVisibility.seo,
      ),
      FieldRow(
        'cabin.meta.name',
        label: (s) => s.weFieldSearchName,
        visibility: FieldVisibility.seo,
      ),
    ],
  ),
  EditorCard(
    id: 'keyFacts',
    title: (s) => s.weCardKeyFacts,
    subtitle: (s) => s.weCardKeyFactsSub,
    icon: Icons.bed_outlined,
    rows: [
      PairListRow(
        'home.keyFacts',
        title: (s) => s.weListKeyFacts,
        itemLabel: (s) => s.weItemKeyFact,
        labelSub: 'label',
        valueSub: 'value',
        minItems: 3,
        maxItems: 6,
        sharedValue: true,
      ),
    ],
  ),
  EditorCard(
    id: 'description',
    title: (s) => s.weCardDescription,
    icon: Icons.notes_outlined,
    rows: [
      ListRow(
        'cabin.description',
        title: (s) => s.weListParagraphs,
        itemLabel: (s) => s.weItemParagraph,
        sub: 'text',
        multiline: true,
        repeatable: true,
        maxItems: 4,
      ),
    ],
  ),
  EditorCard(
    id: 'homeGallery',
    title: (s) => s.weCardHomeGallery,
    subtitle: (s) => s.weCardHomeGallerySub,
    icon: Icons.image_outlined,
    rows: [
      MediaRow('images.homeGallery', minItems: 5, maxItems: 8, grid: true),
    ],
  ),
  EditorCard(
    id: 'amenities',
    title: (s) => s.weCardAmenities,
    subtitle: (s) => s.weCardAmenitiesSub,
    icon: Icons.list_alt_outlined,
    rows: [
      FieldRow('cabin.amenities.title', label: (s) => s.weFieldTitle),
      GroupListRow(
        'cabin.amenities.groups',
        title: (s) => s.weListGroups,
        itemLabel: (s) => s.weItemGroup,
        subItemLabel: (s) => s.weItemAmenity,
        titleSub: 'title',
        itemsListKey: 'items',
        itemsSub: 'text',
        maxItems: 12,
      ),
    ],
  ),
  EditorCard(
    id: 'location',
    title: (s) => s.weCardLocation,
    icon: Icons.place_outlined,
    rows: [
      FieldRow('cabin.location.title', label: (s) => s.weFieldTitle),
      PairListRow(
        'cabin.location.distances',
        title: (s) => s.weListDistances,
        itemLabel: (s) => s.weItemDistance,
        labelLabel: (s) => s.wePairWhat,
        valueLabel: (s) => s.wePairDistance,
        labelSub: 'label',
        valueSub: 'value',
        maxItems: 8,
        sharedValue: true,
      ),
      // The two urls the map is actually built from. `location.mapQuery`
      // used to sit here as "map search term", but the document never held
      // one, and the preview's rewrite set `?q=` on an OpenStreetMap embed
      // that positions itself with `bbox=` — so the field the owner could
      // edit moved nothing, and the values that place the pin and the
      // "open in maps" link could not be reached from any screen.
      FieldRow(
        'site.mapEmbedUrl',
        label: (s) => s.weFieldMapEmbedUrl,
        visibility: FieldVisibility.map,
      ),
      FieldRow(
        'site.mapLinkUrl',
        label: (s) => s.weFieldMapLinkUrl,
        visibility: FieldVisibility.map,
      ),
    ],
  ),
  EditorCard(
    id: 'highlights',
    title: (s) => s.weCardHighlights,
    subtitle: (s) => s.weCardHighlightsSub,
    icon: Icons.star_outline,
    rows: [
      RowListRow(
        'home.highlights',
        title: (s) => s.weCardHighlights,
        itemLabel: (s) => s.weItemHighlight,
        subs: [
          (sub: 'title', multiline: false, label: _subTitle),
          (sub: 'description', multiline: false, label: _subSubline),
        ],
        minItems: 2,
        maxItems: 6,
        media: true,
      ),
    ],
  ),
  EditorCard(
    id: 'houseRules',
    title: (s) => s.weCardHouseRules,
    subtitle: (s) => s.weCardHouseRulesSub,
    icon: Icons.rule_outlined,
    rows: [
      FieldRow('cabin.rules.title', label: (s) => s.weFieldTitle),
      ListRow(
        'cabin.rules.bullets',
        title: (s) => s.weListLines,
        sub: 'text',
        repeatable: true,
        maxItems: 8,
      ),
      PairListRow(
        'cabin.rules.times',
        title: (s) => s.weListTimes,
        itemLabel: (s) => s.weItemTime,
        labelSub: 'label',
        valueSub: 'value',
        sharedValue: true,
        repeatable: false,
        fixedRows: ['cabin.rules.checkIn', 'cabin.rules.checkOut'],
        fixedRowsAreValues: true,
      ),
      FieldRow(
        'cabin.rules.cleaningNote',
        label: (s) => s.weFieldCleaningNote,
        multiline: true,
      ),
      FieldRow(
        'cabin.rules.wifiNote',
        label: (s) => s.weFieldWifiNote,
        multiline: true,
      ),
    ],
  ),
  EditorCard(
    id: 'contact',
    title: (s) => s.weCardContact,
    subtitle: (s) => s.weCardContactSub,
    icon: Icons.mail_outline,
    rows: [
      FieldRow('contact.title', label: (s) => s.weFieldTitle),
      FieldRow(
        'contact.subtitle',
        label: (s) => s.weFieldSubtitle,
        multiline: true,
      ),
      // The four fields are fixed: the form has a backend contract, so only
      // the copy is the owner's.
      PairListRow(
        'contact.form.fields',
        title: (s) => s.weListFormFields,
        itemLabel: (s) => s.weItemFormField,
        labelSub: 'label',
        valueSub: 'placeholder',
        repeatable: false,
        wideValue: true,
        fixedRows: [
          'contact.form.fields.name',
          'contact.form.fields.email',
          'contact.form.fields.period',
          'contact.form.fields.message',
        ],
      ),
      FieldRow('contact.form.submit', label: (s) => s.weFieldSubmit),
      FieldRow(
        'contact.form.success',
        label: (s) => s.weFieldSuccess,
        multiline: true,
        visibility: FieldVisibility.stateSuccess,
      ),
      FieldRow(
        'contact.form.error',
        label: (s) => s.weFieldError,
        multiline: true,
        visibility: FieldVisibility.stateError,
      ),
    ],
  ),
];

final List<EditorCard> _practicalCards = [
  EditorCard(
    id: 'practicalHeader',
    title: (s) => s.weCardHeader,
    icon: Icons.auto_awesome,
    rows: [
      FieldRow('practical.header.title', label: (s) => s.weFieldTitle),
      FieldRow(
        'practical.header.subtitle',
        label: (s) => s.weFieldSubtitle,
        multiline: true,
      ),
    ],
  ),
  EditorCard(
    id: 'quickFacts',
    title: (s) => s.weCardQuickFacts,
    subtitle: (s) => s.weCardQuickFactsSub,
    icon: Icons.schedule_outlined,
    rows: [
      PairListRow(
        'practical.quickFacts',
        title: (s) => s.weListFacts,
        itemLabel: (s) => s.weItemFact,
        labelSub: 'label',
        valueSub: 'value',
        minItems: 2,
        maxItems: 6,
        sharedValue: true,
      ),
    ],
  ),
  EditorCard(
    id: 'arrival',
    title: (s) => s.weCardArrival,
    icon: Icons.route_outlined,
    rows: [
      FieldRow('practical.arrival.title', label: (s) => s.weFieldTitle),
      // Slots, not bare values: unlike the home page's house rules, the
      // Practical page renders its own `checkInLabel`/`checkOutLabel` from
      // the document (arrivalAccess), and they differ per language —
      // "Innsjekk" in Norwegian. Treating them as a system fact left copy
      // on the live page that no field in the console could reach.
      PairListRow(
        'practical.arrival.times',
        title: (s) => s.weListTimes,
        itemLabel: (s) => s.weItemTime,
        labelSub: 'label',
        valueSub: 'value',
        sharedValue: true,
        repeatable: false,
        fixedRows: ['practical.arrival.checkIn', 'practical.arrival.checkOut'],
      ),
      ListRow(
        'practical.arrival.bullets',
        title: (s) => s.weListLines,
        sub: 'text',
        multiline: true,
        repeatable: true,
        maxItems: 8,
      ),
    ],
  ),
  EditorCard(
    id: 'parking',
    title: (s) => s.weCardParking,
    icon: Icons.directions_car_outlined,
    rows: [
      FieldRow('practical.parking.title', label: (s) => s.weFieldTitle),
      ListRow(
        'practical.parking.bullets',
        title: (s) => s.weListLines,
        sub: 'text',
        multiline: true,
        repeatable: true,
        maxItems: 6,
      ),
      FieldRow(
        'practical.parking.callout',
        label: (s) => s.weFieldCallout,
        multiline: true,
      ),
    ],
  ),
  EditorCard(
    id: 'layout',
    title: (s) => s.weCardLayout,
    subtitle: (s) => s.weCardLayoutSub,
    icon: Icons.bed_outlined,
    rows: [
      FieldRow('practical.layout.title', label: (s) => s.weFieldTitle),
      GroupListRow(
        'practical.layout.sections',
        title: (s) => s.weListSections,
        itemLabel: (s) => s.weItemSection,
        titleSub: 'title',
        itemsListKey: 'bullets',
        itemsSub: 'text',
        introSub: 'intro',
        maxItems: 6,
      ),
    ],
  ),
  EditorCard(
    id: 'transport',
    title: (s) => s.weCardTransport,
    subtitle: (s) => s.weCardTransportSub,
    icon: Icons.route_outlined,
    rows: [
      FieldRow('practical.transport.title', label: (s) => s.weFieldTitle),
      GroupListRow(
        'practical.transport.columns',
        title: (s) => s.weListColumns,
        itemLabel: (s) => s.weItemColumn,
        titleSub: 'title',
        itemsListKey: 'bullets',
        itemsSub: 'text',
        maxItems: 5,
        fixedTitles: true,
        // Five slots the transport section always has, named where they are
        // declared rather than by position in a switch.
        fixedTitleLabels: [
          _columnCar,
          _columnAirports,
          _columnPublicTransport,
          _columnParking,
          _columnNotes,
        ],
      ),
    ],
  ),
  EditorCard(
    id: 'goodToKnow',
    title: (s) => s.weCardGoodToKnow,
    icon: Icons.info_outline,
    rows: [
      FieldRow('practical.goodToKnow.title', label: (s) => s.weFieldTitle),
      ListRow(
        'practical.goodToKnow.bullets',
        title: (s) => s.weListLines,
        sub: 'text',
        multiline: true,
        repeatable: true,
        maxItems: 10,
      ),
    ],
  ),
  EditorCard(
    id: 'contactHelp',
    title: (s) => s.weCardContactHelp,
    icon: Icons.mail_outline,
    rows: [
      FieldRow('practical.contactHelp.title', label: (s) => s.weFieldTitle),
      ListRow(
        'practical.contactHelp.bullets',
        title: (s) => s.weListLines,
        sub: 'text',
        multiline: true,
        repeatable: true,
        maxItems: 6,
      ),
    ],
  ),
  // Was read-only, sourced from Lodgify. Nothing syncs Lodgify into this
  // section — not the console, not the website, not a function — so the
  // owner saw their own payment and cancellation terms on the live page
  // with no way to change them. Same shape as practical.transport.columns.
  EditorCard(
    id: 'agreements',
    title: (s) => s.weCardAgreements,
    icon: Icons.notes_outlined,
    rows: [
      FieldRow('practical.agreements.title', label: (s) => s.weFieldTitle),
      GroupListRow(
        'practical.agreements.blocks',
        title: (s) => s.weListSections,
        itemLabel: (s) => s.weItemSection,
        titleSub: 'title',
        itemsListKey: 'items',
        itemsSub: 'text',
        maxItems: 6,
      ),
    ],
  ),
];

final List<EditorCard> _areaCards = [
  EditorCard(
    id: 'areaIntro',
    title: (s) => s.weCardAreaIntro,
    subtitle: (s) => s.weCardAreaIntroSub,
    icon: Icons.auto_awesome,
    rows: [
      FieldRow('area.intro', label: (s) => s.weFieldIntro, multiline: true),
    ],
  ),
  EditorCard(
    id: 'areaSections',
    title: (s) => s.weCardAreaSections,
    subtitle: (s) => s.weCardAreaSectionsSub,
    icon: Icons.list_alt_outlined,
    rows: [
      GroupListRow(
        'area.sections',
        title: (s) => s.weListSections,
        itemLabel: (s) => s.weItemSection,
        titleSub: 'title',
        itemsListKey: 'bullets',
        itemsSub: 'text',
        introSub: 'intro',
        maxItems: 8,
      ),
    ],
  ),
];

final List<EditorCard> _galleryCards = [
  EditorCard(
    id: 'galleryHeader',
    title: (s) => s.weCardHeader,
    subtitle: (s) => s.weCardGalleryHeaderSub,
    icon: Icons.auto_awesome,
    rows: [
      FieldRow(
        'home.tagline',
        label: (s) => s.weFieldSubtitle,
        multiline: true,
      ),
    ],
  ),
  EditorCard(
    id: 'galleryAll',
    title: (s) => s.weCardGalleryAll,
    subtitle: (s) => s.weCardGalleryAllSub,
    icon: Icons.image_outlined,
    rows: [
      MediaRow('images.galleryAll', minItems: 6, maxItems: 40, grid: true),
    ],
  ),
];

/// The field key of one list row: `<listKey>.<rowId>[.<sub>]`.
String listFieldKey(String listKey, String rowId, String? sub) =>
    sub == null ? '$listKey.$rowId' : '$listKey.$rowId.$sub';

/// Makes the stable id a new list row carries for life: 8 lowercase base36
/// characters. It only has to be unique within one list; the migration gives
/// existing rows deterministic ids of the same shape.
String generateRowId() {
  final random = Random.secure();
  const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return [
    for (var i = 0; i < 8; i++) alphabet[random.nextInt(alphabet.length)],
  ].join();
}

/// The list key of a group's nested item list:
/// `<listKey>.<groupId>.<itemsListKey>`.
String groupItemsListKey(String listKey, String groupId, String itemsListKey) =>
    '$listKey.$groupId.$itemsListKey';

/// One concrete editable field, expanded from the schema.
class EditorField extends Equatable {
  const EditorField({
    required this.key,
    required this.cardId,
    this.multiline = false,
    this.visibility = FieldVisibility.inPage,
    this.listKey,
    this.rowId,
    this.sharedValue = false,
  });

  /// Stable field key, e.g. `cabin.hero.title`,
  /// `home.highlights.a1b2c3d4.description`.
  final String key;

  /// The card this field renders on.
  final String cardId;
  final bool multiline;
  final FieldVisibility visibility;

  /// The list this field is a row of; null for a plain field.
  final String? listKey;

  /// The stable id of the row this field belongs to; null for a plain field.
  final String? rowId;

  /// Whether this field's value is language-independent — read-only in a
  /// target language and left out of the translation request.
  final bool sharedValue;

  @override
  List<Object?> get props => [
    key,
    cardId,
    multiline,
    visibility,
    listKey,
    rowId,
    sharedValue,
  ];
}

/// Expands one page's schema into concrete fields: plain fields as-is, list
/// rows one field per row id in [listOrder] (identity from the content, order
/// from the content). Media rows contribute their alt-text field; the image
/// keys themselves are not translatable text.
List<EditorField> _fieldsOfRow(
  EditorRow row,
  String cardId,
  Map<String, List<String>> listOrder,
) {
  switch (row) {
    case FieldRow(:final key, :final multiline, :final visibility):
      return [
        EditorField(
          key: key,
          cardId: cardId,
          multiline: multiline,
          visibility: visibility,
        ),
      ];

    case ListRow(:final listKey, :final sub, :final multiline):
      return [
        for (final rowId in listOrder[listKey] ?? const <String>[])
          EditorField(
            key: listFieldKey(listKey, rowId, sub),
            cardId: cardId,
            multiline: multiline,
            listKey: listKey,
            rowId: rowId,
          ),
      ];

    case PairListRow(
      :final listKey,
      :final labelSub,
      :final valueSub,
      :final sharedValue,
      :final wideValue,
      :final fixedRows,
      :final fixedRowsAreValues,
    ):
      if (fixedRows != null) {
        // A fixed *value* row is one field on a scalar path; the label is a
        // system fact and not a field at all.
        if (fixedRowsAreValues) {
          return [
            for (final key in fixedRows)
              EditorField(
                key: key,
                cardId: cardId,
                listKey: listKey,
                rowId: key,
                multiline: wideValue,
                sharedValue: sharedValue,
              ),
          ];
        }
        // A fixed *slot* row has both fields; only the copy is the owner's.
        return [
          for (final slot in fixedRows) ...[
            EditorField(
              key: '$slot.$labelSub',
              cardId: cardId,
              listKey: listKey,
              rowId: slot,
            ),
            EditorField(
              key: '$slot.$valueSub',
              cardId: cardId,
              listKey: listKey,
              rowId: slot,
              multiline: wideValue,
              sharedValue: sharedValue,
            ),
          ],
        ];
      }
      return [
        for (final rowId in listOrder[listKey] ?? const <String>[]) ...[
          EditorField(
            key: listFieldKey(listKey, rowId, labelSub),
            cardId: cardId,
            listKey: listKey,
            rowId: rowId,
          ),
          EditorField(
            key: listFieldKey(listKey, rowId, valueSub),
            cardId: cardId,
            listKey: listKey,
            rowId: rowId,
            multiline: wideValue,
            sharedValue: sharedValue,
          ),
        ],
      ];

    case RowListRow(:final listKey, :final subs, :final media):
      return [
        for (final rowId in listOrder[listKey] ?? const <String>[]) ...[
          for (final sub in subs)
            EditorField(
              key: listFieldKey(listKey, rowId, sub.sub),
              cardId: cardId,
              multiline: sub.multiline,
              listKey: listKey,
              rowId: rowId,
            ),
          // The photo is language-independent; its alt text is not (§C.4).
          // Both are fields: the row holds one image, so it is a path on a
          // scalar key rather than one of the `images.*` list slots.
          if (media) ...[
            EditorField(
              key: listFieldKey(listKey, rowId, RowListRow.imageSub),
              cardId: cardId,
              listKey: listKey,
              rowId: rowId,
              sharedValue: true,
            ),
            EditorField(
              key: listFieldKey(listKey, rowId, RowListRow.altSub),
              cardId: cardId,
              listKey: listKey,
              rowId: rowId,
            ),
          ],
        ],
      ];

    case GroupListRow(
      :final listKey,
      :final titleSub,
      :final itemsListKey,
      :final itemsSub,
      :final introSub,
      :final fixedTitles,
    ):
      final fields = <EditorField>[];
      for (final groupId in listOrder[listKey] ?? const <String>[]) {
        // A fixed group's title is a label, not a field.
        if (!fixedTitles) {
          fields.add(
            EditorField(
              key: listFieldKey(listKey, groupId, titleSub),
              cardId: cardId,
              listKey: listKey,
              rowId: groupId,
            ),
          );
        }
        if (introSub != null) {
          fields.add(
            EditorField(
              key: listFieldKey(listKey, groupId, introSub),
              cardId: cardId,
              multiline: true,
              listKey: listKey,
              rowId: groupId,
            ),
          );
        }
        final itemsKey = groupItemsListKey(listKey, groupId, itemsListKey);
        for (final itemId in listOrder[itemsKey] ?? const <String>[]) {
          fields.add(
            EditorField(
              key: listFieldKey(itemsKey, itemId, itemsSub),
              cardId: cardId,
              listKey: itemsKey,
              rowId: itemId,
            ),
          );
        }
      }
      return fields;

    case MediaRow(:final altFieldKey):
      // The files are language-independent, so a media row's only field is
      // its summarizing alt text — and only when the site renders one.
      return altFieldKey == null
          ? const []
          : [EditorField(key: altFieldKey, cardId: cardId)];

    case ExternalRow():
      // Read-only: its content belongs to another system.
      return const [];
  }
}

/// Every repeatable list in the schema, with the row type that owns it — what
/// the repository enumerates to learn which lists to read row ids for.

/// The schema row that owns a list key, or null when it is unknown. Used by
/// the cubit to learn a list's subfield and by the renderer to look up limits.
/// Whether a row is where [fieldKey] comes from: its own key, one of its
/// list's rows, or the alt text of its photo set.
bool _rowClaimsField(EditorRow row, String fieldKey) => switch (row) {
  FieldRow(:final key) => key == fieldKey,
  ListRow(:final listKey) ||
  PairListRow(:final listKey) ||
  RowListRow(:final listKey) ||
  GroupListRow(:final listKey) => fieldKey.startsWith('$listKey.'),
  MediaRow(:final altFieldKey) => altFieldKey == fieldKey,
  ExternalRow() => false,
};

/// Whether a row owns [listKey] — its own list, or a group's nested items,
/// which are addressed through the group.
bool _rowOwnsList(EditorRow row, String listKey) {
  switch (row) {
    case ListRow(listKey: final key):
    case PairListRow(listKey: final key):
    case RowListRow(listKey: final key):
    case GroupListRow(listKey: final key):
      if (key == listKey) return true;
      return row is GroupListRow &&
          listKey.startsWith('${row.listKey}.') &&
          listKey.endsWith('.${row.itemsListKey}');
    case FieldRow():
    case MediaRow():
    case ExternalRow():
      return false;
  }
}
