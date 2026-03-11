// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../foundation/applock/types.dart';
import '../../../../foundation/caching/types.dart';
import '../../../analytics/types.dart';
import '../../../backups/auto/types.dart';
import '../../../configs/gesture/types.dart';
import '../../../downloads/downloader/types.dart';
import '../../../haptics/types.dart';
import '../../../home/types.dart';
import '../../../images/types.dart';
import '../../../posts/details/types.dart';
import '../../../posts/listing/types.dart';
import '../../../posts/post/types.dart';
import '../../../posts/slideshow/types.dart';
import '../../../search/search/types.dart';
import '../../../themes/configs/types.dart';
import '../../../themes/theme/types.dart';
import '../../../videos/engines/types.dart';
import '../../../videos/player/types.dart';

class Settings extends Equatable {
  const Settings({
    required this.listing,
    required this.viewer,
    required this.safeMode,
    required this.blacklistedTags,
    required this.themeMode,
    required this.language,
    required this.dataCollectingStatus,
    required this.downloadPath,
    required this.imageQualityInFullView,
    required this.autoFocusSearchBar,
    required this.currentBooruConfigId,
    required this.booruConfigIdOrders,
    required this.downloadQuality,
    required this.enableIncognitoModeForKeyboard,
    required this.enableDynamicColoring,
    required this.clearImageCacheOnStartup,
    required this.appLockType,
    required this.bookmarkFilterType,
    required this.booruConfigSelectorPosition,
    required this.booruConfigSelectorScrollDirection,
    required this.swipeAreaToOpenSidebarPercentage,
    required this.booruConfigLabelVisibility,
    required this.reduceAnimations,
    required this.downloadFileExistedBehavior,
    required this.colors,
    required this.volumeKeyViewerNavigation,
    required this.searchBarScrollBehavior,
    required this.searchBarPosition,
    required this.hapticFeedbackLevel,
    required this.autoBackup,
    required this.videoCacheMaxSize,
  });

  Settings.fromJson(Map<String, dynamic> json)
    : safeMode = json['safeMode'] ?? true,
      listing = ImageListingSettings.fromJson(json),
      viewer = ImageViewerSettings.fromJson(json),
      blacklistedTags = json['hideBlacklist'] ?? '',
      themeMode = AppThemeMode.parse(
        json['themeMode'],
      ),
      dataCollectingStatus = DataCollectingStatus.parse(
        json['dataCollectingStatus'],
      ),
      language = json['language'] ?? 'en-US',
      downloadPath = json['downloadPath'],
      imageQualityInFullView = ImageQuality.parse(
        json['imageQualityInFullView'],
      ),
      downloadQuality = DownloadQuality.parse(json['downloadQuality']),
      autoFocusSearchBar = json['autoFocusSearchBar'] ?? true,
      currentBooruConfigId = json['currentBooruConfigId'],
      booruConfigIdOrders = json['booruConfigIdOrders'] != null
          ? castOrFallback<String>(json['booruConfigIdOrders'], '')
          : '',
      enableIncognitoModeForKeyboard =
          json['enableIncognitoModeForKeyboard'] ?? false,
      enableDynamicColoring = json['enableDynamicColoring'] ?? false,
      clearImageCacheOnStartup = json['clearImageCacheOnStartup'] ?? false,
      appLockType = AppLockType.parse(json['appLockType']),
      bookmarkFilterType = BookmarkFilterType.parse(json['bookmarkFilterType']),
      booruConfigSelectorPosition = BooruConfigSelectorPosition.parse(
        json['booruConfigSelectorPosition'],
      ),
      booruConfigSelectorScrollDirection = BooruConfigScrollDirection.parse(
        json['booruConfigSelectorScrollDirection'],
      ),
      booruConfigLabelVisibility = BooruConfigLabelVisibility.parse(
        json['booruConfigLabelVisibility'],
      ),
      downloadFileExistedBehavior = DownloadFileExistedBehavior.parse(
        json['downloadFileExistedBehavior'],
      ),
      colors = json['colors'] != null
          ? ColorSettings.fromJson(json['colors'])
          : null,
      searchBarScrollBehavior = SearchBarScrollBehavior.parse(
        json['searchBarScrollBehavior'],
      ),
      searchBarPosition = SearchBarPosition.parse(
        json['searchBarPosition'],
      ),
      hapticFeedbackLevel = HapticFeedbackLevel.parse(
        json['hapticFeedbackLevel'],
      ),
      volumeKeyViewerNavigation = json['volumeKeyViewerNavigation'] ?? false,
      reduceAnimations = json['reduceAnimations'] ?? false,
      swipeAreaToOpenSidebarPercentage =
          json['swipeAreaToOpenSidebarPercentage'] ?? 5,
      autoBackup = AutoBackupSettings.parse(json['autoBackup']),
      videoCacheMaxSize = switch (json['videoCacheMaxSize']) {
        final v? => CacheSize.tryParse(v) ?? CacheSize.oneGigabyte,
        _ => CacheSize.oneGigabyte,
      };

