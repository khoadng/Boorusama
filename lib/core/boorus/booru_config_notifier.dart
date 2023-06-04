// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/boorus/boorus.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/utils/collection_utils.dart';

class BooruConfigNotifier extends Notifier<List<BooruConfig>> {
  @override
  List<BooruConfig> build() {
    fetch();
    return [];
  }

  Future<void> fetch() async {
    final configs = await ref.read(booruConfigRepoProvider).getAll();
    state = configs;
  }

  Future<void> add(BooruConfig booruConfig) async {
    state = [...state, booruConfig];
  }

  Future<void> delete(
    BooruConfig config, {
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
  }) async {
    try {
      await ref.read(booruConfigRepoProvider).remove(config);
      final tmp = [...state];
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
            booruId: config.booru.index,
          )
        : BooruConfigData(
            login: config.login,
            apiKey: config.apiKey,
            booruId: config.booru.index,
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
        state.replaceFirst(updatedConfig, (item) => item.id == id);

    onSuccess?.call(updatedConfig);

    state = newConfigs;
  }

  Future<void> addFromAddBooruConfig({
    required AddNewBooruConfig newConfig,
    void Function(String message)? onFailure,
    void Function(BooruConfig booruConfig)? onSuccess,
    bool setAsCurrent = false,
  }) async {
    try {
      if (newConfig.login.isEmpty && newConfig.apiKey.isEmpty) {
        final booruConfigData = BooruConfigData.anonymous(
          booru: newConfig.booru,
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
          booruId: newConfig.booru.index,
        );

        final config =
            await ref.read(booruConfigRepoProvider).add(booruConfigData);

        if (config == null) {
          onFailure?.call('Fail to add account. Account might be incorrect');

          return;
        }

        onSuccess?.call(config);

        add(config);
      }
    } catch (e) {
      onFailure?.call('Failed to add account');
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
  });

  final String login;
  final String apiKey;
  final BooruType booru;
  final String configName;
  final bool hideDeleted;
  final BooruConfigRatingFilter ratingFilter;
  final String url;
}
