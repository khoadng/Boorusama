import 'dart:async';
import 'dart:typed_data';

import 'cache_manager.dart';
import 'cache_utils.dart' as cache_utils;
import 'memory_cache.dart';

class DefaultImageCacheManager implements ImageCacheManager {
  DefaultImageCacheManager({
    this.cacheDirName = 'cacheimage',
    this.enableLogging = false,
    MemoryCache? memoryCache,
  }) : _memoryCache = memoryCache ?? LRUMemoryCache();

  final String cacheDirName;
  final bool enableLogging;
  final MemoryCache _memoryCache;
  final _keyCache = <String, String>{};

  @override
  FutureOr<String?> getCachedFilePath(String key, {Duration? maxAge}) {
    // Web doesn't support file paths, return null
    return null;
  }

  @override
  FutureOr<Uint8List?> getCachedFileBytes(String key, {Duration? maxAge}) {
    return _memoryCache.get(key);
  }

  @override
  Future<void> saveFile(String key, Uint8List bytes) async {
    _memoryCache.put(key, bytes);
  }

  @override
  FutureOr<bool> hasValidCache(String key, {Duration? maxAge}) {
    return _memoryCache.contains(key);
  }

  @override
  Future<void> clearCache(String key) async {
    _memoryCache.remove(key);
  }

  @override
  String generateCacheKey(String url, {String? customKey}) {
    return cache_utils.generateCacheKey(
      url,
      customKey: customKey,
      keyToMd5: _keyToMd5,
    );
  }

  String _keyToMd5(String key) {
    if (_keyCache.containsKey(key)) {
      return _keyCache[key]!;
    }
    final md5Key = cache_utils.keyToMd5(key);
    _keyCache[key] = md5Key;
    return md5Key;
  }

  @override
  void invalidateCacheDirectory() {
    // No-op for web
  }

  @override
  Future<void> dispose() async {
    _memoryCache.clear();
    _keyCache.clear();
  }
}
