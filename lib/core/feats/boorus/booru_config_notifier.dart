// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/analytics.dart';

class BooruConfigNotifier extends Notifier<List<BooruConfig>?> {
  @override
  List<BooruConfig>? build() {
    fetch();
    return null;
  }

  Future<void> fetch() async {
    final configs = await ref.read(booruConfigRepoProvider).getAll();
    state = configs;
  }

  Future<void> add(BooruConfig booruConfig) async {
    if (state == null) return;
    final orders = ref.read(configIdOrdersProvider);
    final newOrders = [...orders, booruConfig.id];

    ref.setBooruConfigOrder(newOrders);

    state = [...state!, booruConfig];
  }

  Future<void> delete(
    BooruConfig config, {
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
  }) async {
    if (state == null) return;
    try {
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
    required AddNewBooruConfig config,
    required BooruConfig oldConfig,
    required int id,
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
  }) async {
    if (state == null) return;
    final booruConfigData = oldConfig.hasLoginDetails()
        ? BooruConfigData(
            login: config.login,
            apiKey: config.apiKey,
            deletedItemBehavior: config.hideDeleted
                ? BooruConfigDeletedItemBehavior.hide.index
                : BooruConfigDeletedItemBehavior.show.index,
            ratingFilter: config.ratingFilter.index,
            name: config.configName,
            url: config.url,
            booruId: config.booru.toBooruId(),
            booruIdHint: config.booruHint.toBooruId(),
          )
        : BooruConfigData(
            login: config.login,
            apiKey: config.apiKey,
            booruId: config.booru.toBooruId(),
            booruIdHint: config.booruHint.toBooruId(),
            deletedItemBehavior: config.hideDeleted
                ? BooruConfigDeletedItemBehavior.hide.index
                : BooruConfigDeletedItemBehavior.show.index,
            ratingFilter: config.ratingFilter.index,
            name: config.configName,
            url: config.url,
          );
    final updatedConfig =
        await ref.read(booruConfigRepoProvider).update(id, booruConfigData);

    if (updatedConfig == null) {
      onFailure?.call('Failed to update account');

      return;
    }

    final newConfigs =
        state!.replaceFirst(updatedConfig, (item) => item.id == id);

    onSuccess?.call(updatedConfig);

    state = newConfigs;
  }

  Future<void> addFromAddBooruConfig({
    required AddNewBooruConfig newConfig,
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
    bool setAsCurrent = false,
  }) async {
    if (state == null) return;
    try {
      if (newConfig.login.isEmpty && newConfig.apiKey.isEmpty) {
        final booruConfigData = BooruConfigData.anonymous(
          booru: newConfig.booru,
          booruHint: newConfig.booruHint,
          filter: newConfig.ratingFilter,
          name: newConfig.configName,
          url: newConfig.url,
        );

        final config =
            await ref.read(booruConfigRepoProvider).add(booruConfigData);

        if (config == null) {
          onFailure?.call('Fail to add account. Account might be incorrect');

          return;
        }

        onSuccess?.call(config);

        add(config);

        if (setAsCurrent) {
          ref.read(currentBooruConfigProvider.notifier).update(config);
        }
      } else {
        final booruConfigData = BooruConfigData(
          login: newConfig.login,
          apiKey: newConfig.apiKey,
          deletedItemBehavior: newConfig.hideDeleted
              ? BooruConfigDeletedItemBehavior.hide.index
              : BooruConfigDeletedItemBehavior.show.index,
          ratingFilter: newConfig.ratingFilter.index,
          name: newConfig.configName,
          url: newConfig.url,
          booruId: newConfig.booru.toBooruId(),
          booruIdHint: newConfig.booruHint.toBooruId(),
        );

        final config =
            await ref.read(booruConfigRepoProvider).add(booruConfigData);

        if (config == null) {
          onFailure?.call('Fail to add account. Account might be incorrect');

          return;
        }

        onSuccess?.call(config);
        sendBooruAddedEvent(
          url: config.url,
          hintSite: config.booruType.name,
          totalSites: state!.length,
          hasLogin: config.hasLoginDetails(),
        );

        add(config);
      }
    } catch (e) {
      onFailure?.call('Failed to add account');
    }
  }
}

extension BooruConfigNotifierX on BooruConfigNotifier {
  void addOrUpdate({
    required BooruConfig config,
    required AddNewBooruConfig newConfig,
  }) {
    if (config.isDefault()) {
      ref.read(booruConfigProvider.notifier).addFromAddBooruConfig(
            newConfig: newConfig,
          );
    } else {
      ref.read(booruConfigProvider.notifier).update(
            config: newConfig,
            oldConfig: config,
            id: config.id,
            onSuccess: (booruConfig) => ref
                .read(currentBooruConfigProvider.notifier)
                .update(booruConfig),
          );
    }
  }
}

class AddNewBooruConfig {
  AddNewBooruConfig({
    required this.login,
    required this.apiKey,
    required this.booru,
    required this.configName,
    required this.hideDeleted,
    required this.ratingFilter,
    required this.url,
    required this.booruHint,
  });

  final String login;
  final String apiKey;
  final BooruType booru;
  final BooruType booruHint;
  final String configName;
  final bool hideDeleted;
  final BooruConfigRatingFilter ratingFilter;
  final String url;
}
