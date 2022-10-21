// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

const String _assetUrl = 'assets/information.json';

class AppInfo {
  const AppInfo({
    required this.discordUrl,
    required this.githubUrl,
    required this.appName,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
        discordUrl: json['discordUrl'],
        githubUrl: json['githubUrl'],
        appName: json['appName'],
      );

  static const empty = AppInfo(
    discordUrl: '',
    githubUrl: '',
    appName: '',
  );

  final String discordUrl;
  final String githubUrl;
  final String appName;
}

Future<AppInfo> getAppInfo() async {
  try {
    final data = await rootBundle.loadString(_assetUrl);

    return AppInfo.fromJson(json.decode(data));
  } catch (e) {
    return AppInfo.empty;
  }
}
