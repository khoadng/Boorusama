// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/configs/export_import/export_import.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/functional.dart';

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

    await ref.read(settingsProvider.notifier).updateOrder(newOrders);

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
      initialConfig: config,
      isCopy: true,
    );
  }

  Future<void> delete(
    BooruConfig config, {
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
  }) async {
    final analytics = ref.read(analyticsProvider);
    final eventName = 'config_delete';
    final baseParams = {
      'url': config.url,
      'hint_site': config.booruType.name,
      'has_login': config.hasLoginDetails(),
    };

    try {
      // check if deleting the last config
      if (state.length == 1) {
        await ref.read(booruConfigRepoProvider).remove(config);
        await ref.read(booruConfigProvider.notifier).fetch();
        // reset order
        await ref.read(settingsProvider.notifier).updateOrder([]);
        await ref.read(currentBooruConfigProvider.notifier).setEmpty();

        onSuccess?.call(config);

        analytics.logEvent(
          eventName,
          parameters: {
            ...baseParams,
            'delete_type': 'last',
          },
        );

        return;
      }

      // check if deleting current config, if so, set current to the first config
      final currentConfig = ref.read(currentBooruConfigProvider);
      var deleteCurrent = false;
      var deleteFirst = false;
      if (currentConfig.id == config.id) {
        final firstConfig = state.first;

        // check if deleting the first config
        deleteFirst = firstConfig.id == config.id;
        deleteCurrent = true;

        final targetConfig = deleteFirst ? state.skip(1).first : firstConfig;

        await ref
            .read(currentBooruConfigProvider.notifier)
            .update(targetConfig);
      }

      await ref.read(booruConfigRepoProvider).remove(config);
      final orders = ref.read(settingsProvider).booruConfigIdOrderList;
      final newOrders = [...orders..remove(config.id)];

      await ref.read(settingsProvider.notifier).updateOrder(newOrders);

      final tmp = [...state];
      tmp.remove(config);
      state = tmp;
      onSuccess?.call(config);

      analytics.logEvent(
        eventName,
        parameters: {
          ...baseParams,
          'delete_type': deleteCurrent
              ? deleteFirst
                  ? 'current_first'
                  : 'current'
              : 'normal',
        },
      );
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
    final oldConfig =
        state.firstWhereOrNull((element) => element.id == oldConfigId);

    final updatedConfig = await ref
        .read(booruConfigRepoProvider)
        .update(oldConfigId, booruConfigData);

    if (updatedConfig == null) {
      onFailure?.call('Failed to update account');

      return;
    }

    final newConfigs =
        state.replaceFirst(updatedConfig, (item) => item.id == oldConfigId);

    onSuccess?.call(updatedConfig);

    state = newConfigs;

    ref.read(analyticsProvider).logEvent(
      'config_update',
      parameters: {
        'url': updatedConfig.url,
        'hint_site': updatedConfig.booruType.name,
        'is_current': ref.readConfig == updatedConfig,
      },
    );

    if (oldConfig != null) {
      ref.read(analyticsProvider).logConfigChangedEvent(
            oldValue: oldConfig,
            newValue: updatedConfig,
          );
    }
  }

  Future<void> add({
    required BooruConfigData data,
    BooruConfig? initialConfig,
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
    bool setAsCurrent = false,
    bool? isCopy,
  }) async {
    try {
      final config = await ref.read(booruConfigRepoProvider).add(data);

      if (config == null) {
        onFailure?.call('Fail to add account. Account might be incorrect');

        return;
      }

      onSuccess?.call(config);
      ref.read(analyticsProvider).logEvent(
        'site_add',
        parameters: {
          'url': config.url,
          'total_sites': state.length,
          'hint_site': config.booruType.name,
          'has_login': config.apiKey.toOption().fold(
                () => false,
                (a) => a.isNotEmpty,
              ),
          'is_copy': isCopy ?? false,
        },
      );

      if (initialConfig != null) {
        ref.read(analyticsProvider).logConfigChangedEvent(
              oldValue: initialConfig,
              newValue: config,
            );
      }

      await _add(config);

      if (setAsCurrent || state.length == 1) {
        await ref.read(currentBooruConfigProvider.notifier).update(config);
      }
    } catch (e) {
      onFailure?.call('Failed to add account');
    }
  }
}

extension BooruConfigNotifierX on BooruConfigNotifier {
  void addOrUpdate({
    required EditBooruConfigId id,
    required BooruConfigData newConfig,
    BooruConfig? initialData,
  }) {
    if (id.isNew) {
      ref.read(booruConfigProvider.notifier).add(
            data: newConfig,
            initialConfig: initialData,
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
