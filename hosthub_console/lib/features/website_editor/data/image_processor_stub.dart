import 'dart:typed_data';

import '../domain/media_file.dart';

/// Off the web there is no decoder to hand this to.
///
/// Nothing calls it: the console is a web app, and a test that needs an upload
/// passes its own [ImageProcessor]. Throwing beats returning the bytes
/// untouched, which would silently store the very originals this exists to
/// avoid.
Future<ProcessedImage> processImage({
  required Uint8List bytes,
  required String contentType,
}) => throw UnsupportedError(
  'Image processing needs a browser canvas; pass an ImageProcessor instead.',
);
