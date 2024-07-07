// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';
import 'package:boorusama/functional.dart';

export 'types_l10n.dart';

enum ImageQuality {
  automatic,
  low,
  high,
  original,
  highest,
}

enum GridSize {
  small,
  normal,
  large,
}

enum ImageListType {
  standard,
  masonry,
}

enum DataCollectingStatus {
  allow,
  prohibit,
}

enum PageMode {
  infinite,
  paginated,
}

enum DownloadQuality {
  original,
  sample,
  preview,
}

enum AppLockType {
  none,
  biometrics,
  pin,
}

enum BookmarkFilterType {
  none,
  hideAll,
}

enum PageIndicatorPosition {
  bottom,
  top,
  both,
}

enum PostDetailsOverlayInitialState {
  hide,
  show,
}

enum BooruConfigSelectorPosition {
  side,
  bottom,
}

enum BooruConfigScrollDirection {
  normal,
  reversed,
}

enum BooruConfigLabelVisibility {
  always,
  never,
}

enum MediaBlurCondition {
  none,
  explicitOnly,
}

enum SlideshowTransitionType {
  none,
  natural,
}

enum DownloaderProviderType {
  appDecide,
  dio,
  backgroundDownloader,
}

enum DownloadFileExistedBehavior {
  appDecide,
  skip,
  overwrite,
}

enum VideoAudioDefaultState {
  unspecified,
  unmute,
  mute,
}

enum SlideshowDirection {
  forward,
  backward,
  random,
}

class Settings extends Equatable {
  const Settings({
    required this.listing,
    required this.safeMode,
    required this.blacklistedTags,
    required this.themeMode,
    required this.language,
    required this.dataCollectingStatus,
    required this.downloadPath,
    required this.imageQualityInFullView,
    required this.autoFocusSearchBar,
    required this.postsPerPage,
    required this.currentBooruConfigId,
    required this.booruConfigIdOrders,
    required this.downloadQuality,
    required this.enableIncognitoModeForKeyboard,
    required this.enableDynamicColoring,
    required this.clearImageCacheOnStartup,
    required this.appLockType,
    required this.bookmarkFilterType,
    required this.postDetailsOverlayInitialState,
    required this.booruConfigSelectorPosition,
    required this.booruConfigSelectorScrollDirection,
    required this.swipeAreaToOpenSidebarPercentage,
    required this.booruConfigLabelVisibility,
    required this.slideshowInterval,
    required this.slideshowTransitionType,
    required this.slideshowDirection,
    required this.reduceAnimations,
    required this.downloaderProviderType,
    required this.downloadFileExistedBehavior,
    required this.videoAudioDefaultState,
  });

