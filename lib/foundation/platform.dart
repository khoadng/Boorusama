// Flutter imports:
import 'package:flutter/foundation.dart';

final _platform = defaultTargetPlatform;

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
