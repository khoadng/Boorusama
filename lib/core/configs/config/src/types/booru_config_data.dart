// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../../foundation/utils/int_utils.dart';
import '../../../../boorus/booru/booru.dart';
import '../../../../posts/rating/rating.dart';
import '../../../../proxy/proxy.dart';
import '../../../../settings/settings.dart';
import '../../../../theme/theme_configs.dart';
import '../../../gesture/gesture.dart';
import '../../../search/search.dart';
import 'booru_config.dart';
import 'rating_parser.dart';

class BooruConfigData extends Equatable {
  const BooruConfigData({
    required this.booruId,
    required this.booruIdHint,
    required this.apiKey,
    required this.login,
    required this.passHash,
    required this.name,
    required this.deletedItemBehavior,
    required this.ratingFilter,
    required this.bannedPostVisibility,
    required this.url,
    required this.customDownloadFileNameFormat,
    required this.customBulkDownloadFileNameFormat,
    required this.customDownloadLocation,
    required this.imageDetaisQuality,
    required this.granularRatingFilterString,
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

  factory BooruConfigData.anonymous({
    required BooruType booru,
    required BooruType booruHint,
    required String name,
    required BooruConfigRatingFilter filter,
    required String url,
    required String? customDownloadFileNameFormat,
    required String? customBulkDownloadFileNameFormat,
    required String? imageDetaisQuality,
  }) => BooruConfigData(
    booruId: booru.id,
    booruIdHint: booruHint.id,
    apiKey: '',
    login: '',
    passHash: null,
    url: url,
    name: name,
    deletedItemBehavior: BooruConfigDeletedItemBehavior.show.index,
    ratingFilter: filter.index,
    bannedPostVisibility: BooruConfigBannedPostVisibility.show.index,
    customDownloadFileNameFormat: customDownloadFileNameFormat,
    customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
    customDownloadLocation: null,
    imageDetaisQuality: imageDetaisQuality,
    granularRatingFilterString: null,
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

  static BooruConfigData? fromJson(Map<String, dynamic> json) {
    try {
      return BooruConfigData(
        booruId: json['booruId'] as int,
        booruIdHint: json['booruIdHint'] as int?,
        apiKey: json['apiKey'] as String,
        login: json['login'] as String,
        passHash: json['passHash'] as String?,
        url: json['url'] as String,
        name: json['name'] as String,
        deletedItemBehavior: parseIntSafe(json['deletedItemBehavior']),
        ratingFilter: parseIntSafe(json['ratingFilter']),
        bannedPostVisibility: parseIntSafe(json['bannedPostVisibility']),
        customDownloadFileNameFormat:
            json['customDownloadFileNameFormat'] as String?,
        customBulkDownloadFileNameFormat:
            json['customBulkDownloadFileNameFormat'] as String?,
        customDownloadLocation: json['customDownloadLocation'] as String?,
        imageDetaisQuality: json['imageDetaisQuality'] as String?,
        granularRatingFilterString:
            json['granularRatingFilterString'] as String?,
        postGestures: json['postGestures'] as String?,
        defaultPreviewImageButtonAction:
            json['defaultPreviewImageButtonAction'] as String?,
        listing: json['listing'] as String?,
        theme: json['theme'] as String?,
        alwaysIncludeTags: json['alwaysIncludeTags'] as String?,
        blacklistConfigs: json['blacklistConfigs'] as String?,
        layout: json['layout'] as String?,
        proxySettings: json['proxySettings'] as String?,
        viewerNotesFetchBehavior: json['viewerNotesFetchBehavior'] as int?,
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
      'passHash': passHash,
      'url': url,
      'name': name,
      'deletedItemBehavior': deletedItemBehavior,
      'ratingFilter': ratingFilter,
      'bannedPostVisibility': bannedPostVisibility,
      'customDownloadFileNameFormat': customDownloadFileNameFormat,
      'customBulkDownloadFileNameFormat': customBulkDownloadFileNameFormat,
      'customDownloadLocation': customDownloadLocation,
      'imageDetaisQuality': imageDetaisQuality,
      'granularRatingFilterString': granularRatingFilterString,
      'postGestures': postGestures,
      'defaultPreviewImageButtonAction': defaultPreviewImageButtonAction,
      'listing': listing,
      'theme': theme,
      'alwaysIncludeTags': alwaysIncludeTags,
      'blacklistConfigs': blacklistConfigs,
      'layout': layout,
      'proxySettings': proxySettings,
      'viewerNotesFetchBehavior': viewerNotesFetchBehavior,
    };
  }

  final int booruId;
  final int? booruIdHint;
  final String apiKey;
  final String login;
  final String? passHash;
  final String name;
  final int deletedItemBehavior;
  final int ratingFilter;
  final int bannedPostVisibility;
  final String url;
  final String? customDownloadFileNameFormat;
  final String? customBulkDownloadFileNameFormat;
  final String? customDownloadLocation;
  final String? imageDetaisQuality;
  final String? granularRatingFilterString;
  final String? postGestures;
  final String? defaultPreviewImageButtonAction;
  final String? listing;
  final String? theme;
  final String? alwaysIncludeTags;
  final String? blacklistConfigs;
  final String? layout;
  final String? proxySettings;
  final int? viewerNotesFetchBehavior;

  @override
  List<Object?> get props => [
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
    granularRatingFilterString,
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
}

extension BooruConfigDataX on BooruConfigData {
  PostGestureConfig? get postGesturesConfigTyped {
    return PostGestureConfig.fromJsonString(postGestures);
  }

  ListingConfigs? get listingTyped {
    return ListingConfigs.fromJsonString(listing);
  }

  LayoutConfigs? get layoutTyped {
    return LayoutConfigs.fromJsonString(layout);
  }

  ThemeConfigs? get themeTyped {
    return ThemeConfigs.fromJsonString(theme);
  }

  BlacklistConfigs? get blacklistConfigsTyped {
    return BlacklistConfigs.fromJsonString(blacklistConfigs);
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

  BooruConfigBannedPostVisibility? get bannedPostVisibilityTyped {
    if (bannedPostVisibility < 0 ||
        bannedPostVisibility >= BooruConfigBannedPostVisibility.values.length) {
      return null;
    }

    return BooruConfigBannedPostVisibility.values[bannedPostVisibility];
  }

  BooruConfigDeletedItemBehavior get deletedItemBehaviorTyped {
    if (deletedItemBehavior < 0 ||
        deletedItemBehavior >= BooruConfigDeletedItemBehavior.values.length) {
      return BooruConfigDeletedItemBehavior.show;
    }

    return BooruConfigDeletedItemBehavior.values[deletedItemBehavior];
  }

  ProxySettings? get proxySettingsTyped {
    return ProxySettings.fromJsonString(proxySettings);
  }

  BooruConfigViewerNotesFetchBehavior? get viewerNotesFetchBehaviorTyped {
    final behavior = viewerNotesFetchBehavior;

    if (behavior == null ||
        behavior < 0 ||
        behavior >= BooruConfigViewerNotesFetchBehavior.values.length) {
      return null;
    }

    return BooruConfigViewerNotesFetchBehavior.values[behavior];
  }
}

extension BooruConfigDataCopyWith on BooruConfigData {
  BooruConfigData copyWith({
    int? booruId,
    int? Function()? booruIdHint,
    String? apiKey,
    String? login,
    String? Function()? passHash,
    String? name,
    BooruConfigDeletedItemBehavior? deletedItemBehavior,
    BooruConfigRatingFilter? ratingFilter,
    BooruConfigBannedPostVisibility? bannedPostVisibility,
    String? url,
    String? Function()? customDownloadFileNameFormat,
    String? Function()? customBulkDownloadFileNameFormat,
    String? Function()? customDownloadLocation,
    String? Function()? imageDetaisQuality,
    Set<Rating>? Function()? granularRatingFilter,
    PostGestureConfig? Function()? postGestures,
    String? Function()? defaultPreviewImageButtonAction,
    ListingConfigs? Function()? listing,
    ThemeConfigs? Function()? theme,
    String? Function()? alwaysIncludeTags,
    BlacklistConfigs? Function()? blacklistConfigs,
    LayoutConfigs? Function()? layout,
    ProxySettings? Function()? proxySettings,
    BooruConfigViewerNotesFetchBehavior? Function()? viewerNotesFetchBehavior,
  }) {
    return BooruConfigData(
      booruId: booruId ?? this.booruId,
      booruIdHint: booruIdHint != null ? booruIdHint() : this.booruIdHint,
      apiKey: apiKey ?? this.apiKey,
      login: login ?? this.login,
      passHash: passHash != null ? passHash() : this.passHash,
      name: name ?? this.name,
      deletedItemBehavior: deletedItemBehavior != null
          ? deletedItemBehavior.index
          : this.deletedItemBehavior,
      ratingFilter: ratingFilter != null
          ? ratingFilter.index
          : this.ratingFilter,
      bannedPostVisibility: bannedPostVisibility != null
          ? bannedPostVisibility.index
          : this.bannedPostVisibility,
      url: url ?? this.url,
      customDownloadFileNameFormat: customDownloadFileNameFormat != null
          ? customDownloadFileNameFormat()
          : this.customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat != null
          ? customBulkDownloadFileNameFormat()
          : this.customBulkDownloadFileNameFormat,
      customDownloadLocation: customDownloadLocation != null
          ? customDownloadLocation()
          : this.customDownloadLocation,
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
      listing: listing != null ? listing()?.toJsonString() : this.listing,
      theme: theme != null ? theme()?.toJsonString() : this.theme,
      alwaysIncludeTags: alwaysIncludeTags != null
          ? alwaysIncludeTags()
          : this.alwaysIncludeTags,
      blacklistConfigs: blacklistConfigs != null
          ? blacklistConfigs()?.toJsonString()
          : this.blacklistConfigs,
      layout: layout != null ? layout()?.toJsonString() : this.layout,
      proxySettings: proxySettings != null
          ? proxySettings()?.toJsonString()
          : this.proxySettings,
      viewerNotesFetchBehavior: viewerNotesFetchBehavior != null
          ? viewerNotesFetchBehavior()?.index
          : this.viewerNotesFetchBehavior,
    );
  }
}
