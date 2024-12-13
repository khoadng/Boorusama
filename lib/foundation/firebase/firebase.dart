// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';

// Project imports:
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/firebase/firebase_options_dev.dart' as dev;
import '../loggers/loggers.dart';
import 'firebase_analytics.dart';
import 'firebase_crashlytics.dart';

import 'package:boorusama/foundation/firebase/firebase_options_prod.dart'
    as prod;

export 'firebase_analytics.dart';
export 'firebase_crashlytics.dart';

const _kEnv = String.fromEnvironment('ENV_NAME', defaultValue: '');

Future<(AnalyticsInterface? analytics, ErrorReporter? reporter)>
    ensureFirebaseInitialized(
  Settings settings, {
  Logger? logger,
}) async {
  final options = _tryGetFirebaseOptions(_kEnv, logger);

  if (options == null) {
    logger?.logW('Firebase', 'Firebase options are not available, skipping');
    return (null, null);
  }

  // Always initialize to prevent crashings
  await Firebase.initializeApp(
    options: options,
  );

  final dataCollectingStatus = settings.dataCollectingStatus;
  final isEnabled =
      isFirebaseEnabled(dataCollectingStatus: dataCollectingStatus);

  final firebaseAnalytics = FirebaseAnalyticsImpl(
    enabled: isEnabled,
  );
  final crashlyticsReporter = FirebaseCrashlyticsReporter(
    isRemoteErrorReportingSupported: isEnabled,
  );

  await firebaseAnalytics.ensureInitialized();
  await crashlyticsReporter.enstureInitialized();

  if (isEnabled) {
    logger?.logI('Firebase', 'All Firebase services are initialized');
    return (firebaseAnalytics, crashlyticsReporter);
  } else {
    logger?.logW(
      'Firebase',
      'Firebase is disabled: status=$dataCollectingStatus, release=$kReleaseMode',
    );
    return (null, null);
  }
}

bool isFirebaseEnabled({
  required DataCollectingStatus dataCollectingStatus,
}) =>
    dataCollectingStatus == DataCollectingStatus.allow &&
    (kProfileMode || kReleaseMode);

FirebaseOptions? _tryGetFirebaseOptions(String env, Logger? logger) {
  try {
    final options = switch (_kEnv) {
      'prod' => prod.DefaultFirebaseOptions.currentPlatform,
      'dev' => dev.DefaultFirebaseOptions.currentPlatform,
      _ => throw UnsupportedError('Invalid environment: $_kEnv'),
    };

    return options;
  } catch (e) {
    logger?.logE('Firebase', 'Failed to get Firebase options: $e');
    return null;
  }
}
