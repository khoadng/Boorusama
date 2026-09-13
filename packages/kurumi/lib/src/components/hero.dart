import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

const kKurumiEnableHeroTransition = false;

class KurumiHero extends StatelessWidget {
  const KurumiHero({
    required this.tag,
    required this.child,
    super.key,
  });

  final Widget child;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        KurumiTheme.maybeBehaviorOf(context)?.reduceMotion ?? false;
    final heroTag = tag;

    return kKurumiEnableHeroTransition && heroTag != null && !reduceMotion
        ? Hero(
            tag: heroTag,
            createRectTween: (begin, end) =>
                KurumiLinearRectTween(begin: begin, end: end),
            child: child,
          )
        : child;
  }
}

class KurumiLinearRectTween extends RectTween {
  KurumiLinearRectTween({super.begin, super.end});

  @override
  Rect lerp(double t) {
    final rect = Rect.lerp(begin, end, t);

    if (rect == null) {
      return Rect.zero;
    }

    return rect;
  }
}
