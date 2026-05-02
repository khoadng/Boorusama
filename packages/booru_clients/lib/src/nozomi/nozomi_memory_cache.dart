typedef NozomiCacheCost<T> = int Function(T value);

class NozomiMemoryCache<T> {
  NozomiMemoryCache({
    this.ttl = const Duration(hours: 1),
    this.maxEntries = 64,
    this.maxTotalCost = 5000000,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Duration ttl;
  final int maxEntries;
  final int maxTotalCost;
  final DateTime Function() _now;

  final _entries = <String, _NozomiCacheEntry<T>>{};
  int _totalCost = 0;

  int get length => _entries.length;

  int get totalCost => _totalCost;

  Future<T>? get(String key) {
    final existing = _entries[key];
    if (existing == null) return null;

    if (_isExpired(existing)) {
      _remove(key);

      return null;
    }

    _markRecentlyUsed(key, existing);

    return existing.future;
  }

  void set(
    String key,
    T value, {
    NozomiCacheCost<T>? estimateCost,
  }) {
    _remove(key);

    final cost = estimateCost?.call(value) ?? 1;
    if (maxTotalCost > 0 && cost > maxTotalCost) return;

    _entries[key] = _NozomiCacheEntry<T>(
      future: Future.value(value),
      expiresAt: _now().add(ttl),
    )..cost = cost;
    _totalCost += cost;
    _evictOverflow();
  }

  Future<T> getOrLoad(
    String key,
    Future<T> Function() load, {
    NozomiCacheCost<T>? estimateCost,
  }) {
    final existing = _entries[key];
    if (existing != null) {
      if (!_isExpired(existing)) {
        _markRecentlyUsed(key, existing);

        return existing.future;
      }

      _remove(key);
    }

    late final _NozomiCacheEntry<T> entry;
    entry = _NozomiCacheEntry<T>(
      future: Future.sync(load).then(
        (value) {
          if (!identical(_entries[key], entry)) return value;

          final cost = estimateCost?.call(value) ?? 1;
          entry.cost = cost;
          _totalCost += cost;

          if (maxTotalCost > 0 && cost > maxTotalCost) {
            _remove(key);

            return value;
          }

          _evictOverflow();

          return value;
        },
        onError: (Object error, StackTrace stackTrace) {
          if (identical(_entries[key], entry)) {
            _remove(key);
          }

          Error.throwWithStackTrace(error, stackTrace);
        },
      ),
      expiresAt: _now().add(ttl),
    );

    _entries[key] = entry;
    _evictOverflow();

    return entry.future;
  }

  void clear() {
    _entries.clear();
    _totalCost = 0;
  }

  bool _isExpired(_NozomiCacheEntry<T> entry) {
    return !_now().isBefore(entry.expiresAt);
  }

  void _markRecentlyUsed(String key, _NozomiCacheEntry<T> entry) {
    _entries
      ..remove(key)
      ..[key] = entry;
  }

  void _remove(String key) {
    final entry = _entries.remove(key);
    if (entry == null) return;

    _totalCost -= entry.cost;
  }

  void _evictOverflow() {
    while (_entries.length > maxEntries ||
        (maxTotalCost > 0 && _totalCost > maxTotalCost)) {
      if (_entries.isEmpty) return;

      _remove(_entries.keys.first);
    }
  }
}

class _NozomiCacheEntry<T> {
  _NozomiCacheEntry({
    required this.future,
    required this.expiresAt,
  });

  final Future<T> future;
  final DateTime expiresAt;
  int cost = 0;
}
