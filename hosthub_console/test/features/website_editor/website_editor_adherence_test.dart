import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// StyledWidgets/design-token adherence checks from CONFORMANCE.md: the
/// feature's widgets must source colours from the theme (no scattered hex
/// literals) and user-facing strings from the ARB files (no literals in
/// Text widgets). Pure source checks — no widgets pumped.
void main() {
  final featureDir = Directory('lib/features/website_editor');

  List<File> dartFiles(Directory dir) => dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('no hardcoded Color(0x...) outside the status-colour tokens', () {
    final offenders = <String>[];
    for (final file in dartFiles(featureDir)) {
      // The single documented home for the semantic green/amber tokens the
      // ColorScheme cannot express (see WebsiteStatusColors).
      if (file.path.endsWith('website_editor_status_colors.dart')) continue;
      final lines = File(file.path).readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains(RegExp(r'Color\(0x'))) {
          offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Colours must come from ColorScheme / WebsiteStatusColors:\n'
          '${offenders.join('\n')}',
    );
  });

  test('no raw BoxDecoration containers doing card/chip chrome', () {
    // The design mandate: chrome comes from StyledWidgets. Small geometric
    // primitives (status dots, the source-language tag, preview-site mock
    // content) are allowed; bordered/shadowed card imitations are not.
    // The preview chrome (SitePreviewFrame + the mocked site inside the
    // preview pane) legitimately draws browser/phone shadows; everything else
    // must get elevation from StyledWidgets.
    const shadowAllowlist = ['preview_pane.dart', 'site_preview_frame.dart'];
    final offenders = <String>[];
    for (final file in dartFiles(featureDir)) {
      final source = File(file.path).readAsStringSync();
      if (source.contains('boxShadow:') &&
          !shadowAllowlist.any(file.path.endsWith)) {
        offenders.add(file.path);
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Card/shadow chrome must be a StyledWidgets component:\n'
          '${offenders.join('\n')}',
    );
  });

  test('user-facing Text() strings resolve through S (context.s)', () {
    // Heuristic: no Text('...literal...') with letters in the presentation
    // layer; allowed exceptions carry a trailing "// non-localized" marker
    // (e.g. the mocked website content in the preview, which is site content,
    // not console UI).
    final offenders = <String>[];
    final presentation = Directory('lib/features/website_editor/presentation');
    for (final file in dartFiles(presentation)) {
      final lines = File(file.path).readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final match = RegExp(
          "Text\\(\\s*'([^']*[A-Za-z]{2,}[^']*)'",
        ).hasMatch(line);
        if (match && !line.contains('// non-localized')) {
          offenders.add('${file.path}:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'User-facing strings must come from the ARB files:\n'
          '${offenders.join('\n')}',
    );
  });

  test('raw chrome stays inside the two files that draw a picture', () {
    // CONFORMANCE fase 2 par. 9: Container/BoxDecoration/Border.all in
    // features/website_editor/** must be empty outside the existing
    // exceptions. Those exceptions are the browser and phone bezel
    // (site_preview_frame) and the schematic site mock (preview_pane): both
    // draw a picture of something that is not this app's UI, which is exactly
    // what should not be a product component.
    const allowed = ['preview_pane.dart', 'site_preview_frame.dart'];
    final offenders = <String>[];
    for (final file in dartFiles(featureDir)) {
      if (allowed.any(file.path.endsWith)) continue;
      final source = File(file.path).readAsStringSync();
      final raw = RegExp(r'BoxDecoration\(|Border\.all\(|[^d]Container\(');
      if (raw.hasMatch(source)) offenders.add(file.path);
    }
    expect(
      offenders,
      isEmpty,
      reason: 'Chrome must come from StyledWidgets:\n${offenders.join('\n')}',
    );
  });

  test('the fase-2 theme groups are stated in the app preset', () {
    // Mapping part C: every number the handoff states lives in the preset, so
    // no card, row or picker in the app repeats one.
    final preset = File(
      'lib/core/widgets/foundation/theme/hosthub_diplora_v1_theme_preset.dart',
    ).readAsStringSync();
    for (final group in ['repeaters:', 'fieldLists:', 'media:', 'uploads:']) {
      expect(
        preset.contains(group),
        isTrue,
        reason: 'The preset does not state the $group theme group',
      );
    }
  });
}
