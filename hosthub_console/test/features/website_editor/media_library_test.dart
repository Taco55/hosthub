import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hosthub_console/features/website_editor/website_editor.dart';

/// In-memory stand-in: the real class's contract, no Supabase.
class FakeMediaRepository implements MediaRepository {
  FakeMediaRepository({this.library = const []});

  List<MediaFile> library;
  final List<String> uploaded = [];
  final List<String> deleted = [];
  final List<Map<String, List<String>>> usageWrites = [];
  Object? nextUploadError;

  @override
  Future<List<MediaFile>> loadLibrary(String siteId) async => library;

  @override
  Future<MediaFile> upload({
    required String siteId,
    required String filename,
    required Uint8List bytes,
    required String contentType,
    int? width,
    int? height,
  }) async {
    final error = nextUploadError;
    if (error != null) {
      nextUploadError = null;
      throw error;
    }
    uploaded.add(filename);
    return MediaFile(
      storagePath: '$siteId/${uploaded.length}.jpg',
      filename: filename,
      width: width,
      height: height,
      sizeBytes: bytes.lengthInBytes,
    );
  }

  @override
  Future<void> delete({
    required String siteId,
    required String storagePath,
  }) async {
    deleted.add(storagePath);
  }

  @override
  Future<void> saveUsage({
    required String siteId,
    required Map<String, List<String>> usageByPath,
  }) async {
    usageWrites.add(usageByPath);
  }