  Settings.fromJson(Map<String, dynamic> json)
      : safeMode = json['safeMode'] ?? true,
        listing = ImageListingSettings.fromJson(json),
        blacklistedTags = json['hideBlacklist'] ?? [],
        themeMode = json['themeMode'] != null
            ? AppThemeMode.values[json['themeMode']]
            : AppThemeMode.amoledDark,
        dataCollectingStatus = json['dataCollectingStatus'] != null
            ? DataCollectingStatus.values[json['dataCollectingStatus']]
            : DataCollectingStatus.allow,
        language = json['language'] ?? 'en-US',
        downloadPath = json['downloadPath'],
        imageQualityInFullView = json['imageQualityInFullView'] != null
            ? ImageQuality.values[json['imageQualityInFullView']]
            : ImageQuality.automatic,
        downloadQuality = json['downloadQuality'] != null
            ? DownloadQuality.values[json['downloadQuality']]
            : DownloadQuality.original,
        autoFocusSearchBar = json['autoFocusSearchBar'] ?? true,
        postsPerPage = json['postsPerPage'] ?? 60,
        currentBooruConfigId = json['currentBooruConfigId'],
        booruConfigIdOrders = json['booruConfigIdOrders'] != null
            ? castOrFallback<String>(json['booruConfigIdOrders'], '')
            : '',
        enableIncognitoModeForKeyboard =
            json['enableIncognitoModeForKeyboard'] ?? false,
        enableDynamicColoring = json['enableDynamicColoring'] ?? false,
        clearImageCacheOnStartup = json['clearImageCacheOnStartup'] ?? false,
        appLockType = json['appLockType'] != null
            ? AppLockType.values[json['appLockType']]
            : AppLockType.none,
        bookmarkFilterType = json['bookmarkFilterType'] != null
            ? BookmarkFilterType.values[json['bookmarkFilterType']]
            : BookmarkFilterType.none,
        postDetailsOverlayInitialState =
            json['postDetailsOverlayInitialState'] != null
                ? PostDetailsOverlayInitialState
                    .values[json['postDetailsOverlayInitialState']]
                : PostDetailsOverlayInitialState.show,
        booruConfigSelectorPosition =
            json['booruConfigSelectorPosition'] != null
                ? BooruConfigSelectorPosition
                    .values[json['booruConfigSelectorPosition']]
                : BooruConfigSelectorPosition.side,
        booruConfigSelectorScrollDirection =
            json['booruConfigSelectorScrollDirection'] != null
                ? BooruConfigScrollDirection
                    .values[json['booruConfigSelectorScrollDirection']]
                : BooruConfigScrollDirection.normal,
        booruConfigLabelVisibility = json['booruConfigLabelVisibility'] != null
            ? BooruConfigLabelVisibility
                .values[json['booruConfigLabelVisibility']]
            : BooruConfigLabelVisibility.always,
        slideshowInterval = json['slideshowInterval'] ?? 6,
        slideshowTransitionType = json['slideshowTransitionType'] != null
            ? SlideshowTransitionType.values[json['slideshowTransitionType']]
            : SlideshowTransitionType.natural,
        slideshowDirection = json['slideshowDirection'] != null
            ? SlideshowDirection.values[json['slideshowDirection']]
            : SlideshowDirection.forward,
        downloaderProviderType = json['downloaderProviderType'] != null
            ? DownloaderProviderType.values[json['downloaderProviderType']]
            : DownloaderProviderType.appDecide,
        downloadFileExistedBehavior =
            json['downloadFileExistedBehavior'] != null
                ? DownloadFileExistedBehavior
                    .values[json['downloadFileExistedBehavior']]
                : DownloadFileExistedBehavior.appDecide,
        videoAudioDefaultState = json['videoAudioDefaultState'] != null
            ? VideoAudioDefaultState.values[json['videoAudioDefaultState']]
            : VideoAudioDefaultState.unspecified,
        reduceAnimations = json['reduceAnimations'] ?? false,
        swipeAreaToOpenSidebarPercentage =
            json['swipeAreaToOpenSidebarPercentage'] ?? 5;

  static const defaultSettings = Settings(
    listing: ImageListingSettings(
      gridSize: GridSize.normal,
      imageListType: ImageListType.masonry,
      imageQuality: ImageQuality.automatic,
      pageMode: PageMode.infinite,
      pageIndicatorPosition: PageIndicatorPosition.bottom,
      showScoresInGrid: false,
      showPostListConfigHeader: true,
      mediaBlurCondition: MediaBlurCondition.none,
      imageGridSpacing: 4,
      imageBorderRadius: 4,
      imageGridPadding: 16,
      imageGridAspectRatio: 0.7,
    ),
    safeMode: true,
    blacklistedTags: '',
    themeMode: AppThemeMode.amoledDark,
    language: 'en-US',
    dataCollectingStatus: DataCollectingStatus.allow,
    downloadPath: null,
    imageQualityInFullView: ImageQuality.automatic,
    autoFocusSearchBar: true,
    postsPerPage: 60,
    currentBooruConfigId: -1,
    booruConfigIdOrders: '',
    downloadQuality: DownloadQuality.original,
    enableIncognitoModeForKeyboard: false,
    enableDynamicColoring: false,
    clearImageCacheOnStartup: false,
    appLockType: AppLockType.none,
    bookmarkFilterType: BookmarkFilterType.none,
    postDetailsOverlayInitialState: PostDetailsOverlayInitialState.show,
    booruConfigSelectorPosition: BooruConfigSelectorPosition.side,
    booruConfigSelectorScrollDirection: BooruConfigScrollDirection.normal,
    swipeAreaToOpenSidebarPercentage: 5,
    booruConfigLabelVisibility: BooruConfigLabelVisibility.always,
    slideshowInterval: 6,
    slideshowTransitionType: SlideshowTransitionType.natural,
    slideshowDirection: SlideshowDirection.forward,
    reduceAnimations: false,
    downloaderProviderType: DownloaderProviderType.appDecide,
    downloadFileExistedBehavior: DownloadFileExistedBehavior.appDecide,
    videoAudioDefaultState: VideoAudioDefaultState.unspecified,
  );

