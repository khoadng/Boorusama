// Package imports:
import 'package:hive_ce/hive.dart';

// Project imports:
import 'persistent_cache_store.dart';

final class HivePersistentCacheStore implements PersistentCacheStore {
  const HivePersistentCacheStore(this.box);

  final Box<String> box;

  @override
  Iterable<String> get keys => box.keys.whereType<String>();

  @override
  int get length => box.length;

  @override
  String? get(String key) => box.get(key);

  @override
  Future<void> put(String key, String value) => box.put(key, value);

  @override
  Future<void> clear() => box.clear();
}
