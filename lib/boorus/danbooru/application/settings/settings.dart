// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';

enum DataCollectingStatus {
  allow,
  prohibit,
}

class Settings {
  Settings({
    required this.safeMode,
    required this.blacklistedTags,
    required this.themeMode,
    required this.language,
    required this.searchHistories,
    required this.dataCollectingStatus,
  });

  Settings.fromJson(Map<String, dynamic> json)
      : safeMode = json["safeMode"],
        blacklistedTags = json["hideBlacklist"],
        themeMode = ThemeMode.values[json["themeMode"]],
        language = json["language"],
        dataCollectingStatus = json["dataCollectingStatus"] == null
            ? DataCollectingStatus.allow
            : DataCollectingStatus.values[json["dataCollectingStatus"]],
        searchHistories = List<SearchHistory>.from(json["searchHistories"]
            ?.map((item) => SearchHistory.fromJson(item))
            ?.toList());

  static final defaultSettings = Settings(
    safeMode: true,
    blacklistedTags: "",
    themeMode: ThemeMode.dark,
    language: "en",
    searchHistories: [],
    dataCollectingStatus: DataCollectingStatus.allow,
  );

  String blacklistedTags;
  String language;
  bool safeMode;
  ThemeMode themeMode;
  List<SearchHistory> searchHistories;
  DataCollectingStatus dataCollectingStatus;

  Map<String, dynamic> toJson() => {
        'safeMode': safeMode,
        'hideBlacklist': blacklistedTags,
        'themeMode': themeMode.index,
        'dataCollectingStatus': dataCollectingStatus.index,
        'language': language,
        'searchHistories':
            searchHistories.map((item) => item.toJson()).toList(),
      };
}