  static const defaultSettings = Settings(
    listing: ImageListingSettings(
      gridSize: GridSize.defaultValue,
      imageListType: ImageListType.defaultValue,
      imageQuality: ImageQuality.defaultValue,
      pageMode: PageMode.defaultValue,
      pageIndicatorPosition: PageIndicatorPosition.defaultValue,
      showScoresInGrid: false,
      showPostListConfigHeader: true,
      mediaBlurCondition: MediaBlurCondition.defaultValue,
      imageGridSpacing: 4,
      imageBorderRadius: 4,
      imageGridPadding: 16,
      imageGridAspectRatio: 0.7,
      postsPerPage: 60,
      animatedPostsDefaultState: AnimatedPostsDefaultState.defaultValue,
    ),
    viewer: ImageViewerSettings(
      swipeMode: PostDetailsSwipeMode.defaultValue,
      postDetailsOverlayInitialState:
          PostDetailsOverlayInitialState.defaultValue,
      slideshowDirection: SlideshowDirection.defaultValue,
      slideshowInterval: 6,
      slideshowTransitionType: SlideshowTransitionType.defaultValue,
      slideshowVideoBehavior: SlideshowVideoBehavior.defaultValue,
      videoAudioDefaultState: VideoAudioDefaultState.defaultValue,
      videoPlayerEngine: VideoPlayerEngine.defaultValue,
      enableVideoCache: true,
      doubleTapSeekDuration: 5,
    ),
    colors: null,
    safeMode: true,
    blacklistedTags: '',
    themeMode: AppThemeMode.defaultValue,
    language: 'en-US',
    dataCollectingStatus: DataCollectingStatus.defaultValue,
    downloadPath: null,
    imageQualityInFullView: ImageQuality.defaultValue,
    autoFocusSearchBar: true,
    currentBooruConfigId: -1,
    booruConfigIdOrders: '',
    downloadQuality: DownloadQuality.defaultValue,
    enableIncognitoModeForKeyboard: false,
    enableDynamicColoring: false,
    clearImageCacheOnStartup: false,
    appLockType: AppLockType.defaultValue,
    bookmarkFilterType: BookmarkFilterType.defaultValue,
    booruConfigSelectorPosition: BooruConfigSelectorPosition.defaultValue,
    booruConfigSelectorScrollDirection: BooruConfigScrollDirection.defaultValue,
    swipeAreaToOpenSidebarPercentage: 5,
    booruConfigLabelVisibility: BooruConfigLabelVisibility.defaultValue,
    reduceAnimations: false,
    downloadFileExistedBehavior: DownloadFileExistedBehavior.defaultValue,
    volumeKeyViewerNavigation: false,
    searchBarScrollBehavior: SearchBarScrollBehavior.defaultValue,
    searchBarPosition: SearchBarPosition.defaultValue,
    hapticFeedbackLevel: HapticFeedbackLevel.defaultValue,
    autoBackup: AutoBackupSettings.defaultValue,
    videoCacheMaxSize: CacheSize.defaultValue,
  );

  final ImageListingSettings listing;

  final ImageViewerSettings viewer;

  final String blacklistedTags;
  final String language;
  final bool safeMode;
  final AppThemeMode themeMode;
  final DataCollectingStatus dataCollectingStatus;

  final String? downloadPath;

  final ImageQuality imageQualityInFullView;

  final bool autoFocusSearchBar;

  final int currentBooruConfigId;

  final String booruConfigIdOrders;

  final DownloadQuality downloadQuality;

  final bool enableIncognitoModeForKeyboard;

