// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Project imports:
import 'package:boorusama/core/platform.dart';

bool isFirebaseCrashlyticsSupportedPlatforms() =>
    isAndroid() || isIOS() || isMacOS();

Future<void> initializeFirebaseCrashlytics() async {
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  await FirebaseCrashlytics.instance
      .setCustomKey('locale', Platform.localeName);

  await FirebaseCrashlytics.instance
      .setCustomKey('time-zone-name', DateTime.now().timeZoneName);

  await FirebaseCrashlytics.instance
      .setCustomKey('time-zone-offset', DateTime.now().timeZoneOffset);
}
