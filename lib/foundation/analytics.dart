// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/manage/manage.dart';

final analyticsProvider = Provider<AnalyticsInterface>(
  (ref) => NoAnalyticsInterface(),
);

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