  final bool enableDynamicColoring;

  final bool clearImageCacheOnStartup;

  final AppLockType appLockType;

  final BookmarkFilterType bookmarkFilterType;

  final BooruConfigSelectorPosition booruConfigSelectorPosition;

  final BooruConfigScrollDirection booruConfigSelectorScrollDirection;

  final int swipeAreaToOpenSidebarPercentage;

  final BooruConfigLabelVisibility booruConfigLabelVisibility;

  final bool reduceAnimations;

  final DownloadFileExistedBehavior downloadFileExistedBehavior;

  final ColorSettings? colors;

  final bool volumeKeyViewerNavigation;

  final SearchBarScrollBehavior searchBarScrollBehavior;

  final SearchBarPosition searchBarPosition;

  final HapticFeedbackLevel hapticFeedbackLevel;

  final AutoBackupSettings autoBackup;

  final CacheSize videoCacheMaxSize;

  Settings copyWith({
    String? blacklistedTags,
    String? language,
    bool? safeMode,
    AppThemeMode? themeMode,
    DataCollectingStatus? dataCollectingStatus,
    String? downloadPath,
    ImageQuality? imageQualityInFullView,
    bool? autoFocusSearchBar,
    int? currentBooruConfigId,
    String? booruConfigIdOrders,
    DownloadQuality? downloadQuality,
    bool? enableIncognitoModeForKeyboard,
    bool? enableDynamicColoring,
    bool? clearImageCacheOnStartup,
    AppLockType? appLockType,
    BookmarkFilterType? bookmarkFilterType,
    PostGestureConfig? postGestures,
    BooruConfigSelectorPosition? booruConfigSelectorPosition,
    BooruConfigScrollDirection? booruConfigSelectorScrollDirection,
    int? swipeAreaToOpenSidebarPercentage,
    BooruConfigLabelVisibility? booruConfigLabelVisibility,
    bool? reduceAnimations,
    DownloadFileExistedBehavior? downloadFileExistedBehavior,
    ImageListingSettings? listing,
    ImageViewerSettings? viewer,
    ColorSettings? colors,
    bool? volumeKeyViewerNavigation,
    SearchBarScrollBehavior? searchBarScrollBehavior,
    SearchBarPosition? searchBarPosition,
    HapticFeedbackLevel? hapticFeedbackLevel,
    AutoBackupSettings? autoBackup,
    CacheSize? videoCacheMaxSize,
  }) => Settings(
    listing: listing ?? this.listing,
    viewer: viewer ?? this.viewer,
    safeMode: safeMode ?? this.safeMode,
    blacklistedTags: blacklistedTags ?? this.blacklistedTags,
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    dataCollectingStatus: dataCollectingStatus ?? this.dataCollectingStatus,
    downloadPath: downloadPath ?? this.downloadPath,
    imageQualityInFullView:
        imageQualityInFullView ?? this.imageQualityInFullView,
    autoFocusSearchBar: autoFocusSearchBar ?? this.autoFocusSearchBar,
    currentBooruConfigId: currentBooruConfigId ?? this.currentBooruConfigId,
    booruConfigIdOrders: booruConfigIdOrders ?? this.booruConfigIdOrders,
    downloadQuality: downloadQuality ?? this.downloadQuality,
    enableIncognitoModeForKeyboard:
        enableIncognitoModeForKeyboard ?? this.enableIncognitoModeForKeyboard,
    enableDynamicColoring: enableDynamicColoring ?? this.enableDynamicColoring,
    clearImageCacheOnStartup:
        clearImageCacheOnStartup ?? this.clearImageCacheOnStartup,
    appLockType: appLockType ?? this.appLockType,
    bookmarkFilterType: bookmarkFilterType ?? this.bookmarkFilterType,
    booruConfigSelectorPosition:
        booruConfigSelectorPosition ?? this.booruConfigSelectorPosition,
    booruConfigSelectorScrollDirection:
        booruConfigSelectorScrollDirection ??
        this.booruConfigSelectorScrollDirection,
    swipeAreaToOpenSidebarPercentage:
        swipeAreaToOpenSidebarPercentage ??
        this.swipeAreaToOpenSidebarPercentage,
    booruConfigLabelVisibility:
        booruConfigLabelVisibility ?? this.booruConfigLabelVisibility,
    reduceAnimations: reduceAnimations ?? this.reduceAnimations,
    downloadFileExistedBehavior:
        downloadFileExistedBehavior ?? this.downloadFileExistedBehavior,
    colors: colors ?? this.colors,
    volumeKeyViewerNavigation:
        volumeKeyViewerNavigation ?? this.volumeKeyViewerNavigation,
    searchBarScrollBehavior:
        searchBarScrollBehavior ?? this.searchBarScrollBehavior,
    searchBarPosition: searchBarPosition ?? this.searchBarPosition,
    hapticFeedbackLevel: hapticFeedbackLevel ?? this.hapticFeedbackLevel,
    autoBackup: autoBackup ?? this.autoBackup,
    videoCacheMaxSize: videoCacheMaxSize ?? this.videoCacheMaxSize,
  );

