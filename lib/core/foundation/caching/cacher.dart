abstract class Cacher<K, V> {
  V? get(K key);
  Future<void> put(K key, V item);
  void clear();
  bool exist(K key);
}
