// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/core/core.dart';

enum DataCollectingStatus {
  allow,
  prohibit,
}

enum ActionBarDisplayBehavior {
  scrolling,
  staticAtBottom,
}

enum DownloadMethod {
  flutterDownloader,
  imageGallerySaver,
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
      ];
}
