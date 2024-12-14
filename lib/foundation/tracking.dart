// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';
import 'firebase/firebase.dart';

export 'firebase/firebase.dart';

Future<(AnalyticsInterface? analytics, ErrorReporter? reporter)>
    initializeTracking(
  Settings settings, {
  Logger? logger,
}) =>
        ensureFirebaseInitialized(
          settings,
          logger: logger,
        );
