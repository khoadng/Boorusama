// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/dart.dart';

typedef CacheSizeInfo = ({
  DirectorySizeInfo appCacheSize,
  DirectorySizeInfo imageCacheSize,
});

class CacheSizeNotifier extends AutoDisposeNotifier<CacheSizeInfo> {
  @override
  CacheSizeInfo build() {
    calculateCacheSize();

    return (
      appCacheSize: DirectorySizeInfo.zero,
      imageCacheSize: DirectorySizeInfo.zero,
    );
  }

  Future<void> clearAppCache() async {
    await clearCache();
    state = (
      appCacheSize: DirectorySizeInfo.zero,
      imageCacheSize: DirectorySizeInfo.zero,
    );
  }

  Future<void> clearAppImageCache() async {
    await clearImageCache();
    await calculateCacheSize();
  }

  Future<void> calculateCacheSize() async {
    final cacheSize = await getCacheSize();
    final imageCacheSize = await getImageCacheSize();
    state = (
      appCacheSize: cacheSize,
      imageCacheSize: imageCacheSize,
    );
  }
}
