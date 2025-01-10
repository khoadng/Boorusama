// Dart imports:
import 'dart:async';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../analytics.dart';
import '../../../foundation/loggers.dart';
import '../../../settings/providers.dart';
import '../booru_config.dart';
import '../booru_config_converter.dart';
import '../booru_config_ref.dart';
import '../data/booru_config_data.dart';
import '../edit_booru_config_id.dart';
import '../export_import/export_import_notifer_mixin.dart';
import 'current_booru_providers.dart';

final booruConfigRepoProvider = Provider<BooruConfigRepository>(
  (ref) => throw UnimplementedError(),
);

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
    const eventName = 'config_delete';
    final baseParams = {
      'url': config.url,
      'hint_site': config.auth.booruType.name,
      'has_login': config.auth.hasLoginDetails(),
    };

    try {
      // check if deleting the last config
      if (state.length == 1) {
        await ref.read(booruConfigRepoProvider).remove(config);
        await ref.read(booruConfigProvider.notifier).fetch();
        // reset order
        await ref.read(settingsNotifierProvider.notifier).updateOrder([]);
        await ref.read(currentBooruConfigProvider.notifier).setEmpty();

        onSuccess?.call(config);

        unawaited(
          analytics.logEvent(
            eventName,
            parameters: {
              ...baseParams,
              'delete_type': 'last',
            },
          ),
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

      await ref.read(settingsNotifierProvider.notifier).updateOrder(newOrders);

      final tmp = [...state]..remove(config);
      state = tmp;
      onSuccess?.call(config);

      unawaited(
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
        ),
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

      final oldConfig =
          state.firstWhereOrNull((element) => element.id == oldConfigId);

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

      unawaited(
        ref.read(analyticsProvider).logEvent(
          'config_update',
          parameters: {
            'url': updatedConfig.url,
            'hint_site': updatedConfig.auth.booruType.name,
            'is_current': ref.readConfigAuth == updatedConfig,
          },
        ),
      );

      if (oldConfig != null) {
        unawaited(
          ref.read(analyticsProvider).logConfigChangedEvent(
                oldValue: oldConfig,
                newValue: updatedConfig,
              ),
        );
      }
    } catch (e) {
      _logError('Failed to update config: $oldConfigId');
      onFailure?.call(
        'Something went wrong while updating your profile. Please try again',
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
        onFailure?.call(
          'Unable to add profile. Please check your inputs and try again',
        );

        return;
      }

      onSuccess?.call(config);

      await _add(config);

      unawaited(
        ref.read(analyticsProvider).logEvent(
          'site_add',
          parameters: {
            'url': config.url,
            'total_sites': state.length,
            'hint_site': config.auth.booruType.name,
            'has_login': config.apiKey.toOption().fold(
                  () => false,
                  (a) => a.isNotEmpty,
                ),
            'is_copy': isCopy ?? false,
          },
        ),
      );

      if (initialConfig != null) {
        unawaited(
          ref.read(analyticsProvider).logConfigChangedEvent(
                oldValue: initialConfig,
                newValue: config,
              ),
        );
      }

      if (setAsCurrent || state.length == 1) {
        await ref.read(currentBooruConfigProvider.notifier).update(config);
      }
    } catch (e) {
      onFailure?.call(
        'Something went wrong while adding your profile. Please try again',
      );
    }
  }

  void _logError(String message) {
    ref.read(loggerProvider).logE('Configs', message);
  }

  void _logInfo(String message) {
    ref.read(loggerProvider).logI('Configs', message);
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
