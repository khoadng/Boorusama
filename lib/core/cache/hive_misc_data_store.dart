// Package imports:
import 'package:hive_ce/hive.dart';

// Project imports:
import 'misc_data_store.dart';

final class HiveMiscDataStore implements MiscDataStore {
  const HiveMiscDataStore(this.box);

  final Box<String> box;

  @override
  String? get(String key) => box.get(key);

  @override
  Future<void> put(String key, String value) => box.put(key, value);
}
