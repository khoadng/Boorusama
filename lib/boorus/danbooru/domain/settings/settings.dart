// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/searches.dart';
import 'package:boorusama/core/presentation/grid_size.dart';

enum DataCollectingStatus {
  allow,
  prohibit,
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
        searchHistories = List<SearchHistory>.from(
            json['searchHistories']?.map(SearchHistory.fromJson)?.toList());

  static const defaultSettings = Settings(
    safeMode: true,
    blacklistedTags: '',
    themeMode: ThemeMode.dark,
    language: 'en',
    searchHistories: [],
    gridSize: GridSize.normal,
    dataCollectingStatus: DataCollectingStatus.allow,
  );

  final String blacklistedTags;
  final String language;
  final bool safeMode;
  final ThemeMode themeMode;
  final List<SearchHistory> searchHistories;
  final GridSize gridSize;
  final DataCollectingStatus dataCollectingStatus;

  Settings copyWith({
    String? blacklistedTags,
    String? language,
    bool? safeMode,
    ThemeMode? themeMode,
    List<SearchHistory>? searchHistories,
    GridSize? gridSize,
    DataCollectingStatus? dataCollectingStatus,
  }) =>
      Settings(
        safeMode: safeMode ?? this.safeMode,
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        searchHistories: searchHistories ?? this.searchHistories,
        gridSize: gridSize ?? this.gridSize,
        dataCollectingStatus: dataCollectingStatus ?? this.dataCollectingStatus,
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
      ];
}
