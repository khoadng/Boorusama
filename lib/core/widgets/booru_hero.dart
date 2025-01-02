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
            child: child,
          )
        : child;
  }
}