  Map<String, dynamic> toJson() {
    final listing = this.listing.toJson();
    final viewer = this.viewer.toJson();

    return {
      ...listing,
      ...viewer,
      'safeMode': safeMode,
      'hideBlacklist': blacklistedTags,
      'themeMode': themeMode.toData(),
      'dataCollectingStatus': dataCollectingStatus.toData(),
      'language': language,
      'downloadPath': downloadPath,
      'imageQualityInFullView': imageQualityInFullView.toData(),
      'autoFocusSearchBar': autoFocusSearchBar,
      'currentBooruConfigId': currentBooruConfigId,
      'booruConfigIdOrders': booruConfigIdOrders,
      'downloadQuality': downloadQuality.toData(),
      'enableIncognitoModeForKeyboard': enableIncognitoModeForKeyboard,
      'enableDynamicColoring': enableDynamicColoring,
      'clearImageCacheOnStartup': clearImageCacheOnStartup,
      'appLockType': appLockType.toData(),
      'bookmarkFilterType': bookmarkFilterType.toData(),
      'booruConfigSelectorPosition': booruConfigSelectorPosition.toData(),
      'booruConfigSelectorScrollDirection': booruConfigSelectorScrollDirection
          .toData(),
      'swipeAreaToOpenSidebarPercentage': swipeAreaToOpenSidebarPercentage,
      'booruConfigLabelVisibility': booruConfigLabelVisibility.toData(),
      'reduceAnimations': reduceAnimations,
      'downloadFileExistedBehavior': downloadFileExistedBehavior.toData(),
      'colors': colors?.toJson(),
      'volumeKeyViewerNavigation': volumeKeyViewerNavigation,
      'searchBarScrollBehavior': searchBarScrollBehavior.toData(),
      'searchBarPosition': searchBarPosition.toData(),
      'hapticFeedbackLevel': hapticFeedbackLevel.toData(),
      'autoBackup': autoBackup.toJson(),
      'videoCacheMaxSize': videoCacheMaxSize.displayString(),
    };
  }

  @override
  List<Object?> get props => [
    listing,
    viewer,
    safeMode,
    blacklistedTags,
    themeMode,
    language,
    dataCollectingStatus,
    downloadPath,
    imageQualityInFullView,
    autoFocusSearchBar,
    currentBooruConfigId,
    booruConfigIdOrders,
    downloadQuality,
    enableIncognitoModeForKeyboard,
    enableDynamicColoring,
    clearImageCacheOnStartup,
    appLockType,
    bookmarkFilterType,
    booruConfigSelectorPosition,
    booruConfigSelectorScrollDirection,
    swipeAreaToOpenSidebarPercentage,
    booruConfigLabelVisibility,
    reduceAnimations,
    downloadFileExistedBehavior,
    colors,
    volumeKeyViewerNavigation,
    searchBarScrollBehavior,
    searchBarPosition,
    hapticFeedbackLevel,
    autoBackup,
    videoCacheMaxSize,
  ];

  List<int> get booruConfigIdOrderList {
    try {
      if (booruConfigIdOrders.isEmpty) return [];

      return booruConfigIdOrders.split(' ').map(int.parse).toList();
    } catch (e) {
      return [];
    }
  }
}

