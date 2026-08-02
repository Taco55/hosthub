/// Re-encoding a picked photo into the sizes the library stores.
///
/// Behind a conditional import for the same reason the live preview frame is:
/// the work is done by the browser's own decoder and canvas, which cannot be
/// compiled for the VM, and a widget test that only wants to build a screen
/// must not need one.
export 'image_processor_stub.dart'
    if (dart.library.js_interop) 'image_processor_web.dart';
