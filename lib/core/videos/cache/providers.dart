// Package imports:
import 'package:background_downloader/background_downloader.dart';
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/filesystem.dart';
import '../../../foundation/platform.dart';
import '../../http/client/providers.dart';
import '../../settings/providers.dart';

final videoCacheManagerProvider = Provider<VideoCacheManager?>(
  (ref) {
    if (isWeb()) {
      return null;
    }

    final enable = ref.watch(
      imageViewerSettingsProvider.select((s) => s.enableVideoCache),
    );

    if (!enable) return null;

    final videoCacheSize = ref.watch(
      settingsProvider.select((s) => s.videoCacheMaxSize),
    );

    if (videoCacheSize.isZero) return null;

    final fs = ref.watch(appFileSystemProvider);
    final manager = VideoCacheManager(
      maxTotalCacheSize: videoCacheSize.bytes,
      fileDownloader: FileDownloader(),
      dio: ref.watch(genericDioProvider),
      cacheRootPathProvider: () async {
        final path = await fs.getTemporaryPath();
        if (path == null) throw Exception('Cache directory not available');
        return path;
      },
    );

    ref.onDispose(() {
      manager.dispose();
    });

    return manager;
  },
);
