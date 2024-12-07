// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/core/settings.dart';
import 'reporter.dart';

void initializeErrorHandlers(Settings settings, ErrorReporter? reporter) {
  if (reporter == null) return;

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = onUncaughtError(
    reporter,
    settings,
  );

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = onAsyncFlutterUncaughtError(
    reporter,
    settings,
  );
}

FlutterExceptionHandler? onUncaughtError(
  ErrorReporter reporter,
  Settings settings,
) =>
    (details) {
      if (kReleaseMode &&
          reporter.isRemoteErrorReportingSupported &&
          settings.dataCollectingStatus == DataCollectingStatus.allow) {
        // Ignore 304 errors
        if (details.exception is DioException) {
          final exception = details.exception as DioException;
          if (exception.response?.statusCode == 304) return;
        }

        // Ignore image service errors
        if (details.library == 'image resource service') return;

        reporter.recordFlutterFatalError(details);

        return;
      }

      FlutterError.presentError(details);
    };

ErrorCallback? onAsyncFlutterUncaughtError(
  ErrorReporter reporter,
  Settings settings,
) =>
    (error, stack) {
      if (kReleaseMode &&
          reporter.isRemoteErrorReportingSupported &&
          settings.dataCollectingStatus == DataCollectingStatus.allow) {
        // Ignore 304 errors
        if (error is DioException) {
          if (error.response?.statusCode == 304) return true;
        }

        reporter.recordError(error, stack);
      }

      return true;
    };
