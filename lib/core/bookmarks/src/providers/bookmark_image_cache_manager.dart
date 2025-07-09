// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Specialized cache manager for bookmarked images that stores files
/// in permanent storage and organizes them by image type
class BookmarkImageCacheManager implements ImageCacheManager {
  BookmarkImageCacheManager({
    this.enableLogging = false,
  });

  final bool enableLogging;

  Directory? _cacheDir;

  /// Get the cache directory, creating it if needed
  Future<Directory> getCacheDirectory() async {
    if (_cacheDir != null) {
      return _cacheDir!;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final dirPath = join(appDir.path, 'bookmarks', 'images');
    final dir = Directory(dirPath);

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    _cacheDir = dir;
    return dir;
  }

  @override
  Future<File?> getCachedFile(String key) async {
    try {
      final cacheDir = await getCacheDirectory();
      final cacheFile = File(join(cacheDir.path, key));

      if (cacheFile.existsSync()) {
        return cacheFile;
      }

      return null;
    } catch (e) {
      _log('Error getting cached file: $e');
    }
    return null;
  }

  @override
  Future<Uint8List?> getCachedFileBytes(String key) async {
    try {
      final cacheFile = await getCachedFile(key);
      if (cacheFile != null) {
        return await cacheFile.readAsBytes();
      }
      return null;
    } catch (e) {
      _log('Error reading cache: $e');
    }
    return null;
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
  Future<bool> hasValidCache(String key, {Duration? maxAge}) async {
    try {
      final cacheDir = await getCacheDirectory();
      final cacheFile = File(join(cacheDir.path, key));

      if (cacheFile.existsSync()) {
        return true;
      }
    } catch (e) {
      _log('Error checking cache: $e');
    }
    return false;
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
  Future<void> dispose() async {
    _cacheDir = null;
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
