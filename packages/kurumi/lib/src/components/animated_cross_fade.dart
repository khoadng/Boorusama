import 'package:flutter/material.dart';

import '../theme/theme.dart';

class KurumiAnimatedCrossFade extends StatelessWidget {
  const KurumiAnimatedCrossFade({
    required this.firstChild,
    required this.secondChild,
    required this.crossFadeState,
    super.key,
    this.duration,
  });

  final Widget firstChild;
  final Widget secondChild;
  final CrossFadeState crossFadeState;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        KurumiTheme.maybeBehaviorOf(context)?.reduceMotion ?? false;

    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState: crossFadeState,
      duration: reduceMotion
          ? Duration.zero
          : duration ?? const Duration(milliseconds: 250),
    );
  }
}
