// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import 'analytics_network_info.dart';

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
}
