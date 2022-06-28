// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'package:boorusama/core/core.dart';

enum DataCollectingStatus {
  allow,
  prohibit,
}

enum ActionBarDisplayBehavior {
  scrolling,
  staticAtBottom,
}

class Settings extends Equatable {
  const Settings({
    required this.safeMode,
    required this.blacklistedTags,
    required this.themeMode,
    required this.language,
    required this.searchHistories,
    required this.gridSize,
    required this.dataCollectingStatus,
    required this.downloadPath,
    required this.imageBorderRadius,
    required this.imageGridSpacing,
    required this.actionBarDisplayBehavior,
    required this.imageQuality,
  });

  Settings.fromJson(Map<String, dynamic> json)
      : safeMode = json['safeMode'] ?? true,
        blacklistedTags = json['hideBlacklist'] ?? [],
        themeMode = json['themeMode'] != null
            ? ThemeMode.values[json['themeMode']]
            : ThemeMode.dark,
        dataCollectingStatus = json['dataCollectingStatus'] != null
            ? DataCollectingStatus.values[json['dataCollectingStatus']]
            : DataCollectingStatus.allow,
        language = json['language'] ?? 'en',
        gridSize = json['gridSize'] != null
            ? GridSize.values[json['gridSize']]
            : GridSize.normal,
        downloadPath = json['downloadPath'],
        searchHistories = List<SearchHistory>.from(json['searchHistories']
            ?.map((e) => SearchHistory.fromJson(e))
            ?.toList()),
        actionBarDisplayBehavior = json['actionBarDisplayBehavior'] != null
            ? ActionBarDisplayBehavior.values[json['actionBarDisplayBehavior']]
            : ActionBarDisplayBehavior.scrolling,
        imageQuality = json['imageQuality'] != null
            ? ImageQuality.values[json['imageQuality']]
            : ImageQuality.automatic,
        imageBorderRadius = json['imageBorderRadius'],
        imageGridSpacing = json['imageGridSpacing'];

  static const defaultSettings = Settings(
    safeMode: true,
    blacklistedTags: '',
    themeMode: ThemeMode.dark,
    language: 'en',
    searchHistories: [],
    gridSize: GridSize.normal,
    dataCollectingStatus: DataCollectingStatus.allow,
    downloadPath: null,
    imageBorderRadius: 4,
    imageGridSpacing: 4,
    actionBarDisplayBehavior: ActionBarDisplayBehavior.scrolling,
    imageQuality: ImageQuality.automatic,
  );

  final String blacklistedTags;
  final String language;
  final bool safeMode;
  final ThemeMode themeMode;
  final List<SearchHistory> searchHistories;
  final GridSize gridSize;
  final DataCollectingStatus dataCollectingStatus;
  final String? downloadPath;

  final double imageBorderRadius;
  final double imageGridSpacing;

  final ActionBarDisplayBehavior actionBarDisplayBehavior;

  final ImageQuality imageQuality;

  Settings copyWith({
    String? blacklistedTags,
    String? language,
    bool? safeMode,
    ThemeMode? themeMode,
    List<SearchHistory>? searchHistories,
    GridSize? gridSize,
    DataCollectingStatus? dataCollectingStatus,
    String? downloadPath,
    double? imageBorderRadius,
    double? imageGridSpacing,
    ActionBarDisplayBehavior? actionBarDisplayBehavior,
    ImageQuality? imageQuality,
  }) =>
      Settings(
        safeMode: safeMode ?? this.safeMode,
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        searchHistories: searchHistories ?? this.searchHistories,
        gridSize: gridSize ?? this.gridSize,
        dataCollectingStatus: dataCollectingStatus ?? this.dataCollectingStatus,
        downloadPath: downloadPath ?? this.downloadPath,
        imageBorderRadius: imageBorderRadius ?? this.imageBorderRadius,
        imageGridSpacing: imageGridSpacing ?? this.imageGridSpacing,
        actionBarDisplayBehavior:
            actionBarDisplayBehavior ?? this.actionBarDisplayBehavior,
        imageQuality: imageQuality ?? this.imageQuality,
      );

  Map<String, dynamic> toJson() => {
        'safeMode': safeMode,
        'hideBlacklist': blacklistedTags,
        'themeMode': themeMode.index,
        'dataCollectingStatus': dataCollectingStatus.index,
        'language': language,
        'searchHistories':
            searchHistories.map((item) => item.toJson()).toList(),
        'gridSize': gridSize.index,
        'downloadPath': downloadPath,
        'imageBorderRadius': imageBorderRadius,
        'imageGridSpacing': imageGridSpacing,
        'actionBarDisplayBehavior': actionBarDisplayBehavior.index,
        'imageQuality': imageQuality.index,
      };

  @override
  List<Object?> get props => [
        safeMode,
        blacklistedTags,
        themeMode,
        language,
        searchHistories,
        gridSize,
        dataCollectingStatus,
        downloadPath,
        imageBorderRadius,
        imageGridSpacing,
        actionBarDisplayBehavior,
        imageQuality,
      ];
}
