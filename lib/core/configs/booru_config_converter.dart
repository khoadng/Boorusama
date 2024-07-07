// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/gestures.dart';

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
      customDownloadFileNameFormat:
          booruConfigData.customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat:
          booruConfigData.customBulkDownloadFileNameFormat,
      customDownloadLocation: booruConfigData.customDownloadLocation,
      imageDetaisQuality: booruConfigData.imageDetaisQuality,
      granularRatingFilters: parseGranularRatingFilters(
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
      url: url,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
      customDownloadLocation: customDownloadLocation,
      imageDetaisQuality: imageDetaisQuality,
      granularRatingFilterString: granularRatingFilterToString(
        granularRatingFilters,
      ),
      postGestures: postGestures?.toJsonString(),
      defaultPreviewImageButtonAction: defaultPreviewImageButtonAction,
      listing: listing?.toJsonString(),
    );
  }
}
