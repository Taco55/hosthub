import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:hosthub_console/features/website_editor/website_editor.dart';

/// The address `contentType/slug:json.path` is a contract between two
/// codebases in two languages: the console derives it from the template's
/// field paths, the rendered page carries it in `data-cms-field`. Both sides
/// implemented it independently and nothing compared them — so they drifted
/// three times in one afternoon: a field the editor deleted that the page
/// still listened for, and fields the editor gained that no element carried.
///
/// This writes the console's half to a file the website's own check reads
/// (`web/scripts/check-cms-addresses.mjs`). Regenerate with:
///
///     UPDATE_CMS_MANIFEST=1 flutter test test/features/website_editor/cms_address_manifest_test.dart
const _manifestPath = '../web/cms-address-manifest.json';

/// One row id per list: a list field's address carries an id the page fills in
/// at render time, so the manifest describes its shape rather than its rows.
const _rowIdPlaceholder = '{id}';

String _buildManifest() {
  final listOrder = <String, List<String>>{};
  for (final list in kDefaultTemplate.lists) {
    listOrder[list.listKey] = [_rowIdPlaceholder];
    final items = list.itemsListKey;
    if (items != null) {
      listOrder[groupItemsListKey(list.listKey, _rowIdPlaceholder, items)] = [
        _rowIdPlaceholder,
      ];
    }
  }

  final entries = <Map<String, Object?>>[];
  for (final page in kDefaultTemplate.pageKeys) {
    for (final field in kDefaultTemplate.fieldsFor(page, listOrder)) {
      final location = kDefaultTemplate.locationOf(field.key);
      if (location == null) continue;
      entries.add({
        'key': field.key,
        'address': location.address,
        'page': page,
        'visibility': field.visibility.name,
        'isList': field.listKey != null,
      });
    }
  }
  entries.sort(
    (a, b) => (a['address']! as String).compareTo(b['address']! as String),
  );

  return '${const JsonEncoder.withIndent('  ').convert({'template': kDefaultTemplate.id, 'rowIdPlaceholder': _rowIdPlaceholder, 'fields': entries})}\n';
}

void main() {
  test('the committed address manifest matches the template', () {
    final manifest = _buildManifest();
    final file = File(_manifestPath);

    if (Platform.environment['UPDATE_CMS_MANIFEST'] == '1') {
      file.writeAsStringSync(manifest);
      return;
    }

    expect(
      file.existsSync(),
      isTrue,
      reason: '$_manifestPath is missing; regenerate it',
    );
    expect(
      file.readAsStringSync(),
      manifest,
      reason:
          'The template changed and the manifest did not. Regenerate with '
          'UPDATE_CMS_MANIFEST=1 flutter test '
          'test/features/website_editor/cms_address_manifest_test.dart',
    );
  });

  test('every address is unique and well formed', () {
    final decoded = jsonDecode(_buildManifest()) as Map<String, dynamic>;
    final fields = (decoded['fields'] as List).cast<Map<String, dynamic>>();
    expect(fields, isNotEmpty);

    final seen = <String>{};
    for (final field in fields) {
      final address = field['address'] as String;
      expect(
        address,
        matches(RegExp(r'^[a-z_]+/[a-z_]+:[A-Za-z0-9_.{}]+$')),
        reason: '$address is not contentType/slug:json.path',
      );
      expect(
        seen.add(address),
        isTrue,
        reason: '$address is claimed by two fields',
      );
    }
  });
}
