import 'boorusama_runtime.dart';

abstract interface class BoorusamaBootstrap {
  Future<BoorusamaRuntime> initialize();
}

final class BoorusamaBootstrapFailure implements Exception {
  const BoorusamaBootstrapFailure({
    required this.error,
    required this.stackTrace,
    required this.logs,
  });

  final Object error;
  final StackTrace stackTrace;
  final String logs;

  @override
  String toString() => error.toString();
}
