// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/platform.dart';
import '../settings/providers.dart';

class BooruAnchor extends ConsumerWidget {
  const BooruAnchor({
    required this.controller,
    required this.overlayBuilder,
    required this.child,
    super.key,
    this.placement = Placement.bottom,
    this.viewPadding,
    this.backgroundColor,
    this.onShow,
    this.onHide,
    this.spacing,
    this.backdropColor,
    this.reduceAnimation,
  });

  final AnchorController controller;
  final WidgetBuilder overlayBuilder;
  final Widget child;
  final Placement placement;
  final EdgeInsets? viewPadding;
  final Color? backgroundColor;
  final VoidCallback? onShow;
  final VoidCallback? onHide;
  final double? spacing;
  final Color? backdropColor;
  final bool? reduceAnimation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final shouldReduceAnimation =
        reduceAnimation ??
        ref.watch(
          settingsProvider.select((value) => value.reduceAnimations),
        );

    final isDesktop = isDesktopPlatform();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) => PopScope(
        canPop: !controller.isShowing,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && controller.isShowing) {
            controller.hide();
          }
        },
        child: child!,
      ),
      child: AnchorPopover(
        controller: controller,
        arrowShape: const NoArrow(),
        placement: placement,
        transitionBuilder: isDesktop || (shouldReduceAnimation ?? false)
            ? null
            : (context, animation, child) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  alignment: switch (AnchorData.of(
                    context,
                  ).geometry.direction) {
                    AxisDirection.up => Alignment.bottomCenter,
                    AxisDirection.down => Alignment.topCenter,
                    AxisDirection.left => Alignment.centerRight,
                    AxisDirection.right => Alignment.centerLeft,
                  },
                  child: child,
                ),
              ),
        backdropBuilder: (context) => GestureDetector(
          onTap: () {
            controller.hide();
          },
          child: Container(
            color:
                backdropColor ??
                (isDesktop ? Colors.transparent : Colors.black45),
          ),
        ),
        triggerMode: const AnchorTriggerMode.manual(),
        border: BorderSide(
          color: colorScheme.outlineVariant,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        viewPadding:
            viewPadding ??
            (isDesktop ? const EdgeInsets.all(4) : const EdgeInsets.all(12)),
        backgroundColor:
            backgroundColor ?? (isDesktop ? null : colorScheme.surface),
        onShow: onShow,
        onHide: onHide,
        spacing: spacing,
        overlayBuilder: overlayBuilder,
        child: child,
      ),
    );
  }
}
