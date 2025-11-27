// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../boorus/booru/types.dart';
import '../../../../home/types.dart';
import '../../../../http/configs/types.dart';
import '../../../../posts/details_manager/types.dart';
import '../../../../posts/details_parts/types.dart';
import '../../../../posts/listing/types.dart';
import '../../../../posts/rating/types.dart';
import '../../../../proxy/types.dart';
import '../../../../settings/types.dart';
import '../../../../themes/configs/types.dart';
import '../../../gesture/types.dart';
import '../../../search/types.dart';
import 'always_included_tags.dart';
import 'booru_config_repository.dart';
import 'granular_rating_filter.dart';
import 'types.dart';

export 'always_included_tags.dart';
export 'booru_login_details.dart';
export 'booru_login_details_impl.dart';
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
    required this.videoQuality,
    required this.granularRatingFilters,
    required this.postGestures,
    required this.defaultPreviewImageButtonAction,
    required this.listing,
    required this.viewerConfigs,
    required this.theme,
    required this.alwaysIncludeTags,
    required this.blacklistConfigs,
    required this.layout,
    required this.proxySettings,
    required this.viewerNotesFetchBehavior,
    required this.tooltipDisplayMode,
    this.networkSettings,
  });

  factory BooruConfig.fromJson(Map<String, dynamic> json) {
    return BooruConfig(
      id: json['id'] as int,
      booruId: json['booruId'] as int,
      booruIdHint: json['booruIdHint'] as int,
      apiKey: json['apiKey'] as String?,
      login: json['login'] as String?,
      passHash: json['passHash'] as String?,
      url: json['url'] as String,
      name: json['name'] as String,
      deletedItemBehavior: BooruConfigDeletedItemBehavior.parse(
        json['deletedItemBehavior'],
      ),
      ratingFilter: BooruConfigRatingFilter.parse(json['ratingFilter']),
      bannedPostVisibility: BooruConfigBannedPostVisibility.parse(
        json['bannedPostVisibility'],
      ),
      customDownloadFileNameFormat:
          json['customDownloadFileNameFormat'] as String?,
      customBulkDownloadFileNameFormat:
          json['customBulkDownloadFileNameFormat'] as String?,
      customDownloadLocation: json['customDownloadLocation'] as String?,
      imageDetaisQuality: json['imageDetaisQuality'] as String?,
      videoQuality: json['videoQuality'] as String?,
      granularRatingFilters: GranularRatingFilter.parse(
        json['granularRatingFilterString'],
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
      viewerConfigs: json['viewer'] == null
          ? null
          : ViewerConfigs.fromJson(json['viewer'] as Map<String, dynamic>),
      theme: json['theme'] == null
          ? null
          : ThemeConfigs.fromJson(json['theme'] as Map<String, dynamic>),
      alwaysIncludeTags: AlwaysIncludedTags.parse(json['alwaysIncludeTags']),
      blacklistConfigs: BlacklistConfigs.tryParse(
        json['blacklistedConfigs'] ?? json['blacklistedTags'],
      ),
      layout: json['layout'] == null
          ? null
          : LayoutConfigs.fromJson(json['layout'] as Map<String, dynamic>),
      proxySettings: json['proxySettings'] == null
          ? null
          : ProxySettings.fromJson(
              json['proxySettings'] as Map<String, dynamic>,
            ),
      viewerNotesFetchBehavior: BooruConfigViewerNotesFetchBehavior.tryParse(
        json['viewerNotesFetchBehavior'],
      ),
      tooltipDisplayMode: TooltipDisplayMode.tryParse(
        json['tooltipDisplayMode'],
      ),
      networkSettings: NetworkSettings.tryParse(json['network']),
    );
  }

  static const empty = BooruConfig(
    id: -2,
    booruId: -1,
    booruIdHint: -1,
    apiKey: null,
    login: null,
    passHash: null,
    name: '',
    deletedItemBehavior: BooruConfigDeletedItemBehavior.defaultValue,
    ratingFilter: BooruConfigRatingFilter.defaultValue,
    bannedPostVisibility: BooruConfigBannedPostVisibility.show,
    url: '',
    customDownloadFileNameFormat: null,
    customBulkDownloadFileNameFormat: null,
    customDownloadLocation: null,
    imageDetaisQuality: null,
    videoQuality: null,
    granularRatingFilters: null,
    postGestures: null,
    defaultPreviewImageButtonAction: null,
    listing: null,
    viewerConfigs: null,
    theme: null,
    alwaysIncludeTags: null,
    blacklistConfigs: null,
    layout: null,
    proxySettings: null,
    viewerNotesFetchBehavior: null,
    tooltipDisplayMode: null,
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
    deletedItemBehavior: BooruConfigDeletedItemBehavior.defaultValue,
    ratingFilter: BooruConfigRatingFilter.defaultValue,
    bannedPostVisibility: BooruConfigBannedPostVisibility.defaultValue,
    url: url,
    customDownloadFileNameFormat: customDownloadFileNameFormat,
    customBulkDownloadFileNameFormat: customDownloadFileNameFormat,
    customDownloadLocation: null,
    imageDetaisQuality: null,
    videoQuality: null,
    granularRatingFilters: null,
    postGestures: null,
    defaultPreviewImageButtonAction: null,
    listing: null,
    viewerConfigs: null,
    theme: null,
    alwaysIncludeTags: null,
    blacklistConfigs: null,
    layout: null,
    proxySettings: null,
    viewerNotesFetchBehavior: null,
    tooltipDisplayMode: null,
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
  final String? videoQuality;
  final GranularRatingFilter? granularRatingFilters;
  final PostGestureConfig? postGestures;
  final String? defaultPreviewImageButtonAction;
  final ListingConfigs? listing;
  final ViewerConfigs? viewerConfigs;
  final ThemeConfigs? theme;
  final AlwaysIncludedTags? alwaysIncludeTags;
  final BlacklistConfigs? blacklistConfigs;
  final LayoutConfigs? layout;
  final ProxySettings? proxySettings;
  final BooruConfigViewerNotesFetchBehavior? viewerNotesFetchBehavior;
  final TooltipDisplayMode? tooltipDisplayMode;
  final NetworkSettings? networkSettings;

  BooruConfig copyWith({
    String? url,
    String? apiKey,
    String? login,
    String? name,
    int? booruIdHint,
    ViewerConfigs? Function()? viewerConfigs,
    LayoutConfigs? Function()? layout,
    TooltipDisplayMode? tooltipDisplayMode,
    NetworkSettings? Function()? networkSettings,
  }) {
    return BooruConfig(
      id: id,
      booruId: booruId,
      booruIdHint: booruIdHint ?? this.booruIdHint,
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
      videoQuality: videoQuality,
      granularRatingFilters: granularRatingFilters,
      postGestures: postGestures,
      defaultPreviewImageButtonAction: defaultPreviewImageButtonAction,
      listing: listing,
      viewerConfigs: viewerConfigs != null
          ? viewerConfigs()
          : this.viewerConfigs,
      theme: theme,
      alwaysIncludeTags: alwaysIncludeTags,
      blacklistConfigs: blacklistConfigs,
      layout: layout != null ? layout() : this.layout,
      proxySettings: proxySettings,
      viewerNotesFetchBehavior: viewerNotesFetchBehavior,
      tooltipDisplayMode: tooltipDisplayMode ?? this.tooltipDisplayMode,
      networkSettings: networkSettings != null
          ? networkSettings()
          : this.networkSettings,
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
    videoQuality,
    granularRatingFilters,
    postGestures,
    defaultPreviewImageButtonAction,
    listing,
    viewerConfigs,
    theme,
    alwaysIncludeTags,
    blacklistConfigs,
    layout,
    proxySettings,
    viewerNotesFetchBehavior,
    tooltipDisplayMode,
    networkSettings,
  ];

  @override
  String toString() {
    return 'Config(id=$id, booruId=$booruIdHint, name=$name, url=$url)';
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
      'videoQuality': videoQuality,
      if (granularRatingFilters case final filter?)
        'granularRatingFilterString': filter.toFilterString(),
      'postGestures': postGestures?.toJson(),
      'defaultPreviewImageButtonAction': defaultPreviewImageButtonAction,
      'listing': listing?.toJson(),
      'viewer': viewerConfigs?.toJson(),
      'theme': theme?.toJson(),
      'alwaysIncludeTags': alwaysIncludeTags?.toJsonString(),
      'blacklistedTags': blacklistConfigs?.toJson(),
      'layout': layout?.toJson(),
      'proxySettings': proxySettings?.toJson(),
      'viewerNotesFetchBehavior': viewerNotesFetchBehavior?.index,
      'tooltipDisplayMode': ?tooltipDisplayMode?.toData(),
      'network': networkSettings?.toJson(),
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
    required this.networkSettings,
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
      networkSettings: config.networkSettings,
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
  final NetworkSettings? networkSettings;

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
    networkSettings,
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
  final GranularRatingFilter? granularRatingFilters;
  final AlwaysIncludedTags? alwaysIncludeTags;
  final BooruConfigDeletedItemBehavior deletedItemBehavior;
  @override
  final BooruConfigBannedPostVisibility bannedPostVisibility;

  final BlacklistConfigs? blacklistConfigs;

  String get ratingVerdict => switch (ratingFilter) {
    BooruConfigRatingFilter.none => 'unfiltered',
    BooruConfigRatingFilter.hideExplicit => 'questionable',
    BooruConfigRatingFilter.hideNSFW => 'sfw',
    BooruConfigRatingFilter.custom => switch (granularRatingFilters
        ?.withoutUnknown()) {
      final filter? => switch (filter.toFilterString(sort: true)) {
        final str when str.isNotEmpty => 'filtered($str)',
        _ => 'custom',
      },
      null => 'custom',
    },
  };

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
    required this.videoQuality,
    required this.viewerNotesFetchBehavior,
    required this.settings,
  });

  factory BooruConfigViewer.fromConfig(BooruConfig config) {
    return BooruConfigViewer(
      imageDetaisQuality: config.imageDetaisQuality,
      videoQuality: config.videoQuality,
      viewerNotesFetchBehavior: config.viewerNotesFetchBehavior,
      settings: (config.viewerConfigs?.enable ?? false)
          ? config.viewerConfigs?.settings
          : null,
    );
  }

  final String? imageDetaisQuality;
  final String? videoQuality;
  final BooruConfigViewerNotesFetchBehavior? viewerNotesFetchBehavior;
  final ImageViewerSettings? settings;

  bool get autoFetchNotes => viewerNotesFetchBehavior?.isAuto ?? false;

  @override
  List<Object?> get props => [
    imageDetaisQuality,
    videoQuality,
    viewerNotesFetchBehavior,
    settings,
  ];
}

class BooruConfigDownload extends Equatable {
  const BooruConfigDownload({
    required this.fileNameFormat,
    required this.bulkFileNameFormat,
    required this.location,
  });

  factory BooruConfigDownload.fromConfig(BooruConfig config) {
    return BooruConfigDownload(
      fileNameFormat: config.customDownloadFileNameFormat,
      bulkFileNameFormat: config.customBulkDownloadFileNameFormat,
      location: config.customDownloadLocation,
    );
  }

  final String? fileNameFormat;
  final String? bulkFileNameFormat;
  final String? location;

  @override
  List<Object?> get props => [
    fileNameFormat,
    bulkFileNameFormat,
    location,
  ];
}

class NetworkSettings extends Equatable {
  const NetworkSettings({
    this.httpSettings,
  });

  static NetworkSettings? tryParse(dynamic data) {
    final json = switch (data) {
      null || '' => null,
      final String str => _tryDecodeJson(str),
      final Map<String, dynamic> map => map,
      _ => null,
    };

    return switch (json) {
      final Map<String, dynamic> map => NetworkSettings(
        httpSettings: HttpSettings.tryParse(map['http']),
      ),
      _ => null,
    };
  }

  static Map<String, dynamic>? _tryDecodeJson(String str) {
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  final HttpSettings? httpSettings;

  NetworkSettings copyWith({
    HttpSettings? Function()? httpSettings,
  }) {
    return NetworkSettings(
      httpSettings: httpSettings != null ? httpSettings() : this.httpSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'http': httpSettings?.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [httpSettings];
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
}

mixin BooruConfigSearchFilterMixin {
  GranularRatingFilter? get granularRatingFilters;
  BooruConfigBannedPostVisibility get bannedPostVisibility;

  Set<Rating>? get granularRatingFiltersWithoutUnknown {
    return granularRatingFilters?.withoutUnknown().ratings;
  }
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
  BooruConfigDownload get download => BooruConfigDownload.fromConfig(this);
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
