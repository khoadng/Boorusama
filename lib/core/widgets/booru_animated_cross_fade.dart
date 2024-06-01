// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';

class BooruAnimatedCrossFade extends ConsumerWidget {
  const BooruAnimatedCrossFade({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.crossFadeState,
    this.duration,
  });

  final Widget firstChild;
  final Widget secondChild;
  final CrossFadeState crossFadeState;
  final Duration? duration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceAnimations =
        ref.watch(settingsProvider.select((value) => value.reduceAnimations));

    if (reduceAnimations) {
      return crossFadeState == CrossFadeState.showFirst
          ? firstChild
          : secondChild;
    }

    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState: crossFadeState,
      duration: duration ?? const Duration(milliseconds: 250),
    );
  }
}
