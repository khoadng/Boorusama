// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/functional.dart';

final booruConfigProvider =
    NotifierProvider<BooruConfigNotifier, List<BooruConfig>>(
  BooruConfigNotifier.new,
  dependencies: [
    booruConfigRepoProvider,
  ],
);

final currentBooruConfigProvider =
    NotifierProvider<CurrentBooruConfigNotifier, BooruConfig>(
  () => throw UnimplementedError(),
  dependencies: [
    settingsProvider,
    loggerProvider,
  ],
);

final configIdOrdersProvider = Provider<List<int>>((ref) {
  final orderString =
      ref.watch(settingsProvider.select((value) => value.booruConfigIdOrders));
  try {
    return orderString.split(' ').map((e) => int.parse(e)).toList();
  } catch (e) {
    return [];
  }
});

final configsProvider = Provider<IList<BooruConfig>>((ref) {
  final configs = {
    for (final config in ref.watch(booruConfigProvider)) config.id: config
  };
  final orders = ref.watch(configIdOrdersProvider);

  if (configs.length != orders.length) return configs.values.toIList();

  try {
    return orders.map((e) => configs[e]!).toIList();
  } catch (e) {
    return configs.values.toIList();
  }
});
