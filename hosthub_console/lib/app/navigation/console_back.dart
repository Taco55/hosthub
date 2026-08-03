import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Leave a page whose entry may or may not have stacked anything.
///
/// Nearly every destination in this console is entered with `go`, which
/// *replaces* the location rather than pushing a page. So a screen reached from
/// the sidebar — or opened cold from a pasted link — has no stack behind it,
/// and a back button that just pops does nothing at all. The pages this is
/// written for are the ones the sidebar carries no row for: hub sub-pages you
/// can otherwise only leave by picking some unrelated destination.
///
/// Honour a stack when there is one, and otherwise name the parent and go
/// there. Anyone who later `push`es to the same page keeps their history for
/// free, and the address bar stays true either way.
///
/// Shaped for `StyledWebPageScaffold.onBack`, where `true` means "go ahead and
/// pop" and `false` means "I navigated myself, do not also pop" — which is why
/// the branch that navigates is the one returning `false`.
Future<bool> leaveTo(BuildContext context, String parentPath) async {
  if (context.canPop()) return true;
  context.go(parentPath);
  return false;
}
