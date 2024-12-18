// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

// Project imports:
import '../analytics.dart';
import '../configs/config.dart';
import '../foundation/loggers.dart';
import '../foundation/platform.dart';

class FirebaseAnalyticsImpl implements AnalyticsInterface {
  FirebaseAnalyticsImpl({
    required this.enabled,
    this.logger,
  });

  final Logger? logger;

  @override
  final bool enabled;

  @override
  bool isPlatformSupported() =>
      isAndroid() || isIOS() || isMacOS() || isWeb() || isWindows();

  bool isFirebasePerformanceSupported() => isAndroid() || isIOS() || isWeb();

  @override
  Future<void> ensureInitialized() async {
    if (isPlatformSupported()) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
    } else {
      logger?.logE('FirebaseAnalytics', 'Platform is not supported');
    }

    if (isFirebasePerformanceSupported()) {
      await FirebasePerformance.instance
          .setPerformanceCollectionEnabled(enabled);
    } else {
      logger?.logE('FirebaseAnalytics', 'Platform is not supported');
    }
  }

  @override
  Future<void> changeCurrentAnalyticConfig(BooruConfig config) async {
    if (enabled) {
      await FirebaseCrashlytics.instance.setCustomKey('url', config.url);
    }
  }

  @override
  Future<void> updateNetworkInfo(AnalyticsNetworkInfo info) async {
    if (enabled) {
      await FirebaseCrashlytics.instance
          .setCustomKey('network_types', info.types);
      await FirebaseCrashlytics.instance
          .setCustomKey('network_state', info.state);
    }
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
    if (enabled) {
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
}
