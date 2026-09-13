import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter/material.dart';

class KurumiTooltip extends StatelessWidget {
  const KurumiTooltip({
    required this.child,
    super.key,
    this.message,
    this.messageWidget,
    this.placement,
    this.spacing,
    this.padding,
  }) : assert(
         message != null || messageWidget != null,
         'Either message or messageWidget must be provided.',
       );

  final String? message;
  final Widget? messageWidget;
  final Placement? placement;
  final Widget child;
  final double? spacing;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final tooltip = AnchorTooltip.arrow(
      placement: placement,
      triggerMode: const AnchorTriggerMode.hover(),
      arrowSize: const Size(12, 4),
      arrowShape: const RoundedArrow(),
      border: BorderSide(
        color: colorScheme.outlineVariant,
        width: 1.5,
      ),
      spacing: spacing ?? 8,
      backgroundColor: colorScheme.surfaceContainerHigh,
      transitionBuilder: (context, animation, child) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final isAppearing = animation.status == AnimationStatus.forward;

          if (isAppearing || animation.status == AnimationStatus.completed) {
            final t = animation.value;
            final scaleValue = Curves.easeOutBack.transform(t);
            final fadeValue = t < 0.2 ? t / 0.2 : 1.0;

            return Opacity(
              opacity: 0.3 + (0.7 * fadeValue),
              child: Transform.scale(
                scale: 0.5 + (0.5 * scaleValue),
                child: child,
              ),
            );
          } else {
            return Opacity(
              opacity: CurveTween(
                curve: Curves.easeIn,
              ).transform(animation.value),
              child: child,
            );
          }
        },
        child: child,
      ),
      content: Padding(
        padding: padding ?? const EdgeInsets.all(8),
        child: SelectableRegion(
          selectionControls: materialTextSelectionControls,
          child: switch (messageWidget) {
            final widget? => widget,
            _ => switch (message) {
              final message? => Text(
                message,
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
              _ => const SizedBox.shrink(),
            },
          },
        ),
      ),
      child: child,
    );

    return Semantics(tooltip: message, child: tooltip);
  }
}
