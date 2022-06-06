class SlideShowConfiguration {
  SlideShowConfiguration({
    required this.interval,
    required this.skipAnimation,
  });
  final int interval;
  final bool skipAnimation;

  SlideShowConfiguration copyWith({
    interval,
    skipAnimation,
  }) =>
      SlideShowConfiguration(
        interval: interval ?? this.interval,
        skipAnimation: skipAnimation ?? this.skipAnimation,
      );
}
