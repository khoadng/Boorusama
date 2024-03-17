// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'firebase.dart';

class FirebaseAnalyticsImpl implements AnalyticsInterface {
  @override
  bool isPlatformSupported() => isFirebaseAnalyticsSupportedPlatforms();

  @override
  Future<void> ensureInitialized() => ensureFirebaseInitialized();

  @override
  void changeCurrentAnalyticConfig(BooruConfig config) {
    changeCurrentAnalyticConfig(config);
  }

  @override
  NavigatorObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
      );

  @override
  Future<void> sendBooruAddedEvent({
    required String url,
    required String hintSite,
    required int totalSites,
    required bool hasLogin,
  }) =>
      sendBooruAddedEvent(
        url: url,
        hintSite: hintSite,
        totalSites: totalSites,
        hasLogin: hasLogin,
      );
}
