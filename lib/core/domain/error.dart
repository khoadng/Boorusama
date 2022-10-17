enum AppErrorType {
  cannotReachServer,
  failedToParseJSON,
  unknown,
}

class AppError extends Error {
  AppError({
    required this.type,
  });

  final AppErrorType type;

  void when({
    void Function()? cannotReachServer,
    void Function()? failedToParseJSON,
    void Function()? unknown,
  }) {
    if (type == AppErrorType.cannotReachServer) {
      cannotReachServer?.call();
    } else if (type == AppErrorType.failedToParseJSON) {
      failedToParseJSON?.call();
    } else {
      unknown?.call();
    }
  }
}

class ServerError extends Error {
  ServerError({
    required this.httpStatusCode,
  });

  final int? httpStatusCode;
}

class BooruError extends Error {
  BooruError({
    required this.error,
  }) : super();

  final Object error;

  void when({
    required void Function(AppError error)? appError,
    required void Function(ServerError error)? serverError,
    required void Function(Object error)? unknownError,
  }) {
    if (error is AppError) {
      appError?.call(error as AppError);
    } else if (error is ServerError) {
      serverError?.call(error as ServerError);
    } else {
      unknownError?.call(error);
    }
  }
}
