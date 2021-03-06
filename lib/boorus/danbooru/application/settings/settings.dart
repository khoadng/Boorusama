// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';

class Settings {
  Settings({
    @required this.safeMode,
    @required this.blacklistedTags,
    @required this.themeMode,
    @required this.language,
    @required this.searchHistories,
  });

  Settings.fromJson(Map<String, dynamic> json)
      : safeMode = json["safeMode"],
        blacklistedTags = json["hideBlacklist"],
        themeMode = ThemeMode.values[json["themeMode"]],
        language = json["language"],
        searchHistories = List<SearchHistory>.from(json["searchHistories"]
                ?.map((item) => SearchHistory.fromJson(item))
                ?.toList()) ??
            <SearchHistory>[];

  static final defaultSettings = Settings(
    safeMode: false,
    blacklistedTags: "",
    themeMode: ThemeMode.dark,
    language: "en",
    searchHistories: [],
  );

  String blacklistedTags;
  String language;
  bool safeMode;
  ThemeMode themeMode;
  List<SearchHistory> searchHistories;

  Map<String, dynamic> toJson() => {
        'safeMode': safeMode,
        'hideBlacklist': blacklistedTags,
        'themeMode': themeMode.index,
        'language': language,
        'searchHistories':
            searchHistories.map((item) => item.toJson()).toList(),
      };
}
