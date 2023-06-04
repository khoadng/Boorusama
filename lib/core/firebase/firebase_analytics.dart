// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';

// Project imports:
import 'package:boorusama/core/platform.dart';

bool isFirebaseAnalyticsSupportedPlatforms() =>
    isAndroid() || isIOS() || isMacOS() || isWeb();

Future<void> initializeFirebaseAnalytics() async {
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
}
