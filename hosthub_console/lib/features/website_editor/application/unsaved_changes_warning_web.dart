import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Browser-level guard for the editor's draft (§11i): closing the tab or hitting
/// back with unsaved copy in the fields asks first. The draft only lives in the
/// cubit, so this is the last thing standing between the owner and losing it —
/// and the answer is a prompt, never an autosave.
///
/// The browser owns the wording; a page cannot supply its own text.
web.EventListener? _listener;

void setUnsavedChangesWarning({required bool enabled}) {
  if (enabled == (_listener != null)) return;
  if (enabled) {
    _listener = ((web.BeforeUnloadEvent event) {
      // Both halves are needed: preventDefault for the modern spec,
      // returnValue for the browsers that still look at it.
      event.preventDefault();
      event.returnValue = '';
    }).toJS;
    web.window.addEventListener('beforeunload', _listener);
  } else {
    web.window.removeEventListener('beforeunload', _listener);
    _listener = null;
  }
}
