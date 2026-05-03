final class CliException implements Exception {
  const CliException(this.message);

  final String message;

  @override
  String toString() => message;
}
