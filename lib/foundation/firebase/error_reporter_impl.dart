// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Project imports:
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/firebase/firebase.dart';

class FirebaseCrashlyticsReporter implements ErrorReporter {
  @override
  bool get isRemoteErrorReportingSupported =>
      isFirebaseCrashlyticsSupportedPlatforms();

  @override
  void recordFlutterFatalError(FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  }

  @override
  void recordError(error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
  }
}
