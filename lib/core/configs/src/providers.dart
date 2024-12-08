// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/settings/data.dart';
import 'package:boorusama/foundation/functional.dart';
import 'booru_config.dart';
import 'manage/booru_config_provider.dart';

final hasBooruConfigsProvider = Provider<bool>((ref) {
  final configs = ref.watch(booruConfigProvider);
  return configs.isNotEmpty;
});

final orderedConfigsProvider =
    FutureProvider.autoDispose<IList<BooruConfig>>((ref) {
  final configs = ref.watch(booruConfigProvider);

  final configMap = {for (final config in configs) config.id: config};
  final orders = ref
      .watch(settingsProvider.select((value) => value.booruConfigIdOrderList));

  if (configMap.length != orders.length) {
    return configMap.values.toIList();
  }

  try {
    return orders.map((e) => configMap[e]!).toIList();
  } catch (e) {
    return configMap.values.toIList();
  }
});
