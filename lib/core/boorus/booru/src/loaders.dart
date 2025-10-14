// Package imports:
import 'package:booru_clients/generated.dart';

// Project imports:
import '../../engine/types.dart';
import 'booru_db.dart';

BooruDb loadBoorus(BooruRegistry registry) {
  return BooruDb.fromConfigs(
    BooruYamlConfigs.values,
    (config) => registry.parseFromConfig(config.name),
  );
}
