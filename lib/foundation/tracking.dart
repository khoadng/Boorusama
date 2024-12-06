// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/error.dart';
import 'firebase.dart';

Future<(AnalyticsInterface? analytics, ErrorReporter? reporter)>
    initializeTracking(Settings settings) =>
        ensureFirebaseInitialized(settings);
