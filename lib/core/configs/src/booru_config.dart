// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/settings.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/functional.dart';
import 'data/booru_config_data.dart';
import 'rating_parser.dart';
import 'types.dart';

class BooruConfig extends Equatable {
  const BooruConfig({
    required this.id,
    required this.booruId,
    required this.booruIdHint,
    required this.apiKey,
    required this.login,
    required this.passHash,
    required this.name,
    required this.ratingFilter,
    required this.deletedItemBehavior,
    required this.bannedPostVisibility,
    required this.url,
    required this.customDownloadFileNameFormat,
    required this.customBulkDownloadFileNameFormat,
    required this.customDownloadLocation,
    required this.imageDetaisQuality,
    required this.granularRatingFilters,
    required this.postGestures,
    required this.defaultPreviewImageButtonAction,
    required this.listing,
    required this.alwaysIncludeTags,
  });

  factory BooruConfig.fromJson(Map<String, dynamic> json) {
    final ratingFilter = json['ratingFilter'] as int?;
    final bannedPostVisibility = json['bannedPostVisibility'] as int?;

    return BooruConfig(
      id: json['id'] as int,
      booruId: json['booruId'] as int,
      booruIdHint: json['booruIdHint'] as int,
      apiKey: json['apiKey'] as String?,
      login: json['login'] as String?,
      passHash: json['passHash'] as String?,
      url: json['url'] as String,
      name: json['name'] as String,
      deletedItemBehavior: BooruConfigDeletedItemBehavior
          .values[json['deletedItemBehavior'] as int],
      ratingFilter: ratingFilter != null
          ? BooruConfigRatingFilter.values.getOrNull(ratingFilter) ??
              BooruConfigRatingFilter.hideNSFW
          : BooruConfigRatingFilter.hideNSFW,
      bannedPostVisibility: bannedPostVisibility != null
          ? BooruConfigBannedPostVisibility.values
                  .getOrNull(bannedPostVisibility) ??
              BooruConfigBannedPostVisibility.show
          : BooruConfigBannedPostVisibility.show,
      customDownloadFileNameFormat:
          json['customDownloadFileNameFormat'] as String?,
      customBulkDownloadFileNameFormat:
          json['customBulkDownloadFileNameFormat'] as String?,
      customDownloadLocation: json['customDownloadLocation'] as String?,
      imageDetaisQuality: json['imageDetaisQuality'] as String?,
      granularRatingFilters: parseGranularRatingFilters(
        json['granularRatingFilterString'] as String?,
      ),
      postGestures: json['postGestures'] == null
          ? null
          : PostGestureConfig.fromJson(
              json['postGestures'] as Map<String, dynamic>),
      defaultPreviewImageButtonAction:
          json['defaultPreviewImageButtonAction'] as String?,
      listing: json['listing'] == null
          ? null
          : ListingConfigs.fromJson(json['listing'] as Map<String, dynamic>),
      alwaysIncludeTags: json['alwaysIncludeTags'] as String?,
    );
  }

  static const BooruConfig empty = BooruConfig(
    id: -2,
    booruId: -1,
    booruIdHint: -1,
    apiKey: null,
    login: null,
    passHash: null,
    name: '',
    deletedItemBehavior: BooruConfigDeletedItemBehavior.show,
    ratingFilter: BooruConfigRatingFilter.none,
    bannedPostVisibility: BooruConfigBannedPostVisibility.show,
    url: '',
    customDownloadFileNameFormat: null,
    customBulkDownloadFileNameFormat: null,
    customDownloadLocation: null,
    imageDetaisQuality: null,
    granularRatingFilters: null,
    postGestures: null,
    defaultPreviewImageButtonAction: null,
    listing: null,
    alwaysIncludeTags: null,
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
        passHash: null,
        name: 'new profile',
        deletedItemBehavior: BooruConfigDeletedItemBehavior.show,
        ratingFilter: BooruConfigRatingFilter.none,
        bannedPostVisibility: BooruConfigBannedPostVisibility.show,
        url: url,
        customDownloadFileNameFormat: customDownloadFileNameFormat,
        customBulkDownloadFileNameFormat: customDownloadFileNameFormat,
        customDownloadLocation: null,
        imageDetaisQuality: null,
        granularRatingFilters: null,
        postGestures: null,
        defaultPreviewImageButtonAction: null,
        listing: null,
        alwaysIncludeTags: null,
      );

