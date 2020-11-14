import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class Setting {
  bool safeMode;
  String blacklistedTags;
  ThemeMode themeMode;

  Setting({
    @required this.safeMode,
    @required this.blacklistedTags,
    @required this.themeMode,
  });

  static final defaultSettings =
      Setting(safeMode: false, blacklistedTags: "", themeMode: ThemeMode.dark);

  Setting.fromJson(Map<String, dynamic> json)
      : safeMode = json["safeMode"],
        blacklistedTags = json["hideBlacklist"],
        themeMode = ThemeMode.values[json["themeMode"]];

  Map<String, dynamic> toJson() => {
        'safeMode': safeMode,
        'hideBlacklist': blacklistedTags,
        'themeMode': themeMode.index,
      };
}
