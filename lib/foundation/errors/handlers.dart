// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:path/path.dart' show extension;

// Project imports:
import 'reporter.dart';

void initializeErrorHandlers(ErrorReporter? reporter) {
  if (reporter == null) return;

  // Pass all uncaught "fatal" errors from the framework to the reporter
  FlutterError.onError = onUncaughtError(
    reporter,
  );

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to the reporter
  PlatformDispatcher.instance.onError = onAsyncFlutterUncaughtError(
    reporter,
  );
}

FlutterExceptionHandler? onUncaughtError(
  ErrorReporter reporter,
) => (details) {
  if (reporter.isRemoteErrorReportingSupported) {
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
) => (error, stack) {
  if (reporter.isRemoteErrorReportingSupported) {
    if (error is DioException) {
      // Ignore 304 errors
      if (error.response?.statusCode == 304) return true;
      // Ignore image loading errors
      final uri = error.requestOptions.uri.toString();
      if (_isImageUrl(uri)) return true;
    }

    reporter.recordError(error, stack);
  }

  return true;
};

const _kExtensions = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.avif'};

bool _isImageUrl(String url) {
  final ext = sanitizedExtension(url);

  if (ext.isEmpty) return false;

  final effectiveExt = !ext.startsWith('.') ? '.$ext' : ext;

  return _kExtensions.contains(effectiveExt.toLowerCase());
}

String sanitizedExtension(String url) {
  return extension(sanitizedUrl(url));
}

String sanitizedUrl(String url) {
  final ext = extension(url);
  final indexOfQuestionMark = ext.indexOf('?');

  if (indexOfQuestionMark != -1) {
    final trimmedExt = ext.substring(0, indexOfQuestionMark);

    return url.replaceFirst(ext, trimmedExt);
  } else {
    return url;
  }
}