  final int id;
  final int booruId;
  final int booruIdHint;
  final String url;
  final String? apiKey;
  final String? login;
  final String? passHash;
  final String name;
  final BooruConfigDeletedItemBehavior deletedItemBehavior;
  final BooruConfigRatingFilter ratingFilter;
  final BooruConfigBannedPostVisibility bannedPostVisibility;
  final String? customDownloadFileNameFormat;
  final String? customBulkDownloadFileNameFormat;
  final String? customDownloadLocation;
  final String? imageDetaisQuality;
  final Set<Rating>? granularRatingFilters;
  final PostGestureConfig? postGestures;
  final String? defaultPreviewImageButtonAction;
  final ListingConfigs? listing;
  final String? alwaysIncludeTags;

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
      passHash: passHash,
      deletedItemBehavior: deletedItemBehavior,
      ratingFilter: ratingFilter,
      bannedPostVisibility: bannedPostVisibility,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
      customDownloadLocation: customDownloadLocation,
      imageDetaisQuality: imageDetaisQuality,
      granularRatingFilters: granularRatingFilters,
      postGestures: postGestures,
      defaultPreviewImageButtonAction: defaultPreviewImageButtonAction,
      listing: listing,
      alwaysIncludeTags: alwaysIncludeTags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        booruId,
        booruIdHint,
        apiKey,
        login,
        passHash,
        name,
        deletedItemBehavior,
        ratingFilter,
        bannedPostVisibility,
        url,
        customDownloadFileNameFormat,
        customBulkDownloadFileNameFormat,
        customDownloadLocation,
        imageDetaisQuality,
        granularRatingFilters,
        postGestures,
        defaultPreviewImageButtonAction,
        listing,
        alwaysIncludeTags,
      ];

  @override
  String toString() {
    return 'Config(id=$id, booruId=$booruIdHint, name=$name, url=$url, login=${auth.hasLoginDetails()})';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booruId': booruId,
      'booruIdHint': booruIdHint,
      'apiKey': apiKey,
      'login': login,
      'passHash': passHash,
      'url': url,
      'name': name,
      'deletedItemBehavior': deletedItemBehavior.index,
      'ratingFilter': ratingFilter.index,
      'bannedPostVisibility': bannedPostVisibility.index,
      'customDownloadFileNameFormat': customDownloadFileNameFormat,
      'customBulkDownloadFileNameFormat': customBulkDownloadFileNameFormat,
      'customDownloadLocation': customDownloadLocation,
      'imageDetaisQuality': imageDetaisQuality,
      'granularRatingFilterString': granularRatingFilterToString(
        granularRatingFilters,
      ),
      'postGestures': postGestures?.toJson(),
      'defaultPreviewImageButtonAction': defaultPreviewImageButtonAction,
      'listing': listing?.toJson(),
      'alwaysIncludeTags': alwaysIncludeTags,
    };
  }
}

class BooruConfigAuth extends Equatable with BooruConfigAuthMixin {
  const BooruConfigAuth({
    required this.booruId,
    required this.booruIdHint,
    required this.url,
    required this.apiKey,
    required this.login,
    required this.passHash,
  });

  factory BooruConfigAuth.fromConfig(BooruConfig config) {
    return BooruConfigAuth(
      booruId: config.booruId,
      booruIdHint: config.booruIdHint,
      url: config.url,
      apiKey: config.apiKey,
      login: config.login,
      passHash: config.passHash,
    );
  }

  @override
  final int booruId;
  @override
  final int booruIdHint;
  @override
  final String url;
  @override
  final String? apiKey;
  @override
  final String? login;
  final String? passHash;

  @override
  List<Object?> get props => [
        booruId,
        booruIdHint,
        url,
        apiKey,
        login,
        passHash,
      ];
}

class BooruConfigFilter extends Equatable with BooruConfigFilterMixin {
  const BooruConfigFilter({
    required this.ratingFilter,
    required this.granularRatingFilters,
    required this.alwaysIncludeTags,
    required this.deletedItemBehavior,
    required this.bannedPostVisibility,
  });

