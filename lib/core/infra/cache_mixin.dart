class CacheEntry<T> {
  final DateTime timestamp;
  final T value;

  CacheEntry(this.value) : timestamp = DateTime.now();
}

mixin CacheMixin<T> {
  Duration get staleDuration;
  int get maxCapacity;
  final _cache = <String, CacheEntry<T>>{};

  T? get(String key) {
    var cacheEntry = _cache[key];
    if (cacheEntry == null) {
      return null;
    } else if (DateTime.now().difference(cacheEntry.timestamp) >
        staleDuration) {
      _cache.remove(key);
      return null;
    }
    return cacheEntry.value;
  }

  void set(String key, T value) {
    if (_cache.length >= maxCapacity) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = CacheEntry(value);
  }

  bool exist(String key) {
    var cacheEntry = _cache[key];
    if (cacheEntry == null) {
      return false;
    } else if (DateTime.now().difference(cacheEntry.timestamp) >
        staleDuration) {
      return false;
    }
    return true;
  }

  void clear() async {
    _cache.clear();
  }
}
