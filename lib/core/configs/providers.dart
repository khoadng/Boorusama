// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/functional.dart';
import 'export_import/export_import.dart';

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

class BooruConfigNotifier extends Notifier<List<BooruConfig>>
    with BooruConfigExportImportMixin {
  BooruConfigNotifier({
    required this.initialConfigs,
  });

  final List<BooruConfig> initialConfigs;

  @override
  List<BooruConfig> build() {
    return initialConfigs;
  }

  Future<void> fetch() async {
    final configs = await ref.read(booruConfigRepoProvider).getAll();
    state = configs;
  }

  Future<void> _add(BooruConfig booruConfig) async {
    final orders = ref.read(settingsProvider).booruConfigIdOrderList;
    final newOrders = [...orders, booruConfig.id];

    await ref.read(settingsNotifierProvider.notifier).updateOrder(newOrders);

    state = [...state, booruConfig];
  }

  Future<void> duplicate({
    required BooruConfig config,
  }) {
    final copyData = config.copyWith(
      name: '${config.name} copy',
    );

    return add(
      data: copyData.toBooruConfigData(),
    );
  }

  Future<void> delete(
    BooruConfig config, {
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
  }) async {
    try {
      // check if deleting the last config
      if (state.length == 1) {
        await ref.read(booruConfigRepoProvider).remove(config);
        await ref.read(booruConfigProvider.notifier).fetch();
        // reset order
        await ref.read(settingsNotifierProvider.notifier).updateOrder([]);
        await ref.read(currentBooruConfigProvider.notifier).setEmpty();

        onSuccess?.call(config);

        return;
      }

      // check if deleting current config, if so, set current to the first config
      final currentConfig = ref.read(currentBooruConfigProvider);
      if (currentConfig.id == config.id) {
        final firstConfig = state.first;

        // check if deleting the first config
        final targetConfig =
            firstConfig.id == config.id ? state.skip(1).first : firstConfig;

        await ref
            .read(currentBooruConfigProvider.notifier)
            .update(targetConfig);
      }

      await ref.read(booruConfigRepoProvider).remove(config);
      final orders = ref.read(settingsProvider).booruConfigIdOrderList;
      final newOrders = [...orders..remove(config.id)];

      await ref.read(settingsNotifierProvider.notifier).updateOrder(newOrders);

      final tmp = [...state];
      tmp.remove(config);
      state = tmp;
      onSuccess?.call(config);
    } catch (e) {
      onFailure?.call(e.toString());
    }
  }

  Future<void> update({
    required BooruConfigData booruConfigData,
    required int oldConfigId,
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
  }) async {
    try {
      // Validate inputs
      if (oldConfigId < 0) {
        _logError('Invalid config id: $oldConfigId');
        onFailure?.call('Unable to find this account');
        return;
      }

      // Check if config exists
      final existingConfig = state.firstWhereOrNull((c) => c.id == oldConfigId);
      if (existingConfig == null) {
        _logError('Config not found: $oldConfigId');
        onFailure?.call('This profile no longer exists');
        return;
      }

      final updatedConfig = await ref
          .read(booruConfigRepoProvider)
          .update(oldConfigId, booruConfigData);

      if (updatedConfig == null) {
        _logError('Failed to update config: $oldConfigId');
        onFailure?.call('Unable to update profile. Failed to save changes');
        return;
      }

      final newConfigs = state.map((config) {
        return config.id == oldConfigId ? updatedConfig : config;
      }).toList();

      _logInfo('Updated config: $oldConfigId');
      state = newConfigs;
      onSuccess?.call(updatedConfig);
    } catch (e) {
      _logError('Failed to update config: $oldConfigId');
      onFailure?.call(
          'Something went wrong while updating your profile. Please try again');
    }
  }

  Future<void> add({
    required BooruConfigData data,
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
    bool setAsCurrent = false,
  }) async {
    try {
      final config = await ref.read(booruConfigRepoProvider).add(data);

      if (config == null) {
        onFailure?.call(
            'Unable to add profile. Please check your inputs and try again');

        return;
      }

      onSuccess?.call(config);
      ref.read(analyticsProvider).sendBooruAddedEvent(
            url: config.url,
            hintSite: config.auth.booruType.name,
            totalSites: state.length,
            hasLogin: config.auth.hasLoginDetails(),
          );

      await _add(config);

      if (setAsCurrent || state.length == 1) {
        await ref.read(currentBooruConfigProvider.notifier).update(config);
      }
    } catch (e) {
      onFailure?.call(
          'Something went wrong while adding your profile. Please try again');
    }
  }

  void _logError(String message) {
    ref.read(loggerProvider).logE('Configs', message);
  }

  void _logInfo(String message) {
    ref.read(loggerProvider).logI('Configs', message);
  }
}

class EditBooruConfigId extends Equatable {
  const EditBooruConfigId({
    required this.id,
    required this.booruType,
    required this.url,
  });

  const EditBooruConfigId.newId({
    required BooruType booruType,
    required String url,
  }) : this(id: -1, booruType: booruType, url: url);

  EditBooruConfigId.fromConfig(
    BooruConfig config,
  )   : id = config.id,
        booruType = config.auth.booruType,
        url = config.url;

  final int id;
  final BooruType booruType;
  final String url;

  bool get isNew => id == -1;

  @override
  List<Object> get props => [id, booruType, url];
}

extension BooruConfigNotifierX on BooruConfigNotifier {
  void addOrUpdate({
    required EditBooruConfigId id,
    required BooruConfigData newConfig,
  }) {
    if (id.isNew) {
      ref.read(booruConfigProvider.notifier).add(
            data: newConfig,
          );
    } else {
      ref.read(booruConfigProvider.notifier).update(
            booruConfigData: newConfig,
            oldConfigId: id.id,
            onSuccess: (booruConfig) {
              // if edit current config, update current config
              final currentConfig = ref.read(currentBooruConfigProvider);

              if (currentConfig.id == booruConfig.id) {
                ref
                    .read(currentBooruConfigProvider.notifier)
                    .update(booruConfig);
              }
            },
          );
    }
  }
}