  final ImageListingSettings listing;

  final String blacklistedTags;
  final String language;
  final bool safeMode;
  final AppThemeMode themeMode;
  final DataCollectingStatus dataCollectingStatus;

  final String? downloadPath;

  final ImageQuality imageQualityInFullView;

  final bool autoFocusSearchBar;

  final int postsPerPage;

  final int currentBooruConfigId;

  final String booruConfigIdOrders;

  final DownloadQuality downloadQuality;

  final bool enableIncognitoModeForKeyboard;

  final bool enableDynamicColoring;

  final bool clearImageCacheOnStartup;

  final AppLockType appLockType;

  final BookmarkFilterType bookmarkFilterType;

  final PostDetailsOverlayInitialState postDetailsOverlayInitialState;

  final BooruConfigSelectorPosition booruConfigSelectorPosition;

  final BooruConfigScrollDirection booruConfigSelectorScrollDirection;

  final int swipeAreaToOpenSidebarPercentage;

  final BooruConfigLabelVisibility booruConfigLabelVisibility;

  final double slideshowInterval;

  final SlideshowTransitionType slideshowTransitionType;

  final SlideshowDirection slideshowDirection;

  final bool reduceAnimations;

  final DownloaderProviderType downloaderProviderType;

  final DownloadFileExistedBehavior downloadFileExistedBehavior;

  final VideoAudioDefaultState videoAudioDefaultState;

  Settings copyWith({
    String? blacklistedTags,
    String? language,
    bool? safeMode,
    AppThemeMode? themeMode,
    DataCollectingStatus? dataCollectingStatus,
    String? downloadPath,
    ImageQuality? imageQualityInFullView,
    bool? autoFocusSearchBar,
    int? postsPerPage,
    int? currentBooruConfigId,
    String? booruConfigIdOrders,
    DownloadQuality? downloadQuality,
    bool? enableIncognitoModeForKeyboard,
    bool? enableDynamicColoring,
    bool? clearImageCacheOnStartup,
    AppLockType? appLockType,
    BookmarkFilterType? bookmarkFilterType,
    PostDetailsOverlayInitialState? postDetailsOverlayInitialState,
    PostGestureConfig? postGestures,
    BooruConfigSelectorPosition? booruConfigSelectorPosition,
    BooruConfigScrollDirection? booruConfigSelectorScrollDirection,
    int? swipeAreaToOpenSidebarPercentage,
    BooruConfigLabelVisibility? booruConfigLabelVisibility,
    double? slideshowInterval,
    SlideshowTransitionType? slideshowTransitionType,
    SlideshowDirection? slideshowDirection,
    bool? reduceAnimations,
    DownloaderProviderType? downloaderProviderType,
    DownloadFileExistedBehavior? downloadFileExistedBehavior,
    VideoAudioDefaultState? videoAudioDefaultState,
    ImageListingSettings? listing,
  }) =>
      Settings(
        listing: listing ?? this.listing,
        safeMode: safeMode ?? this.safeMode,
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        dataCollectingStatus: dataCollectingStatus ?? this.dataCollectingStatus,
        downloadPath: downloadPath ?? this.downloadPath,
        imageQualityInFullView:
            imageQualityInFullView ?? this.imageQualityInFullView,
        autoFocusSearchBar: autoFocusSearchBar ?? this.autoFocusSearchBar,
        postsPerPage: postsPerPage ?? this.postsPerPage,
        currentBooruConfigId: currentBooruConfigId ?? this.currentBooruConfigId,
        booruConfigIdOrders: booruConfigIdOrders ?? this.booruConfigIdOrders,
        downloadQuality: downloadQuality ?? this.downloadQuality,
        enableIncognitoModeForKeyboard: enableIncognitoModeForKeyboard ??
            this.enableIncognitoModeForKeyboard,
        enableDynamicColoring:
            enableDynamicColoring ?? this.enableDynamicColoring,
        clearImageCacheOnStartup:
            clearImageCacheOnStartup ?? this.clearImageCacheOnStartup,
        appLockType: appLockType ?? this.appLockType,
        bookmarkFilterType: bookmarkFilterType ?? this.bookmarkFilterType,
        postDetailsOverlayInitialState: postDetailsOverlayInitialState ??
            this.postDetailsOverlayInitialState,
        booruConfigSelectorPosition:
            booruConfigSelectorPosition ?? this.booruConfigSelectorPosition,
        booruConfigSelectorScrollDirection:
            booruConfigSelectorScrollDirection ??
                this.booruConfigSelectorScrollDirection,
        swipeAreaToOpenSidebarPercentage: swipeAreaToOpenSidebarPercentage ??
            this.swipeAreaToOpenSidebarPercentage,
        booruConfigLabelVisibility:
            booruConfigLabelVisibility ?? this.booruConfigLabelVisibility,
        slideshowInterval: slideshowInterval ?? this.slideshowInterval,
        slideshowTransitionType:
            slideshowTransitionType ?? this.slideshowTransitionType,
        slideshowDirection: slideshowDirection ?? this.slideshowDirection,
        reduceAnimations: reduceAnimations ?? this.reduceAnimations,
        downloaderProviderType:
            downloaderProviderType ?? this.downloaderProviderType,
        downloadFileExistedBehavior:
            downloadFileExistedBehavior ?? this.downloadFileExistedBehavior,
        videoAudioDefaultState:
            videoAudioDefaultState ?? this.videoAudioDefaultState,
      );

