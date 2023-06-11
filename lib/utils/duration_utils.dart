extension DurationX on Duration {
  double get inPreciseSeconds => inMilliseconds.toDouble() / 1000;
  Future<void> get future => Future.delayed(this);
}