class ListingConfigs extends Equatable {
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
        final String s => tryDecodeJson(s).fold(
          (_) => ListingConfigs.undefined(),
          (json) => ListingConfigs.fromJson(json),
        ),
      };

  factory ListingConfigs.fromJson(Map<String, dynamic> json) {
    return ListingConfigs(
      settings: ImageListingSettings.fromJson(json['settings']),
      enable: json['enable'],
    );
  }
  final ImageListingSettings settings;
  final bool enable;

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
}

class ViewerConfigs extends Equatable {
  const ViewerConfigs({
    required this.settings,
    required this.enable,
  });

  ViewerConfigs.undefined()
    : settings = Settings.defaultSettings.viewer,
      enable = false;

  factory ViewerConfigs.fromJsonString(String? jsonString) =>
      switch (jsonString) {
        null => ViewerConfigs.undefined(),
        final String s => tryDecodeJson(s).fold(
          (_) => ViewerConfigs.undefined(),
          (json) => ViewerConfigs.fromJson(json),
        ),
      };

  factory ViewerConfigs.fromJson(Map<String, dynamic> json) {
    return ViewerConfigs(
      settings: ImageViewerSettings.fromJson(json['settings']),
      enable: json['enable'],
    );
  }
  final ImageViewerSettings settings;
  final bool enable;

  ViewerConfigs copyWith({
    ImageViewerSettings? settings,
    bool? enable,
  }) {
    return ViewerConfigs(
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
}

class ImageViewerSettings extends Equatable {
  const ImageViewerSettings({
    required this.swipeMode,
    required this.postDetailsOverlayInitialState,
    required this.slideshowDirection,
    required this.slideshowInterval,
    required this.slideshowTransitionType,
    required this.slideshowVideoBehavior,
    required this.videoAudioDefaultState,
    required this.videoPlayerEngine,
    required this.enableVideoCache,
    required this.doubleTapSeekDuration,
  });

  ImageViewerSettings.fromJson(Map<String, dynamic> json)
    : swipeMode = PostDetailsSwipeMode.parse(json['swipeMode']),
      postDetailsOverlayInitialState = PostDetailsOverlayInitialState.parse(
        json['postDetailsOverlayInitialState'],
      ),
      slideshowDirection = SlideshowDirection.parse(json['slideshowDirection']),
      slideshowInterval = json['slideshowInterval'] ?? 6,
      slideshowTransitionType = SlideshowTransitionType.parse(
        json['slideshowTransitionType'],
      ),
      slideshowVideoBehavior = SlideshowVideoBehavior.parse(
        json['slideshowVideoBehavior'],
      ),
      videoAudioDefaultState = VideoAudioDefaultState.parse(
        json['videoAudioDefaultState'],
      ),
      videoPlayerEngine = VideoPlayerEngine.parse(
        json['videoPlayerEngine'],
      ),
      enableVideoCache = json['enableVideoCache'] ?? true,
      doubleTapSeekDuration = json['doubleTapSeekDuration'] ?? 10;

  final PostDetailsSwipeMode swipeMode;
  final PostDetailsOverlayInitialState postDetailsOverlayInitialState;
  final SlideshowDirection slideshowDirection;
  final double slideshowInterval;
  final SlideshowTransitionType slideshowTransitionType;
  final SlideshowVideoBehavior slideshowVideoBehavior;
  final VideoAudioDefaultState videoAudioDefaultState;
  final VideoPlayerEngine videoPlayerEngine;
  final bool enableVideoCache;
  final int doubleTapSeekDuration;

  ImageViewerSettings copyWith({
    PostDetailsSwipeMode? swipeMode,
    PostDetailsOverlayInitialState? postDetailsOverlayInitialState,
    SlideshowDirection? slideshowDirection,
    double? slideshowInterval,
    SlideshowTransitionType? slideshowTransitionType,
    SlideshowVideoBehavior? slideshowVideoBehavior,
    VideoAudioDefaultState? videoAudioDefaultState,
    VideoPlayerEngine? videoPlayerEngine,
    bool? enableVideoCache,
    int? doubleTapSeekDuration,
  }) {
    return ImageViewerSettings(
      swipeMode: swipeMode ?? this.swipeMode,
      postDetailsOverlayInitialState:
          postDetailsOverlayInitialState ?? this.postDetailsOverlayInitialState,
      slideshowDirection: slideshowDirection ?? this.slideshowDirection,
      slideshowInterval: slideshowInterval ?? this.slideshowInterval,
      slideshowTransitionType:
          slideshowTransitionType ?? this.slideshowTransitionType,
      slideshowVideoBehavior:
          slideshowVideoBehavior ?? this.slideshowVideoBehavior,
      videoAudioDefaultState:
          videoAudioDefaultState ?? this.videoAudioDefaultState,
      videoPlayerEngine: videoPlayerEngine ?? this.videoPlayerEngine,
      enableVideoCache: enableVideoCache ?? this.enableVideoCache,
      doubleTapSeekDuration:
          doubleTapSeekDuration ?? this.doubleTapSeekDuration,
    );
  }

  Map<String, dynamic> toJson() => {
    'swipeMode': swipeMode.toData(),
    'postDetailsOverlayInitialState': postDetailsOverlayInitialState.toData(),
    'slideshowDirection': slideshowDirection.toData(),
    'slideshowInterval': slideshowInterval,
    'slideshowTransitionType': slideshowTransitionType.toData(),
    'slideshowVideoBehavior': slideshowVideoBehavior.toData(),
    'videoAudioDefaultState': videoAudioDefaultState.toData(),
    'videoPlayerEngine': videoPlayerEngine.toData(),
    'enableVideoCache': enableVideoCache,
    'doubleTapSeekDuration': doubleTapSeekDuration,
  };

  @override
  List<Object> get props => [
    swipeMode,
    postDetailsOverlayInitialState,
    slideshowDirection,
    slideshowInterval,
    slideshowTransitionType,
    slideshowVideoBehavior,
    videoAudioDefaultState,
    videoPlayerEngine,
    enableVideoCache,
    doubleTapSeekDuration,
  ];
}

class ImageListingSettings extends Equatable {
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
    required this.postsPerPage,
    required this.animatedPostsDefaultState,
  });

