// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';

final analyticsProvider = Provider<AnalyticsInterface>(
  (ref) => NoAnalyticsInterface(),
);

bool defaultBooruRouteFilter(Route<dynamic>? route) =>
    route is PageRoute ||
    route is ModalBottomSheetRoute ||
    route is DialogRoute;

class AnalyticsNetworkInfo extends Equatable {
  const AnalyticsNetworkInfo({
    required this.types,
    required this.state,
  });

  const AnalyticsNetworkInfo.error(String message)
      : types = 'none',
        state = 'error: $message';

  const AnalyticsNetworkInfo.connected(this.types) : state = 'connected';

  const AnalyticsNetworkInfo.disconnected()
      : types = 'none',
        state = 'disconnected';

  final String types;
  final String state;

  @override
  List<Object> get props => [types, state];
}

abstract interface class AnalyticsInterface {
  bool get enabled;
  bool isPlatformSupported();
  Future<void> ensureInitialized();
  Future<void> changeCurrentAnalyticConfig(BooruConfig config);
  Future<void> updateNetworkInfo(AnalyticsNetworkInfo info);
  NavigatorObserver getAnalyticsObserver();
  void sendBooruAddedEvent({
    required String url,
    required String hintSite,
    required int totalSites,
    required bool hasLogin,
  });

  Future<void> logScreenView(String screenName);
}

class NoAnalyticsInterface implements AnalyticsInterface {
  @override
  bool get enabled => false;

  @override
  bool isPlatformSupported() => false;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<void> changeCurrentAnalyticConfig(BooruConfig config) async {}

  @override
  Future<void> updateNetworkInfo(AnalyticsNetworkInfo info) async {}

  @override
  NavigatorObserver getAnalyticsObserver() => NavigatorObserver();

  @override
  Future<void> sendBooruAddedEvent({
    required String url,
    required String hintSite,
    required int totalSites,
    required bool hasLogin,
  }) async {}

  @override
  Future<void> logScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {}
}

class DebugPrintAnalyticsImpl implements AnalyticsInterface {
  DebugPrintAnalyticsImpl({
    this.enabled = false,
  });

  BooruConfig? _currentConfig;

  @override
  final bool enabled;

  @override
  bool isPlatformSupported() => enabled;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<void> changeCurrentAnalyticConfig(BooruConfig config) async {
    if (!enabled) return;
    _currentConfig = config;
  }

  @override
  Future<void> updateNetworkInfo(AnalyticsNetworkInfo info) async {}

  @override
  NavigatorObserver getAnalyticsObserver() => enabled
      ? DebugPrintAnalyticsObserver(
          paramsExtractor: _extractParams,
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
    debugPrint('BooruAddedEvent: $url, $hintSite, $totalSites, $hasLogin');
  }

  @override
  Future<void> logScreenView(String screenName) async {
    if (!enabled) return;
    final params = _extractParams(null);

    _printDebugScreenView(
      screenName,
      parameters: params,
    );
  }

  Map<String, dynamic> _extractParams(RouteSettings? settings) {
    final config = _currentConfig;

    final params = config != null
        ? {
            'hint_site': config.booruType.name,
            'url': config.url,
            'has_login': config.apiKey != null && config.apiKey!.isNotEmpty,
            'rating': config.ratingVerdict,
          }
        : <String, dynamic>{};

    return params;
  }
}

class AnalyticsScope extends ConsumerWidget {
  const AnalyticsScope({
    super.key,
    required this.builder,
  });

  final Widget Function(bool analyticsEnabled) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final enabled = analytics.enabled;

    ref.listen(
      currentBooruConfigProvider,
      (p, c) {
        if (p != c) {
          if (enabled) {
            analytics.changeCurrentAnalyticConfig(c);
          }
        }
      },
    );

    return builder(enabled);
  }
}

void _printDebugScreenView(
  String screenName, {
  Map<String, dynamic>? parameters,
}) {
  debugPrint('ScreenView: [$screenName] with parameters: $parameters');
}

typedef ScreenNameExtractor = String? Function(RouteSettings settings);

String? defaultNameExtractor(RouteSettings settings) => settings.name;

typedef RouteFilter = bool Function(Route<dynamic>? route);

Map<String, String> defaultParamsExtractor(RouteSettings settings) => {};

class DebugPrintAnalyticsObserver extends RouteObserver<ModalRoute<dynamic>> {
  DebugPrintAnalyticsObserver({
    this.nameExtractor = defaultNameExtractor,
    this.routeFilter = defaultBooruRouteFilter,
    this.paramsExtractor = defaultParamsExtractor,
  });

  final ScreenNameExtractor nameExtractor;
  final RouteFilter routeFilter;
  final Map<String, dynamic> Function(RouteSettings settings) paramsExtractor;

  void _sendScreenView(Route<dynamic> route) {
    final screenName = nameExtractor(route.settings);
    if (screenName != null) {
      final params = paramsExtractor(route.settings);
      _printDebugScreenView(screenName, parameters: params);
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
