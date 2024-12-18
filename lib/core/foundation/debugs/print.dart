mixin DebugPrintMixin {
  bool get debugPrintEnabled;

  String get debugTargetName;

  void printDebug(String message) {
    if (debugPrintEnabled) {
      // ignore: avoid_print
      print('[$debugTargetName] $message');
    }
  }
}
