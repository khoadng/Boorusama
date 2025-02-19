// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../configs/config.dart';
import 'analytics_interface.dart';
import 'analytics_network_info.dart';
import 'analytics_view_info.dart';

class DebugPrintAnalyticsImpl implements AnalyticsInterface {
  DebugPrintAnalyticsImpl({
    this.enabled = false,
  });

  BooruConfig? _currentConfig;
  AnalyticsViewInfo? _deviceInfo;

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
  Future<void> updateViewInfo(AnalyticsViewInfo info) async {
    if (!enabled) return;
    _deviceInfo = info;
    debugPrint('Device aspect ratio: ${info.aspectRatio}');
  }

  @override
  NavigatorObserver getAnalyticsObserver() => enabled
      ? DebugPrintAnalyticsObserver(
          paramsExtractor: (settings) => defaultParamsExtractor(
            _currentConfig,
            _deviceInfo,
          ),
        )
      : NavigatorObserver();

  @override
  Future<void> logScreenView(String screenName) async {
    if (!enabled) return;
    final params = defaultParamsExtractor(
      _currentConfig,
      _deviceInfo,
    );

    _printDebugScreenView(
      screenName,
      parameters: params,
    );
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!enabled) return;
    debugPrint('Event: $name with parameters: $parameters');
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

class DebugPrintAnalyticsObserver extends RouteObserver<ModalRoute<dynamic>> {
  DebugPrintAnalyticsObserver({
    required this.paramsExtractor,
    this.nameExtractor = defaultNameExtractor,
    this.routeFilter = defaultBooruRouteFilter,
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
