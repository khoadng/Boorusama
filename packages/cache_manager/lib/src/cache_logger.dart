class CacheLogger {
  CacheLogger({
    required this.tag,
    this.enableLogging = false,
  });

  final String tag;
  final bool enableLogging;

  void log(String message) {
    if (!enableLogging) return;

    print('[$tag] $message');
  }
}
