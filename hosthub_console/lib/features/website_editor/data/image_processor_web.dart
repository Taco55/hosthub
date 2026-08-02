import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../domain/media_file.dart';

/// Re-encodes a picked photo into the two sizes the library stores.
///
/// The browser's own decoder does the work: it already has to decode the file
/// to show the owner a preview, and it does it in native code rather than in
/// compiled Dart on the UI isolate.
///
/// The bytes never leave in their original form. An unprocessed phone photo is
/// three to five megabytes and every visitor of the site would be sent all of
/// it; the master below lands around a tenth of that with no visible loss at
/// the sizes a page renders.
Future<ProcessedImage> processImage({
  required Uint8List bytes,
  required String contentType,
}) async {
  final blob = web.Blob(
    <JSUint8Array>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: contentType),
  );
  final bitmap = await web.window.createImageBitmap(blob).toDart;
  try {
    final master = await _encode(
      bitmap,
      MediaVariants.masterMaxEdge,
      MediaVariants.masterQuality,
    );
    final thumb = await _encode(
      bitmap,
      MediaVariants.thumbMaxEdge,
      MediaVariants.thumbQuality,
    );
    return ProcessedImage(
      master: master.bytes,
      thumb: thumb.bytes,
      width: master.width,
      height: master.height,
    );
  } finally {
    // The decoded frame is off-heap and the garbage collector does not know
    // how big it is; a batch of eighty uploads notices the difference.
    bitmap.close();
  }
}

typedef _Encoded = ({Uint8List bytes, int width, int height});

Future<_Encoded> _encode(
  web.ImageBitmap bitmap,
  int maxEdge,
  double quality,
) async {
  final (width, height) = MediaVariants.fitWithin(
    bitmap.width,
    bitmap.height,
    maxEdge,
  );
  final canvas = web.OffscreenCanvas(width, height);
  final context =
      canvas.getContext('2d') as web.OffscreenCanvasRenderingContext2D?;
  if (context == null) {
    throw UnsupportedError('This browser has no 2d canvas to re-encode with.');
  }
  // The default resampling is fast and visibly rough on a 4× downscale, which
  // is exactly the reduction every upload gets.
  context.imageSmoothingEnabled = true;
  context.imageSmoothingQuality = 'high';
  context.drawImage(bitmap, 0, 0, width, height);

  final blob = await canvas
      .convertToBlob(
        web.ImageEncodeOptions(
          type: MediaVariants.contentType,
          quality: quality,
        ),
      )
      .toDart;
  final buffer = await blob.arrayBuffer().toDart;
  return (bytes: buffer.toDart.asUint8List(), width: width, height: height);
}
