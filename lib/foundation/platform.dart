// Flutter imports:
import 'package:flutter/foundation.dart';

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

extension AppPlatformX on AppPlatform {
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

bool isDesktopPlatform() =>
    isNotWeb() && (isMacOS() || isWindows() || isLinux());
bool isMobilePlatform() => isAndroid() || isIOS();

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
