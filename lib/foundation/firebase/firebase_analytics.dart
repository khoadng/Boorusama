// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/platform.dart';

class FirebaseAnalyticsImpl implements AnalyticsInterface {
  FirebaseAnalyticsImpl({
    required this.dataCollectingStatus,
  });

  final DataCollectingStatus dataCollectingStatus;

  @override
  bool get enabled =>
      dataCollectingStatus == DataCollectingStatus.allow &&
      kReleaseMode &&
      isPlatformSupported();

  @override
  bool isPlatformSupported() => isAndroid() || isIOS() || isMacOS() || isWeb();

  @override
  Future<void> ensureInitialized() async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> changeCurrentAnalyticConfig(BooruConfig config) async {
    await FirebaseCrashlytics.instance.setCustomKey('url', config.url);
  }

  @override
  NavigatorObserver getAnalyticsObserver() => enabled
      ? FirebaseAnalyticsObserver(
          analytics: FirebaseAnalytics.instance,
        )
      : NavigatorObserver();

  @override
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
}
