extension DurationX on Duration {
  double get inPreciseSeconds => inMilliseconds.toDouble() / 1000;
}
