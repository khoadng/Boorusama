// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';

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

class Settings extends Equatable {
  const Settings({
    required this.safeMode,
    required this.blacklistedTags,
    required this.themeMode,
    required this.language,
    required this.gridSize,
    required this.dataCollectingStatus,
    required this.downloadPath,
    required this.imageBorderRadius,
    required this.imageGridSpacing,
    required this.imageQuality,
    required this.imageQualityInFullView,
    required this.imageListType,
    required this.pageMode,
    required this.autoFocusSearchBar,
    required this.postsPerPage,
    required this.currentBooruConfigId,
    required this.booruConfigIdOrders,
    required this.downloadQuality,
    required this.showScoresInGrid,
    required this.showPostListConfigHeader,
    required this.enableIncognitoModeForKeyboard,
    required this.enableDynamicColoring,
    required this.clearImageCacheOnStartup,
    required this.appLockType,
    required this.bookmarkFilterType,
    required this.pageIndicatorPosition,
  });

  Settings.fromJson(Map<String, dynamic> json)
      : safeMode = json['safeMode'] ?? true,
        blacklistedTags = json['hideBlacklist'] ?? [],
        themeMode = json['themeMode'] != null
            ? ThemeMode.values[json['themeMode']]
            : ThemeMode.amoledDark,
        dataCollectingStatus = json['dataCollectingStatus'] != null
            ? DataCollectingStatus.values[json['dataCollectingStatus']]
            : DataCollectingStatus.allow,
        language = json['language'] ?? 'en-US',
        gridSize = json['gridSize'] != null
            ? GridSize.values[json['gridSize']]
            : GridSize.normal,
        downloadPath = json['downloadPath'],
        imageQuality = json['imageQuality'] != null
            ? ImageQuality.values[json['imageQuality']]
            : ImageQuality.automatic,
        imageQualityInFullView = json['imageQualityInFullView'] != null
            ? ImageQuality.values[json['imageQualityInFullView']]
            : ImageQuality.automatic,
        imageListType = json['imageListType'] != null
            ? ImageListType.values[json['imageListType']]
            : ImageListType.masonry,
        pageMode = json['contentOrganizationCategory'] != null
            ? PageMode.values[json['contentOrganizationCategory']]
            : PageMode.infinite,
        downloadQuality = json['downloadQuality'] != null
            ? DownloadQuality.values[json['downloadQuality']]
            : DownloadQuality.original,
        showScoresInGrid = json['showScoresInGrid'] ?? false,
        autoFocusSearchBar = json['autoFocusSearchBar'] ?? true,
        postsPerPage = json['postsPerPage'] ?? 60,
        currentBooruConfigId = json['currentBooruConfigId'],
        booruConfigIdOrders = json['booruConfigIdOrders'] != null
            ? castOrFallback<String>(json['booruConfigIdOrders'], '')
            : '',
        showPostListConfigHeader = json['showPostListConfigHeader'] ?? true,
        enableIncognitoModeForKeyboard =
            json['enableIncognitoModeForKeyboard'] ?? false,
        enableDynamicColoring = json['enableDynamicColoring'] ?? false,
        clearImageCacheOnStartup = json['clearImageCacheOnStartup'] ?? false,
        imageBorderRadius = json['imageBorderRadius'],
        appLockType = json['appLockType'] != null
            ? AppLockType.values[json['appLockType']]
            : AppLockType.none,
        bookmarkFilterType = json['bookmarkFilterType'] != null
            ? BookmarkFilterType.values[json['bookmarkFilterType']]
            : BookmarkFilterType.none,
        pageIndicatorPosition = json['pageIndicatorPosition'] != null
            ? PageIndicatorPosition.values[json['pageIndicatorPosition']]
            : PageIndicatorPosition.bottom,
        imageGridSpacing = json['imageGridSpacing'];

  static const defaultSettings = Settings(
    safeMode: true,
    blacklistedTags: '',
    themeMode: ThemeMode.amoledDark,
    language: 'en-US',
    gridSize: GridSize.normal,
    dataCollectingStatus: DataCollectingStatus.allow,
    downloadPath: null,
    imageBorderRadius: 4,
    imageGridSpacing: 4,
    imageQuality: ImageQuality.automatic,
    imageQualityInFullView: ImageQuality.automatic,
    imageListType: ImageListType.masonry,
    pageMode: PageMode.infinite,
    autoFocusSearchBar: true,
    postsPerPage: 60,
    currentBooruConfigId: -1,
    booruConfigIdOrders: '',
    downloadQuality: DownloadQuality.original,
    showScoresInGrid: false,
    showPostListConfigHeader: true,
    enableIncognitoModeForKeyboard: false,
    enableDynamicColoring: false,
    clearImageCacheOnStartup: false,
    appLockType: AppLockType.none,
    bookmarkFilterType: BookmarkFilterType.none,
    pageIndicatorPosition: PageIndicatorPosition.bottom,
  );

  final String blacklistedTags;
  final String language;
  final bool safeMode;
  final ThemeMode themeMode;
  final GridSize gridSize;
  final DataCollectingStatus dataCollectingStatus;

  final String? downloadPath;

  final double imageBorderRadius;
  final double imageGridSpacing;

  final ImageQuality imageQuality;

  final ImageQuality imageQualityInFullView;

  final ImageListType imageListType;

  final PageMode pageMode;

  final bool autoFocusSearchBar;

  final int postsPerPage;

  final int currentBooruConfigId;

  final String booruConfigIdOrders;

  final DownloadQuality downloadQuality;

  final bool showScoresInGrid;

  final bool showPostListConfigHeader;

  final bool enableIncognitoModeForKeyboard;

  final bool enableDynamicColoring;

  final bool clearImageCacheOnStartup;

