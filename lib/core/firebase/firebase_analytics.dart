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

  BooruConfig? _currentConfig;
  AnalyticsViewInfo? _deviceInfo;

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
    _currentConfig = config;

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
  Future<void> updateViewInfo(AnalyticsViewInfo info) async {
    if (!enabled) return;
    _deviceInfo = info;
  }

  @override
  NavigatorObserver getAnalyticsObserver() => enabled
      ? AppAnalyticsObserver(
          analytics: FirebaseAnalytics.instance,
          paramsExtractor: (settings) => defaultParamsExtractor(
            _currentConfig,
            _deviceInfo,
          ),
        )
      : NavigatorObserver();

  @override
  Future<void> logScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!enabled) return;

    return FirebaseAnalytics.instance._logScreenView(
      screenName: screenName,
      parameters: parameters != null && parameters.isNotEmpty
          ? {
              ...parameters,
            }
          : null,
    );
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!enabled) return;

    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters != null && parameters.isNotEmpty
            ? {
                ...parameters,
              }
            : null,
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        logger?.logE('FirebaseAnalytics', 'Failed to log event: $name, $e');
      }
    }
  }
}

extension FirebaseAnalyticsX on FirebaseAnalytics {
  Future<void> _logScreenView({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await logScreenView(
        screenName: screenName,
        parameters: parameters != null && parameters.isNotEmpty
            ? {
                ...parameters,
              }
            : null,
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('FirebaseAnalytics: Failed to log screen view: $e');
      }
    }
  }
}

typedef ScreenNameExtractor = String? Function(RouteSettings settings);

String? defaultNameExtractor(RouteSettings settings) => settings.name;

class AppAnalyticsObserver extends RouteObserver<ModalRoute<dynamic>> {
  AppAnalyticsObserver({
    required this.analytics,
    required this.paramsExtractor,
  });

  final FirebaseAnalytics analytics;
  final routeFilter = defaultBooruRouteFilter;
  final Map<String, dynamic> Function(RouteSettings settings) paramsExtractor;

  void _sendScreenView(Route<dynamic> route) {
    final screenName = defaultNameExtractor(route.settings);

    if (screenName != null) {
      analytics._logScreenView(
        screenName: screenName,
        parameters: paramsExtractor(route.settings),
      );
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (routeFilter(route)) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null && routeFilter(newRoute)) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null &&
        routeFilter(previousRoute) &&
        routeFilter(route)) {
      _sendScreenView(previousRoute);
    }
  }
}
