import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// A [RadioGroup] whose arrow keys move focus instead of changing the
/// selection, so D-pad and keyboard users can browse options and leave the
/// group. Select, Enter and Space still pick the focused option.
class KurumiRadioGroup<T> extends StatelessWidget {
  const KurumiRadioGroup({
    required this.groupValue,
    required this.onChanged,
    required this.child,
    super.key,
  });

  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Widget child;

  static const _arrowsMoveFocus = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(
      TraversalDirection.up,
    ),
    SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(
      TraversalDirection.down,
    ),
    SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(
      TraversalDirection.left,
    ),
    SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(
      TraversalDirection.right,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: Shortcuts(
        shortcuts: _arrowsMoveFocus,
        child: child,
      ),
    );
  }
}
