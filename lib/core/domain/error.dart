// Package imports:
import 'package:equatable/equatable.dart';

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
