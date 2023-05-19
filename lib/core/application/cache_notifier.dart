// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/utils/file_utils.dart';

class CacheSizeNotifier extends Notifier<DirectorySizeInfo> {
  @override
  DirectorySizeInfo build() {
    calculateCacheSize();
    return DirectorySizeInfo.zero;
  }

  Future<void> clearAppCache() async {
    await clearCache();
    state = DirectorySizeInfo.zero;
  }

  Future<void> calculateCacheSize() async {
    final cacheSize = await getCacheSize();
    state = cacheSize;
  }
}
