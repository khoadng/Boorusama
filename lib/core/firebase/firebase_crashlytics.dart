// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Project imports:
import '../foundation/error.dart';
import '../foundation/loggers.dart';
import '../foundation/platform.dart';
import '../info/package_info.dart';

class FirebaseCrashlyticsReporter implements ErrorReporter {
  FirebaseCrashlyticsReporter({
    required this.isRemoteErrorReportingSupported,
    this.logger,
  });

  final Logger? logger;

  @override
  final bool isRemoteErrorReportingSupported;

  bool isPlatformSupported() => isAndroid() || isIOS() || isMacOS();

  @override
  void recordFlutterFatalError(FlutterErrorDetails details) {
    if (isRemoteErrorReportingSupported) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  }

  @override
  void recordError(error, stackTrace) {
    if (isRemoteErrorReportingSupported) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    }
  }

  Future<void> enstureInitialized() async {
    if (isPlatformSupported()) {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(isRemoteErrorReportingSupported);

      await FirebaseCrashlytics.instance
          .setCustomKey('locale', Platform.localeName);

      await FirebaseCrashlytics.instance
          .setCustomKey('time-zone-name', DateTime.now().timeZoneName);

      await FirebaseCrashlytics.instance.setCustomKey(
        'time-zone-offset',
        DateTime.now().timeZoneOffset.inHours,
      );

      await FirebaseCrashlytics.instance
          .setCustomKey('environment', kEnvironment);
    } else {
      logger?.logE('FirebaseCrashlytics', 'Platform is not supported');
    }
  }
}
