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

export 'firebase_analytics.dart';
export 'firebase_crashlytics.dart';

Future<(AnalyticsInterface? analytics, ErrorReporter? reporter)>
    ensureFirebaseInitialized(Settings settings) async {
  if (!isFirebaseEnabled(dataCollectingStatus: settings.dataCollectingStatus)) {
    return (null, null);
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseAnalytics = FirebaseAnalyticsImpl(
    dataCollectingStatus: settings.dataCollectingStatus,
  );
  final crashlyticsReporter = FirebaseCrashlyticsReporter();

  await firebaseAnalytics.ensureInitialized();
  await crashlyticsReporter.enstureInitialized();

  return (firebaseAnalytics, crashlyticsReporter);
}

bool isFirebaseEnabled({
  required DataCollectingStatus dataCollectingStatus,
}) =>
    dataCollectingStatus == DataCollectingStatus.allow &&
    kReleaseMode &&
    _isFirebasePlatformSupported();

bool _isFirebasePlatformSupported() => isAndroid() || isIOS() || isMacOS();