  ImageListingSettings.fromJson(Map<String, dynamic> json)
    : gridSize = GridSize.parse(json['gridSize']),
      imageQuality = ImageQuality.parse(json['imageQuality']),
      imageListType = ImageListType.parse(json['imageListType']),
      pageMode = PageMode.parse(
        json['contentOrganizationCategory'],
      ),
      showScoresInGrid = json['showScoresInGrid'] ?? false,
      showPostListConfigHeader = json['showPostListConfigHeader'] ?? true,
      imageBorderRadius = json['imageBorderRadius'],
      pageIndicatorPosition = PageIndicatorPosition.parse(
        json['pageIndicatorPosition'],
      ),
      mediaBlurCondition = MediaBlurCondition.parse(
        json['mediaBlurCondition'],
      ),
      postsPerPage = json['postsPerPage'] ?? 60,
      imageGridAspectRatio = json['imageGridAspectRatio'] ?? 0.7,
      imageGridPadding = json['imageGridPadding'] ?? 16,
      imageGridSpacing = json['imageGridSpacing'] ?? 4,
      animatedPostsDefaultState = AnimatedPostsDefaultState.parse(
        json['animatedPostsDefaultState'],
      );

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
  final int postsPerPage;
  final AnimatedPostsDefaultState animatedPostsDefaultState;

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
    int? postsPerPage,
    AnimatedPostsDefaultState? animatedPostsDefaultState,
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
      postsPerPage: postsPerPage ?? this.postsPerPage,
      animatedPostsDefaultState:
          animatedPostsDefaultState ?? this.animatedPostsDefaultState,
    );
  }

  Map<String, dynamic> toJson() => {
    'gridSize': gridSize.toData(),
    'imageListType': imageListType.toData(),
    'imageQuality': imageQuality.toData(),
    'contentOrganizationCategory': pageMode.toData(),
    'pageIndicatorPosition': pageIndicatorPosition.toData(),
    'showScoresInGrid': showScoresInGrid,
    'showPostListConfigHeader': showPostListConfigHeader,
    'mediaBlurCondition': mediaBlurCondition.toData(),
    'imageGridSpacing': imageGridSpacing,
    'imageBorderRadius': imageBorderRadius,
    'imageGridPadding': imageGridPadding,
    'imageGridAspectRatio': imageGridAspectRatio,
    'postsPerPage': postsPerPage,
    'animatedPostsDefaultState': animatedPostsDefaultState.toData(),
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
    postsPerPage,
    animatedPostsDefaultState,
  ];
}
