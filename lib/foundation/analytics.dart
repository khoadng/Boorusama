// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'firebase/firebase.dart';

export 'firebase/firebase.dart';

bool isAnalyticsEnabled({
  required DataCollectingStatus dataCollectingStatus,
}) =>
    dataCollectingStatus == DataCollectingStatus.allow &&
    kReleaseMode &&
    isFirebaseAnalyticsSupportedPlatforms();

NavigatorObserver getAnalyticsObserver() => FirebaseAnalyticsObserver(
      analytics: FirebaseAnalytics.instance,
    );

Future<void> initializeAnalytics(Settings settings) async {
  if (isAnalyticsEnabled(dataCollectingStatus: settings.dataCollectingStatus)) {
    await ensureFirebaseInitialized();
  }
}

class AnalyticsScope extends ConsumerWidget {
  const AnalyticsScope({
    super.key,
    required this.settings,
    required this.builder,
  });

  final Settings settings;
  final Widget Function(bool anlyticsEnabled) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = isAnalyticsEnabled(
      dataCollectingStatus: settings.dataCollectingStatus,
    );

    ref.listen(
      currentBooruConfigProvider,
      (p, c) {
        if (p != c) {
          if (enabled) {
            changeCurrentAnalyticConfig(c);
          }
        }
      },
    );

    return builder(enabled);
  }
}
