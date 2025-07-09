// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../foundation/platform.dart';
import '../../../../boorus/booru/booru.dart';
import '../../../../home/custom_home.dart';
import '../../../../posts/details_manager/types.dart';
import '../../../../posts/rating/rating.dart';
import '../../../../proxy/proxy.dart';
import '../../../../settings/settings.dart';
import '../../../../theme/theme_configs.dart';
import '../../../constants.dart';
import '../../../gesture/gesture.dart';
import '../../../search/search.dart';
import 'booru_config_repository.dart';
import 'rating_parser.dart';
import 'types.dart';

export 'types.dart';

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
    required this.theme,
    required this.alwaysIncludeTags,
    required this.blacklistConfigs,
    required this.layout,
    required this.proxySettings,
    required this.viewerNotesFetchBehavior,
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
          ? BooruConfigBannedPostVisibility.values.getOrNull(
                  bannedPostVisibility,
                ) ??
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
              json['postGestures'] as Map<String, dynamic>,
            ),
      defaultPreviewImageButtonAction:
          json['defaultPreviewImageButtonAction'] as String?,
      listing: json['listing'] == null
          ? null
          : ListingConfigs.fromJson(json['listing'] as Map<String, dynamic>),
      theme: json['theme'] == null
          ? null
          : ThemeConfigs.fromJson(json['theme'] as Map<String, dynamic>),
      alwaysIncludeTags: json['alwaysIncludeTags'] as String?,
      blacklistConfigs: json['blacklistedConfigs'] != null
          ? BlacklistConfigs.fromJson(
              json['blacklistedConfigs'] as Map<String, dynamic>,
            )
          : null,
      layout: json['layout'] == null
          ? null
          : LayoutConfigs.fromJson(json['layout'] as Map<String, dynamic>),
      proxySettings: json['proxySettings'] == null
          ? null
          : ProxySettings.fromJson(
              json['proxySettings'] as Map<String, dynamic>,
            ),
      viewerNotesFetchBehavior: json['viewerNotesFetchBehavior'] == null
          ? null
          : BooruConfigViewerNotesFetchBehavior
                .values[json['viewerNotesFetchBehavior'] as int],
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
    theme: null,
    alwaysIncludeTags: null,
    blacklistConfigs: null,
    layout: null,
    proxySettings: null,
    viewerNotesFetchBehavior: null,
  );

  // ignore: prefer_constructors_over_static_methods
  static BooruConfig defaultConfig({
    required BooruType booruType,
    required String url,
    required String? customDownloadFileNameFormat,
  }) => BooruConfig(
    id: -1,
    booruId: booruType.id,
    booruIdHint: booruType.id,
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
    theme: null,
    alwaysIncludeTags: null,
    blacklistConfigs: null,
    layout: null,
    proxySettings: null,
    viewerNotesFetchBehavior: null,
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
  final ThemeConfigs? theme;
  final String? alwaysIncludeTags;
  final BlacklistConfigs? blacklistConfigs;
  final LayoutConfigs? layout;
  final ProxySettings? proxySettings;
  final BooruConfigViewerNotesFetchBehavior? viewerNotesFetchBehavior;

  BooruConfig copyWith({
    String? url,
    String? apiKey,
    String? login,
    String? name,
    LayoutConfigs? Function()? layout,
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
      theme: theme,
      alwaysIncludeTags: alwaysIncludeTags,
      blacklistConfigs: blacklistConfigs,
      layout: layout != null ? layout() : this.layout,
      proxySettings: proxySettings,
      viewerNotesFetchBehavior: viewerNotesFetchBehavior,
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
    theme,
    alwaysIncludeTags,
    blacklistConfigs,
    layout,
    proxySettings,
    viewerNotesFetchBehavior,
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
      'theme': theme?.toJson(),
      'alwaysIncludeTags': alwaysIncludeTags,
      'blacklistedTags': blacklistConfigs?.toJson(),
      'layout': layout?.toJson(),
      'proxySettings': proxySettings?.toJson(),
      'viewerNotesFetchBehavior': viewerNotesFetchBehavior?.index,
    };
  }
}

class BooruConfigAuth extends Equatable with BooruConfigAuthMixin {
  const BooruConfigAuth({
    required this.booruId,
    required this.booruIdHint,
    required this.url,
    required String? apiKey,
    required String? login,
    required String? passHash,
    required this.proxySettings,
  }) : _apiKey = apiKey,
       _login = login,
       _passHash = passHash;

  factory BooruConfigAuth.fromConfig(BooruConfig config) {
    return BooruConfigAuth(
      booruId: config.booruId,
      booruIdHint: config.booruIdHint,
      url: config.url,
      apiKey: config.apiKey,
      login: config.login,
      passHash: config.passHash,
      proxySettings: config.proxySettings,
    );
  }

  final String? _apiKey;
  final String? _login;
  final String? _passHash;

