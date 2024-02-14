// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';

class BooruConfigData {
  const BooruConfigData({
    required this.booruId,
    required this.booruIdHint,
    required this.apiKey,
    required this.login,
    required this.name,
    required this.deletedItemBehavior,
    required this.ratingFilter,
    required this.url,
    required this.customDownloadFileNameFormat,
    required this.customBulkDownloadFileNameFormat,
    required this.imageDetaisQuality,
    required this.granularRatingFilterString,
  });

  factory BooruConfigData.anonymous({
    required BooruType booru,
    required BooruType booruHint,
    required String name,
    required BooruConfigRatingFilter filter,
    required String url,
    required String? customDownloadFileNameFormat,
    required String? customBulkDownloadFileNameFormat,
    required String? imageDetaisQuality,
  }) =>
      BooruConfigData(
        booruId: booru.toBooruId(),
        booruIdHint: booruHint.toBooruId(),
        apiKey: '',
        login: '',
        url: url,
        name: name,
        deletedItemBehavior: BooruConfigDeletedItemBehavior.show.index,
        ratingFilter: filter.index,
        customDownloadFileNameFormat: customDownloadFileNameFormat,
        customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
        imageDetaisQuality: imageDetaisQuality,
        granularRatingFilterString: null,
      );

  static BooruConfigData? fromJson(Map<String, dynamic> json) {
    try {
      return BooruConfigData(
        booruId: json['booruId'] as int,
        booruIdHint: json['booruIdHint'] as int?,
        apiKey: json['apiKey'] as String,
        login: json['login'] as String,
        url: json['url'] as String,
        name: json['name'] as String,
        deletedItemBehavior: json['deletedItemBehavior'] as int,
        ratingFilter: json['ratingFilter'] as int,
        customDownloadFileNameFormat:
            json['customDownloadFileNameFormat'] as String?,
        customBulkDownloadFileNameFormat:
            json['customBulkDownloadFileNameFormat'] as String?,
        imageDetaisQuality: json['imageDetaisQuality'] as String?,
        granularRatingFilterString:
            json['granularRatingFilterString'] as String?,
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'booruId': booruId,
      'booruIdHint': booruIdHint,
      'apiKey': apiKey,
      'login': login,
      'url': url,
      'name': name,
      'deletedItemBehavior': deletedItemBehavior,
      'ratingFilter': ratingFilter,
      'customDownloadFileNameFormat': customDownloadFileNameFormat,
      'customBulkDownloadFileNameFormat': customBulkDownloadFileNameFormat,
      'imageDetaisQuality': imageDetaisQuality,
      'granularRatingFilterString': granularRatingFilterString,
    };
  }

  final int booruId;
  final int? booruIdHint;
  final String apiKey;
  final String login;
  final String name;
  final int deletedItemBehavior;
  final int ratingFilter;
  final String url;
  final String? customDownloadFileNameFormat;
  final String? customBulkDownloadFileNameFormat;
  final String? imageDetaisQuality;
  final String? granularRatingFilterString;
}

BooruConfig? convertToBooruConfig({
  required int? id,
  required BooruConfigData? booruConfigData,
}) {
  if (booruConfigData == null || id == null) return null;

  return BooruConfig(
    id: id,
    booruId: booruConfigData.booruId,
    booruIdHint: booruConfigData.booruIdHint ?? booruConfigData.booruId,
    apiKey: booruConfigData.apiKey.isEmpty ? null : booruConfigData.apiKey,
    login: booruConfigData.login.isEmpty ? null : booruConfigData.login,
    url: booruConfigData.url,
    name: booruConfigData.name,
    ratingFilter: BooruConfigRatingFilter.values[booruConfigData.ratingFilter],
    deletedItemBehavior: BooruConfigDeletedItemBehavior
        .values[booruConfigData.deletedItemBehavior],
    customDownloadFileNameFormat: booruConfigData.customDownloadFileNameFormat,
    customBulkDownloadFileNameFormat:
        booruConfigData.customBulkDownloadFileNameFormat,
    imageDetaisQuality: booruConfigData.imageDetaisQuality,
    granularRatingFilters: parseGranularRatingFilters(
      booruConfigData.granularRatingFilterString,
    ),
  );
}
