// Project imports:
import '../../foundation/error_monitor.dart';
import '../analytics/providers.dart';
import '../analytics/types.dart';

abstract class Tracker {
  AnalyticsInterface get analytics;
  ErrorReporter get reporter;
}

class DummyTracker implements Tracker {
  @override
  final AnalyticsInterface analytics = NoAnalyticsInterface();

  @override
  final ErrorReporter reporter = NoErrorReporter();
}
