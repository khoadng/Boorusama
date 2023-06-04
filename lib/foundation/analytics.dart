// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/settings/settings.dart';
import 'firebase/firebase.dart';

bool isAnalyticsEnabled(Settings settings) =>
    settings.dataCollectingStatus == DataCollectingStatus.allow &&
    kReleaseMode &&
    isFirebaseAnalyticsSupportedPlatforms();

NavigatorObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(
      analytics: FirebaseAnalytics.instance,
    );

Future<void> initializeAnalytics(Settings settings) async {
  if (isAnalyticsEnabled(settings)) {
    await ensureFirebaseInitialized();
  }
}
