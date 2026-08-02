import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// One file in a site's media library.
///
/// The library is keyed by [storagePath] — `<siteId>/<uuid>.webp` — which is
/// also what a document stores and what the public website resolves to a URL.
/// Nothing references a file by its display name: two uploads may be called
/// `IMG_2043.jpg` and mean different photos.
class MediaFile extends Equatable {
  const MediaFile({
    required this.storagePath,
    required this.filename,
    this.width,
    this.height,
    this.sizeBytes,
    this.usage = const [],
  });

  /// Path inside the `site-media` bucket, site folder included.
  final String storagePath;

  /// The name the owner uploaded it under; shown in the picker.
  final String filename;

  final int? width;
  final int? height;
  final int? sizeBytes;

  /// Field addresses that reference this file (`page/home:heroPhotos`). Empty
  /// means nothing on the site uses it, which is the only state in which the
  /// library allows deleting it.
  final List<String> usage;

  bool get isUsed => usage.isNotEmpty;

  /// Whether the image is landscape and large enough for a hero or gallery —
  /// the requirement the picker states in its dropzone. Unknown dimensions
  /// count as acceptable: the file is already there, and refusing it after the
  /// fact would be a worse lie than showing it.
  bool get meetsPrintRequirements {
    final w = width;
    final h = height;
    if (w == null || h == null) return true;
    return w >= 1600 && h >= 1200 && w >= h;
  }

  MediaFile copyWith({List<String>? usage}) => MediaFile(
    storagePath: storagePath,
    filename: filename,
    width: width,
    height: height,
    sizeBytes: sizeBytes,
    usage: usage ?? this.usage,
  );

  @override
  List<Object?> get props => [
    storagePath,
    filename,
    width,
    height,
    sizeBytes,
    usage,
  ];
}

/// Why an upload was refused, before a byte leaves the browser.
///
/// The check happens client-side because the answer is about the file the owner
/// just picked: telling them after a 6 MB round trip that it was 6 MB is the
/// kind of feedback that arrives too late to be help.
enum MediaRejection { type, tooLarge, tooSmall, portrait }

/// The upload rules the dropzone states and this layer enforces.
class MediaLimits {
  const MediaLimits();

  static const int maxBytes = 8 * 1024 * 1024;
  static const int minWidth = 1600;
  static const int minHeight = 1200;
  static const Set<String> allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  /// The reason this file cannot be uploaded, or null when it can.
  ///
  /// [width]/[height] may be null when the browser could not decode the image;
  /// the size and the type are always known, so those are always checked.
  static MediaRejection? rejectionFor({
    required String filename,
    required int sizeBytes,
    int? width,
    int? height,
  }) {
    final extension = filename.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) return MediaRejection.type;
    if (sizeBytes > maxBytes) return MediaRejection.tooLarge;
    if (width == null || height == null) return null;
    if (width < minWidth || height < minHeight) return MediaRejection.tooSmall;
    if (height > width) return MediaRejection.portrait;
    return null;
  }
}

/// The sizes an upload is stored in, and how their paths relate.
///
/// A photo straight off a phone is three to five megabytes, and the website
/// used to serve exactly that to every visitor — the bytes leaving storage are
/// what the hosting bill is made of, not the bytes sitting in it. So the
/// browser re-encodes before anything is sent: one copy large enough for a
/// full-bleed hero, and one small enough for a grid of eighty tiles.
///
/// The thumb's path is *derived* from the master's rather than stored beside
/// it, the same `@<width>w` convention the bundled site images already use
/// (`web/scripts/resize-images.js`). One name in the document, and any layer
/// that has it can name the other size without a lookup.
class MediaVariants {
  const MediaVariants();

  /// Long edge of the copy the website renders. Above this, a photo only
  /// carries detail no screen in a hero position will show.
  static const int masterMaxEdge = 2560;

  /// Long edge of the copy the console's grids and strips render.
  static const int thumbMaxEdge = 640;

  /// WebP at these qualities is visually clean for photography while landing
  /// roughly an order of magnitude under an unprocessed JPEG.
  static const double masterQuality = 0.82;
  static const double thumbQuality = 0.75;

  /// Everything is stored re-encoded, so the format is a fact and not a
  /// property of what the owner happened to pick.
  static const String extension = 'webp';
  static const String contentType = 'image/webp';

  /// A year. The stored name contains a uuid, so a given path's bytes never
  /// change — the only reason the default hour existed was that nobody had
  /// said otherwise, and it makes every CDN re-ask for a file that cannot
  /// have moved.
  static const String cacheControl = '31536000';

  /// The thumb belonging to [storagePath], or null when that path predates
  /// this pipeline (anything not stored as `.webp` — an object dropped in
  /// through the Supabase dashboard, say). Callers fall back to the master,
  /// which is always right and merely larger.
  static String? thumbPathOf(String storagePath) {
    const suffix = '.$extension';
    if (!storagePath.endsWith(suffix)) return null;
    final base = storagePath.substring(0, storagePath.length - suffix.length);
    return '$base@${thumbMaxEdge}w$suffix';
  }

  /// [width]×[height] scaled to fit a [maxEdge] box, keeping the aspect ratio
  /// and never enlarging: upscaling invents detail and costs bytes to do it.
  static (int width, int height) fitWithin(int width, int height, int maxEdge) {
    final longest = width > height ? width : height;
    if (longest <= maxEdge || longest == 0) return (width, height);
    final scale = maxEdge / longest;
    // Round rather than truncate, and never to zero: a 4000×1 strip is not a
    // real photo, but it must not become a canvas the browser refuses.
    final scaledWidth = (width * scale).round();
    final scaledHeight = (height * scale).round();
    return (
      scaledWidth < 1 ? 1 : scaledWidth,
      scaledHeight < 1 ? 1 : scaledHeight,
    );
  }
}

/// What the browser hands the repository: the two copies it will store.
class ProcessedImage extends Equatable {
  const ProcessedImage({
    required this.master,
    required this.thumb,
    required this.width,
    required this.height,
  });

  /// The copy the website renders, at most [MediaVariants.masterMaxEdge] on
  /// its long edge.
  final Uint8List master;

  /// The copy the console's grids render.
  final Uint8List thumb;

  /// Dimensions of [master] — what the library records, because it is what a
  /// page will actually be given.
  final int width;
  final int height;

  int get masterSizeBytes => master.lengthInBytes;

  @override
  List<Object?> get props => [master, thumb, width, height];
}

/// Turns picked bytes into the sizes that get stored.
///
/// A function rather than a class so the cubit can be handed a plain stub in a
/// test: the real one needs a browser, and a widget test that uploads a file
/// must not need a canvas.
typedef ImageProcessor =
    Future<ProcessedImage> Function({
      required Uint8List bytes,
      required String contentType,
    });