  @override
  final int booruId;
  @override
  final int booruIdHint;
  @override
  final String url;
  @override
  String? get apiKey => _emptyAsNull(_apiKey);
  @override
  String? get login => _emptyAsNull(_login);
  String? get passHash => _emptyAsNull(_passHash);

  @override
  final ProxySettings? proxySettings;

  String? _emptyAsNull(String? value) {
    if (value == null) return null;
    if (value.isEmpty) return null;

    return value;
  }

  String computeHash() {
    final key = '$booruId$booruIdHint$url$apiKey$login$passHash';

    final bytes = utf8.encode(key);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  @override
  List<Object?> get props => [
    booruId,
    booruIdHint,
    url,
    apiKey,
    login,
    passHash,
    proxySettings,
  ];
}

class BooruConfigSearchFilter extends Equatable
    with BooruConfigSearchFilterMixin {
  const BooruConfigSearchFilter({
    required this.ratingFilter,
    required this.granularRatingFilters,
    required this.alwaysIncludeTags,
    required this.deletedItemBehavior,
    required this.bannedPostVisibility,
    required this.blacklistConfigs,
  });

  factory BooruConfigSearchFilter.fromConfig(BooruConfig config) {
    return BooruConfigSearchFilter(
      ratingFilter: config.ratingFilter,
      granularRatingFilters: config.granularRatingFilters,
      alwaysIncludeTags: config.alwaysIncludeTags,
      deletedItemBehavior: config.deletedItemBehavior,
      bannedPostVisibility: config.bannedPostVisibility,
      blacklistConfigs: config.blacklistConfigs,
    );
  }

  final BooruConfigRatingFilter ratingFilter;
  @override
  final Set<Rating>? granularRatingFilters;
  final String? alwaysIncludeTags;
  final BooruConfigDeletedItemBehavior deletedItemBehavior;
  @override
  final BooruConfigBannedPostVisibility bannedPostVisibility;

  final BlacklistConfigs? blacklistConfigs;

  String get ratingVerdict => switch (ratingFilter) {
    BooruConfigRatingFilter.none => 'unfiltered',
    BooruConfigRatingFilter.hideExplicit => 'questionable',
    BooruConfigRatingFilter.hideNSFW => 'sfw',
    BooruConfigRatingFilter.custom => () {
      final filters = granularRatingFiltersWithoutUnknown;

      if (filters == null) return 'custom';

      final str = granularRatingFilterToString(filters, sort: true);

      if (str == null) return 'custom';

      return 'filtered($str)';
    }(),
  };

  bool canView(String rating) {
    final parsedRating = mapStringToRating(rating);

    if (ratingFilter == BooruConfigRatingFilter.none) return true;

    if (ratingFilter == BooruConfigRatingFilter.custom) {
      final granularRatingFilters = granularRatingFiltersWithoutUnknown;

      if (granularRatingFilters == null) return false;

      return granularRatingFilters.contains(parsedRating);
    }

    if (ratingFilter == BooruConfigRatingFilter.hideExplicit &&
        parsedRating == Rating.explicit) {
      return false;
    }

    if (ratingFilter == BooruConfigRatingFilter.hideNSFW &&
        (parsedRating == Rating.explicit ||
            parsedRating == Rating.questionable)) {
      return false;
    }

    return true;
  }

  @override
  List<Object?> get props => [
    ratingFilter,
    granularRatingFilters,
    alwaysIncludeTags,
    deletedItemBehavior,
    bannedPostVisibility,
    blacklistConfigs,
  ];
}

class BooruConfigSearch extends Equatable {
  const BooruConfigSearch({
    required this.filter,
    required this.auth,
  });

  factory BooruConfigSearch.fromConfig(BooruConfig config) {
    return BooruConfigSearch(
      filter: BooruConfigSearchFilter.fromConfig(config),
      auth: BooruConfigAuth.fromConfig(config),
    );
  }

  final BooruConfigSearchFilter filter;
  final BooruConfigAuth auth;

  BooruType get booruType => auth.booruType;

  @override
  List<Object?> get props => [filter, auth];
}

class BooruConfigFilter extends Equatable {
  const BooruConfigFilter({
    required this.auth,
    required this.blacklistConfigs,
  });

  factory BooruConfigFilter.fromConfig(BooruConfig config) {
    return BooruConfigFilter(
      auth: BooruConfigAuth.fromConfig(config),
      blacklistConfigs: config.blacklistConfigs,
    );
  }

  final BooruConfigAuth auth;
  final BlacklistConfigs? blacklistConfigs;

  @override
  List<Object?> get props => [auth, blacklistConfigs];
}

class BooruConfigViewer extends Equatable {
  const BooruConfigViewer({
    required this.imageDetaisQuality,
    required this.viewerNotesFetchBehavior,
  });