  factory BooruConfigFilter.fromConfig(BooruConfig config) {
    return BooruConfigFilter(
      ratingFilter: config.ratingFilter,
      granularRatingFilters: config.granularRatingFilters,
      alwaysIncludeTags: config.alwaysIncludeTags,
      deletedItemBehavior: config.deletedItemBehavior,
      bannedPostVisibility: config.bannedPostVisibility,
    );
  }

  final BooruConfigRatingFilter ratingFilter;
  @override
  final Set<Rating>? granularRatingFilters;
  final String? alwaysIncludeTags;
  final BooruConfigDeletedItemBehavior deletedItemBehavior;
  @override
  final BooruConfigBannedPostVisibility bannedPostVisibility;

  @override
  List<Object?> get props => [
        ratingFilter,
        granularRatingFilters,
        alwaysIncludeTags,
        deletedItemBehavior,
        bannedPostVisibility,
      ];
}

class BooruConfigSearch extends Equatable {
  const BooruConfigSearch({
    required this.filter,
    required this.auth,
  });

  factory BooruConfigSearch.fromConfig(BooruConfig config) {
    return BooruConfigSearch(
      filter: BooruConfigFilter.fromConfig(config),
      auth: BooruConfigAuth.fromConfig(config),
    );
  }

  final BooruConfigFilter filter;
  final BooruConfigAuth auth;

  BooruType get booruType => auth.booruType;

  @override
  List<Object?> get props => [filter, auth];
}

mixin BooruConfigAuthMixin {
  int? get booruIdHint;
  int get booruId;

  String? get login;
  String? get apiKey;
  String get url;

  BooruType get booruType => intToBooruType(booruIdHint);

  bool isUnverified() => booruId != booruIdHint;

  bool hasLoginDetails() {
    if (login == null || apiKey == null) return false;
    if (login!.isEmpty && apiKey!.isEmpty) return false;

    return true;
  }

  Booru? createBooruFrom(BooruFactory factory) =>
      factory.create(type: intToBooruType(booruId));

  bool get hasStrictSFW => url == kDanbooruSafeUrl && isIOS();
  bool get hasSoftSFW => url == kDanbooruSafeUrl;
}

mixin BooruConfigFilterMixin {
  Set<Rating>? get granularRatingFilters;
  BooruConfigBannedPostVisibility get bannedPostVisibility;

  Set<Rating>? get granularRatingFiltersWithoutUnknown {
    if (granularRatingFilters == null) return null;

    return granularRatingFilters!.where((e) => e != Rating.unknown).toSet();
  }

  bool get hideBannedPosts =>
      bannedPostVisibility == BooruConfigBannedPostVisibility.hide;
}

extension BooruConfigX on BooruConfig {
  bool isDefault() => id == -1;

  ImageQuickActionType get defaultPreviewImageButtonActionType =>
      switch (defaultPreviewImageButtonAction) {
        kDownloadAction => ImageQuickActionType.download,
        kToggleBookmarkAction => ImageQuickActionType.bookmark,
        kViewArtistAction => ImageQuickActionType.artist,
        '' => ImageQuickActionType.none,
        _ => ImageQuickActionType.defaultAction,
      };

  BooruConfigAuth get auth => BooruConfigAuth.fromConfig(this);
  BooruConfigFilter get filter => BooruConfigFilter.fromConfig(this);
  BooruConfigSearch get search => BooruConfigSearch.fromConfig(this);
}

enum ImageQuickActionType {
  none,
  defaultAction,
  download,
  bookmark,
  artist,
}

abstract class BooruConfigRepository {
  Future<BooruConfig?> add(BooruConfigData booruConfigData);
  Future<BooruConfig?> update(int id, BooruConfigData booruConfigData);
  Future<void> remove(BooruConfig booruConfig);
  Future<List<BooruConfig>> getAll();
  Future<void> clear();
  Future<List<BooruConfig>> addAll(List<BooruConfig> booruConfigs);
}

extension BooruConfigRepositoryX on BooruConfigRepository {
  Future<BooruConfig?> getCurrentBooruConfigFrom(Settings settings) async {
    final booruConfigs = await getAll();
    return booruConfigs
        .firstWhereOrNull((e) => e.id == settings.currentBooruConfigId);
  }
}
