// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/settings/settings.dart';

final analyticsProvider = Provider<AnalyticsInterface>(
  (ref) => NoAnalyticsInterface(),
);

abstract interface class AnalyticsInterface {
  bool isPlatformSupported();
  Future<void> ensureInitialized();
  void changeCurrentAnalyticConfig(BooruConfig config);
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
  bool isPlatformSupported() => false;

  @override
  Future<void> ensureInitialized() async {}

  @override
  void changeCurrentAnalyticConfig(BooruConfig config) {}

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

bool isAnalyticsEnabled({
  required DataCollectingStatus dataCollectingStatus,
  required AnalyticsInterface analytics,
}) =>
    dataCollectingStatus == DataCollectingStatus.allow &&
    kReleaseMode &&
    analytics.isPlatformSupported();

Future<void> initializeAnalytics(
  Settings settings,
  AnalyticsInterface analytics,
) async {
  if (isAnalyticsEnabled(
    dataCollectingStatus: settings.dataCollectingStatus,
    analytics: analytics,
  )) {
    await analytics.ensureInitialized();
  }
}

class AnalyticsScope extends ConsumerWidget {
  const AnalyticsScope({
    super.key,
    required this.settings,
    required this.analytics,
    required this.builder,
  });

  final Settings settings;
  final AnalyticsInterface analytics;
  final Widget Function(bool anlyticsEnabled) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = isAnalyticsEnabled(
      dataCollectingStatus: settings.dataCollectingStatus,
      analytics: analytics,
    );

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
