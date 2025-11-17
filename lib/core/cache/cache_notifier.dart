// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/utils/file_utils.dart';
import '../images/providers.dart';
import '../tags/local/providers.dart';
import '../videos/cache/providers.dart';
import 'persistent/providers.dart';

final appCacheSizeProvider = FutureProvider.autoDispose<DirectorySizeInfo>(
  (
    ref,
  ) => getCacheSize().catchError((_) => DirectorySizeInfo.zero),
);

final imageCacheSizeProvider = FutureProvider.autoDispose<DirectorySizeInfo>(
  (
    ref,
  ) => getImageCacheSize().catchError((_) => DirectorySizeInfo.zero),
);

final tagCacheSizeProvider = FutureProvider.autoDispose<int>(
  (ref) => _getTagCacheSize().catchError((_) => 0),
);

final diskSpaceInfoProvider = FutureProvider.autoDispose<DiskSpaceInfo>(
  (
    ref,
  ) => DiskSpaceInfo.fromTempDir().catchError((_) => DiskSpaceInfo.zero),
);

final videoCacheSizeProvider = FutureProvider.autoDispose<DirectorySizeInfo>(
  (ref) => getVideoCacheSize().catchError((_) => DirectorySizeInfo.zero),
);

final persistentCacheSizeProvider = FutureProvider.autoDispose<int>(
  (ref) => _getPersistentCacheSize(ref).catchError((_) => 0),
);

final cacheSizeProvider =
    AsyncNotifierProvider.autoDispose<CacheSizeNotifier, CacheSizeInfo>(
      CacheSizeNotifier.new,
    );

enum StorageType {
  systemData,
  imageCache,
  videoCache,
  bookmarkImages,
  tagCache,
  appCache,
  freeSpace,
}

class StorageInfo {
  const StorageInfo({
    required this.type,
    required this.size,
  });

  final StorageType type;
  final int size;
}

class CacheSizeInfo {
  const CacheSizeInfo({
    required this.appCacheSize,
    required this.imageCacheSize,
    required this.videoCacheSize,
    required this.tagCacheSize,
    required this.persistentCacheSize,
    required this.diskSpaceInfo,
  });

  final DirectorySizeInfo appCacheSize;
  final DirectorySizeInfo imageCacheSize;
  final DirectorySizeInfo videoCacheSize;
  final int tagCacheSize;
  final int persistentCacheSize;
  final DiskSpaceInfo diskSpaceInfo;

  static final zero = CacheSizeInfo(
    appCacheSize: DirectorySizeInfo.zero,
    imageCacheSize: DirectorySizeInfo.zero,
    videoCacheSize: DirectorySizeInfo.zero,
    tagCacheSize: 0,
    persistentCacheSize: 0,
    diskSpaceInfo: DiskSpaceInfo.zero,
  );

  int get totalSize =>
      appCacheSize.size +
      imageCacheSize.size +
      videoCacheSize.size +
      tagCacheSize +
      persistentCacheSize;

  List<StorageInfo> getStorageBreakdown({
    int bookmarkCacheSize = 0,
  }) {
    final totalCacheSize = totalSize + bookmarkCacheSize;
    final systemUsedSpace = diskSpaceInfo.usedSpace - totalCacheSize;

    return [
      if (systemUsedSpace > 0)
        StorageInfo(
          type: StorageType.systemData,
          size: systemUsedSpace,
        ),
      if (imageCacheSize.size > 0)
        StorageInfo(
          type: StorageType.imageCache,
          size: imageCacheSize.size,
        ),
      if (videoCacheSize.size > 0)
        StorageInfo(
          type: StorageType.videoCache,
          size: videoCacheSize.size,
        ),
      if (bookmarkCacheSize > 0)
        StorageInfo(
          type: StorageType.bookmarkImages,
          size: bookmarkCacheSize,
        ),
      if (tagCacheSize > 0)
        StorageInfo(
          type: StorageType.tagCache,
          size: tagCacheSize,
        ),
      if (appCacheSize.size > 0 || persistentCacheSize > 0)
        StorageInfo(
          type: StorageType.appCache,
          size: appCacheSize.size + persistentCacheSize,
        ),
      if (diskSpaceInfo.freeSpace > 0)
        StorageInfo(
          type: StorageType.freeSpace,
          size: diskSpaceInfo.freeSpace,
        ),
    ];
  }
}

