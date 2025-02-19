// Project imports:
import '../analytics/analytics_interface.dart';
import '../foundation/errors/reporter.dart';

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
