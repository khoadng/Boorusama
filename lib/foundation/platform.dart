// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

bool isAndroid() => isNotWeb() && Platform.isAndroid;
bool isIOS() => isNotWeb() && Platform.isIOS;
bool isApple() => isNotWeb() && (isIOS() || isMacOS());
bool isLinux() => isNotWeb() && Platform.isLinux;
bool isMacOS() => isNotWeb() && Platform.isMacOS;
bool isWindows() => isNotWeb() && Platform.isWindows;
bool isWeb() => kIsWeb;
bool isNotWeb() => !kIsWeb;

bool isDesktopPlatform() =>
    isNotWeb() && (isMacOS() || isWindows() || isLinux());
bool isMobilePlatform() => isAndroid() || isIOS();

bool hasStatusBar() => isMobilePlatform();
