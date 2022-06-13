// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/searches/search_history.dart';

class Settings extends Equatable {
  const Settings({
    required this.safeMode,
    required this.blacklistedTags,
    required this.themeMode,
    required this.language,
    required this.searchHistories,
  });

  Settings.fromJson(Map<String, dynamic> json)
      : safeMode = json['safeMode'],
        blacklistedTags = json['hideBlacklist'],
        themeMode = ThemeMode.values[json['themeMode']],
        language = json['language'],
        searchHistories = List<SearchHistory>.from(json['searchHistories']
            ?.map((item) => SearchHistory.fromJson(item))
            ?.toList());

  static const defaultSettings = Settings(
    safeMode: true,
    blacklistedTags: '',
    themeMode: ThemeMode.dark,
    language: 'en',
    searchHistories: [],
  );

  final String blacklistedTags;
  final String language;
  final bool safeMode;
  final ThemeMode themeMode;
  final List<SearchHistory> searchHistories;

  Settings copyWith({
    String? blacklistedTags,
    String? language,
    bool? safeMode,
    ThemeMode? themeMode,
    List<SearchHistory>? searchHistories,
  }) =>
      Settings(
        safeMode: safeMode ?? this.safeMode,
        blacklistedTags: blacklistedTags ?? this.blacklistedTags,
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        searchHistories: searchHistories ?? this.searchHistories,
      );

  Map<String, dynamic> toJson() => {
        'safeMode': safeMode,
        'hideBlacklist': blacklistedTags,
        'themeMode': themeMode.index,
        'language': language,
        'searchHistories':
            searchHistories.map((item) => item.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [safeMode, blacklistedTags, themeMode, language, searchHistories];
}
