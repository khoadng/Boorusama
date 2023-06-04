mixin DebounceMixin {
  final Map<String, DateTime> _lastInvocationTimeMap = {};

  void debounce<T>(
    String key,
    Function function, {
    Duration duration = const Duration(milliseconds: 350),
  }) {
    final now = DateTime.now();

    if (_lastInvocationTimeMap.containsKey(key)) {
      final timeSinceLastInvocation =
          now.difference(_lastInvocationTimeMap[key]!);

      if (timeSinceLastInvocation < duration) {
        return;
      }
    }

    _lastInvocationTimeMap[key] = now;
    function();
  }
}
