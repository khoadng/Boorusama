// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../configs/config.dart';
import 'analytics_network_info.dart';

bool defaultBooruRouteFilter(Route<dynamic>? route) =>
    route is PageRoute ||
    route is ModalBottomSheetRoute ||
    route is DialogRoute;

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
