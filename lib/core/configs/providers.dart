// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/functional.dart';

final booruConfigProvider =
    NotifierProvider<BooruConfigNotifier, List<BooruConfig>?>(
  BooruConfigNotifier.new,
  dependencies: [
    booruConfigRepoProvider,
    settingsProvider,
    currentBooruConfigProvider,
  ],
);

final configsProvider = FutureProvider.autoDispose<IList<BooruConfig>>((ref) {
  final configs = ref.watch(booruConfigProvider);
  if (configs == null) return <BooruConfig>[].lock;

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
  /// {@template boorusama.booru.readConfig}
  /// Shortcut for `read(currentBooruConfigProvider)`
  /// {@endtemplate}
  BooruConfig get readConfig => read(currentBooruConfigProvider);

  /// {@template boorusama.booru.watchConfig}
  /// Shortcut for `watch(currentBooruConfigProvider)`
  /// {@endtemplate}
  BooruConfig get watchConfig => watch(currentBooruConfigProvider);
}

extension BooruAutoDisposeProviderRef<T> on AutoDisposeProviderRef<T> {
  /// {@macro boorusama.booru.readConfig}
  BooruConfig get readConfig => read(currentBooruConfigProvider);

  /// {@macro boorusama.booru.watchConfig}
  BooruConfig get watchConfig => watch(currentBooruConfigProvider);
}

extension BooruProviderRef<T> on ProviderRef<T> {
  /// {@macro boorusama.booru.readConfig}
  BooruConfig get readConfig => read(currentBooruConfigProvider);

  /// {@macro boorusama.booru.watchConfig}
  BooruConfig get watchConfig => watch(currentBooruConfigProvider);
}

extension BooruFutureProviderRef<T> on FutureProviderRef<T> {
  /// {@macro boorusama.booru.readConfig}
  BooruConfig get readConfig => read(currentBooruConfigProvider);

  /// {@macro boorusama.booru.watchConfig}
  BooruConfig get watchConfig => watch(currentBooruConfigProvider);
}

extension BooruNotifierProviderRef<T> on NotifierProviderRef<T> {
  /// {@macro boorusama.booru.readConfig}
  BooruConfig get readConfig => read(currentBooruConfigProvider);

  /// {@macro boorusama.booru.watchConfig}
  BooruConfig get watchConfig => watch(currentBooruConfigProvider);
}

extension BooruAsyncNotifierProviderRef<T> on AsyncNotifierProviderRef<T> {
  /// {@macro boorusama.booru.readConfig}
  BooruConfig get readConfig => read(currentBooruConfigProvider);

  /// {@macro boorusama.booru.watchConfig}
  BooruConfig get watchConfig => watch(currentBooruConfigProvider);
}

extension BooruAutoDisposeFutureProviderRef<T>
    on AutoDisposeFutureProviderRef<T> {
  /// {@macro boorusama.booru.readConfig}
  BooruConfig get readConfig => read(currentBooruConfigProvider);

  /// {@macro boorusama.booru.watchConfig}
  BooruConfig get watchConfig => watch(currentBooruConfigProvider);
}

extension BooruAutoDisposeNotifierProviderRef<T>
    on AutoDisposeNotifierProviderRef<T> {
  /// {@macro boorusama.booru.readConfig}
  BooruConfig get readConfig => read(currentBooruConfigProvider);

  /// {@macro boorusama.booru.watchConfig}
  BooruConfig get watchConfig => watch(currentBooruConfigProvider);
}