class CacheSizeNotifier extends AutoDisposeAsyncNotifier<CacheSizeInfo> {
  @override
  Future<CacheSizeInfo> build() async {
    final appCache = ref.watch(appCacheSizeProvider);
    final imageCache = ref.watch(imageCacheSizeProvider);
    final tagCache = ref.watch(tagCacheSizeProvider);
    final diskSpace = ref.watch(diskSpaceInfoProvider);
    final videoCache = ref.watch(videoCacheSizeProvider);
    final persistentCache = ref.watch(persistentCacheSizeProvider);

    return CacheSizeInfo(
      appCacheSize: appCache.valueOrNull ?? DirectorySizeInfo.zero,
      imageCacheSize: imageCache.valueOrNull ?? DirectorySizeInfo.zero,
      tagCacheSize: tagCache.valueOrNull ?? 0,
      diskSpaceInfo: diskSpace.valueOrNull ?? DiskSpaceInfo.zero,
      videoCacheSize: videoCache.valueOrNull ?? DirectorySizeInfo.zero,
      persistentCacheSize: persistentCache.valueOrNull ?? 0,
    );
  }

  void refreshCacheSize() {
    ref
      ..invalidate(appCacheSizeProvider)
      ..invalidate(imageCacheSizeProvider)
      ..invalidate(tagCacheSizeProvider)
      ..invalidate(diskSpaceInfoProvider)
      ..invalidate(videoCacheSizeProvider)
      ..invalidate(persistentCacheSizeProvider)
      ..invalidateSelf();
  }

  Future<void> clearAllCache() async {
    state = const AsyncValue.loading();
    await _withMinimumDelay(() async {
      final cacheManager = ref.read(defaultImageCacheManagerProvider);
      await clearImageCache(cacheManager);
      await clearCache();
      await clearTagCacheDatabase(ref);
      await clearVideoCache(ref);
      await clearPersistentCache(ref);
    });
    refreshCacheSize();
  }

  Future<void> clearAppImageCache() async {
    state = const AsyncValue.loading();
    await _withMinimumDelay(() async {
      final cacheManager = ref.read(defaultImageCacheManagerProvider);
      await clearImageCache(cacheManager);
    });
    refreshCacheSize();
  }

  Future<void> clearAppTagCache() async {
    state = const AsyncValue.loading();
    await _withMinimumDelay(() async {
      await clearTagCacheDatabase(ref);
    });
    refreshCacheSize();
  }

  Future<void> clearAppVideoCache() async {
    state = const AsyncValue.loading();
    await _withMinimumDelay(() async {
      await clearVideoCache(ref);
    });
    refreshCacheSize();
  }

  // Ensure that the operation takes at least some time to prevent UI flickering
  Future<void> _withMinimumDelay(Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();

    final remainingTime = 500 - stopwatch.elapsedMilliseconds;
    if (remainingTime > 0) {
      await Future.delayed(Duration(milliseconds: remainingTime));
    }
  }
}

Future<int> _getTagCacheSize() async {
  final dbFile = await _getTagCacheFile();
  return dbFile.existsSync() ? dbFile.statSync().size : 0;
}

Future<bool> clearTagCacheDatabase(Ref ref) async {
  try {
    final currentRepo = await ref.read(tagCacheRepositoryProvider.future);
    await currentRepo.dispose();

    ref.invalidate(tagCacheRepositoryProvider);

    final dbFile = await _getTagCacheFile();
    if (dbFile.existsSync()) {
      await dbFile.delete();

      // Invalidate to make sure we not use the old database connection
      ref.invalidate(tagCacheRepositoryProvider);

      return true;
    }

    return false;
  } on Exception catch (_) {
    return false;
  }
}

Future<File> _getTagCacheFile() async {
  final dbPath = await getTagCacheDbPath();
  return File(dbPath);
}

Future<bool> clearVideoCache(Ref ref) async {
  try {
    final cacheManager = ref.read(videoCacheManagerProvider);
    await cacheManager?.clearAllVideos();
    return true;
  } on Exception catch (_) {
    return false;
  }
}

Future<int> _getPersistentCacheSize(Ref ref) async {
  try {
    final box = await ref.watch(persistentCacheBoxProvider.future);
    // Hive doesn't provide direct size calculation, so we estimate based on entry count
    return box.length * 1024;
  } on Exception catch (_) {
    return 0;
  }
}

Future<bool> clearPersistentCache(Ref ref) async {
  try {
    final box = await ref.read(persistentCacheBoxProvider.future);
    await box.clear();
    return true;
  } on Exception catch (_) {
    return false;
  }
}
