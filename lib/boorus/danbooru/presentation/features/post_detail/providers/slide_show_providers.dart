class SlideShowConfiguration {
  SlideShowConfiguration({
    required this.interval,
    required this.skipAnimation,
  });
  final num interval;
  final bool skipAnimation;

  SlideShowConfiguration copyWith({
    num? interval,
    bool? skipAnimation,
  }) =>
      SlideShowConfiguration(
        interval: interval ?? this.interval,
        skipAnimation: skipAnimation ?? this.skipAnimation,
      );
}
