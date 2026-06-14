// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/filesystem.dart';

final defaultCachedImageFileProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>(
      (ref, imageUrl) async {
        final cacheManager = ref.watch(defaultImageCacheManagerProvider);
        final cacheKey = cacheManager.generateCacheKey(imageUrl);
        final bytes = await cacheManager.getCachedFileBytes(cacheKey);

        return bytes;
      },
    );

final defaultImageCacheManagerProvider = Provider<ImageCacheManager>(
  (ref) {
    final fs = ref.watch(appFileSystemProvider);
    final manager = createDefaultImageCacheManager(fs);

    ref.onDispose(() {
      manager.dispose();
    });

    return manager;
  },
);

ImageCacheManager createDefaultImageCacheManager(AppFileSystem fs) {
  return DefaultImageCacheManager(
    enableLogging: kDebugMode,
    cacheRootPathProvider: () async {
      final path = await fs.getTemporaryPath();
      if (path == null) throw Exception('Cache directory not available');
      return path;
    },
    memoryCache: LRUMemoryCache(
      maxEntries: 500,
    ),
  );
}
