// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../themes/theme/types.dart';
import 'constants.dart';
import 'post_details_page_view_controller.dart';

class SideSheet extends StatelessWidget {
  const SideSheet({
    required this.controller,
    required this.sheetBuilder,
    required this.animationController,
    super.key,
  });

  final PostDetailsPageViewController controller;
  final AnimationController? animationController;
  final Widget Function(BuildContext, ScrollController?) sheetBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final child = Container(
      constraints: const BoxConstraints(maxWidth: kSideSheetWidth),
      color: colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: colorScheme.hintColor,
              width: 0.25,
            ),
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: controller.cooldown,
          builder: (_, cooldown, _) => cooldown
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : sheetBuilder(context, null),
        ),
      ),
    );

    final anim = animationController;

    if (anim != null) {
      return AnimatedBuilder(
        animation: anim,
        builder: (_, _) {
          // Show content whenever the panel is visually present (value > 0).
          // This avoids a flash between animation completing and state updating.
          if (anim.value > 0) return child;

          return ValueListenableBuilder(
            valueListenable: controller.sheetState,
            builder: (_, state, _) => switch (state) {
              SheetState.expanded => child,
              SheetState.collapsed => const SizedBox.shrink(),
              SheetState.hidden => Offstage(child: child),
            },
          );
        },
      );
    }

    return ValueListenableBuilder(
      valueListenable: controller.sheetState,
      builder: (_, state, _) => switch (state) {
        SheetState.expanded => child,
        SheetState.collapsed => const SizedBox.shrink(),
        SheetState.hidden => Offstage(child: child),
      },
    );
  }
}
