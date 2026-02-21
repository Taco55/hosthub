import 'package:flutter/widgets.dart';

class NavigationGuardController extends ChangeNotifier {
  Future<bool> Function()? _guard;

  /// Called by navigation anchors (e.g. the side menu) before routing away.
  Future<bool> canNavigateAway() async {
    final guard = _guard;
    if (guard == null) return true;
    return await guard();
  }

  /// Called by widgets that manage their own pop handling (e.g. WillPopScope).
  Future<bool> maybePop() => canNavigateAway();

  void setGuard(Future<bool> Function()? guard) {
    _guard = guard;
  }
}
