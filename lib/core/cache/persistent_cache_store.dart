abstract interface class PersistentCacheStore {
  Iterable<String> get keys;

  int get length;

  String? get(String key);

  Future<void> put(String key, String value);

  Future<void> clear();
}
