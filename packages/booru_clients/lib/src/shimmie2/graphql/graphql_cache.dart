abstract class GraphQLCache {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value);
  Future<void> remove(String key);
  Future<void> clear();
  Future<DateTime?> getTimestamp(String key);
  Future<void> setTimestamp(String key, DateTime timestamp);
}

class LazyGraphQLCache implements GraphQLCache {
  LazyGraphQLCache(this._cacheFactory);

  final Future<GraphQLCache> Function() _cacheFactory;
  GraphQLCache? _cache;

  Future<GraphQLCache> _ensureInitialized() async {
    return _cache ??= await _cacheFactory();
  }

  @override
  Future<T?> get<T>(String key) async {
    final cache = await _ensureInitialized();
    return cache.get<T>(key);
  }

  @override
  Future<void> set<T>(String key, T value) async {
    final cache = await _ensureInitialized();
    return cache.set(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final cache = await _ensureInitialized();
    return cache.remove(key);
  }

  @override
  Future<void> clear() async {
    final cache = await _ensureInitialized();
    return cache.clear();
  }

  @override
  Future<DateTime?> getTimestamp(String key) async {
    final cache = await _ensureInitialized();
    return cache.getTimestamp(key);
  }

  @override
  Future<void> setTimestamp(String key, DateTime timestamp) async {
    final cache = await _ensureInitialized();
    return cache.setTimestamp(key, timestamp);
  }
}

class InMemoryGraphQLCache implements GraphQLCache {
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _timestamps = {};

  @override
  Future<T?> get<T>(String key) async => _cache[key] as T?;

  @override
  Future<void> set<T>(String key, T value) async => _cache[key] = value;

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
    _timestamps.remove(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
    _timestamps.clear();
  }

  @override
  Future<DateTime?> getTimestamp(String key) async => _timestamps[key];

  @override
  Future<void> setTimestamp(String key, DateTime timestamp) async =>
      _timestamps[key] = timestamp;
}
