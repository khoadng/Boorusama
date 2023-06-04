// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/settings/settings.dart';
import 'firebase/firebase.dart';

enum AppErrorType {
  failedToLoadBooruConfig,
  booruConfigNotFound,
  cannotReachServer,
  failedToParseJSON,
  loadDataFromServerFailed,
  unknown,
}

sealed class BooruError extends Error {}

class AppError extends BooruError with EquatableMixin {
  AppError({
    required this.type,
  });

  final AppErrorType type;

  @override
  String toString() => 'Error: $type';

  @override
  List<Object?> get props => [type];
}

class ServerError extends BooruError with EquatableMixin {
  ServerError({
    required this.httpStatusCode,
  });

  final int? httpStatusCode;

  @override
  String toString() => 'HTTP error with status code $httpStatusCode';

  @override
  List<Object?> get props => [httpStatusCode];
}

class UnknownError extends BooruError {
  UnknownError({
    required this.error,
  }) : super();

  final Object error;

  @override
  String toString() => error.toString();
}

extension ServerErrorX on ServerError {
  bool get isNotFound => httpStatusCode == 404;
  bool get isForbidden => httpStatusCode == 403;
  bool get isUnauthorized => httpStatusCode == 401;
  bool get isBadRequest => httpStatusCode == 400;
  bool get isInternalServerError => httpStatusCode == 500;
  bool get isServiceUnavailable => httpStatusCode == 503;
  bool get isGatewayTimeout => httpStatusCode == 504;

  bool get isClientError => httpStatusCode! >= 400 && httpStatusCode! < 500;
  bool get isServerError => httpStatusCode! >= 500 && httpStatusCode! < 600;
}

void initializeErrorHandlers(Settings settings) {
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (details) {
    if (kReleaseMode &&
        isFirebaseCrashlyticsSupportedPlatforms() &&
        settings.dataCollectingStatus == DataCollectingStatus.allow) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);

      return;
    }

    FlutterError.presentError(details);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kReleaseMode &&
        isFirebaseCrashlyticsSupportedPlatforms() &&
        settings.dataCollectingStatus == DataCollectingStatus.allow) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }

    return true;
  };
}
