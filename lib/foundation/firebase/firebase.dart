// Package imports:
import 'package:firebase_core/firebase_core.dart';

// Project imports:
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/error.dart';
import 'firebase_analytics.dart';
import 'firebase_crashlytics.dart';
import 'firebase_options.dart';

export 'firebase_analytics.dart';
export 'firebase_crashlytics.dart';

Future<(AnalyticsInterface analytics, ErrorReporter reporter)>
    ensureFirebaseInitialized() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseAnalytics = FirebaseAnalyticsImpl();
  final crashlyticsReporter = FirebaseCrashlyticsReporter();

  await firebaseAnalytics.ensureInitialized();
  await crashlyticsReporter.enstureInitialized();

  return (firebaseAnalytics, crashlyticsReporter);
}
