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
}
