// Dart imports:
import 'dart:math';

extension IntX on int {
  int digitCount({
    double epsilonOffset = 0.0000000001,
  }) {
    if (this == 0) return 1;

    // Adding a small epsilon before flooring
    return (log(abs()) / ln10 + epsilonOffset).floor() + 1;
  }
}