  Map<String, dynamic> toJson() {
    final listing = this.listing.toJson();

    return {
      ...listing,
      'safeMode': safeMode,
      'hideBlacklist': blacklistedTags,
      'themeMode': themeMode.index,
      'dataCollectingStatus': dataCollectingStatus.index,
      'language': language,
      'downloadPath': downloadPath,
      'imageQualityInFullView': imageQualityInFullView.index,
      'autoFocusSearchBar': autoFocusSearchBar,
      'postsPerPage': postsPerPage,
      'currentBooruConfigId': currentBooruConfigId,
      'booruConfigIdOrders': booruConfigIdOrders,
      'downloadQuality': downloadQuality.index,
      'enableIncognitoModeForKeyboard': enableIncognitoModeForKeyboard,
      'enableDynamicColoring': enableDynamicColoring,
      'clearImageCacheOnStartup': clearImageCacheOnStartup,
      'appLockType': appLockType.index,
      'bookmarkFilterType': bookmarkFilterType.index,
      'postDetailsOverlayInitialState': postDetailsOverlayInitialState.index,
      'booruConfigSelectorPosition': booruConfigSelectorPosition.index,
      'booruConfigSelectorScrollDirection':
          booruConfigSelectorScrollDirection.index,
      'swipeAreaToOpenSidebarPercentage': swipeAreaToOpenSidebarPercentage,
      'booruConfigLabelVisibility': booruConfigLabelVisibility.index,
      'slideshowInterval': slideshowInterval,
      'slideshowTransitionType': slideshowTransitionType.index,
      'slideshowDirection': slideshowDirection.index,
      'reduceAnimations': reduceAnimations,
      'downloaderProviderType': downloaderProviderType.index,
      'downloadFileExistedBehavior': downloadFileExistedBehavior.index,
      'videoAudioDefaultState': videoAudioDefaultState.index,
    };
  }

  @override
  List<Object?> get props => [
        listing,
        safeMode,
        blacklistedTags,
        themeMode,
        language,
        dataCollectingStatus,
        downloadPath,
        imageQualityInFullView,
        autoFocusSearchBar,
        postsPerPage,
        currentBooruConfigId,
        booruConfigIdOrders,
        downloadQuality,
        enableIncognitoModeForKeyboard,
        enableDynamicColoring,
        clearImageCacheOnStartup,
        appLockType,
        bookmarkFilterType,
        postDetailsOverlayInitialState,
        booruConfigSelectorPosition,
        booruConfigSelectorScrollDirection,
        swipeAreaToOpenSidebarPercentage,
        booruConfigLabelVisibility,
        slideshowInterval,
        slideshowTransitionType,
        slideshowDirection,
        reduceAnimations,
        downloaderProviderType,
        downloadFileExistedBehavior,
        videoAudioDefaultState,
      ];
}

class ListingConfigs extends Equatable {
  final ImageListingSettings settings;
  final bool enable;

  const ListingConfigs({
    required this.settings,
    required this.enable,
  });

  ListingConfigs.undefined()
      : settings = Settings.defaultSettings.listing,
        enable = false;

