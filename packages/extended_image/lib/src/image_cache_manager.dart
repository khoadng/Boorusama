// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Abstract interface for image caching operations
abstract class ImageCacheManager {
  /// Retrieves the cached file for the given key
  Future<File?> getCachedFile(String key);

  /// Retrieves cached file data for the given key
  Future<Uint8List?> getCachedFileBytes(String key);

  /// Saves file data to cache with the specified key
  Future<void> saveFile(String key, Uint8List bytes);

  /// Checks if a valid cache exists for the key
  Future<bool> hasValidCache(String key, {Duration? maxAge});

  /// Clears the cached file for the specified key
  Future<void> clearCache(String key);

  /// Generates a cache key for a URL, optionally using a custom key
  String generateCacheKey(String url, {String? customKey});

  /// Disposes the cache manager resources
  Future<void> dispose();
}

/// Default implementation of ImageCacheManager that uses file system for caching
class DefaultImageCacheManager implements ImageCacheManager {
  DefaultImageCacheManager({
    this.cacheDirName = 'cacheimage',
    this.enableLogging = false,
  });

  final String cacheDirName;
  final bool enableLogging;
  Directory? _cacheDir;

  /// Get the cache directory, creating it if needed
  Future<Directory> getCacheDirectory() async {
    if (_cacheDir != null) {
      return _cacheDir!;
    }

    final tempDir = await getTemporaryDirectory();
    final dir = Directory(join(tempDir.path, cacheDirName));

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
        if (maxAge != null) {
          final now = DateTime.now();
          final fileStats = cacheFile.statSync();

          if (now.subtract(maxAge).isAfter(fileStats.modified)) {
            // File is expired, delete it
            try {
              await cacheFile.delete();
            } catch (e) {
              _log('Error deleting expired cache file: $e');
            }
            return false;
          }
        }
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

    try {
      // More flexible matching for Google favicons
      if (url.toLowerCase().contains('google.com') &&
          url.toLowerCase().contains('favicons')) {
        return keyToMd5(url); // Use full URL since domain parameter matters
      }

      // Parse the URL and use only the path component for other URLs
      final uri = Uri.parse(url);
      return keyToMd5(uri.path);
    } catch (e) {
      // Fallback to basic hashing if URL parsing fails
      return keyToMd5(url);
    }
  }

  @override
  Future<void> dispose() async {
    _cacheDir = null;
  }

  void _log(String message) {
    if (enableLogging && kDebugMode) {
      debugPrint('[ImageCacheManager] $message');
    }
  }
}
