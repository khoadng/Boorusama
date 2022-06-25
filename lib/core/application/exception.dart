class UnknownException implements BooruException {
  UnknownException(this.message);

  @override
  final String message;
}

class BooruException implements Exception {
  BooruException(this.message);

  final String message;
}
