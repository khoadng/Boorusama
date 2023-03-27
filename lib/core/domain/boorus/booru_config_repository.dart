// Project imports:
import 'booru_config.dart';
import 'booru_config_data.dart';

abstract class BooruConfigRepository {
  Future<BooruConfig?> add(BooruConfigData booruConfigData);
  Future<BooruConfig?> update(int id, BooruConfigData booruConfigData);
  Future<void> remove(BooruConfig booruConfig);
  Future<List<BooruConfig>> getAll();
}
