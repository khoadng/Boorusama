import 'dart:async';
import 'dart:typed_data';

import 'package:background_downloader/background_downloader.dart';
import 'package:dio/dio.dart';

import 'cache_manager.dart';
import 'cache_utils.dart' as cache_utils;
import 'memory_cache.dart';

class VideoCacheManager implements ImageCacheManager {
  VideoCacheManager({
    required this.fileDownloader,
    required this.dio,
    this.maxTotalCacheSize = 1 * 1024 * 1024 * 1024, // 1GB
    this.maxItemSize = 100 * 1024 * 1024, // 100MB
    this.evictionThreshold = 0.8,
    this.enableLogging = false,
    this.cacheDirName = defaultSubPath,
    MemoryCache? memoryCache,
  }) : _memoryCache = memoryCache ?? LRUMemoryCache();

  final String cacheDirName;
  final bool enableLogging;
  final MemoryCache _memoryCache;
  final _keyCache = <String, String>{};

  // Not used on web, but kept for interface compatibility
  final int maxTotalCacheSize;
  final int maxItemSize;
  final double evictionThreshold;
  final FileDownloader fileDownloader;
  final Dio dio;

  static const String videoCacheGroup = 'video_cache';
  static const String defaultSubPath = 'cachevideo';

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
  FutureOr<bool> hasValidCache(String key, {Duration? maxAge}) {
    return _memoryCache.contains(key);
  }

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
  Future<void> clearCache(String key) async {
    _memoryCache.remove(key);
  }

  @override
  void invalidateCacheDirectory() {
    // No-op for web
  }

  Future<void> clearAllVideos() async {
    _memoryCache.clear();
  }

  Future<bool> isVideoCached(String url, {Duration? maxAge}) async {
    final cacheKey = generateCacheKey(url);
    return await hasValidCache(cacheKey, maxAge: maxAge);
  }

  Future<String?> getCachedVideoPath(String url, {Duration? maxAge}) async {
    final cacheKey = generateCacheKey(url);
    return await getCachedFilePath(cacheKey, maxAge: maxAge);
  }

  Future<String?> cacheVideo(
    String url, {
    Map<String, String>? headers,
    int? fileSize,
  }) async {
    // Not supported on web - videos are not pre-cached
    return null;
  }

  Future<bool> cancelPreload(String taskId) async {
    // Not supported on web
    return false;
  }

  Future<void> clearVideo(String url) async {
    final cacheKey = generateCacheKey(url);
    await clearCache(cacheKey);
  }

  @override
  Future<void> dispose() async {
    _memoryCache.clear();
    _keyCache.clear();
  }
}
