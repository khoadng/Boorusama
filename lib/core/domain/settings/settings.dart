// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/core/application/theme/theme.dart';
import 'package:boorusama/core/core.dart';

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

enum DownloadMethod {
  flutterDownloader,
  imageGallerySaver,
}

enum ContentOrganizationCategory {
  infiniteScroll,
  pagination,
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
    required this.downloadMethod,
    required this.imageBorderRadius,
    required this.imageGridSpacing,
    required this.actionBarDisplayBehavior,
    required this.imageQuality,
    required this.imageQualityInFullView,
    required this.imageListType,
    required this.detailsDisplay,
    required this.contentOrganizationCategory,
    required this.autoFocusSearchBar,
    required this.postsPerPage,
    required this.currentBooru,
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
        language = json['language'] ?? 'en',
        gridSize = json['gridSize'] != null
            ? GridSize.values[json['gridSize']]
            : GridSize.normal,
        downloadPath = json['downloadPath'],
        downloadMethod = json['downloadMethod'] != null
            ? DownloadMethod.values[json['downloadMethod']]
            : DownloadMethod.flutterDownloader,
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
        contentOrganizationCategory =
            json['contentOrganizationCategory'] != null
                ? ContentOrganizationCategory
                    .values[json['contentOrganizationCategory']]
                : ContentOrganizationCategory.infiniteScroll,
        autoFocusSearchBar = json['autoFocusSearchBar'] ?? true,
        postsPerPage = json['postsPerPage'] ?? 60,
        currentBooru = json['currentBooru'] != null
            ? BooruType.values[json['currentBooru']]
            : BooruType.unknown,
        imageBorderRadius = json['imageBorderRadius'],
        imageGridSpacing = json['imageGridSpacing'];

  static const defaultSettings = Settings(
    safeMode: true,
    blacklistedTags: '',
    themeMode: ThemeMode.amoledDark,
    language: 'en',
    gridSize: GridSize.normal,
    dataCollectingStatus: DataCollectingStatus.allow,
    downloadPath: null,
    downloadMethod: DownloadMethod.flutterDownloader,
    imageBorderRadius: 4,
    imageGridSpacing: 4,
    actionBarDisplayBehavior: ActionBarDisplayBehavior.scrolling,
    imageQuality: ImageQuality.automatic,
    imageQualityInFullView: ImageQuality.automatic,
    imageListType: ImageListType.masonry,
    detailsDisplay: DetailsDisplay.postFocus,
    contentOrganizationCategory: ContentOrganizationCategory.infiniteScroll,
    autoFocusSearchBar: true,
    postsPerPage: 60,
    currentBooru: BooruType.unknown,
  );

  final String blacklistedTags;
  final String language;
  final bool safeMode;
  final ThemeMode themeMode;
  final GridSize gridSize;
  final DataCollectingStatus dataCollectingStatus;

  final String? downloadPath;
  final DownloadMethod downloadMethod;

  final double imageBorderRadius;
  final double imageGridSpacing;

  final ActionBarDisplayBehavior actionBarDisplayBehavior;

  final ImageQuality imageQuality;

  final ImageQuality imageQualityInFullView;

  final ImageListType imageListType;

  final DetailsDisplay detailsDisplay;

  final ContentOrganizationCategory contentOrganizationCategory;

  final bool autoFocusSearchBar;

  final int postsPerPage;

  final BooruType currentBooru;

  Settings copyWith({
    String? blacklistedTags,
    String? language,
    bool? safeMode,
    ThemeMode? themeMode,
    GridSize? gridSize,
    DataCollectingStatus? dataCollectingStatus,
    String? downloadPath,
    DownloadMethod? downloadMethod,
    double? imageBorderRadius,
    double? imageGridSpacing,
    ActionBarDisplayBehavior? actionBarDisplayBehavior,
    ImageQuality? imageQuality,
    ImageQuality? imageQualityInFullView,
    ImageListType? imageListType,
    DetailsDisplay? detailsDisplay,
    ContentOrganizationCategory? contentOrganizationCategory,
    bool? autoFocusSearchBar,
    int? postsPerPage,
    BooruType? currentBooru,
  }) =>
      Settings(
        safeMode: safeMode ?? this.safeMode,
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        gridSize: gridSize ?? this.gridSize,
        dataCollectingStatus: dataCollectingStatus ?? this.dataCollectingStatus,
        downloadPath: downloadPath ?? this.downloadPath,
        downloadMethod: downloadMethod ?? this.downloadMethod,
        imageBorderRadius: imageBorderRadius ?? this.imageBorderRadius,
        imageGridSpacing: imageGridSpacing ?? this.imageGridSpacing,
        actionBarDisplayBehavior:
            actionBarDisplayBehavior ?? this.actionBarDisplayBehavior,
        imageQuality: imageQuality ?? this.imageQuality,
        imageQualityInFullView:
            imageQualityInFullView ?? this.imageQualityInFullView,
        imageListType: imageListType ?? this.imageListType,
        detailsDisplay: detailsDisplay ?? this.detailsDisplay,
        contentOrganizationCategory:
            contentOrganizationCategory ?? this.contentOrganizationCategory,
        autoFocusSearchBar: autoFocusSearchBar ?? this.autoFocusSearchBar,
        postsPerPage: postsPerPage ?? this.postsPerPage,
        currentBooru: currentBooru ?? this.currentBooru,
      );

  Map<String, dynamic> toJson() => {
        'safeMode': safeMode,
        'hideBlacklist': blacklistedTags,
        'themeMode': themeMode.index,
        'dataCollectingStatus': dataCollectingStatus.index,
        'language': language,
        'gridSize': gridSize.index,
        'downloadPath': downloadPath,
        'downloadMethod': downloadMethod.index,
        'imageBorderRadius': imageBorderRadius,
        'imageGridSpacing': imageGridSpacing,
        'actionBarDisplayBehavior': actionBarDisplayBehavior.index,
        'imageQuality': imageQuality.index,
        'imageQualityInFullView': imageQualityInFullView.index,
        'imageListType': imageListType.index,
        'detailsDisplay': detailsDisplay.index,
        'contentOrganizationCategory': contentOrganizationCategory.index,
        'autoFocusSearchBar': autoFocusSearchBar,
        'postsPerPage': postsPerPage,
        'currentBooru': currentBooru.index,
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
        downloadMethod,
        imageBorderRadius,
        imageGridSpacing,
        actionBarDisplayBehavior,
        imageQuality,
        imageQualityInFullView,
        imageListType,
        detailsDisplay,
        contentOrganizationCategory,
        autoFocusSearchBar,
        postsPerPage,
        currentBooru,
      ];
}
