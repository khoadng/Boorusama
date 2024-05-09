// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/gestures.dart';

class BooruConfigData extends Equatable {
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
    required this.postGestures,
    required this.defaultPreviewImageButtonAction,
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
        postGestures: null,
        defaultPreviewImageButtonAction: null,
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
        postGestures: json['postGestures'] as String?,
        defaultPreviewImageButtonAction:
            json['defaultPreviewImageButtonAction'] as String?,
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
      'postGestures': postGestures,
      'defaultPreviewImageButtonAction': defaultPreviewImageButtonAction,
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
  final String? postGestures;
  final String? defaultPreviewImageButtonAction;

  @override
  List<Object?> get props => [
        booruId,
        booruIdHint,
        apiKey,
        login,
        name,
        deletedItemBehavior,
        ratingFilter,
        url,
        customDownloadFileNameFormat,
        customBulkDownloadFileNameFormat,
        imageDetaisQuality,
        granularRatingFilterString,
        postGestures,
        defaultPreviewImageButtonAction,
      ];
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
    postGestures: booruConfigData.postGestures == null
        ? null
        : PostGestureConfig.fromJsonString(booruConfigData.postGestures),
    defaultPreviewImageButtonAction:
        booruConfigData.defaultPreviewImageButtonAction,
  );
}

extension BooruConfigDataTransfrom on BooruConfig {
  BooruConfigData toBooruConfigData() {
    return BooruConfigData(
      booruId: booruId,
      booruIdHint: booruIdHint,
      apiKey: apiKey ?? '',
      login: login ?? '',
      name: name,
      deletedItemBehavior: deletedItemBehavior.index,
      ratingFilter: ratingFilter.index,
      url: url,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
      imageDetaisQuality: imageDetaisQuality,
      granularRatingFilterString: granularRatingFilterToString(
        granularRatingFilters,
      ),
      postGestures: postGestures?.toJsonString(),
      defaultPreviewImageButtonAction: defaultPreviewImageButtonAction,
    );
  }
}

extension BooruConfigDataX on BooruConfigData {
  PostGestureConfig? get postGesturesConfigTyped {
    return PostGestureConfig.fromJsonString(postGestures);
  }

  Set<Rating>? get granularRatingFilterTyped {
    return parseGranularRatingFilters(granularRatingFilterString);
  }

  BooruConfigRatingFilter? get ratingFilterTyped {
    if (ratingFilter < 0 ||
        ratingFilter >= BooruConfigRatingFilter.values.length) {
      return null;
    }

    return BooruConfigRatingFilter.values[ratingFilter];
  }
}

extension BooruConfigDataCopyWith on BooruConfigData {
  BooruConfigData copyWith({
    int? booruId,
    int? Function()? booruIdHint,
    String? apiKey,
    String? login,
    String? name,
    BooruConfigDeletedItemBehavior? deletedItemBehavior,
    BooruConfigRatingFilter? ratingFilter,
    String? url,
    String? Function()? customDownloadFileNameFormat,
    String? Function()? customBulkDownloadFileNameFormat,
    String? Function()? imageDetaisQuality,
    Set<Rating>? Function()? granularRatingFilter,
    PostGestureConfig? Function()? postGestures,
    String? Function()? defaultPreviewImageButtonAction,
  }) {
    return BooruConfigData(
      booruId: booruId ?? this.booruId,
      booruIdHint: booruIdHint != null ? booruIdHint() : this.booruIdHint,
      apiKey: apiKey ?? this.apiKey,
      login: login ?? this.login,
      name: name ?? this.name,
      deletedItemBehavior: deletedItemBehavior != null
          ? deletedItemBehavior.index
          : this.deletedItemBehavior,
      ratingFilter:
          ratingFilter != null ? ratingFilter.index : this.ratingFilter,
      url: url ?? this.url,
      customDownloadFileNameFormat: customDownloadFileNameFormat != null
          ? customDownloadFileNameFormat()
          : this.customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat != null
          ? customBulkDownloadFileNameFormat()
          : this.customBulkDownloadFileNameFormat,
      imageDetaisQuality: imageDetaisQuality != null
          ? imageDetaisQuality()
          : this.imageDetaisQuality,
      granularRatingFilterString: granularRatingFilter != null
          ? granularRatingFilterToString(granularRatingFilter())
          : granularRatingFilterString,
      postGestures: postGestures != null
          ? postGestures()?.toJsonString() ??
              const PostGestureConfig.undefined().toJsonString()
          : this.postGestures,
      defaultPreviewImageButtonAction: defaultPreviewImageButtonAction != null
          ? defaultPreviewImageButtonAction()
          : this.defaultPreviewImageButtonAction,
    );
  }
}
