// Project imports:
import 'slideshow_direction.dart';

class SlideshowOptions {
  const SlideshowOptions({
    this.duration = const Duration(seconds: 5),
    this.direction = SlideshowDirection.forward,
    this.skipTransition = false,
  });

  final Duration duration;
  final SlideshowDirection direction;
  final bool skipTransition;
}
