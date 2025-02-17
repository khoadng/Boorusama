// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../tracking.dart';
import 'analytics_interface.dart';

final analyticsProvider = FutureProvider<AnalyticsInterface>(
  (ref) async {
    final tracker = await ref.watch(trackerProvider.future);

    return tracker.analytics;
  },
);
