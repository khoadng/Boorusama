// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/gestures.dart';

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

    return addFromAddBooruConfig(
        newConfig: AddNewBooruConfig(
      login: copyData.login ?? '',
      apiKey: copyData.apiKey ?? '',
      booru: copyData.booruType,
      configName: copyData.name,
      hideDeleted:
          copyData.deletedItemBehavior == BooruConfigDeletedItemBehavior.hide,
      ratingFilter: copyData.ratingFilter,
      url: copyData.url,
      booruHint: copyData.booruType,
      customDownloadFileNameFormat: copyData.customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat:
          copyData.customBulkDownloadFileNameFormat,
      imageDetaisQuality: copyData.imageDetaisQuality,
      granularRatingFilters: copyData.granularRatingFilters,
      postGestures: copyData.postGestures,
    ));
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
            customDownloadFileNameFormat: config.customDownloadFileNameFormat,
            customBulkDownloadFileNameFormat:
                config.customBulkDownloadFileNameFormat,
            imageDetaisQuality: config.imageDetaisQuality,
            granularRatingFilterString:
                granularRatingFilterToString(config.granularRatingFilters),
            postGestures: config.postGestures?.toJsonString(),
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
            customDownloadFileNameFormat: config.customDownloadFileNameFormat,
            customBulkDownloadFileNameFormat:
                config.customBulkDownloadFileNameFormat,
            imageDetaisQuality: config.imageDetaisQuality,
            granularRatingFilterString:
                granularRatingFilterToString(config.granularRatingFilters),
            postGestures: config.postGestures?.toJsonString(),
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
          customDownloadFileNameFormat: newConfig.customDownloadFileNameFormat,
          customBulkDownloadFileNameFormat:
              newConfig.customBulkDownloadFileNameFormat,
          imageDetaisQuality: newConfig.imageDetaisQuality,
        );

        final config =
            await ref.read(booruConfigRepoProvider).add(booruConfigData);

        if (config == null) {
          onFailure?.call('Fail to add account. Account might be incorrect');

          return;
        }

        onSuccess?.call(config);

        _add(config);

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
          customDownloadFileNameFormat: newConfig.customDownloadFileNameFormat,
          customBulkDownloadFileNameFormat:
              newConfig.customBulkDownloadFileNameFormat,
          imageDetaisQuality: newConfig.imageDetaisQuality,
          granularRatingFilterString:
              granularRatingFilterToString(newConfig.granularRatingFilters),
          postGestures: newConfig.postGestures?.toJsonString(),
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

        _add(config);
      }
    } catch (e) {
      onFailure?.call('Failed to add account');
    }
  }

  // import from json
  Future<void> import({
    required String path,
    void Function(String message)? onFailure,
    void Function(String message, List<BooruConfig> configs)? onSuccess,
    Future<bool> Function(BooruConfigExportData data)? onWillImport,
  }) async {
    if (state == null) return;
    final configRepo = ref.read(booruConfigRepoProvider);

    ref
        .read(booruConfigFileHandlerProvider)
        .import(
          from: path,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) => onFailure?.call(l.toString()),
            (r) async {
              final willImport = await onWillImport?.call(r);
              if (willImport == null || !willImport) return;

              await configRepo.clear();
              state = await configRepo.addAll(r.data);
              onSuccess?.call('Imported successfully', r.data);
            },
          ),
        );
  }

  // export to json
  Future<void> export({
    required String path,
    void Function(String message)? onFailure,
    void Function(String message)? onSuccess,
  }) async {
    if (state == null) return;

    await ref
        .read(booruConfigFileHandlerProvider)
        .export(
          configs: state!,
          path: path,
        )
        .run()
        .then(
          (value) => value.fold(
            (l) => onFailure?.call(l.toString()),
            (r) {
              onSuccess?.call('Exported successfully');
            },
          ),
        );
  }

  Future<void> exportClipboard({
    void Function(String message)? onFailure,
    void Function(String message)? onSuccess,
  }) async {
    if (state == null) return;

    BooruConfigIOHandler.exportToClipboard(
      configs: state!,
      onSucceed: () => onSuccess?.call('Copied to clipboard'),
      onError: (e) => onFailure?.call(e),
    );
  }

  Future<void> importClipboard({
    void Function(String message)? onFailure,
    void Function(String message, List<BooruConfig> configs)? onSuccess,
    Future<bool> Function(BooruConfigExportData data)? onWillImport,
  }) async {
    if (state == null) return;

    BooruConfigIOHandler.importFromClipboard().then(
      (value) => value.fold(
        (l) => onFailure?.call(l.toString()),
        (r) async {
          final willImport = await onWillImport?.call(r);
          if (willImport == null || !willImport) return;

          final configRepo = ref.read(booruConfigRepoProvider);

          await configRepo.clear();
          state = await configRepo.addAll(r.data);
          onSuccess?.call('Imported successfully', r.data);
        },
      ),
    );
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
    required this.customDownloadFileNameFormat,
    required this.customBulkDownloadFileNameFormat,
    required this.imageDetaisQuality,
    required this.granularRatingFilters,
    required this.postGestures,
  });

  final String login;
  final String apiKey;
  final BooruType booru;
  final BooruType booruHint;
  final String configName;
  final bool hideDeleted;
  final BooruConfigRatingFilter ratingFilter;
  final String url;
  final String? customDownloadFileNameFormat;
  final String? customBulkDownloadFileNameFormat;
  final String? imageDetaisQuality;
  final Set<Rating>? granularRatingFilters;
  final PostGestureConfig? postGestures;
}
