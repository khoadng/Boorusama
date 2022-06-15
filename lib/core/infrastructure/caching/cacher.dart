abstract class Cacher<K, V> {
  V? get(K key);
  void put(K key, V item);
  void clear();
  bool exist(K key);
}
