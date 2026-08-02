import 'dart:typed_data';

import 'package:app_errors/app_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:hosthub_console/features/auth/infrastructure/supabase/supabase_repository.dart';

import '../domain/media_file.dart';

/// The site's media library: rows in `cms_media`, bytes in the `site-media`
/// bucket.
///
/// Both live under the site's own folder (`<siteId>/<uuid>.<ext>`), which is
/// what the storage policies read to decide whether a byte may cross a tenant
/// boundary — so the path is not a convention here, it is the boundary.
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

  /// Uploads one file and records it in the library.
  ///
  /// The stored name is a fresh uuid: two photos called `IMG_2043.jpg` are two
  /// photos, and a name the owner chose must never be able to overwrite a file
  /// a page already renders. The original name is kept as the label.
  Future<MediaFile> upload({
    required String siteId,
    required String filename,
    required Uint8List bytes,
    required String contentType,
    int? width,
    int? height,
  }) async {
    final extension = filename.split('.').last.toLowerCase();
    final storagePath = '$siteId/${_uuid.v4()}.$extension';
    try {
      await supabase.storage
          .from(bucket)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );

      await supabase.from('cms_media').insert({
        'site_id': siteId,
        'storage_path': storagePath,
        'filename': filename,
        'mime_type': contentType,
        'width': width,
        'height': height,
        'file_size_bytes': bytes.lengthInBytes,
      });

      return MediaFile(
        storagePath: storagePath,
        filename: filename,
        width: width,
        height: height,
        sizeBytes: bytes.lengthInBytes,
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

  /// Removes a file from the library and the bucket, in that order: a row
  /// without bytes shows a broken tile the owner can delete, while bytes
  /// without a row are invisible and cost storage forever.
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
      await supabase.storage.from(bucket).remove([storagePath]);
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
