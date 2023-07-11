// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
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
    required this.downloadQuality,
    required this.showScoresInGrid,
    required this.showHiddenPostsHeader,
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
        showHiddenPostsHeader = json['showHiddenPostsHeader'] ?? true,
        imageBorderRadius = json['imageBorderRadius'],
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
    downloadQuality: DownloadQuality.original,
    showScoresInGrid: false,
    showHiddenPostsHeader: true,
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

  final DownloadQuality downloadQuality;

  final bool showScoresInGrid;

  final bool showHiddenPostsHeader;

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
    DownloadQuality? downloadQuality,
    bool? showScoresInGrid,
    bool? showHiddenPostsHeader,
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
        downloadQuality: downloadQuality ?? this.downloadQuality,
        showScoresInGrid: showScoresInGrid ?? this.showScoresInGrid,
        showHiddenPostsHeader:
            showHiddenPostsHeader ?? this.showHiddenPostsHeader,
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
        'downloadQuality': downloadQuality.index,
        'showScoresInGrid': showScoresInGrid,
        'showHiddenPostsHeader': showHiddenPostsHeader,
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
        downloadQuality,
        showScoresInGrid,
        showHiddenPostsHeader,
      ];
}

extension SettingsX on Settings {
  bool get hasSelectedBooru => currentBooruConfigId != -1;
}
