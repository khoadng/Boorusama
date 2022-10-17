enum AppError {
  cannotReachServer,
  failedToParseJSON,
}

enum BooruErrorType {
  server,
  client,
}

class BooruError extends Error {
  BooruError({
    required this.type,
    required this.error,
  }) : super();

  final BooruErrorType type;
  final Object error;
}
