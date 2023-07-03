// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

const String _assetUrl = 'assets/information.json';

typedef YearRange = ({
  int start,
  int end,
});

class AppInfo {
  AppInfo({
    required this.discordUrl,
    required this.githubUrl,
    required this.appName,
    required this.translationProjectUrl,
  })  : copyrightYearRange = (
          start: 2020,
          end: DateTime.now().toUtc().year,
        ),
        author = 'Nguyen Duc Khoa';

  factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
        discordUrl: json['discordUrl'],
        githubUrl: json['githubUrl'],
        appName: json['appName'],
        translationProjectUrl: json['translationProjectUrl'],
      );

  static final empty = AppInfo(
    discordUrl: '',
    githubUrl: '',
    appName: '',
    translationProjectUrl: '',
  );

  final String discordUrl;
  final String githubUrl;
  final String appName;
  final String translationProjectUrl;
  final YearRange copyrightYearRange;
  final String author;
}

Future<AppInfo> getAppInfo() async {
  try {
    final data = await rootBundle.loadString(_assetUrl);

    return AppInfo.fromJson(json.decode(data));
  } catch (e) {
    return AppInfo.empty;
  }
}
