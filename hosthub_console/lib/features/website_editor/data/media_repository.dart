import 'dart:typed_data';

import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';

import '../domain/media_file.dart';

/// The site's media library: rows in `cms_media`, bytes in the `site-media`
/// bucket.
///
/// Both live under the site's own folder (`<siteId>/<uuid>.webp`), which is
/// what the storage policies read to decide whether a byte may cross a tenant
/// boundary — so the path is not a convention here, it is the boundary.
///
/// Every upload is stored twice, master and thumb (see [MediaVariants]); the
/// library has one row for the pair, because they are one photo.
class MediaRepository extends SupabaseRepository {
  MediaRepository({required SupabaseClient supabase}) : super(supabase);

  static const String bucket = 'site-media';
  static const _uuid = Uuid();

  /// The public URL of a stored file — what a document holds and what the
  /// website renders. Public by design (a public site's photos are public);
  /// the API path is what the policies scope.
  ///
  /// A value that is already a URL (or a repo path like `/images/hero/x.jpg`)
  /// is returned untouched, mirroring `mediaPublicUrl` in `web/lib/media-url.ts` —
  /// a site can be half-migrated without either side mangling the other's paths.
  String publicUrlOf(String storagePath) => _isResolvedImageSrc(storagePath)
      ? storagePath
      : supabase.storage.from(bucket).getPublicUrl(storagePath);

  /// The URL of the small copy — what the console's grids and strips render.
  ///
  /// A picker showing eighty tiles at 160 pixels used to download eighty
  /// full-size photos to do it. Anything without a thumb (an object that
  /// predates this pipeline) falls back to the master, which is never wrong,
  /// only larger.
  String thumbUrlOf(String storagePath) {
    if (_isResolvedImageSrc(storagePath)) return storagePath;
    return publicUrlOf(MediaVariants.thumbPathOf(storagePath) ?? storagePath);
  }

  static bool _isResolvedImageSrc(String value) =>
      value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('/');

  Future<List<MediaFile>> loadLibrary(String siteId) async {
    try {
      final rows = await supabase
          .from('cms_media')
          .select(
            'storage_path, filename, width, height, file_size_bytes, usage',
          )
          .eq('site_id', siteId)
          .order('created_at');
      return [
        for (final row in rows as List<dynamic>)
          MediaFile(
            storagePath: row['storage_path'] as String,
            filename: row['filename'] as String,
            width: row['width'] as int?,
            height: row['height'] as int?,
            sizeBytes: (row['file_size_bytes'] as num?)?.toInt(),
            usage: [
              for (final entry in (row['usage'] as List<dynamic>? ?? const []))
                entry as String,
            ],
          ),
      ];
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotLoadData,
        context: {'op': 'loadLibrary', 'siteId': siteId},
      );
    }
  }

  /// Uploads one already-processed photo and records it in the library.
  ///
  /// The stored name is a fresh uuid: two photos called `IMG_2043.jpg` are two
  /// photos, and a name the owner chose must never be able to overwrite a file
  /// a page already renders. The original name is kept as the label.
  ///
  /// Two objects go up, the master and its thumb, at paths that derive from
  /// each other (see [MediaVariants]). Only the master is recorded in
  /// `cms_media` and only the master is what a document ever refers to — the
  /// thumb is a rendering detail of the same file, not a second library entry
  /// the owner has to know about.
  Future<MediaFile> upload({
    required String siteId,
    required String filename,
    required ProcessedImage image,
  }) async {
    final storagePath = '$siteId/${_uuid.v4()}.${MediaVariants.extension}';
    final thumbPath = MediaVariants.thumbPathOf(storagePath)!;
    try {
      await _putObject(storagePath, image.master);
      await _putObject(thumbPath, image.thumb);

      await supabase.from('cms_media').insert({
        'site_id': siteId,
        'storage_path': storagePath,
        'filename': filename,
        'mime_type': MediaVariants.contentType,
        'width': image.width,
        'height': image.height,
        'file_size_bytes': image.masterSizeBytes,
      });

      return MediaFile(
        storagePath: storagePath,
        filename: filename,
        width: image.width,
        height: image.height,
        sizeBytes: image.masterSizeBytes,
      );
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'uploadMedia', 'siteId': siteId, 'file': filename},
      );
    }
  }

  /// A stored object never changes: the path carries a uuid and the bytes are
  /// written once. Saying so is the difference between a CDN serving a photo
  /// from its own edge and re-asking storage for it every hour.
  Future<void> _putObject(String path, Uint8List bytes) => supabase.storage
      .from(bucket)
      .uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          contentType: MediaVariants.contentType,
          cacheControl: MediaVariants.cacheControl,
          upsert: false,
        ),
      );

  /// Removes a file from the library and the bucket, in that order: a row
  /// without bytes shows a broken tile the owner can delete, while bytes
  /// without a row are invisible and cost storage forever.
  ///
  /// Both variants go: the thumb has no row of its own, so nothing would ever
  /// come back for it.
  Future<void> delete({
    required String siteId,
    required String storagePath,
  }) async {
    try {
      await supabase
          .from('cms_media')
          .delete()
          .eq('site_id', siteId)
          .eq('storage_path', storagePath);
      final thumbPath = MediaVariants.thumbPathOf(storagePath);
      await supabase.storage.from(bucket).remove([
        storagePath,
        if (thumbPath != null) thumbPath,
      ]);
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'deleteMedia', 'siteId': siteId, 'path': storagePath},
      );
    }
  }

  /// Records which field addresses reference which file, so the picker can say
  /// what a photo is used for and refuse to delete one a live page renders.
  Future<void> saveUsage({
    required String siteId,
    required Map<String, List<String>> usageByPath,
  }) async {
    try {
      for (final entry in usageByPath.entries) {
        await supabase
            .from('cms_media')
            .update({'usage': entry.value})
            .eq('site_id', siteId)
            .eq('storage_path', entry.key);
      }
    } catch (error, stack) {
      throw mapError(
        error,
        stack,
        reason: DomainErrorReason.cannotSaveData,
        context: {'op': 'saveMediaUsage', 'siteId': siteId},
      );
    }
  }
}
