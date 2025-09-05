// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appInfoProvider = Provider<AppInfo>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'appInfoProvider',
);

const _assetUrl = 'assets/information.json';

typedef YearRange = ({int start, int end});

class AppInfo {
  AppInfo({
    required this.discordUrl,
    required this.githubUrl,
    required this.patreonUrl,
    required this.koFiUrl,
    required this.buyMeCoffeeUrl,
    required this.playStoreUrl,
    required this.appName,
    required this.translationProjectUrl,
    required this.translationStatusUrl,
    required this.translationBadgeUrl,
    required this.supportEmail,
    required this.booruDefUrl,
    required this.termsOfServiceUrl,
    required this.privacyPolicyUrl,
  }) : copyrightYearRange = (
         start: 2020,
         end: DateTime.now().toUtc().year,
       ),
       author = 'Nguyen Duc Khoa';

  factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
    discordUrl: json['discordUrl'],
    githubUrl: json['githubUrl'],
    patreonUrl: json['patreonUrl'],
    koFiUrl: json['koFiUrl'],
    buyMeCoffeeUrl: json['buyMeACoffeeUrl'],
    playStoreUrl: json['playStoreUrl'],
    appName: const String.fromEnvironment('APP_NAME'),
    translationProjectUrl: json['translationProjectUrl'],
    translationStatusUrl: json['translationStatusUrl'],
    translationBadgeUrl: json['translationBadgeUrl'],
    supportEmail: json['supportEmail'],
    booruDefUrl: json['booruDefUrl'],
    termsOfServiceUrl: json['termsOfServiceUrl'],
    privacyPolicyUrl: json['privacyPolicyUrl'],
  );

  static final empty = AppInfo(
    discordUrl: '',
    githubUrl: '',
    patreonUrl: '',
    koFiUrl: '',
    buyMeCoffeeUrl: '',
    playStoreUrl: '',
    appName: '',
    translationProjectUrl: '',
    translationStatusUrl: '',
    translationBadgeUrl: '',
    supportEmail: '',
    booruDefUrl: '',
    termsOfServiceUrl: '',
    privacyPolicyUrl: '',
  );

  final String discordUrl;
  final String githubUrl;
  final String patreonUrl;
  final String koFiUrl;
  final String buyMeCoffeeUrl;
  final String playStoreUrl;
  final String appName;
  final String translationProjectUrl;
  final String translationStatusUrl;
  final String translationBadgeUrl;
  final String supportEmail;
  final String booruDefUrl;
  final String termsOfServiceUrl;
  final String privacyPolicyUrl;

  final YearRange copyrightYearRange;
  final String author;

  List<String> get donationUrls => [
    patreonUrl,
    koFiUrl,
    buyMeCoffeeUrl,
  ];
}

Future<AppInfo> getAppInfo() async {
  try {
    final data = await rootBundle.loadString(_assetUrl);

    return AppInfo.fromJson(json.decode(data));
  } catch (e) {
    return AppInfo.empty;
  }
}
