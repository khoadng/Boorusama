// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:selection_mode/selection_mode.dart';

const _kAnimDuration = Duration(milliseconds: 100);

class SelectionModeAnimatedFooter extends StatelessWidget {
  const SelectionModeAnimatedFooter({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = SelectionMode.of(context);
    final enable = controller.enabled;

    return Material(
      color: enable ? colorScheme.surface : Colors.transparent,
      child: SafeArea(
        top: false,
        child: AnimatedSlide(
          duration: _kAnimDuration,
          curve: Curves.easeInOut,
          offset: enable ? Offset.zero : const Offset(0, 1),
          child: AnimatedOpacity(
            duration: _kAnimDuration,
            opacity: enable ? 1.0 : 0.0,
            child: enable ? child : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