  final AppLockType appLockType;

  final BookmarkFilterType bookmarkFilterType;

  final PageIndicatorPosition pageIndicatorPosition;

  Settings copyWith({
    String? blacklistedTags,
    String? language,
    bool? safeMode,
    ThemeMode? themeMode,
    GridSize? gridSize,
    DataCollectingStatus? dataCollectingStatus,
    String? downloadPath,
    double? imageBorderRadius,
    double? imageGridSpacing,
    ImageQuality? imageQuality,
    ImageQuality? imageQualityInFullView,
    ImageListType? imageListType,
    PageMode? pageMode,
    bool? autoFocusSearchBar,
    int? postsPerPage,
    int? currentBooruConfigId,
    String? booruConfigIdOrders,
    DownloadQuality? downloadQuality,
    bool? showScoresInGrid,
    bool? showPostListConfigHeader,
    bool? enableIncognitoModeForKeyboard,
    bool? enableDynamicColoring,
    bool? clearImageCacheOnStartup,
    AppLockType? appLockType,
    BookmarkFilterType? bookmarkFilterType,
    PageIndicatorPosition? pageIndicatorPosition,
  }) =>
      Settings(
        safeMode: safeMode ?? this.safeMode,
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        gridSize: gridSize ?? this.gridSize,
        dataCollectingStatus: dataCollectingStatus ?? this.dataCollectingStatus,
        downloadPath: downloadPath ?? this.downloadPath,
        imageBorderRadius: imageBorderRadius ?? this.imageBorderRadius,
        imageGridSpacing: imageGridSpacing ?? this.imageGridSpacing,
        imageQuality: imageQuality ?? this.imageQuality,
        imageQualityInFullView:
            imageQualityInFullView ?? this.imageQualityInFullView,
        imageListType: imageListType ?? this.imageListType,
        pageMode: pageMode ?? this.pageMode,
        autoFocusSearchBar: autoFocusSearchBar ?? this.autoFocusSearchBar,
        postsPerPage: postsPerPage ?? this.postsPerPage,
        currentBooruConfigId: currentBooruConfigId ?? this.currentBooruConfigId,
        booruConfigIdOrders: booruConfigIdOrders ?? this.booruConfigIdOrders,
        downloadQuality: downloadQuality ?? this.downloadQuality,
        showScoresInGrid: showScoresInGrid ?? this.showScoresInGrid,
        showPostListConfigHeader:
            showPostListConfigHeader ?? this.showPostListConfigHeader,
        enableIncognitoModeForKeyboard: enableIncognitoModeForKeyboard ??
            this.enableIncognitoModeForKeyboard,
        enableDynamicColoring:
            enableDynamicColoring ?? this.enableDynamicColoring,
        clearImageCacheOnStartup:
            clearImageCacheOnStartup ?? this.clearImageCacheOnStartup,
        appLockType: appLockType ?? this.appLockType,
        bookmarkFilterType: bookmarkFilterType ?? this.bookmarkFilterType,
        pageIndicatorPosition:
            pageIndicatorPosition ?? this.pageIndicatorPosition,
      );

  Map<String, dynamic> toJson() => {
        'safeMode': safeMode,
        'hideBlacklist': blacklistedTags,
        'themeMode': themeMode.index,
        'dataCollectingStatus': dataCollectingStatus.index,
        'language': language,
        'gridSize': gridSize.index,
        'downloadPath': downloadPath,
        'imageBorderRadius': imageBorderRadius,
        'imageGridSpacing': imageGridSpacing,
        'imageQuality': imageQuality.index,
        'imageQualityInFullView': imageQualityInFullView.index,
        'imageListType': imageListType.index,
        'contentOrganizationCategory': pageMode.index,
        'autoFocusSearchBar': autoFocusSearchBar,
        'postsPerPage': postsPerPage,
        'currentBooruConfigId': currentBooruConfigId,
        'booruConfigIdOrders': booruConfigIdOrders,
        'downloadQuality': downloadQuality.index,
        'showScoresInGrid': showScoresInGrid,
        'showPostListConfigHeader': showPostListConfigHeader,
        'enableIncognitoModeForKeyboard': enableIncognitoModeForKeyboard,
        'enableDynamicColoring': enableDynamicColoring,
        'clearImageCacheOnStartup': clearImageCacheOnStartup,
        'appLockType': appLockType.index,
        'bookmarkFilterType': bookmarkFilterType.index,
        'pageIndicatorPosition': pageIndicatorPosition.index,
      };

  @override
  List<Object?> get props => [
        safeMode,
        blacklistedTags,
        themeMode,
        language,
        gridSize,
        dataCollectingStatus,
        downloadPath,
        imageBorderRadius,
        imageGridSpacing,
        imageQuality,
        imageQualityInFullView,
        imageListType,
        pageMode,
        autoFocusSearchBar,
        postsPerPage,
        currentBooruConfigId,
        booruConfigIdOrders,
        downloadQuality,
        showScoresInGrid,
        showPostListConfigHeader,
        enableIncognitoModeForKeyboard,
        enableDynamicColoring,
        clearImageCacheOnStartup,
        appLockType,
        bookmarkFilterType,
        pageIndicatorPosition,
      ];
}

extension SettingsX on Settings {
  bool get appLockEnabled => appLockType == AppLockType.biometrics;
  bool get shouldFilterBookmarks =>
      bookmarkFilterType != BookmarkFilterType.none;
}

extension PageIndicatorPositionX on PageIndicatorPosition {
  bool get isVisibleAtBottom =>
      this == PageIndicatorPosition.bottom ||
      this == PageIndicatorPosition.both;
  bool get isVisibleAtTop =>
      this == PageIndicatorPosition.top || this == PageIndicatorPosition.both;
}
