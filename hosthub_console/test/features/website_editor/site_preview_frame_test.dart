import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/features/website_editor/presentation/widgets/site_preview_frame.dart';

void main() {
  testWidgets('desktop renders url, toolbar slot and child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SitePreviewFrame(
            url: 'trysilpanorama.com/nl',
            toolbar: Text('TOOLBAR'),
            child: Text('PAGE'),
          ),
        ),
      ),
    );

    expect(find.text('trysilpanorama.com/nl'), findsOneWidget);
    expect(find.text('TOOLBAR'), findsOneWidget);
    expect(find.text('PAGE'), findsOneWidget);
  });

  testWidgets('desktop honours maxWidth', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SitePreviewFrame(
            url: 'example.com',
            maxWidth: 400,
            child: SizedBox.expand(),
          ),
        ),
      ),
    );

    final constrained = tester.widget<ConstrainedBox>(
      find
          .ancestor(
            of: find.byType(StyledContainer),
            matching: find.byType(ConstrainedBox),
          )
          .first,
    );
    expect(constrained.constraints.maxWidth, 400);
  });

  testWidgets('no traffic-light dots when disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SitePreviewFrame(
            url: 'example.com',
            showTrafficLights: false,
            child: Text('PAGE'),
          ),
        ),
      ),
    );

    final circleDots = tester.widgetList<Container>(find.byType(Container)).where(
      (c) {
        final d = c.decoration;
        return d is BoxDecoration && d.shape == BoxShape.circle;
      },
    );
    expect(circleDots, isEmpty);
  });

  testWidgets('mobile renders a phone bezel + host, no address bar',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SitePreviewFrame(
            url: 'trysilpanorama.com/nl',
            device: SitePreviewFrameDevice.mobile,
            child: Text('PAGE'),
          ),
        ),
      ),
    );

    // Host is derived from the url (path stripped); full url is not shown.
    expect(find.text('trysilpanorama.com'), findsOneWidget);
    expect(find.text('trysilpanorama.com/nl'), findsNothing);
    expect(find.text('PAGE'), findsOneWidget);
    // Status-bar time marker.
    expect(find.text('9:41'), findsOneWidget);
  });
}
