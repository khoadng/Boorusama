// Project imports:
import '../../../../proxy/types.dart';
import '../../../../settings/types.dart';
import '../../../../themes/configs/types.dart';
import '../../../gesture/types.dart';
import '../../../search/types.dart';
import '../types/booru_config.dart';
import '../types/booru_config_data.dart';
import '../types/granular_rating_filter.dart';

extension BooruConfigDataConverter on BooruConfigData? {
  BooruConfig? toBooruConfig({required int? id}) {
    final booruConfigData = this;

    if (booruConfigData == null || id == null) return null;

    return BooruConfig(
      id: id,
      booruId: booruConfigData.booruId,
      booruIdHint: booruConfigData.booruIdHint ?? booruConfigData.booruId,
      apiKey: booruConfigData.apiKey.isEmpty ? null : booruConfigData.apiKey,
      login: booruConfigData.login.isEmpty ? null : booruConfigData.login,
      passHash: booruConfigData.passHash,
      url: booruConfigData.url,
      name: booruConfigData.name,
      ratingFilter:
          BooruConfigRatingFilter.values[booruConfigData.ratingFilter],
      deletedItemBehavior: BooruConfigDeletedItemBehavior
          .values[booruConfigData.deletedItemBehavior],
      bannedPostVisibility: BooruConfigBannedPostVisibility
          .values[booruConfigData.bannedPostVisibility],
      customDownloadFileNameFormat:
          booruConfigData.customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat:
          booruConfigData.customBulkDownloadFileNameFormat,
      customDownloadLocation: booruConfigData.customDownloadLocation,
      imageDetaisQuality: booruConfigData.imageDetaisQuality,
      videoQuality: booruConfigData.videoQuality,
      granularRatingFilters: GranularRatingFilter.parse(
        booruConfigData.granularRatingFilterString,
      ),
      postGestures: booruConfigData.postGestures == null
          ? null
          : PostGestureConfig.fromJsonString(booruConfigData.postGestures),
      defaultPreviewImageButtonAction:
          booruConfigData.defaultPreviewImageButtonAction,
      listing: booruConfigData.listing == null
          ? null
          : ListingConfigs.fromJsonString(booruConfigData.listing),
      viewerConfigs: booruConfigData.viewerConfigs == null
          ? null
          : ViewerConfigs.fromJsonString(booruConfigData.viewerConfigs),
      theme: booruConfigData.theme == null
          ? null
          : ThemeConfigs.fromJsonString(booruConfigData.theme),
      alwaysIncludeTags: AlwaysIncludedTags.parse(
        booruConfigData.alwaysIncludeTags,
      ),
      blacklistConfigs: BlacklistConfigs.tryParse(
        booruConfigData.blacklistConfigs,
      ),
      layout: booruConfigData.layout != null
          ? LayoutConfigs.fromJsonString(booruConfigData.layout)
          : null,
      proxySettings: ProxySettings.fromJsonString(
        booruConfigData.proxySettings,
      ),
      viewerNotesFetchBehavior: booruConfigData.viewerNotesFetchBehavior != null
          ? BooruConfigViewerNotesFetchBehavior.values[booruConfigData
                .viewerNotesFetchBehavior!]
          : null,
    );
  }
}

extension BooruConfigConverter on BooruConfig {
  BooruConfigData toBooruConfigData() {
    return BooruConfigData(
      booruId: booruId,
      booruIdHint: booruIdHint,
      apiKey: apiKey ?? '',
      login: login ?? '',
      passHash: passHash,
      name: name,
      deletedItemBehavior: deletedItemBehavior.index,
      ratingFilter: ratingFilter.index,
      bannedPostVisibility: bannedPostVisibility.index,
      url: url,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
      customDownloadLocation: customDownloadLocation,
      imageDetaisQuality: imageDetaisQuality,
      videoQuality: videoQuality,
      granularRatingFilterString: granularRatingFilters?.toFilterString(),
      postGestures: postGestures?.toJsonString(),
      defaultPreviewImageButtonAction: defaultPreviewImageButtonAction,
      listing: listing?.toJsonString(),
      viewerConfigs: viewerConfigs?.toJsonString(),
      theme: theme?.toJsonString(),
      alwaysIncludeTags: alwaysIncludeTags?.toJsonString(),
      blacklistConfigs: blacklistConfigs?.toJsonString(),
      layout: layout?.toJsonString(),
      proxySettings: proxySettings?.toJsonString(),
      viewerNotesFetchBehavior: viewerNotesFetchBehavior?.index,
    );
  }
}
