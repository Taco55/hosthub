/// Opening a link outside the console.
///
/// Behind a conditional import for the same reason the live preview frame is:
/// `package:web` cannot be compiled for the VM, and a widget test that only
/// wants to build a screen must not need a browser.
export 'external_link_stub.dart'
    if (dart.library.js_interop) 'external_link_web.dart';
