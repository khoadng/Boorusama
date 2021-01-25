// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:meta/meta.dart';

class Setting {
  bool safeMode;
  String blacklistedTags;
  ThemeMode themeMode;
  String language;

  Setting({
    @required this.safeMode,
    @required this.blacklistedTags,
    @required this.themeMode,
    @required this.language,
  });

  static final defaultSettings = Setting(
      safeMode: false,
      blacklistedTags: "",
      themeMode: ThemeMode.dark,
      language: "en");

  Setting.fromJson(Map<String, dynamic> json)
      : safeMode = json["safeMode"],
        blacklistedTags = json["hideBlacklist"],
        themeMode = ThemeMode.values[json["themeMode"]],
        language = json["language"];

  Map<String, dynamic> toJson() => {
        'safeMode': safeMode,
        'hideBlacklist': blacklistedTags,
        'themeMode': themeMode.index,
        'language': language,
      };
}
