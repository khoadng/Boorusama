// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/theme/theme_mode.dart';

enum ImageQuality {
  automatic,
  low,
  high,
  original,
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

enum ActionBarDisplayBehavior {
  scrolling,
  staticAtBottom,
}

enum DetailsDisplay {
  postFocus,
  imageFocus,
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
    required this.actionBarDisplayBehavior,
    required this.imageQuality,
    required this.imageQualityInFullView,
    required this.imageListType,
    required this.detailsDisplay,
    required this.pageMode,
    required this.autoFocusSearchBar,
    required this.postsPerPage,
    required this.currentBooruConfigId,
    required this.downloadQuality,
    required this.showScoresInGrid,
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
        actionBarDisplayBehavior = json['actionBarDisplayBehavior'] != null
            ? ActionBarDisplayBehavior.values[json['actionBarDisplayBehavior']]
            : ActionBarDisplayBehavior.scrolling,
        imageQuality = json['imageQuality'] != null
            ? ImageQuality.values[json['imageQuality']]
            : ImageQuality.automatic,
        imageQualityInFullView = json['imageQualityInFullView'] != null
            ? ImageQuality.values[json['imageQualityInFullView']]
            : ImageQuality.automatic,
        imageListType = json['imageListType'] != null
            ? ImageListType.values[json['imageListType']]
            : ImageListType.masonry,
        detailsDisplay = json['detailsDisplay'] != null
            ? DetailsDisplay.values[json['detailsDisplay']]
            : DetailsDisplay.postFocus,
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
    actionBarDisplayBehavior: ActionBarDisplayBehavior.scrolling,
    imageQuality: ImageQuality.automatic,
    imageQualityInFullView: ImageQuality.automatic,
    imageListType: ImageListType.masonry,
    detailsDisplay: DetailsDisplay.postFocus,
    pageMode: PageMode.infinite,
    autoFocusSearchBar: true,
    postsPerPage: 60,
    currentBooruConfigId: -1,
    downloadQuality: DownloadQuality.original,
    showScoresInGrid: false,
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

  final ActionBarDisplayBehavior actionBarDisplayBehavior;

  final ImageQuality imageQuality;

  final ImageQuality imageQualityInFullView;

  final ImageListType imageListType;

  final DetailsDisplay detailsDisplay;

  final PageMode pageMode;

  final bool autoFocusSearchBar;

  final int postsPerPage;

  final int currentBooruConfigId;

  final DownloadQuality downloadQuality;

  final bool showScoresInGrid;

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
    ActionBarDisplayBehavior? actionBarDisplayBehavior,
    ImageQuality? imageQuality,
    ImageQuality? imageQualityInFullView,
    ImageListType? imageListType,
    DetailsDisplay? detailsDisplay,
    PageMode? pageMode,
    bool? autoFocusSearchBar,
    int? postsPerPage,
    int? currentBooruConfigId,
    DownloadQuality? downloadQuality,
    bool? showScoresInGrid,
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
        actionBarDisplayBehavior:
            actionBarDisplayBehavior ?? this.actionBarDisplayBehavior,
        imageQuality: imageQuality ?? this.imageQuality,
        imageQualityInFullView:
            imageQualityInFullView ?? this.imageQualityInFullView,
        imageListType: imageListType ?? this.imageListType,
        detailsDisplay: detailsDisplay ?? this.detailsDisplay,
        pageMode: pageMode ?? this.pageMode,
        autoFocusSearchBar: autoFocusSearchBar ?? this.autoFocusSearchBar,
        postsPerPage: postsPerPage ?? this.postsPerPage,
        currentBooruConfigId: currentBooruConfigId ?? this.currentBooruConfigId,
        downloadQuality: downloadQuality ?? this.downloadQuality,
        showScoresInGrid: showScoresInGrid ?? this.showScoresInGrid,
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
        'actionBarDisplayBehavior': actionBarDisplayBehavior.index,
        'imageQuality': imageQuality.index,
        'imageQualityInFullView': imageQualityInFullView.index,
        'imageListType': imageListType.index,
        'detailsDisplay': detailsDisplay.index,
        'contentOrganizationCategory': pageMode.index,
        'autoFocusSearchBar': autoFocusSearchBar,
        'postsPerPage': postsPerPage,
        'currentBooruConfigId': currentBooruConfigId,
        'downloadQuality': downloadQuality.index,
        'showScoresInGrid': showScoresInGrid,
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
        actionBarDisplayBehavior,
        imageQuality,
        imageQualityInFullView,
        imageListType,
        detailsDisplay,
        pageMode,
        autoFocusSearchBar,
        postsPerPage,
        currentBooruConfigId,
        downloadQuality,
        showScoresInGrid,
      ];
}

extension SettingsX on Settings {
  bool get hasSelectedBooru => currentBooruConfigId != -1;
}
