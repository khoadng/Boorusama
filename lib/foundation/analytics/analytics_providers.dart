// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'analytics_interface.dart';

final analyticsProvider = Provider<AnalyticsInterface>(
  (ref) => NoAnalyticsInterface(),
);
