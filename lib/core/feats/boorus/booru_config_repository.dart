// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:boorusama/core/feats/settings/settings.dart';
import 'booru_config.dart';
import 'booru_config_data.dart';

abstract class BooruConfigRepository {
  Future<BooruConfig?> add(BooruConfigData booruConfigData);
  Future<BooruConfig?> update(int id, BooruConfigData booruConfigData);
  Future<void> remove(BooruConfig booruConfig);
  Future<List<BooruConfig>> getAll();
  Future<void> clear();
  Future<List<BooruConfig>> addAll(List<BooruConfig> booruConfigs);
}

extension BooruConfigRepositoryX on BooruConfigRepository {
  Future<BooruConfig?> getCurrentBooruConfigFrom(Settings settings) async {
    final booruConfigs = await getAll();
    return booruConfigs
        .firstWhereOrNull((e) => e.id == settings.currentBooruConfigId);
  }
}
