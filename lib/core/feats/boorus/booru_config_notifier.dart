// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/export_import/export_import.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/analytics.dart';

class BooruConfigNotifier extends Notifier<List<BooruConfig>?>
    with BooruConfigExportImportMixin {
  @override
  List<BooruConfig>? build() {
    fetch();
    return null;
  }

  Future<void> fetch() async {
    final configs = await ref.read(booruConfigRepoProvider).getAll();
    state = configs;
  }

  Future<void> _add(BooruConfig booruConfig) async {
    if (state == null) return;
    final orders = ref.read(configIdOrdersProvider);
    final newOrders = [...orders, booruConfig.id];

    ref.setBooruConfigOrder(newOrders);

    state = [...state!, booruConfig];
  }

  Future<void> duplicate({
    required BooruConfig config,
  }) {
    final copyData = config.copyWith(
      name: '${config.name} copy',
    );

    return add(
      booruConfigData: copyData.toBooruConfigData(),
    );
  }

  Future<void> delete(
    BooruConfig config, {
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
  }) async {
    if (state == null) return;
    try {
      // check if deleting current config, if so, set current to the first config
      // if there is no config left, fail
      final currentConfig = ref.read(currentBooruConfigProvider);
      if (currentConfig.id == config.id) {
        if (state!.length <= 1) {
          onFailure?.call('Must have at least one profile');
          return;
        }

        final firstConfig = state!.first;

        // check if deleting the first config
        final targetConfig =
            firstConfig.id == config.id ? state!.skip(1).first : firstConfig;

        await ref
            .read(currentBooruConfigProvider.notifier)
            .update(targetConfig);
      }

      await ref.read(booruConfigRepoProvider).remove(config);
      final orders = ref.read(configIdOrdersProvider);
      final newOrders = [...orders..remove(config.id)];

      ref.setBooruConfigOrder(newOrders);

      final tmp = [...state!];
      tmp.remove(config);
      state = tmp;
      onSuccess?.call(config);
    } catch (e) {
      onFailure?.call(e.toString());
    }
  }

  Future<void> update({
    required BooruConfigData booruConfigData,
    required BooruConfig oldConfig,
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
  }) async {
    if (state == null) return;
    final updatedConfig = await ref
        .read(booruConfigRepoProvider)
        .update(oldConfig.id, booruConfigData);

    if (updatedConfig == null) {
      onFailure?.call('Failed to update account');

      return;
    }

    final newConfigs =
        state!.replaceFirst(updatedConfig, (item) => item.id == oldConfig.id);

    onSuccess?.call(updatedConfig);

    state = newConfigs;
  }

  Future<void> add({
    required BooruConfigData booruConfigData,
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
    bool setAsCurrent = false,
  }) async {
    if (state == null) return;
    try {
      final config =
          await ref.read(booruConfigRepoProvider).add(booruConfigData);

      if (config == null) {
        onFailure?.call('Fail to add account. Account might be incorrect');

        return;
      }

      onSuccess?.call(config);
      ref.read(analyticsProvider).sendBooruAddedEvent(
            url: config.url,
            hintSite: config.booruType.name,
            totalSites: state!.length,
            hasLogin: config.hasLoginDetails(),
          );

      _add(config);

      if (setAsCurrent) {
        ref.read(currentBooruConfigProvider.notifier).update(config);
      }
    } catch (e) {
      onFailure?.call('Failed to add account');
    }
  }
}

extension BooruConfigNotifierX on BooruConfigNotifier {
  void addOrUpdate({
    required BooruConfig config,
    required BooruConfigData newConfig,
  }) {
    if (config.isDefault()) {
      ref.read(booruConfigProvider.notifier).add(
            booruConfigData: newConfig,
          );
    } else {
      ref.read(booruConfigProvider.notifier).update(
            booruConfigData: newConfig,
            oldConfig: config,
            onSuccess: (booruConfig) => ref
                .read(currentBooruConfigProvider.notifier)
                .update(booruConfig),
          );
    }
  }
}
