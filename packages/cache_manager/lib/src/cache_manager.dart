import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

/// Abstract interface for cache operations
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
