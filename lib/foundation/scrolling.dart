// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';

class NoOverscrollBehavior extends ScrollBehavior {
  const NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

class ScrollBehaviorBuilder extends ConsumerWidget {
  const ScrollBehaviorBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, ScrollBehavior? behavior) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceAnimations =
        ref.watch(settingsProvider.select((value) => value.reduceAnimations));

    return builder(
      context,
      reduceAnimations ? const NoOverscrollBehavior() : null,
    );
  }
}
