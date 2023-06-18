// Dart imports:
import 'dart:core';
import 'dart:developer';

mixin BenchmarkMixin {
  R benchmark<R>(
    R Function() function, {
    String description = '',
    void Function(Duration elapsed)? onResult,
  }) {
    final stopwatch = Stopwatch()..start();
    final result = function();
    stopwatch.stop();

    final elapsed = stopwatch.elapsed;

    if (onResult != null) {
      onResult(elapsed);
    } else {
      log('$description execution time: $elapsed ms');
    }

    return result;
  }
}
