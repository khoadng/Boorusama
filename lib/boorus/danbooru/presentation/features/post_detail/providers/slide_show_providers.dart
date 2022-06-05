// Package imports:
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

final slideShowConfigurationStateProvider =
    StateProvider<SlideShowConfiguration>((ref) {
  return SlideShowConfiguration(interval: 4, skipAnimation: false);
});
