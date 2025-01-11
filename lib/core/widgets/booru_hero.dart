// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../settings/providers.dart';

class BooruHero extends ConsumerWidget {
  const BooruHero({
    required this.tag,
    required this.child,
    super.key,
  });

  final Widget child;
  final String? tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceAnimations =
        ref.watch(settingsProvider.select((value) => value.reduceAnimations));
    final heroTag = tag;

    return heroTag != null && !reduceAnimations
        ? Hero(
            tag: heroTag,
            createRectTween: (begin, end) =>
                LinearRectTween(begin: begin, end: end),
            child: child,
          )
        : child;
  }
}

class LinearRectTween extends RectTween {
  LinearRectTween({super.begin, super.end});

  @override
  Rect lerp(double t) {
    final rect = Rect.lerp(begin, end, t);

    if (rect == null) {
      return Rect.zero;
    }

    return rect;
  }
}
