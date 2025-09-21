// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final manager = DefaultImageCacheManager(
      enableLogging: kDebugMode,
      memoryCache: LRUMemoryCache(
        maxEntries: 500,
      ),
    );

    ref.onDispose(() {
      manager.dispose();
    });

    return manager;
  },
);
