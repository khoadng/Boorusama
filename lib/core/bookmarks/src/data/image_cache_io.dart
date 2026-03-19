// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/filesystem.dart';
import '../../../../foundation/path.dart';
import '../../../../foundation/platform.dart';

final bookmarkImageCacheManagerProvider = Provider<BookmarkImageCacheManager?>(
  (ref) => !isWeb()
      ? BookmarkImageCacheManager(fs: ref.watch(appFileSystemProvider))
      : null,
);

final bookmarkCacheInfoProvider = FutureProvider.autoDispose<(int, int)>((
  ref,
) {
  final cacheManager = ref.watch(bookmarkImageCacheManagerProvider);
  return cacheManager?.getCacheStats() ?? (0, 0);
});

/// Specialized cache manager for bookmarked images that stores files
/// in permanent storage and organizes them by image type
class BookmarkImageCacheManager implements ImageCacheManager {
  BookmarkImageCacheManager({
    required AppFileSystem fs,
    this.enableLogging = false,
  }) : _fs = fs;

  final AppFileSystem _fs;
  final bool enableLogging;

  String? _cacheDirPath;
  Future<String>? _cacheDirFuture;

  /// Get the cache directory path, creating it if needed
  FutureOr<String> getCacheDirectory() {
    if (_cacheDirPath != null) {
      return _cacheDirPath!;
    }

    if (_cacheDirFuture != null) {
      return _cacheDirFuture!;
    }

    _cacheDirFuture = _initializeCacheDirectory();

    return _cacheDirFuture!
        .then((dirPath) {
          _cacheDirPath = dirPath;
          return dirPath;
        })
        .catchError((e) {
          _cacheDirFuture = null;
          throw e;
        });
  }

  Future<String> _initializeCacheDirectory() async {
    final basePath = await _fs.getAppStoragePath();

    if (basePath.isEmpty) {
      throw Exception('Dir not found');
    }

    final dirPath = join(basePath, 'bookmarks', 'images');

    if (!_fs.directoryExistsSync(dirPath)) {
      await _fs.createDirectory(dirPath, recursive: true);
    }

    return dirPath;
  }

  FutureOr<String?> _getCachedFile(String key, {Duration? maxAge}) {
    final dirResult = getCacheDirectory();

    if (dirResult is Future<String>) {
      return dirResult.then(
        (cacheDirPath) => _getValidFile(cacheDirPath, key, maxAge),
      );
    }

    final cacheDirPath = dirResult;
    return _getValidFile(cacheDirPath, key, maxAge);
  }

  @override
  FutureOr<String?> getCachedFilePath(String key, {Duration? maxAge}) {
    return _getCachedFile(key, maxAge: maxAge);
  }

  String? _getValidFile(String cacheDirPath, String key, Duration? maxAge) {
    try {
      final filePath = join(cacheDirPath, key);

      if (_fs.fileExistsSync(filePath)) {
        return filePath;
      }

      return null;
    } catch (e) {
      _log('Error getting cached file: $e');
      return null;
    }
  }

  @override
  FutureOr<Uint8List?> getCachedFileBytes(String key, {Duration? maxAge}) {
    final fileResult = _getCachedFile(key, maxAge: maxAge);

    if (fileResult is Future<String?>) {
      return fileResult.then((path) => _readFileBytes(path));
    }

    final path = fileResult;
    return _readFileBytes(path);
  }

  FutureOr<Uint8List?> _readFileBytes(String? path) {
    if (path == null) return null;

    try {
      return _fs.readBytes(path);
    } catch (e) {
      _log('Error reading cache: $e');
      return null;
    }
  }

  @override
  Future<void> saveFile(String key, Uint8List bytes) async {
    try {
      final cacheDirPath = await getCacheDirectory();
      final filePath = join(cacheDirPath, key);
      await _fs.writeBytes(filePath, bytes);
    } catch (e) {
      _log('Failed to write cache: $e');
    }
  }

  @override
  FutureOr<bool> hasValidCache(String key, {Duration? maxAge}) {
    final fileResult = _getCachedFile(key, maxAge: maxAge);

    if (fileResult is Future<String?>) {
      return fileResult.then((path) => path != null);
    }

    return fileResult != null;
  }

  @override
  Future<void> clearCache(String key) async {
    try {
      final cacheDirPath = await getCacheDirectory();
      final filePath = join(cacheDirPath, key);

      if (_fs.fileExistsSync(filePath)) {
        await _fs.deleteFile(filePath);
      }
    } catch (e) {
      _log('Error clearing cache: $e');
    }
  }

  @override
  String generateCacheKey(String url, {String? customKey}) {
    if (customKey != null) {
      return customKey;
    }

    final md5Hash = keyToMd5(url);
    final ext = _extractExtension(url);

    return '$md5Hash$ext';
  }

  @override
  void invalidateCacheDirectory() {
    _cacheDirPath = null;
    _cacheDirFuture = null;
  }

  @override
  Future<void> dispose() async {
    _cacheDirPath = null;
    _cacheDirFuture = null;
  }

  /// Clear all files in this cache directory
  Future<void> clearAllCache() async {
    try {
      final cacheDirPath = await getCacheDirectory();
      final entries = _fs.listDirectorySync(cacheDirPath);

      for (final entry in entries.where((e) => e.isFile)) {
        await _fs.deleteFile(entry.path);
      }

      _log('Cleared all cached files in $cacheDirPath');
    } catch (e) {
      _log('Error clearing all cache: $e');
    }
  }

  /// Get total size of cached files
  Future<int> getCacheSize() async {
    try {
      final cacheDirPath = await getCacheDirectory();
      final entries = _fs.listDirectorySync(cacheDirPath);

      var totalSize = 0;
      for (final entry in entries.where((e) => e.isFile)) {
        totalSize += _fs.fileSizeSync(entry.path);
      }

      return totalSize;
    } catch (e) {
      _log('Error calculating cache size: $e');
      return 0;
    }
  }

  /// Get list of cached file paths
  Future<List<String>> getCachedFiles() async {
    try {
      final cacheDirPath = await getCacheDirectory();
      final entries = _fs.listDirectorySync(cacheDirPath);

      return entries.where((e) => e.isFile).map((e) => e.path).toList();
    } catch (e) {
      _log('Error listing cached files: $e');
      return [];
    }
  }

  /// Get cache stats including total size and file count
  Future<(int size, int fileCount)> getCacheStats() async {
    try {
      final files = await getCachedFiles();
      var totalSize = 0;

      for (final path in files) {
        totalSize += _fs.fileSizeSync(path);
      }

      return (totalSize, files.length);
    } catch (e) {
      _log('Error getting cache stats: $e');
      return (0, 0);
    }
  }

  void _log(String message) {
    if (enableLogging && kDebugMode) {
      debugPrint('[BookmarkImageCacheManager] $message');
    }
  }
}

String _extractExtension(String url) {
  final uri = Uri.parse(url);
  final pathOnly = uri.path;

  return extension(pathOnly).toLowerCase();
}
