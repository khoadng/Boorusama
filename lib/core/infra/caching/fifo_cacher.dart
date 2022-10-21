// Dart imports:
import 'dart:collection';

// Project imports:
import 'cacher.dart';

class FifoCacher<K, V> implements Cacher<K, V> {
  FifoCacher({
    this.capacity = 50,
  });

  final _queue = Queue<K>();
  final _map = <K, V>{};
  final int capacity;

  bool get _atMax => _map.length == capacity;

  @override
  void clear() {
    _queue.clear();
    _map.clear();
  }

  @override
  bool exist(K key) => _map.containsKey(key);

  @override
  V? get(K key) {
    if (exist(key)) return _map[key];

    return null;
  }

  @override
  Future<void> put(K key, V item) async {
    if (_atMax) {
      _remove();
    }

    _map[key] = item;
    _queue.add(key);
  }

  void _remove() {
    final k = _queue.removeFirst();
    _map.remove(k);
  }
}