  factory BooruConfigViewer.fromConfig(BooruConfig config) {
    return BooruConfigViewer(
      imageDetaisQuality: config.imageDetaisQuality,
      viewerNotesFetchBehavior: config.viewerNotesFetchBehavior,
    );
  }

  final String? imageDetaisQuality;
  final BooruConfigViewerNotesFetchBehavior? viewerNotesFetchBehavior;

  bool get autoFetchNotes =>
      viewerNotesFetchBehavior == BooruConfigViewerNotesFetchBehavior.auto;

  @override
  List<Object?> get props => [
    imageDetaisQuality,
    viewerNotesFetchBehavior,
  ];
}

mixin BooruConfigAuthMixin {
  int? get booruIdHint;
  int get booruId;

  String? get login;
  String? get apiKey;
  String get url;

  ProxySettings? get proxySettings;

  BooruType get booruType => intToBooruType(booruIdHint);

  bool isUnverified() => booruId != booruIdHint;

  bool hasLoginDetails() {
    if (login == null || apiKey == null) return false;
    if (login!.isEmpty && apiKey!.isEmpty) return false;

    return true;
  }

  bool get hasStrictSFW => url == kDanbooruSafeUrl && isIOS();
  bool get hasSoftSFW => url == kDanbooruSafeUrl;
}

mixin BooruConfigSearchFilterMixin {
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
  BooruConfigSearch get search => BooruConfigSearch.fromConfig(this);
  BooruConfigFilter get filter => BooruConfigFilter.fromConfig(this);
  BooruConfigViewer get viewer => BooruConfigViewer.fromConfig(this);
}

enum ImageQuickActionType {
  none,
  defaultAction,
  download,
  bookmark,
  artist,
}

class LayoutConfigs extends Equatable {
  const LayoutConfigs({
    required this.home,
    required this.details,
    required this.previewDetails,
  });
  factory LayoutConfigs.fromJson(Map<String, dynamic> json) {
    final home = json['home'] == null
        ? const CustomHomeViewKey.defaultValue()
        : CustomHomeViewKey.fromJson(json['home']);

    final details = json['details'] == null
        ? null
        : (json['details'] as List<dynamic>)
              .map((e) => CustomDetailsPartKey.fromJson(e))
              .toList();

    final previewDetails = json['previewDetails'] == null
        ? null
        : (json['previewDetails'] as List<dynamic>)
              .map((e) => CustomDetailsPartKey.fromJson(e))
              .toList();

    return LayoutConfigs(
      home: home,
      details: details,
      previewDetails: previewDetails,
    );
  }

  const LayoutConfigs.undefined()
    : home = const CustomHomeViewKey.defaultValue(),
      previewDetails = null,
      details = null;

  final CustomHomeViewKey? home;
  final List<CustomDetailsPartKey>? details;
  final List<CustomDetailsPartKey>? previewDetails;

  LayoutConfigs copyWith({
    CustomHomeViewKey? Function()? home,
    List<CustomDetailsPartKey>? Function()? details,
    List<CustomDetailsPartKey>? Function()? previewDetails,
  }) {
    return LayoutConfigs(
      home: home != null ? home() : this.home,
      details: details != null ? details() : this.details,
      previewDetails: previewDetails != null
          ? previewDetails()
          : this.previewDetails,
    );
  }

  static LayoutConfigs? fromJsonString(String? jsonString) {
    if (jsonString == null) return null;

    return LayoutConfigs.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() {
    return {
      'home': home?.toJson(),
      'details': details?.map((e) => e.toJson()).toList(),
      'previewDetails': previewDetails?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [home, details, previewDetails];
}

Set<DetailsPart>? getLayoutParsedParts({
  required List<CustomDetailsPartKey>? details,
  required bool hasPremium,
}) {
  if (!hasPremium) return null;
  if (details == null) return null;
  if (details.isEmpty) return null;

  final parts = <DetailsPart>{};

  for (final part in details) {
    final parsedPart = parseDetailsPart(part.name);

    if (parsedPart != null) {
      parts.add(parsedPart);
    }
  }

  return parts;
}

Set<DetailsPart>? getLayoutPreviewParsedParts({
  required List<CustomDetailsPartKey>? previewDetails,
  required bool hasPremium,
}) {
  if (!hasPremium) return null;

  if (previewDetails == null) return null;
  if (previewDetails.isEmpty) return null;

  final parts = <DetailsPart>{};

  for (final part in previewDetails) {
    final parsedPart = parseDetailsPart(part.name);

    if (parsedPart != null) {
      parts.add(parsedPart);
    }
  }

  return parts;
}

extension BooruConfigRepositoryX on BooruConfigRepository {
  Future<BooruConfig?> getCurrentBooruConfigFrom(Settings settings) async {
    final booruConfigs = await getAll();
    return booruConfigs.firstWhereOrNull(
      (e) => e.id == settings.currentBooruConfigId,
    );
  }
}
