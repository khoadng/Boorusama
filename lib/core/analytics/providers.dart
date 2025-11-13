// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../configs/config/types.dart';
import '../tracking/providers.dart';
import 'analytics_interface.dart';
import 'analytics_network_info.dart';
import 'analytics_view_info.dart';
import 'download.dart';

final analyticsProvider = FutureProvider<AnalyticsInterface?>(
  (ref) async {
    final tracker = await ref.watch(trackerProvider.future);

    return tracker?.analytics;
  },
);

final analyticsDownloadObserverProvider =
    Provider.family<AnalyticsDownloadObserver, BooruConfigAuth>((ref, config) {
      return AnalyticsDownloadObserver(
        analytics: ref
            .watch(analyticsProvider)
            .whenOrNull(data: (data) => data),
        getConfig: () => config,
      );
    });

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
  Future<void> updateViewInfo(AnalyticsViewInfo info) async {}

  @override
  NavigatorObserver getAnalyticsObserver() => NavigatorObserver();

  @override
  Future<void> logScreenView(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {}

  @override
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {}
}
