// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:path/path.dart';

class BookmarkCacheKeyGenerator implements CacheKeyGenerator {
  @override
  String generateKey(String url, {String? customKey}) {
    if (customKey != null) {
      return customKey;
    }

    final md5Hash = keyToMd5(url);
    final extension = _extractExtension(url);

    return '$md5Hash$extension';
  }

  String _extractExtension(String url) {
    final uri = Uri.parse(url);
    final pathOnly = uri.path;

    return extension(pathOnly).toLowerCase();
  }
}

/// Specialized cache manager for bookmarked images that stores files
/// in permanent storage and organizes them by image type
class BookmarkImageCacheManager implements CacheManager {
  BookmarkImageCacheManager({
    required this.fileManager,
    required this.cacheDir,
    required this.keyGenerator,
    required this.logger,
  });

  final FileManager fileManager;
  final CacheDirectory cacheDir;
  final CacheKeyGenerator keyGenerator;
  final CacheLogger logger;

  @override
  FutureOr<File?> getCachedFile(String key) async {
    try {
      final cacheDir = await this.cacheDir.get();
      final filePath = join(cacheDir.path, key);
      return fileManager.getFileIfExists(filePath);
    } catch (e) {
      logger.log('Error getting cached file: $e');
      return null;
    }
  }

  @override
  FutureOr<Uint8List?> getCachedFileBytes(String key) async {
    try {
      final cacheDir = await this.cacheDir.get();
      final filePath = join(cacheDir.path, key);
      return await fileManager.readFileBytes(filePath);
    } catch (e) {
      logger.log('Error reading cache: $e');
      return null;
    }
  }

  @override
  Future<void> saveFile(String key, Uint8List bytes) async {
    try {
      final cacheDir = await this.cacheDir.get();
      final filePath = join(cacheDir.path, key);
      await fileManager.writeFileBytes(filePath, bytes);
    } catch (e) {
      logger.log('Failed to write cache: $e');
    }
  }

  @override
  FutureOr<bool> hasValidCache(String key, {Duration? maxAge}) async {
    try {
      final cacheDir = await this.cacheDir.get();
      final filePath = join(cacheDir.path, key);
      return fileManager.fileExists(filePath);
    } catch (e) {
      logger.log('Error checking cache: $e');
      return false;
    }
  }

  @override
  Future<void> clearCache(String key) async {
    try {
      final cacheDir = await this.cacheDir.get();
      final filePath = join(cacheDir.path, key);
      await fileManager.deleteFile(filePath);
    } catch (e) {
      logger.log('Error clearing cache: $e');
    }
  }

  @override
  String generateCacheKey(String url, {String? customKey}) =>
      keyGenerator.generateKey(url, customKey: customKey);

  @override
  void invalidateCacheDirectory() => cacheDir.invalidate();

  @override
  Future<void> dispose() async => cacheDir.dispose();

  /// Clear all files in this cache directory
  Future<void> clearAllCache() async {
    try {
      final cacheDir = await this.cacheDir.get();
      final files = await fileManager.listFiles(cacheDir.path);

      for (final file in files) {
        await fileManager.deleteFile(file.path);
      }

      logger.log('Cleared all cached files in ${cacheDir.path}');
    } catch (e) {
      logger.log('Error clearing all cache: $e');
    }
  }

  /// Get total size of cached files
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await this.cacheDir.get();
      final files = await fileManager.listFiles(cacheDir.path);

      var totalSize = 0;
      for (final file in files) {
        totalSize += fileManager.getFileSize(file.path);
      }

      return totalSize;
    } catch (e) {
      logger.log('Error calculating cache size: $e');
      return 0;
    }
  }

  /// Get list of cached files
  Future<List<File>> getCachedFiles() async {
    try {
      final cacheDir = await this.cacheDir.get();
      return fileManager.listFiles(cacheDir.path);
    } catch (e) {
      logger.log('Error listing cached files: $e');
      return [];
    }
  }

  /// Get cache stats including total size and file count
  Future<(int size, int fileCount)> getCacheStats() async {
    try {
      final files = await getCachedFiles();
      var totalSize = 0;

      for (final file in files) {
        totalSize += fileManager.getFileSize(file.path);
      }

      return (totalSize, files.length);
    } catch (e) {
      logger.log('Error getting cache stats: $e');
      return (0, 0);
    }
  }
}
