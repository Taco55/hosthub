import 'dart:typed_data';

import 'package:app_errors/app_errors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/image_processor.dart' as processing;
import '../data/media_repository.dart';
import '../domain/media_file.dart';

/// One file on its way into the library.
class MediaUpload extends Equatable {
  const MediaUpload({
    required this.filename,
    required this.sizeBytes,
    this.progress = 0,
    this.done = false,
    this.rejection,
    this.failed = false,
    this.width,
    this.height,
  });

  final String filename;
  final int sizeBytes;

  /// 0..1 while in flight.
  final double progress;
  final bool done;

  /// Why the file was refused before it was sent, when it was.
  final MediaRejection? rejection;

  /// Whether the upload itself failed (network, policy) rather than the file
  /// being wrong.
  final bool failed;

  final int? width;
  final int? height;

  bool get isRejected => rejection != null;
  bool get isFailed => failed;
  bool get isBusy => !done && !isRejected && !failed;

  MediaUpload copyWith({
    double? progress,
    bool? done,
    bool? failed,
    MediaRejection? rejection,
  }) => MediaUpload(
    filename: filename,
    sizeBytes: sizeBytes,
    progress: progress ?? this.progress,
    done: done ?? this.done,
    failed: failed ?? this.failed,
    rejection: rejection ?? this.rejection,
    width: width,
    height: height,
  );

  @override
  List<Object?> get props => [
    filename,
    sizeBytes,
    progress,
    done,
    rejection,
    failed,
    width,
    height,
  ];
}

/// The library and the upload queue of one site.
class MediaLibraryState extends Equatable {
  const MediaLibraryState({
    this.files = const [],
    this.uploads = const [],
    this.loading = false,
    this.error,
  });

  final List<MediaFile> files;

  /// The queue, newest last. It survives a finished upload on purpose: a row
  /// that reports what happened to a file is the only record the owner gets.
  final List<MediaUpload> uploads;

  final bool loading;
  final DomainError? error;

  MediaLibraryState copyWith({
    List<MediaFile>? files,
    List<MediaUpload>? uploads,
    bool? loading,
    DomainError? error,
    bool clearError = false,
  }) => MediaLibraryState(
    files: files ?? this.files,
    uploads: uploads ?? this.uploads,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );

  /// The file for a stored path, or null when the library does not have it
  /// (a document referencing a deleted file).
  MediaFile? fileFor(String storagePath) {
    for (final file in files) {
      if (file.storagePath == storagePath) return file;
    }
    return null;
  }

  @override
  List<Object?> get props => [files, uploads, loading, error];
}

/// Drives the media library: what is in it, what is being uploaded, and which
/// fields use which file.
///
/// Separate from `SiteContentCubit` on purpose (handoff Part D): a photo is not
/// a translatable field, and the picker hands back storage paths that the
/// content cubit then writes into the document. That keeps one owner for the
/// draft/saved/published layers and one owner for the library.
class MediaLibraryCubit extends Cubit<MediaLibraryState> {
  MediaLibraryCubit({
    required MediaRepository repository,
    required String siteId,
    ImageProcessor? processImage,
  }) : _repository = repository,
       _siteId = siteId,
       _processImage = processImage ?? processing.processImage,
       super(const MediaLibraryState());

  final MediaRepository _repository;
  final String _siteId;

  /// Injectable so a test can upload without a browser canvas; the default is
  /// the real browser re-encode.
  final ImageProcessor _processImage;

  String publicUrlOf(String storagePath) =>
      _repository.publicUrlOf(storagePath);

