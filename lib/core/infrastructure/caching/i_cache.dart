abstract class ICache<T> {
  T? get(String key);
  void put(String key, T item, Duration expire);
}
