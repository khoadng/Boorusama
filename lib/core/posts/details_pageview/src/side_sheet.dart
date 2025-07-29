// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../theme.dart';
import 'constants.dart';
import 'post_details_page_view_controller.dart';

class SideSheet extends StatefulWidget {
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
  State<SideSheet> createState() => _SideSheetState();
}

class _SideSheetState extends State<SideSheet> {
  final _animating = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    widget.animationController?.addStatusListener(_onAnimationStatusChanged);
  }

  @override
  void dispose() {
    _animating.dispose();
    widget.animationController?.removeStatusListener(_onAnimationStatusChanged);

    super.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    _animating.value = status.isAnimating;
  }

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
          valueListenable: widget.controller.cooldown,
          builder: (_, cooldown, _) => cooldown
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : widget.sheetBuilder(context, null),
        ),
      ),
    );

    return ValueListenableBuilder(
      valueListenable: _animating,
      builder: (_, animating, _) => animating
          ? ValueListenableBuilder(
              valueListenable: widget.controller.sheetState,
              builder: (_, state, _) => switch (state) {
                // collapsed -> expanded, don't show the side sheet to prevent building it while animating
                SheetState.collapsed => const SizedBox.shrink(),
                _ => child,
              },
              child: child,
            )
          : ValueListenableBuilder(
              valueListenable: widget.controller.sheetState,
              builder: (_, state, _) => switch (state) {
                SheetState.expanded => child,
                SheetState.collapsed => const SizedBox.shrink(),
                SheetState.hidden => Offstage(
                  child: child,
                ),
              },
            ),
    );
  }
}
