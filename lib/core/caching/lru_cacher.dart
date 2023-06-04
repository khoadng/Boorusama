// Dart imports:
import 'dart:collection';

// Project imports:
import 'package:boorusama/core/caching/caching.dart';

class CacheObject<K, V> {
  const CacheObject(this.node, this.value);

  final K node;
  final V value;
}

class LruCacher<K, V> implements Cacher<K, V> {
  LruCacher({
    this.capacity = 50,
  });

  final int capacity;
  final _cache = <K, CacheObject<K, V>>{};
  late final ListQueue<K> _list = ListQueue<K>(capacity);

  bool get _atMax => _cache.length >= capacity;

  @override
  void clear() {
    _cache.clear();
    _list.clear();
  }

  @override
  bool exist(K key) => _cache.containsKey(key);

  @override
  V? get(K key) {
    if (!exist(key)) return null;
    final value = _cache[key];

    _list.remove(value);
    _cache.remove(value);

    return value!.value;
  }

  @override
  Future<void> put(K key, V item) async {
    if (_cache.containsKey(key)) {
      _list
        ..remove(_cache[key]!.node)
        ..addFirst(_cache[key]!.node);
      _cache[key] = CacheObject(_cache[key]!.node, item);
    } else {
      if (_atMax) {
        final removedKey = _list.last;
        _cache.remove(removedKey);
        _list.removeLast();
      }
      _list.addFirst(key);
      _cache[key] = CacheObject(key, item);
    }
  }

  void remove(K key) {
    if (_cache.containsKey(key)) {
      _list.remove(key);
      _cache.remove(key);
    }
  }
}
