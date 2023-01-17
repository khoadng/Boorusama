// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Project imports:
import 'package:boorusama/firebase_options.dart';
import 'platform.dart';

bool isFirebaseCrashlyticsSupportedPlatforms() =>
    isAndroid() || isIOS() || isMacOS();
bool isFirebaseAnalyticsSupportedPlatforms() =>
    isAndroid() || isIOS() || isMacOS() || isWeb();

Future<void> ensureFirebaseInitialized() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
}
