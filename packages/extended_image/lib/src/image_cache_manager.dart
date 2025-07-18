// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// Import the memory cache
import 'memory_cache.dart';

/// Abstract interface for image caching operations
abstract class ImageCacheManager {
  /// Retrieves the cached file for the given key
  FutureOr<File?> getCachedFile(String key);

  /// Retrieves cached file data for the given key
  FutureOr<Uint8List?> getCachedFileBytes(String key);

  /// Saves file data to cache with the specified key
  Future<void> saveFile(String key, Uint8List bytes);

  /// Checks if a valid cache exists for the key
  FutureOr<bool> hasValidCache(String key, {Duration? maxAge});

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
    MemoryCache? memoryCache,
  }) : _memoryCache = memoryCache;

  final String cacheDirName;
  final bool enableLogging;
  final MemoryCache? _memoryCache;

  Directory? _cacheDir;
  Future<Directory>? _cacheDirFuture;

  /// Get the cache directory, creating it if needed
  FutureOr<Directory> getCacheDirectory() {
    // Return cached directory immediately if available (synchronous)
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
    final tempDir = await getTemporaryDirectory();
    final dirPath = join(tempDir.path, cacheDirName);
    final dir = Directory(dirPath);

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  @override
  FutureOr<File?> getCachedFile(String key) {
    final dirResult = getCacheDirectory();

    if (dirResult is Future<Directory>) {
      return dirResult.then((cacheDir) => _getFileIfExists(cacheDir, key));
    }

    final cacheDir = dirResult;
    return _getFileIfExists(cacheDir, key);
  }

  File? _getFileIfExists(Directory cacheDir, String key) {
    try {
      final cacheFile = File(join(cacheDir.path, key));
      return cacheFile.existsSync() ? cacheFile : null;
    } catch (e) {
      _log('Error getting cached file: $e');
      return null;
    }
  }

  @override
  FutureOr<Uint8List?> getCachedFileBytes(String key) {
    final memoryData = _memoryCache?.get(key);
    if (memoryData != null) {
      return memoryData;
    }

    final fileResult = getCachedFile(key);

    if (fileResult is Future<File?>) {
      return fileResult.then((file) => _readFileBytes(file, key));
    }

    final file = fileResult;
    return _readFileBytes(file, key);
  }

  FutureOr<Uint8List?> _readFileBytes(File? file, String key) {
    if (file == null) return null;

    try {
      return file.readAsBytes().then((data) {
        _cacheInMemoryIfEligible(key, data);
        return data;
      });
    } catch (e) {
      _log('Error reading cache: $e');
      return null;
    }
  }

  void _cacheInMemoryIfEligible(String key, Uint8List bytes) {
    _memoryCache?.put(key, bytes);
  }

  @override
  Future<void> saveFile(String key, Uint8List bytes) async {
    try {
      final cacheDir = await getCacheDirectory();
      final cacheFile = File(join(cacheDir.path, key));
      await cacheFile.writeAsBytes(bytes);

      // Save to memory cache if eligible
      _cacheInMemoryIfEligible(key, bytes);
    } catch (e) {
      _log('Failed to write cache: $e');
    }
  }

  FutureOr<bool> _deleteExpired(File cacheFile, Duration? maxAge) {
    if (maxAge == null) {
      return true; // No expiration check needed
    }

    final now = DateTime.now();
    final fileStats = cacheFile.statSync();

    final isExpired = now.subtract(maxAge).isAfter(fileStats.modified);
    if (!isExpired) return true;

    return cacheFile.delete().then((_) => false).catchError((e) {
      _log('Error deleting expired cache file: $e');
      return false;
    });
  }

  File? _getFile(Directory cacheDir, String key) {
    final cacheFile = File(join(cacheDir.path, key));
    final exists = cacheFile.existsSync();
    if (!exists) return null;
    return cacheFile;
  }

  @override
  FutureOr<bool> hasValidCache(String key, {Duration? maxAge}) {
    if (_memoryCache?.contains(key) == true) {
      return true;
    }

    final dirResult = getCacheDirectory();

    if (dirResult is Future<Directory>) {
      return dirResult.then((cacheDir) {
        final cacheFile = _getFile(cacheDir, key);
        if (cacheFile == null) return false;

        return _deleteExpired(cacheFile, maxAge);
      });
    }

    final cacheDir = dirResult;
    final cacheFile = _getFile(cacheDir, key);
    if (cacheFile == null) return false;

    return _deleteExpired(cacheFile, maxAge);
  }

  @override
  Future<void> clearCache(String key) async {
    try {
      _memoryCache?.remove(key);

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
    _memoryCache?.clear();
    _cacheDir = null;
    _cacheDirFuture = null;
  }

  void _log(String message) {
    if (enableLogging && kDebugMode) {
      debugPrint('[ImageCacheManager] $message');
    }
  }
}
