// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/platform.dart';

class BooruConfig extends Equatable {
  const BooruConfig({
    required this.id,
    required this.booruId,
    required this.booruIdHint,
    required this.apiKey,
    required this.login,
    required this.name,
    required this.ratingFilter,
    required this.deletedItemBehavior,
    required this.url,
    required this.customDownloadFileNameFormat,
    required this.customBulkDownloadFileNameFormat,
    required this.imageDetaisQuality,
  });

  static const BooruConfig empty = BooruConfig(
    id: -1,
    booruId: -1,
    booruIdHint: -1,
    apiKey: null,
    login: null,
    name: '',
    deletedItemBehavior: BooruConfigDeletedItemBehavior.show,
    ratingFilter: BooruConfigRatingFilter.none,
    url: '',
    customDownloadFileNameFormat: null,
    customBulkDownloadFileNameFormat: null,
    imageDetaisQuality: null,
  );

  static BooruConfig defaultConfig({
    required BooruType booruType,
    required String url,
    required String? customDownloadFileNameFormat,
  }) =>
      BooruConfig(
        id: -1,
        booruId: booruType.toBooruId(),
        booruIdHint: booruType.toBooruId(),
        apiKey: null,
        login: null,
        name: 'new profile',
        deletedItemBehavior: BooruConfigDeletedItemBehavior.show,
        ratingFilter: BooruConfigRatingFilter.none,
        url: url,
        customDownloadFileNameFormat: customDownloadFileNameFormat,
        customBulkDownloadFileNameFormat: customDownloadFileNameFormat,
        imageDetaisQuality: null,
      );

  final int id;
  final int booruId;
  final int booruIdHint;
  final String url;
  final String? apiKey;
  final String? login;
  final String name;
  final BooruConfigDeletedItemBehavior deletedItemBehavior;
  final BooruConfigRatingFilter ratingFilter;
  final String? customDownloadFileNameFormat;
  final String? customBulkDownloadFileNameFormat;
  final String? imageDetaisQuality;

  BooruConfig copyWith({
    String? url,
    String? apiKey,
    String? login,
    String? name,
  }) {
    return BooruConfig(
      id: id,
      booruId: booruId,
      booruIdHint: booruIdHint,
      url: url ?? this.url,
      apiKey: apiKey ?? this.apiKey,
      login: login ?? this.login,
      name: name ?? this.name,
      deletedItemBehavior: deletedItemBehavior,
      ratingFilter: ratingFilter,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
      imageDetaisQuality: imageDetaisQuality,
    );
  }

  @override
  List<Object?> get props => [
        id,
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
      ];

  factory BooruConfig.fromJson(Map<String, dynamic> json) {
    return BooruConfig(
      id: json['id'] as int,
      booruId: json['booruId'] as int,
      booruIdHint: json['booruIdHint'] as int,
      apiKey: json['apiKey'] as String?,
      login: json['login'] as String?,
      url: json['url'] as String,
      name: json['name'] as String,
      deletedItemBehavior: BooruConfigDeletedItemBehavior
          .values[json['deletedItemBehavior'] as int],
      ratingFilter: BooruConfigRatingFilter.values[json['ratingFilter'] as int],
      customDownloadFileNameFormat:
          json['customDownloadFileNameFormat'] as String?,
      customBulkDownloadFileNameFormat:
          json['customBulkDownloadFileNameFormat'] as String?,
      imageDetaisQuality: json['imageDetaisQuality'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booruId': booruId,
      'booruIdHint': booruIdHint,
      'apiKey': apiKey,
      'login': login,
      'url': url,
      'name': name,
      'deletedItemBehavior': deletedItemBehavior.index,
      'ratingFilter': ratingFilter.index,
      'customDownloadFileNameFormat': customDownloadFileNameFormat,
      'customBulkDownloadFileNameFormat': customBulkDownloadFileNameFormat,
      'imageDetaisQuality': imageDetaisQuality,
    };
  }
}

enum BooruConfigDeletedItemBehavior {
  show,
  hide,
}

enum BooruConfigRatingFilter {
  none,
  hideExplicit,
  hideNSFW,
}

extension BooruConfigRatingFilterX on BooruConfigRatingFilter {
  String getRatingTerm() => switch (this) {
        BooruConfigRatingFilter.none => 'None',
        BooruConfigRatingFilter.hideExplicit => 'Safeish',
        BooruConfigRatingFilter.hideNSFW => 'Safe'
      };

  String getFilterRatingTerm() => switch (this) {
        BooruConfigRatingFilter.none => 'None',
        BooruConfigRatingFilter.hideExplicit => 'Moderate',
        BooruConfigRatingFilter.hideNSFW => 'Aggressive'
      };
}

extension BooruConfigNullX on BooruConfig? {
  bool hasLoginDetails() {
    if (this == null) return false;
    if (this!.login == null || this!.apiKey == null) return false;
    if (this!.login!.isEmpty && this!.apiKey!.isEmpty) return false;

    return true;
  }
}

extension BooruConfigX on BooruConfig {
  Booru? createBooruFrom(BooruFactory factory) =>
      factory.create(type: intToBooruType(booruId));

  BooruType get booruType => intToBooruType(booruIdHint);

  bool isUnverified() => booruId != booruIdHint;

  bool isDefault() => id == -1;

  bool get hasStrictSFW => url == kDanbooruSafeUrl && isIOS();
}