  /// The small copy, for grids and strips.
  String thumbUrlOf(String storagePath) => _repository.thumbUrlOf(storagePath);

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final files = await _repository.loadLibrary(_siteId);
      if (isClosed) return;
      emit(state.copyWith(files: files, loading: false));
    } catch (error, stack) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          error: error is DomainError
              ? error
              : DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  /// Puts one file through the queue. A refusal never touches the network and
  /// never stops the files beside it: each row carries its own outcome
  /// (README §C.3).
  Future<void> addUpload({
    required String filename,
    required Uint8List bytes,
    required String contentType,
    int? width,
    int? height,
  }) async {
    final rejection = MediaLimits.rejectionFor(
      filename: filename,
      sizeBytes: bytes.lengthInBytes,
      width: width,
      height: height,
    );
    final upload = MediaUpload(
      filename: filename,
      sizeBytes: bytes.lengthInBytes,
      width: width,
      height: height,
      rejection: rejection,
    );
    emit(state.copyWith(uploads: [...state.uploads, upload]));
    if (rejection != null) return;

    void progress(double value) {
      emit(
        state.copyWith(
          uploads: [
            for (final queued in state.uploads)
              if (queued.filename == filename && queued.isBusy)
                queued.copyWith(progress: value)
              else
                queued,
          ],
        ),
      );
    }

    // The Supabase client uploads in one call, so there is no byte-level
    // progress to report: the row shows that work started and then that it
    // finished. A fake animated percentage would be a lie about a fact the
    // owner can check.
    progress(0.1);
    try {
      // Re-encode first. What the owner picked is a camera original; what a
      // visitor of the site should be sent is a tenth of it, and the moment to
      // decide that is before the bytes cross the network, not after they are
      // already in the bucket being billed for.
      final image = await _processImage(bytes: bytes, contentType: contentType);
      if (isClosed) return;
      progress(0.5);

      final file = await _repository.upload(
        siteId: _siteId,
        filename: filename,
        image: image,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          files: [...state.files, file],
          uploads: [
            for (final queued in state.uploads)
              if (queued.filename == filename && queued.isBusy)
                queued.copyWith(progress: 1, done: true)
              else
                queued,
          ],
        ),
      );
    } catch (error, stack) {
      if (isClosed) return;
      emit(
        state.copyWith(
          uploads: [
            for (final queued in state.uploads)
              if (queued.filename == filename && queued.isBusy)
                queued.copyWith(failed: true)
              else
                queued,
          ],
          error: error is DomainError
              ? error
              : DomainError.from(error, stack: stack),
        ),
      );
    }
  }

  /// Forgets the queue — after the picker closes, the rows have said what they
  /// had to say.
  void clearUploads() => emit(state.copyWith(uploads: const []));

  /// Deletes a file, but never one a page still renders: the worst outcome of
  /// this screen is a photo disappearing from a live page because somebody
  /// tidied the library (README §C.3).
  Future<bool> deleteFile(String storagePath) async {
    final file = state.fileFor(storagePath);
    if (file == null || file.isUsed) return false;
    try {
      await _repository.delete(siteId: _siteId, storagePath: storagePath);
      if (isClosed) return true;
      emit(
        state.copyWith(
          files: [
            for (final entry in state.files)
              if (entry.storagePath != storagePath) entry,
          ],
        ),
      );
      return true;
    } catch (error, stack) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          error: error is DomainError
              ? error
              : DomainError.from(error, stack: stack),
        ),
      );
      return false;
    }
  }

  /// Records which field addresses reference which file. Called after a save,
  /// with the whole picture: usage is derived from the documents, so it cannot
  /// drift from what the pages actually render.
  Future<void> syncUsage(Map<String, List<String>> usageByPath) async {
    final changed = <String, List<String>>{};
    for (final file in state.files) {
      final next = usageByPath[file.storagePath] ?? const <String>[];
      if (!_sameUsage(file.usage, next)) changed[file.storagePath] = next;
    }
    if (changed.isEmpty) return;

    emit(
      state.copyWith(
        files: [
          for (final file in state.files)
            changed.containsKey(file.storagePath)
                ? file.copyWith(usage: changed[file.storagePath])
                : file,
        ],
      ),
    );
    try {
      await _repository.saveUsage(siteId: _siteId, usageByPath: changed);
    } catch (_) {
      // Usage is a convenience the picker reads, not content: a failed write
      // must not take the editor down with it. The next save tries again.
    }
  }

  static bool _sameUsage(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
