// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';

// Project imports:
import 'package:boorusama/foundation/platform.dart';

bool isFirebaseAnalyticsSupportedPlatforms() =>
    isAndroid() || isIOS() || isMacOS() || isWeb();

Future<void> initializeFirebaseAnalytics() async {
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);
}

Future<void> sendBooruAddedEvent({
  required String url,
  required String hintSite,
  required int totalSites,
  required bool hasLogin,
}) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'site_add',
    parameters: {
      'url': url,
      'total_sites': totalSites,
      'hint_site': hintSite,
      'has_login': hasLogin,
    },
  );
}
