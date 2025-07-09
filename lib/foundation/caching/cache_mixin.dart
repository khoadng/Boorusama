// Project imports:
import 'lru_cacher.dart';

class Cache<T> with CacheMixin<T> {
  Cache({
    required this.maxCapacity,
    required this.staleDuration,
  });

  @override
  final int maxCapacity;

  @override
  final Duration staleDuration;
}

class CacheEntry<T> {
  CacheEntry(this.value) : timestamp = DateTime.now();
  final DateTime timestamp;
  final T value;
}

mixin CacheMixin<T> {
  Duration get staleDuration;
  int get maxCapacity;

  late final _cache = LruCacher<String, CacheEntry<T>>(capacity: maxCapacity);

  bool _isStale(CacheEntry<T> cacheEntry) =>
      DateTime.now().difference(cacheEntry.timestamp) > staleDuration;

  T? get(String key) {
    final cacheEntry = _cache.get(key);

    if (cacheEntry == null) return null;

    if (_isStale(cacheEntry)) {
      _cache.remove(key);
      return null;
    }

    // Refresh the timestamp of the accessed key
    _cache.put(key, CacheEntry(cacheEntry.value));

    return cacheEntry.value;
  }

  void set(String key, T value) => _cache.put(key, CacheEntry(value));

  bool exist(String key) => _cache.exist(key);

  void clear() => _cache.clear();

  void remove(String key) => _cache.remove(key);
}

mixin SimpleCacheMixin<T> {
  Cache<T> get cache;

  Future<T> tryGet(
    String key, {
    required Function() orElse,
  }) async {
    final cached = cache.get(key);
    if (cached != null) return cached;

    final fetched = await orElse();

    cache.set(key, fetched);

    return fetched;
  }
}
