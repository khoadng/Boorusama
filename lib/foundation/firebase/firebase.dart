// Package imports:
import 'package:firebase_core/firebase_core.dart';

// Project imports:
import 'firebase_analytics.dart';
import 'firebase_crashlytics.dart';
import 'firebase_options.dart';

export 'firebase_analytics.dart';
export 'firebase_crashlytics.dart';

// ignore: no-empty-block
Future<void> ensureFirebaseInitialized() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeFirebaseCrashlytics();
  await initializeFirebaseAnalytics();
}
