// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../analytics/providers.dart';
import '../../../../boorus/booru/booru.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../posts/rating/rating.dart';
import '../../../../proxy/proxy.dart';
import '../../../../settings/settings.dart';
import '../../../../theme/theme_configs.dart';
import '../../../config/data.dart';
import '../../../config/types.dart';
import '../../../gesture/gesture.dart';
import '../../../manage/providers.dart';
import '../../../search/search.dart';
import '../types/edit_booru_config_id.dart';

final booruEngineProvider = StateProvider.autoDispose<BooruType?>(
  (ref) => null,
);

final siteUrlProvider = StateProvider.autoDispose.family<String?, BooruConfig>(
  (ref, config) => config.url,
);

final targetConfigToValidateProvider =
    StateProvider.autoDispose<BooruConfigAuth?>((ref) {
      return null;
    });

final validateConfigProvider = FutureProvider.autoDispose<bool?>((ref) async {
  final config = ref.watch(targetConfigToValidateProvider);
  if (config == null) return null;

  ref
      .watch(analyticsProvider)
      .whenData(
        (analytics) => analytics?.logEvent(
          'config_verify',
          parameters: {
            'url': Uri.tryParse(config.url)?.host,
            'hint_site': config.booruType.name,
            'has_login': config.hasLoginDetails(),
          },
        ),
      );

  final result = await ref.watch(booruSiteValidatorProvider(config).future);
  return result;
});

final booruSiteValidatorProvider = FutureProvider.autoDispose
    .family<bool, BooruConfigAuth>(
      (ref, config) {
        final repo = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        final siteValidator = repo?.siteValidator(config);

        if (siteValidator != null) {
          return siteValidator();
        }

        return Future.value(false);
      },
    );

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
    final config = arg.isNew
        ? null
        : configs.firstWhereOrNull((e) => e.id == arg.id);

    return (config ?? defaultConfig).toBooruConfigData();
  }

  void updateLogin(
    String login,
  ) => state = state.copyWith(login: login);

  void updateApiKey(
    String apiKey,
  ) => state = state.copyWith(apiKey: apiKey);

  void updatePassHash(
    String? passHash,
  ) => state = state.copyWith(passHash: () => passHash);

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
  ) => state = state.copyWith(name: name);

  void updateAlwaysIncludeTags(
    String? alwaysIncludeTags,
  ) => state = state.copyWith(alwaysIncludeTags: () => alwaysIncludeTags);

  void updateListing(
    ListingConfigs? listing,
  ) => state = state.copyWith(listing: () => listing);

  void updateCustomDownloadLocation(
    String? customDownloadLocation,
  ) => state = state.copyWith(
    customDownloadLocation: () => customDownloadLocation,
  );

  void updateCustomDownloadFileNameFormat(
    String? customDownloadFileNameFormat,
  ) => state = state.copyWith(
    customDownloadFileNameFormat: () => customDownloadFileNameFormat,
  );

  void updateCustomBulkDownloadFileNameFormat(
    String? customBulkDownloadFileNameFormat,
  ) => state = state.copyWith(
    customBulkDownloadFileNameFormat: () => customBulkDownloadFileNameFormat,
  );

  void updateImageDetailsQuality(
    String? imageDetailsQuality,
  ) => state = state.copyWith(imageDetaisQuality: () => imageDetailsQuality);

  void updateDefaultPreviewImageButtonAction(
    String? defaultPreviewImageButtonAction,
  ) => state = state.copyWith(
    defaultPreviewImageButtonAction: () => defaultPreviewImageButtonAction,
  );

  void updateGranularRatingFilter(
    Set<Rating>? granularRatingFilter,
  ) => state = state.copyWith(granularRatingFilter: () => granularRatingFilter);

  void updateRatingFilter(
    BooruConfigRatingFilter? ratingFilter,
  ) => state = state.copyWith(ratingFilter: ratingFilter);

  void updateGesturesConfigData(
    PostGestureConfig? data,
  ) => state = state.copyWith(postGestures: () => data);

  void updateBannedPostVisibility(
    bool bannedPostVisibility,
  ) => state = state.copyWith(
    bannedPostVisibility: bannedPostVisibility
        ? BooruConfigBannedPostVisibility.hide
        : BooruConfigBannedPostVisibility.show,
  );

  void updateDeletedItemBehavior(
    bool hideDeleted,
  ) => state = state.copyWith(
    deletedItemBehavior: hideDeleted
        ? BooruConfigDeletedItemBehavior.hide
        : BooruConfigDeletedItemBehavior.show,
  );

  void updateLayout(
    LayoutConfigs? layout,
  ) => state = state.copyWith(layout: () => layout);

  void updateTheme(
    ThemeConfigs? theme,
  ) => state = state.copyWith(theme: () => theme);

  void updateProxySettings(
    ProxySettings? proxySettings,
  ) => state = state.copyWith(proxySettings: () => proxySettings);

  void updateViewerNotesFetchBehavior(
    bool autoFetch,
  ) => state = state.copyWith(
    viewerNotesFetchBehavior: () => autoFetch
        ? BooruConfigViewerNotesFetchBehavior.auto
        : BooruConfigViewerNotesFetchBehavior.manual,
  );

  void updateBlacklistConfigs(
    BlacklistConfigs? blacklistConfigs,
  ) => state = state.copyWith(blacklistConfigs: () => blacklistConfigs);
}