  factory ListingConfigs.fromJsonString(String? jsonString) =>
      switch (jsonString) {
        null => ListingConfigs.undefined(),
        String s => tryDecodeJson(s).fold(
            (_) => ListingConfigs.undefined(),
            (json) => ListingConfigs.fromJson(json),
          ),
      };

  ListingConfigs copyWith({
    ImageListingSettings? settings,
    bool? enable,
  }) {
    return ListingConfigs(
      settings: settings ?? this.settings,
      enable: enable ?? this.enable,
    );
  }

  @override
  List<Object> get props => [settings, enable];

  Map<String, dynamic> toJson() => {
        'settings': settings.toJson(),
        'enable': enable,
      };

  String toJsonString() => jsonEncode(toJson());

  factory ListingConfigs.fromJson(Map<String, dynamic> json) {
    return ListingConfigs(
      settings: ImageListingSettings.fromJson(json['settings']),
      enable: json['enable'],
    );
  }
}

class ImageListingSettings extends Equatable {
  final GridSize gridSize;
  final ImageListType imageListType;
  final ImageQuality imageQuality;
  final PageMode pageMode;
  final PageIndicatorPosition pageIndicatorPosition;
  final bool showScoresInGrid;
  final bool showPostListConfigHeader;
  final MediaBlurCondition mediaBlurCondition;
  final double imageGridSpacing;
  final double imageBorderRadius;
  final double imageGridPadding;
  final double imageGridAspectRatio;

  const ImageListingSettings({
    required this.gridSize,
    required this.imageListType,
    required this.imageQuality,
    required this.pageMode,
    required this.pageIndicatorPosition,
    required this.showScoresInGrid,
    required this.showPostListConfigHeader,
    required this.mediaBlurCondition,
    required this.imageGridSpacing,
    required this.imageBorderRadius,
    required this.imageGridPadding,
    required this.imageGridAspectRatio,
  });

  ImageListingSettings.fromJson(Map<String, dynamic> json)
      : gridSize = json['gridSize'] != null
            ? GridSize.values[json['gridSize']]
            : GridSize.normal,
        imageQuality = json['imageQuality'] != null
            ? ImageQuality.values[json['imageQuality']]
            : ImageQuality.automatic,
        imageListType = json['imageListType'] != null
            ? ImageListType.values[json['imageListType']]
            : ImageListType.masonry,
        pageMode = json['contentOrganizationCategory'] != null
            ? PageMode.values[json['contentOrganizationCategory']]
            : PageMode.infinite,
        showScoresInGrid = json['showScoresInGrid'] ?? false,
        showPostListConfigHeader = json['showPostListConfigHeader'] ?? true,
        imageBorderRadius = json['imageBorderRadius'],
        pageIndicatorPosition = json['pageIndicatorPosition'] != null
            ? PageIndicatorPosition.values[json['pageIndicatorPosition']]
            : PageIndicatorPosition.bottom,
        mediaBlurCondition = json['mediaBlurCondition'] != null
            ? MediaBlurCondition.values[json['mediaBlurCondition']]
            : MediaBlurCondition.none,
        imageGridAspectRatio = json['imageGridAspectRatio'] ?? 0.7,
        imageGridPadding = json['imageGridPadding'] ?? 16,
        imageGridSpacing = json['imageGridSpacing'] ?? 4;

  //TODO: duplicate code
  bool get blurExplicitMedia =>
      mediaBlurCondition == MediaBlurCondition.explicitOnly;

  ImageListingSettings copyWith({
    GridSize? gridSize,
    ImageListType? imageListType,
    ImageQuality? imageQuality,
    PageMode? pageMode,
    PageIndicatorPosition? pageIndicatorPosition,
    bool? showScoresInGrid,
    bool? showPostListConfigHeader,
    MediaBlurCondition? mediaBlurCondition,
    bool? enableDynamicColoring,
    AppThemeMode? themeMode,
    double? imageGridSpacing,
    double? imageBorderRadius,
    double? imageGridPadding,
    double? imageGridAspectRatio,
  }) {
    return ImageListingSettings(
      gridSize: gridSize ?? this.gridSize,
      imageListType: imageListType ?? this.imageListType,
      imageQuality: imageQuality ?? this.imageQuality,
      pageMode: pageMode ?? this.pageMode,
      pageIndicatorPosition:
          pageIndicatorPosition ?? this.pageIndicatorPosition,
      showScoresInGrid: showScoresInGrid ?? this.showScoresInGrid,
      showPostListConfigHeader:
          showPostListConfigHeader ?? this.showPostListConfigHeader,
      mediaBlurCondition: mediaBlurCondition ?? this.mediaBlurCondition,
      imageGridSpacing: imageGridSpacing ?? this.imageGridSpacing,
      imageBorderRadius: imageBorderRadius ?? this.imageBorderRadius,
      imageGridPadding: imageGridPadding ?? this.imageGridPadding,
      imageGridAspectRatio: imageGridAspectRatio ?? this.imageGridAspectRatio,
    );
  }

