import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Abstract interface for in-memory caching
abstract class MemoryCache {
  /// Gets cached data for the given key
  Uint8List? get(String key);

  /// Stores data in cache if it meets size requirements
  void put(String key, Uint8List data);

  /// Checks if key exists in cache
  bool contains(String key);

  /// Removes specific key from cache
  void remove(String key);

  /// Clears all cached data
  void clear();

  /// Gets current cache statistics
  MemoryCacheStats get stats;
}

/// Cache statistics
class MemoryCacheStats {
  const MemoryCacheStats({
    required this.entryCount,
    required this.totalBytes,
    required this.hitCount,
    required this.missCount,
  });

  final int entryCount;
  final int totalBytes;
  final int hitCount;
  final int missCount;

  double get hitRate =>
      (hitCount + missCount) > 0 ? hitCount / (hitCount + missCount) : 0.0;
}

/// LRU (Least Recently Used) memory cache implementation
class LRUMemoryCache implements MemoryCache {
  LRUMemoryCache({
    this.maxEntries = 1000,
    this.maxSizePerEntry = 100 * 1024, // 100KB
  });

  final int maxEntries;
  final int maxSizePerEntry;

  final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};
  final List<String> _accessOrder = <String>[];

  int _totalBytes = 0;
  int _hitCount = 0;
  int _missCount = 0;

  @override
  Uint8List? get(String key) {
    final entry = _cache[key];
    if (entry != null) {
      _updateAccessOrder(key);
      _hitCount++;
      return entry.data;
    }
    _missCount++;
    return null;
  }

  @override
  void put(String key, Uint8List data) {
    // Skip if data is too large
    if (data.length > maxSizePerEntry) {
      return;
    }

    // Remove existing entry if present
    if (_cache.containsKey(key)) {
      remove(key);
    }

    // Ensure we have space
    while (_cache.length >= maxEntries && _cache.isNotEmpty) {
      _evictLeastRecentlyUsed();
    }

    // Add new entry
    _cache[key] = _CacheEntry(data);
    _accessOrder.add(key);
    _totalBytes += data.length;
  }

  @override
  bool contains(String key) {
    final exists = _cache.containsKey(key);
    if (exists) {
      _updateAccessOrder(key);
    }
    return exists;
  }

  @override
  void remove(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _totalBytes -= entry.data.length;
      _accessOrder.remove(key);
    }
  }

  @override
  void clear() {
    _cache.clear();
    _accessOrder.clear();
    _totalBytes = 0;
    _hitCount = 0;
    _missCount = 0;
  }

  @override
  MemoryCacheStats get stats => MemoryCacheStats(
    entryCount: _cache.length,
    totalBytes: _totalBytes,
    hitCount: _hitCount,
    missCount: _missCount,
  );

  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  void _evictLeastRecentlyUsed() {
    if (_accessOrder.isNotEmpty) {
      final oldestKey = _accessOrder.first;
      remove(oldestKey);
    }
  }
}

class _CacheEntry {
  const _CacheEntry(this.data);
  final Uint8List data;
}
