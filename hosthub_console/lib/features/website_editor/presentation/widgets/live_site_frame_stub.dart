import 'package:flutter/widgets.dart';

/// Non-web stand-in for the live site iframe (the console ships web-only;
/// this exists so widget tests on the VM can build the preview pane).
class LiveSiteFrame extends StatelessWidget {
  const LiveSiteFrame({
    super.key,
    required this.url,
    required this.locale,
    required this.fields,
  });

  final String url;
  final String locale;
  final Map<String, String> fields;

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