  Map<String, dynamic> toJson() => {
        'gridSize': gridSize.index,
        'imageListType': imageListType.index,
        'imageQuality': imageQuality.index,
        'pageMode': pageMode.index,
        'pageIndicatorPosition': pageIndicatorPosition.index,
        'showScoresInGrid': showScoresInGrid,
        'showPostListConfigHeader': showPostListConfigHeader,
        'mediaBlurCondition': mediaBlurCondition.index,
        'imageGridSpacing': imageGridSpacing,
        'imageBorderRadius': imageBorderRadius,
        'imageGridPadding': imageGridPadding,
        'imageGridAspectRatio': imageGridAspectRatio,
      };

  @override
  List<Object> get props => [
        gridSize,
        imageListType,
        imageQuality,
        pageMode,
        pageIndicatorPosition,
        showScoresInGrid,
        showPostListConfigHeader,
        mediaBlurCondition,
        imageGridSpacing,
        imageBorderRadius,
        imageGridPadding,
        imageGridAspectRatio,
      ];
}

extension SettingsX on Settings {
  bool get appLockEnabled => appLockType == AppLockType.biometrics;
  bool get shouldFilterBookmarks =>
      bookmarkFilterType != BookmarkFilterType.none;

  bool get hidePostDetailsOverlay =>
      postDetailsOverlayInitialState == PostDetailsOverlayInitialState.hide;

  bool get hideBooruConfigLabel =>
      booruConfigLabelVisibility == BooruConfigLabelVisibility.never;

  bool get reverseBooruConfigSelectorScrollDirection =>
      booruConfigSelectorScrollDirection == BooruConfigScrollDirection.reversed;

  bool get skipSlideshowTransition =>
      slideshowTransitionType == SlideshowTransitionType.none;

  bool get useLegacyDownloader =>
      downloaderProviderType == DownloaderProviderType.dio;

  bool get skipDownloadIfExists =>
      downloadFileExistedBehavior == DownloadFileExistedBehavior.skip;

  bool get muteAudioByDefault =>
      videoAudioDefaultState == VideoAudioDefaultState.mute;

  Duration get slideshowDuration {
    // if less than 1 second, should use milliseconds instead
    return slideshowInterval < 1
        ? Duration(milliseconds: (slideshowInterval * 1000).toInt())
        : Duration(seconds: slideshowInterval.toInt());
  }

  List<int> get booruConfigIdOrderList {
    try {
      if (booruConfigIdOrders.isEmpty) return [];

      return booruConfigIdOrders.split(' ').map(int.parse).toList();
    } catch (e) {
      return [];
    }
  }
}

extension ImageQualityX on ImageQuality {
  bool get isHighres => switch (this) {
        ImageQuality.high => true,
        ImageQuality.highest => true,
        _ => false
      };
}

extension PageIndicatorPositionX on PageIndicatorPosition {
  bool get isVisibleAtBottom =>
      this == PageIndicatorPosition.bottom ||
      this == PageIndicatorPosition.both;
  bool get isVisibleAtTop =>
      this == PageIndicatorPosition.top || this == PageIndicatorPosition.both;
}

extension SettingsUpdateX on WidgetRef {
  Future<void> updateDownloaderStatus(Settings settings, bool legacy) {
    return updateSettings(settings.copyWith(
      downloaderProviderType: legacy
          ? DownloaderProviderType.dio
          : DownloaderProviderType.appDecide,
    ));
  }

  Future<void> updateDownloadFileExistedBehavior(
    Settings settings,
    bool skipIfExists,
  ) {
    return updateSettings(settings.copyWith(
      downloadFileExistedBehavior: skipIfExists
          ? DownloadFileExistedBehavior.skip
          : DownloadFileExistedBehavior.appDecide,
    ));
  }
}
