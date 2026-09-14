// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;

// Project imports:
import 'package:boorusama/core/downloads/background/downloader.dart';
import 'package:boorusama/core/downloads/downloader/types.dart';
import 'package:boorusama/core/downloads/sidecar/data.dart';
import 'package:boorusama/core/downloads/sidecar/types.dart';
import 'package:boorusama/foundation/filesystem.dart';

class _Cache extends Mock implements VideoCacheManager {}

class _FileSystem extends IoFileSystem {
  const _FileSystem(this.storagePath);
  final String storagePath;
  @override
  Future<String> getAppStoragePath() async => storagePath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'cached media finalizes metadata and skip-existing skips the whole pair',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final root = await Directory.systemTemp.createTemp('sidecar-cache-test-');
      addTearDown(() => root.delete(recursive: true));
      final cached = File(p.join(root.path, 'cached.mp4'));
      await cached.writeAsBytes([1, 2, 3, 4]);
      final cache = _Cache();
      when(
        () => cache.getCachedVideoPath(any()),
      ).thenAnswer((_) async => cached.path);
      final downloader = BackgroundDownloader(
        fs: _FileSystem(p.join(root.path, 'app')),
        sidecarStore: Future.value(
          SidecarStore(
            directory: p.join(root.path, 'app', 'download-sidecars'),
            fs: _FileSystem(p.join(root.path, 'app')),
          ),
        ),
        videoCacheManager: cache,
      );
      final options = DownloadOptions(
        url: 'https://example.org/video.mp4',
        filename: 'video.mp4',
        path: p.join(root.path, 'downloads'),
        skipIfExists: true,
        metadata: const DownloaderMetadata(
          thumbnailUrl: null,
          fileSize: null,
          siteUrl: null,
          group: null,
          isVideo: true,
        ),
        sidecar: SidecarSnapshot(
          format: SidecarFormat.tags,
          tags: const ['artist:one'],
          quality: 'original',
        ),
      );
      final result = await downloader.download(options);
      expect(
        result,
        isA<DownloadCompleted>(),
        reason: result is DownloadFailure
            ? result.error.getErrorMessage()
            : null,
      );
      final completed = result as DownloadCompleted;
      expect(completed.source, DownloadCompletionSource.cache);
      expect(await File(completed.info.path).readAsBytes(), [1, 2, 3, 4]);
      final sidecar = File('${completed.info.path}.txt');
      expect(await sidecar.readAsString(), 'artist:one\n');

      await sidecar.delete();
      expect(await downloader.download(options), isA<DownloadSkipped>());
      expect(sidecar.existsSync(), isFalse);
    },
  );
}
