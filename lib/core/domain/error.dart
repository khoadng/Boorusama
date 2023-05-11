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
