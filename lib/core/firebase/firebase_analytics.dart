// Flutter imports:
import 'package:flutter/foundation.dart';
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
    try {
      if (isPlatformSupported()) {
        await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);

        if (isFirebasePerformanceSupported()) {
          await FirebasePerformance.instance
              .setPerformanceCollectionEnabled(enabled);
        }
      } else {
        logger?.logE('FirebaseAnalytics', 'Platform is not supported');
      }
    } on Exception catch (e) {
      logger?.logE('FirebaseAnalytics', 'Failed to initialize: $e');
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
          routeFilter: defaultBooruRouteFilter,
        )
      : NavigatorObserver();

  @override
  Future<void> sendBooruAddedEvent({
    required String url,
    required String hintSite,
    required int totalSites,
    required bool hasLogin,
  }) async {
    if (!enabled) return;

    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'site_add',
        parameters: {
          'url': url,
          'total_sites': totalSites,
          'hint_site': hintSite,
          'has_login': hasLogin,
        },
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        logger?.logE('FirebaseAnalytics', 'Failed to log event: site_add, $e');
      }
    }
  }

  @override
  Future<void> logScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!enabled) return;

    try {
      await FirebaseAnalytics.instance.logScreenView(
        screenName: screenName,
        parameters: parameters != null
            ? {
                ...parameters,
              }
            : null,
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        logger?.logE('FirebaseAnalytics', 'Failed to log screen view: $e');
      }
    }
  }
}
