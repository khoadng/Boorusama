// Project imports:
import '../foundation/error.dart';
import 'analytics.dart';
import 'firebase.dart';
import 'settings.dart';

Future<(AnalyticsInterface? analytics, ErrorReporter? reporter)>
    initializeTracking(Settings settings) =>
        ensureFirebaseInitialized(settings);
