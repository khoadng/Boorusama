// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';

// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/platform.dart';
import 'firebase_analytics.dart';
import 'firebase_crashlytics.dart';
import 'firebase_options.dart';

Future<(AnalyticsInterface? analytics, ErrorReporter? reporter)>
    ensureFirebaseInitialized(Settings settings) async {
  if (!_isFirebasePlatformSupported()) {
    return (null, null);
  }

  // Always initialize to prevent crashings
  await Firebase.initializeApp(
    name: 'boorusama',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseAnalytics = FirebaseAnalyticsImpl(
    dataCollectingStatus: settings.dataCollectingStatus,
  );
  final crashlyticsReporter = FirebaseCrashlyticsReporter();

  await firebaseAnalytics.ensureInitialized();
  await crashlyticsReporter.enstureInitialized();

  return isFirebaseEnabled(dataCollectingStatus: settings.dataCollectingStatus)
      ? (firebaseAnalytics, crashlyticsReporter)
      : (null, null);
}

bool isFirebaseEnabled({
  required DataCollectingStatus dataCollectingStatus,
}) =>
    dataCollectingStatus == DataCollectingStatus.allow && kReleaseMode;

bool _isFirebasePlatformSupported() => isAndroid() || isIOS() || isMacOS();
