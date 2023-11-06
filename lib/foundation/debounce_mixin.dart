// Dart imports:
import 'dart:async';

mixin DebounceMixin {
  final Map<String, Timer> _timers = {};

  void debounce<T>(
    String key,
    Function function, {
    Duration duration = const Duration(milliseconds: 350),
  }) {
    if (_timers.containsKey(key)) {
      _timers[key]?.cancel();
    }

    _timers[key] = Timer(
      duration,
      () {
        function();
        _timers.remove(key);
      },
    );
  }
}
