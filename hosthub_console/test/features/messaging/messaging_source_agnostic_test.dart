import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The test that justifies the port.
///
/// Adding a second messaging source must be one `MessagingRepository`
/// implementation plus one line of DI — never a sweep through the screen. That
/// only stays true if no source is named above the infrastructure layer, and
/// "we intend to keep it that way" in a markdown file is not a check. This is.
void main() {
  group('messaging is source-agnostic above infrastructure', () {
    /// Names of sources the console might grow. Matched case-insensitively so
    /// `LodgifyService`, `lodgify-sync` and a comment all count.
    const sourceNames = ['lodgify', 'guesty', 'hostaway', 'beds24'];

    /// The layers the rule covers.
    ///
    /// `infrastructure/` and `messaging_di.dart` are where a source belongs.
    /// `domain/` is deliberately out of scope: the port's doc comment names the
    /// sources it was written to abstract over, which is documentation of the
    /// abstraction rather than a dependency on one. What must never happen is
    /// state or a screen deciding anything from a source's name — hence exactly
    /// these two directories.
    const coveredDirectories = [
      'lib/features/messaging/application',
      'lib/features/messaging/presentation',
    ];

    test('no source is named in application or presentation', () {
      final offenders = <String>[];

      for (final directory in coveredDirectories) {
        final dir = Directory(directory);
        expect(
          dir.existsSync(),
          isTrue,
          reason: '$directory should exist — did the feature move?',
        );
        for (final entity in dir.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;
          final contents = entity.readAsStringSync().toLowerCase();
          for (final name in sourceNames) {
            if (contents.contains(name)) {
              offenders.add('${entity.path}: "$name"');
            }
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'A messaging source may only be named under infrastructure/ and in '
            'messaging_di.dart. Ask MessagingCapabilities instead of asking '
            'which source this is.\n${offenders.join('\n')}',
      );
    });

    test('the source lives where it is allowed to', () {
      // The counterpart: if the check above passed because the adapter
      // disappeared, this fails.
      final adapter = File(
        'lib/features/messaging/infrastructure/lodgify/'
        'lodgify_messaging_repository.dart',
      );
      expect(adapter.existsSync(), isTrue);
      expect(adapter.readAsStringSync().toLowerCase(), contains('lodgify'));
    });
  });
}
