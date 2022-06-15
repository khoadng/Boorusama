// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/theme/theme_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';
import 'package:boorusama/core/presentation/grid_size.dart';

class Settings extends Equatable {
  const Settings({
    required this.safeMode,
    required this.blacklistedTags,
    required this.themeMode,
    required this.language,
    required this.searchHistories,
    required this.gridSize,
  });

  Settings.fromJson(Map<String, dynamic> json)
      : safeMode = json['safeMode'] ?? true,
        blacklistedTags = json['hideBlacklist'] ?? [],
        themeMode = json['themeMode'] != null
            ? ThemeMode.values[json['themeMode']]
            : ThemeMode.dark,
        language = json['language'] ?? 'en',
        gridSize = json['gridSize'] != null
            ? GridSize.values[json['gridSize']]
            : GridSize.normal,
        searchHistories = List<SearchHistory>.from(json['searchHistories']
            ?.map((item) => SearchHistory.fromJson(item))
            ?.toList());

  static const defaultSettings = Settings(
    safeMode: true,
    blacklistedTags: '',
    themeMode: ThemeMode.dark,
    language: 'en',
    searchHistories: [],
    gridSize: GridSize.normal,
  );

  final String blacklistedTags;
  final String language;
  final bool safeMode;
  final ThemeMode themeMode;
  final List<SearchHistory> searchHistories;
  final GridSize gridSize;

  Settings copyWith({
    String? blacklistedTags,
    String? language,
    bool? safeMode,
    ThemeMode? themeMode,
    List<SearchHistory>? searchHistories,
    GridSize? gridSize,
  }) =>
      Settings(
        safeMode: safeMode ?? this.safeMode,
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        searchHistories: searchHistories ?? this.searchHistories,
        gridSize: gridSize ?? this.gridSize,
      );

  Map<String, dynamic> toJson() => {
        'safeMode': safeMode,
        'hideBlacklist': blacklistedTags,
        'themeMode': themeMode.index,
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
        gridSize
      ];
}
