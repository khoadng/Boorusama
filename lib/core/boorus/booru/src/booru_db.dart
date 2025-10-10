// Package imports:
import 'package:booru_clients/generated.dart';

// Project imports:
import 'booru.dart';

class BooruDb {
  const BooruDb({
    required this.boorus,
  });

  factory BooruDb.fromConfigs(
    List<BooruYamlConfig> configs,
    Booru Function(BooruYamlConfig) configToBooru,
  ) {
    final booruMap = <BooruType, Booru>{};
    for (final config in configs) {
      booruMap[config.type] = configToBooru(config);
    }
    return BooruDb(boorus: booruMap);
  }

  final Map<BooruType, Booru> boorus;

  Booru? getBooru(BooruType type) => boorus[type];

  List<Booru> getAllBoorus() => boorus.values.toList();

  Booru? getBooruFromUrl(String url) {
    for (final booru in boorus.values) {
      if (booru.hasSite(url)) {
        return booru;
      }
    }
    return null;
  }

  Booru? getBooruFromId(int id) {
    final config = BooruYamlConfigs.byId[id];
    return config != null ? boorus[config.type] : null;
  }
}
