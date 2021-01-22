abstract class ICache<T> {
  Future<T> get(String key);
  void put(String key, T item, Duration expire);
  Future<bool> isExist(String key);
  Future<bool> isExpired(String key);
}
