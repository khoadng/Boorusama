// Project imports:
import 'i_cache.dart';

class CacheObject<T> {
  const CacheObject({
    required this.object,
    required this.expireDate,
  });

  final T object;
  final DateTime expireDate;
}

class DefaultCacher<T> implements ICache<T> {
  DefaultCacher({
    required this.currentTimeBuilder,
  });

  final Map<String, CacheObject<T>> _cache = {};
  final DateTime Function() currentTimeBuilder;

  @override
  T? get(String key) {
    if (!_cache.containsKey(key)) return null;

    final cache = _cache[key]!;
    final now = currentTimeBuilder.call();
    final duration = cache.expireDate.difference(now);

    if (duration < Duration.zero) return null;

    return cache.object;
  }

  @override
  void put(String key, T item, Duration expire) {
    final now = currentTimeBuilder.call();
    final expireDate = now.add(expire);
    _cache[key] = CacheObject(
      object: item,
      expireDate: expireDate,
    );
  }
}
