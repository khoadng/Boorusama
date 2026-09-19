// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';

final _platform = defaultTargetPlatform;

enum AppPlatform {
  android,
  ios,
  macos,
  windows,
  linux,
  web,
  unknown,
}

final appPlatformProvider = Provider<AppPlatform>(
  (_) => throw UnimplementedError(),
  name: 'appPlatformProvider',
);

extension AppPlatformX on AppPlatform {
  bool get isAndroid => this == AppPlatform.android;

  bool get isIOS => this == AppPlatform.ios;

  bool get isDesktop => switch (this) {
    AppPlatform.macos || AppPlatform.windows || AppPlatform.linux => true,
    AppPlatform.android ||
    AppPlatform.ios ||
    AppPlatform.web ||
    AppPlatform.unknown => false,
  };

  bool get isMobile => isAndroid || isIOS;

  bool get supportsEmbeddedWebView => switch (this) {
    AppPlatform.android ||
    AppPlatform.ios ||
    AppPlatform.macos ||
    AppPlatform.windows => true,
    AppPlatform.linux || AppPlatform.web || AppPlatform.unknown => false,
  };

  String get wireName => switch (this) {
    AppPlatform.android => 'android',
    AppPlatform.ios => 'ios',
    AppPlatform.macos => 'macos',
    AppPlatform.windows => 'windows',
    AppPlatform.linux => 'linux',
    AppPlatform.web => 'web',
    AppPlatform.unknown => 'unknown',
  };
}

bool isAndroid() => isNotWeb() && _platform == TargetPlatform.android;
bool isIOS() => isNotWeb() && _platform == TargetPlatform.iOS;
bool isApple() => isNotWeb() && (isIOS() || isMacOS());
bool isLinux() => isNotWeb() && _platform == TargetPlatform.linux;
bool isMacOS() => isNotWeb() && _platform == TargetPlatform.macOS;
bool isWindows() => isNotWeb() && _platform == TargetPlatform.windows;
bool isWeb() => kIsWeb;
bool isNotWeb() => !kIsWeb;

bool isDesktopPlatform() => Kurumi.isDesktopPlatform();
bool isMobilePlatform() => Kurumi.isMobilePlatform();

bool hasStatusBar() => isMobilePlatform();

AppPlatform currentAppPlatform() {
  if (isWeb()) return AppPlatform.web;
  if (isAndroid()) return AppPlatform.android;
  if (isIOS()) return AppPlatform.ios;
  if (isMacOS()) return AppPlatform.macos;
  if (isWindows()) return AppPlatform.windows;
  if (isLinux()) return AppPlatform.linux;

  return AppPlatform.unknown;
}