  @override
  String publicUrlOf(String storagePath) => 'https://cdn.test/$storagePath';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Uint8List _bytes(int length) => Uint8List(length);

void main() {
  group('MediaLimits', () {
    test('states the reason a file cannot be uploaded', () {
      expect(
        MediaLimits.rejectionFor(filename: 'photo.heic', sizeBytes: 1000),
        MediaRejection.type,
      );
      expect(
        MediaLimits.rejectionFor(
          filename: 'photo.jpg',
          sizeBytes: 9 * 1024 * 1024,
        ),
        MediaRejection.tooLarge,
      );
      expect(
        MediaLimits.rejectionFor(
          filename: 'photo.jpg',
          sizeBytes: 1000,
          width: 1200,
          height: 800,
        ),
        MediaRejection.tooSmall,
      );
      expect(
        MediaLimits.rejectionFor(
          filename: 'photo.jpg',
          sizeBytes: 1000,
          width: 1600,
          height: 2400,
        ),
        MediaRejection.portrait,
      );
      expect(
        MediaLimits.rejectionFor(
          filename: 'photo.jpg',
          sizeBytes: 1000,
          width: 2400,
          height: 1600,
        ),
        isNull,
      );
    });

    test('an image it cannot measure is not refused for its size', () {
      // The bytes are there and the type is right; refusing on a dimension
      // nobody could read would be a guess presented as a rule.
      expect(
        MediaLimits.rejectionFor(filename: 'photo.webp', sizeBytes: 2048),
        isNull,
      );
    });
  });

  group('MediaLibraryCubit', () {
    MediaLibraryCubit build(FakeMediaRepository repo) =>
        MediaLibraryCubit(repository: repo, siteId: 'site-1');

    test('loads the library', () async {
      final repo = FakeMediaRepository(
        library: const [
          MediaFile(storagePath: 'site-1/a.jpg', filename: 'a.jpg'),
        ],
      );
      final cubit = build(repo);

      await cubit.load();

      expect(cubit.state.files, hasLength(1));
      expect(cubit.state.loading, isFalse);
      await cubit.close();
    });

    test('a refused file never reaches the network, and says why', () async {
      final repo = FakeMediaRepository();
      final cubit = build(repo);

      await cubit.addUpload(
        filename: 'holiday.heic',
        bytes: _bytes(1024),
        contentType: 'image/heic',
      );

      expect(repo.uploaded, isEmpty);
      expect(cubit.state.uploads.single.rejection, MediaRejection.type);
      expect(cubit.state.files, isEmpty);
      await cubit.close();
    });

    test('a bad file does not stop the good ones in the same batch', () async {
      // README §C.3: the files that made it land; the one that did not says
      // which one it was.
      final repo = FakeMediaRepository();
      final cubit = build(repo);

      await cubit.addUpload(
        filename: 'good.jpg',
        bytes: _bytes(2048),
        contentType: 'image/jpeg',
        width: 2400,
        height: 1600,
      );
      await cubit.addUpload(
        filename: 'small.jpg',
        bytes: _bytes(2048),
        contentType: 'image/jpeg',
        width: 1200,
        height: 800,
      );

      expect(repo.uploaded, ['good.jpg']);
      expect(cubit.state.files, hasLength(1));
      expect(cubit.state.uploads.map((u) => u.filename), [
        'good.jpg',
        'small.jpg',
      ]);
      expect(cubit.state.uploads.first.done, isTrue);
      expect(cubit.state.uploads.last.rejection, MediaRejection.tooSmall);
      await cubit.close();
    });

    test(
      'a failed upload marks its own row and keeps the library intact',
      () async {
        final repo = FakeMediaRepository()
          ..nextUploadError = StateError('offline');
        final cubit = build(repo);

        await cubit.addUpload(
          filename: 'good.jpg',
          bytes: _bytes(2048),
          contentType: 'image/jpeg',
          width: 2400,
          height: 1600,
        );

        expect(cubit.state.uploads.single.isFailed, isTrue);
        expect(cubit.state.files, isEmpty);
        expect(cubit.state.error, isNotNull);
        await cubit.close();
      },
    );

    test('a file a page renders cannot be deleted', () async {
      // The worst outcome of this screen is a photo vanishing from a live page
      // because somebody tidied the library (README §C.3).
      final repo = FakeMediaRepository(
        library: const [
          MediaFile(
            storagePath: 'site-1/used.jpg',
            filename: 'used.jpg',
            usage: ['page/home:heroPhotos'],
          ),
          MediaFile(storagePath: 'site-1/free.jpg', filename: 'free.jpg'),
        ],
      );
      final cubit = build(repo);
      await cubit.load();

      expect(await cubit.deleteFile('site-1/used.jpg'), isFalse);
      expect(repo.deleted, isEmpty);
      expect(cubit.state.files, hasLength(2));

      expect(await cubit.deleteFile('site-1/free.jpg'), isTrue);
      expect(repo.deleted, ['site-1/free.jpg']);
      expect(cubit.state.files.single.storagePath, 'site-1/used.jpg');
      await cubit.close();
    });

    test('usage is written only where it changed', () async {
      final repo = FakeMediaRepository(
        library: const [
          MediaFile(
            storagePath: 'site-1/a.jpg',
            filename: 'a.jpg',
            usage: ['page/home:heroPhotos'],
          ),
          MediaFile(storagePath: 'site-1/b.jpg', filename: 'b.jpg'),
        ],
      );
      final cubit = build(repo);
      await cubit.load();

      await cubit.syncUsage({
        'site-1/a.jpg': ['page/home:heroPhotos'],
        'site-1/b.jpg': ['page/gallery:galleryAll'],
      });

      expect(repo.usageWrites.single.keys, ['site-1/b.jpg']);
      expect(cubit.state.fileFor('site-1/b.jpg')!.usage, [
        'page/gallery:galleryAll',
      ]);
      await cubit.close();
    });

    test('a failed usage write does not surface as an editor error', () async {
      // Usage is a convenience the picker reads, not content.
      final repo = _UsageFailingRepository();
      final cubit = MediaLibraryCubit(repository: repo, siteId: 'site-1');
      await cubit.load();

      await cubit.syncUsage({'site-1/a.jpg': const []});

      expect(cubit.state.error, isNull);
      await cubit.close();
    });
  });
}

class _UsageFailingRepository extends FakeMediaRepository {
  _UsageFailingRepository()
    : super(
        library: const [
          MediaFile(
            storagePath: 'site-1/a.jpg',
            filename: 'a.jpg',
            usage: ['page/home:heroPhotos'],
          ),
        ],
      );

  @override
  Future<void> saveUsage({
    required String siteId,
    required Map<String, List<String>> usageByPath,
  }) async {
    throw StateError('offline');
  }
}
