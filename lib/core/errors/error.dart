// Package imports:
import 'package:equatable/equatable.dart';

enum AppErrorType {
  cannotReachServer,
  loadDataFromServerFailed,
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
    required this.message,
  });

  final int? httpStatusCode;
  final dynamic message;

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
  bool get isServerError => httpStatusCode! >= 500 && httpStatusCode! < 600;
}
