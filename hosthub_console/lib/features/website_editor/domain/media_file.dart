import 'package:equatable/equatable.dart';

/// One file in a site's media library.
///
/// The library is keyed by [storagePath] — `<siteId>/<uuid>.<ext>` — which is
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
