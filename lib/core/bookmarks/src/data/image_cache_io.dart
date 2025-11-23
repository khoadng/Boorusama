// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final bookmarkImageCacheManagerProvider = Provider<BookmarkImageCacheManager>(
  (ref) => BookmarkImageCacheManager(),
);

final bookmarkCacheInfoProvider = FutureProvider.autoDispose<(int, int)>((
  ref,
) {
  final cacheManager = ref.watch(bookmarkImageCacheManagerProvider);
  return cacheManager.getCacheStats();
});

/// Specialized cache manager for bookmarked images that stores files
/// in permanent storage and organizes them by image type
class BookmarkImageCacheManager implements ImageCacheManager {
  BookmarkImageCacheManager({
    this.enableLogging = false,
  });

  final bool enableLogging;

  Directory? _cacheDir;
  Future<Directory>? _cacheDirFuture;

  /// Get the cache directory, creating it if needed
  FutureOr<Directory> getCacheDirectory() {
    if (_cacheDir != null) {
      return _cacheDir!;
    }

    // If initialization is already in progress, await that same future
    if (_cacheDirFuture != null) {
      return _cacheDirFuture!;
    }

    // Start initialization and cache the future
    _cacheDirFuture = _initializeCacheDirectory();

    return _cacheDirFuture!
        .then((dir) {
          _cacheDir = dir;
          return dir;
        })
        .catchError((e) {
          _cacheDirFuture = null;
          throw e;
        });
  }

  Future<Directory> _initializeCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dirPath = join(appDir.path, 'bookmarks', 'images');
    final dir = Directory(dirPath);

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  FutureOr<File?> _getCachedFile(String key, {Duration? maxAge}) {
    final dirResult = getCacheDirectory();

    if (dirResult is Future<Directory>) {
      return dirResult.then((cacheDir) => _getValidFile(cacheDir, key, maxAge));
    }

    final cacheDir = dirResult;
    return _getValidFile(cacheDir, key, maxAge);
  }

  @override
  FutureOr<String?> getCachedFilePath(String key, {Duration? maxAge}) async {
    final fileResult = await _getCachedFile(key, maxAge: maxAge);

    return fileResult?.path;
  }

  File? _getValidFile(Directory cacheDir, String key, Duration? maxAge) {
    try {
      final cacheFile = File(join(cacheDir.path, key));

      if (cacheFile.existsSync()) {
        return cacheFile;
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

    if (fileResult is Future<File?>) {
      return fileResult.then((file) => _readFileBytes(file));
    }

    final file = fileResult;
    return _readFileBytes(file);
  }

  FutureOr<Uint8List?> _readFileBytes(File? file) {
    if (file == null) return null;

    try {
      return file.readAsBytes();
    } catch (e) {
      _log('Error reading cache: $e');
      return null;
    }
  }

  @override
  Future<void> saveFile(String key, Uint8List bytes) async {
    try {
      final cacheDir = await getCacheDirectory();
      final cacheFile = File(join(cacheDir.path, key));
      await cacheFile.writeAsBytes(bytes);
    } catch (e) {
      _log('Failed to write cache: $e');
    }
  }

  @override
  FutureOr<bool> hasValidCache(String key, {Duration? maxAge}) {
    final fileResult = _getCachedFile(key, maxAge: maxAge);

    if (fileResult is Future<File?>) {
      return fileResult.then((file) => file != null);
    }

    return fileResult != null;
  }

  @override
  Future<void> clearCache(String key) async {
    try {
      final cacheDir = await getCacheDirectory();
      final cacheFile = File(join(cacheDir.path, key));

      if (cacheFile.existsSync()) {
        await cacheFile.delete();
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
    final extension = _extractExtension(url);

    return '$md5Hash$extension';
  }

  @override
  void invalidateCacheDirectory() {
    _cacheDir = null;
    _cacheDirFuture = null;
  }

  @override
  Future<void> dispose() async {
    _cacheDir = null;
    _cacheDirFuture = null;
  }

  /// Clear all files in this cache directory
  Future<void> clearAllCache() async {
    try {
      final cacheDir = await getCacheDirectory();
      final files = cacheDir.listSync();

      for (final file in files) {
        if (file is File) {
          await file.delete();
        }
      }

      _log('Cleared all cached files in ${cacheDir.path}');
    } catch (e) {
      _log('Error clearing all cache: $e');
    }
  }

  /// Get total size of cached files
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await getCacheDirectory();
      final files = cacheDir.listSync();

      var totalSize = 0;
      for (final file in files) {
        if (file is File) {
          totalSize += file.lengthSync();
        }
      }

      return totalSize;
    } catch (e) {
      _log('Error calculating cache size: $e');
      return 0;
    }
  }

  /// Get list of cached files
  Future<List<File>> getCachedFiles() async {
    try {
      final cacheDir = await getCacheDirectory();
      final files = cacheDir.listSync();

      return files.whereType<File>().toList();
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

      for (final file in files) {
        totalSize += file.lengthSync();
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
  // Extract just the path part, without query parameters
  final uri = Uri.parse(url);
  final pathOnly = uri.path;

  return extension(pathOnly).toLowerCase();
}
