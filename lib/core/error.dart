// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Project imports:
import 'package:boorusama/core/domain/settings/settings.dart';
import 'firebase.dart';

void initializeErrorHandlers(Settings settings) {
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (details) {
    if (kReleaseMode &&
        isFirebaseCrashlyticsSupportedPlatforms() &&
        settings.dataCollectingStatus == DataCollectingStatus.allow) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);

      return;
    }

    FlutterError.presentError(details);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode &&
        isFirebaseCrashlyticsSupportedPlatforms() &&
        settings.dataCollectingStatus == DataCollectingStatus.allow) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }

    return true;
  };
}
