// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../posts/rating/rating.dart';
import '../../../proxy/proxy.dart';
import '../../../settings/settings.dart';
import '../../../theme/theme_configs.dart';
import '../booru_config.dart';
import '../booru_config_converter.dart';
import '../data/booru_config_data.dart';
import '../edit_booru_config_id.dart';
import '../gestures.dart';
import '../manage/booru_config_provider.dart';
import '../types.dart';

final editBooruConfigIdProvider = Provider.autoDispose<EditBooruConfigId>(
  (ref) => throw UnimplementedError(),
);

final editBooruConfigProvider = NotifierProvider.autoDispose
    .family<EditBooruConfigNotifier, BooruConfigData, EditBooruConfigId>(
  EditBooruConfigNotifier.new,
);

final initialBooruConfigProvider = Provider.autoDispose<BooruConfig>(
  (ref) => throw UnimplementedError(),
);

final booruConfigDataProvider = StateProvider.autoDispose<BooruConfigData>(
  (ref) => ref.watch(initialBooruConfigProvider).toBooruConfigData(),
  dependencies: [initialBooruConfigProvider],
);

typedef BooruSiteValidator = Future<bool> Function();

final booruSiteValidatorProvider =
    FutureProvider.autoDispose.family<bool, BooruConfigAuth>(
  (ref, config) {
    final repo =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    final siteValidator = repo?.siteValidator(config);

    if (siteValidator != null) {
      return siteValidator();
    }

    return Future.value(false);
  },
);

extension UpdateDataX on WidgetRef {
  EditBooruConfigNotifier get editNotifier =>
      read(editBooruConfigProvider(read(editBooruConfigIdProvider)).notifier);
}

class EditBooruConfigNotifier
    extends AutoDisposeFamilyNotifier<BooruConfigData, EditBooruConfigId> {
  @override
  BooruConfigData build(EditBooruConfigId arg) {
    final configs = ref.watch(booruConfigProvider);
    final defaultConfig = BooruConfig.defaultConfig(
      booruType: arg.booruType,
      url: arg.url,
      customDownloadFileNameFormat: null,
    );
    final config =
        arg.isNew ? null : configs.firstWhereOrNull((e) => e.id == arg.id);

    return (config ?? defaultConfig).toBooruConfigData();
  }

  void updateLogin(
    String login,
  ) =>
      state = state.copyWith(login: login);

  void updateApiKey(
    String apiKey,
  ) =>
      state = state.copyWith(apiKey: apiKey);

  void updatePassHash(
    String? passHash,
  ) =>
      state = state.copyWith(passHash: () => passHash);

  void updateLoginAndApiKey(
    String login,
    String apiKey,
  ) {
    state = state.copyWith(
      login: login,
      apiKey: apiKey,
    );
  }

  void updateName(
    String name,
  ) =>
      state = state.copyWith(name: name);

  void updateAlwaysIncludeTags(
    String? alwaysIncludeTags,
  ) =>
      state = state.copyWith(alwaysIncludeTags: () => alwaysIncludeTags);

  void updateListing(
    ListingConfigs? listing,
  ) =>
      state = state.copyWith(listing: () => listing);

  void updateCustomDownloadLocation(
    String? customDownloadLocation,
  ) =>
      state =
          state.copyWith(customDownloadLocation: () => customDownloadLocation);

  void updateCustomDownloadFileNameFormat(
    String? customDownloadFileNameFormat,
  ) =>
      state = state.copyWith(
        customDownloadFileNameFormat: () => customDownloadFileNameFormat,
      );

  void updateCustomBulkDownloadFileNameFormat(
    String? customBulkDownloadFileNameFormat,
  ) =>
      state = state.copyWith(
        customBulkDownloadFileNameFormat: () =>
            customBulkDownloadFileNameFormat,
      );

  void updateImageDetailsQuality(
    String? imageDetailsQuality,
  ) =>
      state = state.copyWith(imageDetaisQuality: () => imageDetailsQuality);

  void updateDefaultPreviewImageButtonAction(
    String? defaultPreviewImageButtonAction,
  ) =>
      state = state.copyWith(
        defaultPreviewImageButtonAction: () => defaultPreviewImageButtonAction,
      );

  void updateGranularRatingFilter(
    Set<Rating>? granularRatingFilter,
  ) =>
      state = state.copyWith(granularRatingFilter: () => granularRatingFilter);

  void updateRatingFilter(
    BooruConfigRatingFilter? ratingFilter,
  ) =>
      state = state.copyWith(ratingFilter: ratingFilter);

  void updateGesturesConfigData(
    PostGestureConfig? data,
  ) =>
      state = state.copyWith(postGestures: () => data);

  void updateBannedPostVisibility(
    bool bannedPostVisibility,
  ) =>
      state = state.copyWith(
        bannedPostVisibility: bannedPostVisibility
            ? BooruConfigBannedPostVisibility.hide
            : BooruConfigBannedPostVisibility.show,
      );

  void updateDeletedItemBehavior(
    bool hideDeleted,
  ) =>
      state = state.copyWith(
        deletedItemBehavior: hideDeleted
            ? BooruConfigDeletedItemBehavior.hide
            : BooruConfigDeletedItemBehavior.show,
      );

  void updateLayout(
    LayoutConfigs? layout,
  ) =>
      state = state.copyWith(layout: () => layout);

  void updateTheme(
    ThemeConfigs? theme,
  ) =>
      state = state.copyWith(theme: () => theme);

  void updateProxySettings(
    ProxySettings? proxySettings,
  ) =>
      state = state.copyWith(proxySettings: () => proxySettings);
}
