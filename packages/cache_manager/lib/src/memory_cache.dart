import 'dart:typed_data';

abstract class MemoryCache {
  Uint8List? get(String key);
  void put(String key, Uint8List data);
  bool contains(String key);
  void remove(String key);
  void clear();
}

class LRUMemoryCache implements MemoryCache {
  LRUMemoryCache({
    this.maxEntries = 1000,
    this.maxSizePerEntry = 100 * 1024, // 100KB
  });

  final int maxEntries;
  final int maxSizePerEntry;

  final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};
  final List<String> _accessOrder = <String>[];

  @override
  Uint8List? get(String key) {
    final entry = _cache[key];
    if (entry != null) {
      _updateAccessOrder(key);
      return entry.data;
    }
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
      _accessOrder.remove(key);
    }
  }

  @override
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

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
