// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/functional.dart';

final booruConfigProvider =
    NotifierProvider<BooruConfigNotifier, List<BooruConfig>>(
  () => throw UnimplementedError(),
  dependencies: [
    booruConfigRepoProvider,
    settingsProvider,
    currentBooruConfigProvider,
  ],
  name: 'booruConfigProvider',
);

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

extension BooruWidgetRef on WidgetRef {
  BooruConfig get readConfig => read(currentReadOnlyBooruConfigProvider);

  BooruConfig get watchConfig => watch(currentReadOnlyBooruConfigProvider);

  BooruConfigAuth get readConfigAuth =>
      read(currentReadOnlyBooruConfigAuthProvider);

  BooruConfigAuth get watchConfigAuth =>
      watch(currentReadOnlyBooruConfigAuthProvider);

  BooruConfigSearch get readConfigSearch =>
      read(currentReadOnlyBooruConfigSearchProvider);

  BooruConfigSearch get watchConfigSearch =>
      watch(currentReadOnlyBooruConfigSearchProvider);

  PostGestureConfig? get watchPostGestures =>
      watch(currentReadOnlyBooruConfigGestureProvider);
}

extension BooruAutoDisposeProviderRef<T> on Ref<T> {
  BooruConfig get readConfig => read(currentReadOnlyBooruConfigProvider);

  BooruConfig get watchConfig => watch(currentReadOnlyBooruConfigProvider);

  BooruConfigAuth get readConfigAuth =>
      read(currentReadOnlyBooruConfigAuthProvider);

  BooruConfigAuth get watchConfigAuth =>
      watch(currentReadOnlyBooruConfigAuthProvider);

  BooruConfigSearch get readConfigSearch =>
      read(currentReadOnlyBooruConfigSearchProvider);

  BooruConfigSearch get watchConfigSearch =>
      watch(currentReadOnlyBooruConfigSearchProvider);
}
