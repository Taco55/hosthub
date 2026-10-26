import 'package:flutter/widgets.dart';

class NavigationGuardController extends ChangeNotifier {
  Future<bool> Function()? _guard;

  /// Called by navigation anchors (e.g. the side menu) before routing away.
  Future<bool> canNavigateAway() async {
    final guard = _guard;
    if (guard == null) return true;
    return await guard();
  }

  void setGuard(Future<bool> Function()? guard) {
    _guard = guard;
  }
}
