// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Project imports:
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/package_info.dart';
import 'package:boorusama/foundation/platform.dart';

class FirebaseCrashlyticsReporter implements ErrorReporter {
  @override
  bool get isRemoteErrorReportingSupported =>
      isAndroid() || isIOS() || isMacOS();

  @override
  void recordFlutterFatalError(FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  }

  @override
  void recordError(error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
  }

  Future<void> enstureInitialized() async {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    await FirebaseCrashlytics.instance
        .setCustomKey('locale', Platform.localeName);

    await FirebaseCrashlytics.instance
        .setCustomKey('time-zone-name', DateTime.now().timeZoneName);

    await FirebaseCrashlytics.instance.setCustomKey(
        'time-zone-offset', DateTime.now().timeZoneOffset.inHours);

    await FirebaseCrashlytics.instance
        .setCustomKey('environment', kEnvironment);
  }
}
