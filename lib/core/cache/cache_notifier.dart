// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/utils/file_utils.dart';
import '../tags/local/providers.dart';

final cacheSizeProvider =
    AsyncNotifierProvider.autoDispose<CacheSizeNotifier, CacheSizeInfo>(
  CacheSizeNotifier.new,
);

class CacheSizeInfo {
  const CacheSizeInfo({
    required this.appCacheSize,
    required this.imageCacheSize,
    required this.tagCacheSize,
  });

  final DirectorySizeInfo appCacheSize;
  final DirectorySizeInfo imageCacheSize;
  final int tagCacheSize;

  static final zero = CacheSizeInfo(
    appCacheSize: DirectorySizeInfo.zero,
    imageCacheSize: DirectorySizeInfo.zero,
    tagCacheSize: 0,
  );

  int get totalSize => appCacheSize.size + imageCacheSize.size + tagCacheSize;
}

class CacheSizeNotifier extends AutoDisposeAsyncNotifier<CacheSizeInfo> {
  @override
  Future<CacheSizeInfo> build() {
    return calculateCacheSize();
  }

  void refreshCacheSize() {
    ref.invalidateSelf();
  }

  Future<void> clearAllCache() async {
    state = const AsyncValue.loading();
    await _withMinimumDelay(() async {
      await clearImageCache();
      await clearCache();
      await clearTagCacheDatabase();
    });
    refreshCacheSize();
  }

  Future<void> clearAppImageCache() async {
    state = const AsyncValue.loading();
    await _withMinimumDelay(() async {
      await clearImageCache();
    });
    refreshCacheSize();
  }

  Future<void> clearAppTagCache() async {
    state = const AsyncValue.loading();
    await _withMinimumDelay(() async {
      await clearTagCacheDatabase();
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

Future<CacheSizeInfo> calculateCacheSize() async {
  final cacheSize = await getCacheSize();
  final imageCacheSize = await getImageCacheSize();
  final tagCacheSize = await _getTagCacheSize();

  return CacheSizeInfo(
    appCacheSize: cacheSize,
    imageCacheSize: imageCacheSize,
    tagCacheSize: tagCacheSize,
  );
}

Future<int> _getTagCacheSize() async {
  final dbFile = await _getTagCacheFile();
  return dbFile.existsSync() ? dbFile.statSync().size : 0;
}

Future<bool> clearTagCacheDatabase() async {
  try {
    final dbFile = await _getTagCacheFile();
    if (dbFile.existsSync()) {
      await dbFile.delete();

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
