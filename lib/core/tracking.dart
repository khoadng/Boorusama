// Project imports:
import 'analytics.dart';
import 'firebase.dart';
import 'foundation/error.dart';
import 'foundation/loggers.dart';
import 'settings/settings.dart';

Future<(AnalyticsInterface? analytics, ErrorReporter? reporter)>
    initializeTracking(
  Settings settings, {
  Logger? logger,
}) =>
        ensureFirebaseInitialized(
          settings,
          logger: logger,
        );
