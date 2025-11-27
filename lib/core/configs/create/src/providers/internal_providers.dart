// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../analytics/providers.dart';
import '../../../../boorus/booru/types.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../posts/listing/types.dart';
import '../../../../posts/rating/types.dart';
import '../../../../proxy/types.dart';
import '../../../../settings/types.dart';
import '../../../../themes/configs/types.dart';
import '../../../config/data.dart';
import '../../../config/providers.dart';
import '../../../config/types.dart';
import '../../../gesture/types.dart';
import '../../../manage/providers.dart';
import '../../../search/types.dart';
import '../types/edit_booru_config_id.dart';

final booruEngineProvider = StateProvider.autoDispose<BooruType?>(
  (ref) => null,
);

final targetConfigToValidateProvider =
    StateProvider.autoDispose<BooruConfigAuth?>((ref) {
      return null;
    });

final validateConfigProvider = FutureProvider.autoDispose<bool?>((ref) async {
  final config = ref.watch(targetConfigToValidateProvider);
  if (config == null) return null;

  final loginDetails = ref.watch(booruLoginDetailsProvider(config));

  ref
      .watch(analyticsProvider)
      .whenData(
        (analytics) => analytics?.logEvent(
          'config_verify',
          parameters: {
            'url': Uri.tryParse(config.url)?.host,
            'hint_site': config.booruType.name,
            'has_login': loginDetails.hasLogin(),
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

  void updateUrl(
    String? url,
  ) => state = state.copyWith(url: url);

  void updateAlwaysIncludeTags(
    String? alwaysIncludeTags,
  ) => state = state.copyWith(alwaysIncludeTags: () => alwaysIncludeTags);

  void updateListing(
    ListingConfigs? listing,
  ) => state = state.copyWith(listing: () => listing);

  void updateViewerConfigs(
    ViewerConfigs? viewerConfigs,
  ) => state = state.copyWith(viewerConfigs: () => viewerConfigs);

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

  void updateVideoQuality(
    String? videoQuality,
  ) => state = state.copyWith(videoQuality: () => videoQuality);

  void updateDefaultPreviewImageButtonAction(
    String? defaultPreviewImageButtonAction,
  ) => state = state.copyWith(
    defaultPreviewImageButtonAction: () => defaultPreviewImageButtonAction,
  );

  void updateTooltipDisplayMode(
    TooltipDisplayMode? tooltipDisplayMode,
  ) => state = state.copyWith(tooltipDisplayMode: () => tooltipDisplayMode);

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

  void updateNetworkSettings(
    NetworkSettings? networkSettings,
  ) => state = state.copyWith(networkSettings: () => networkSettings);
}
