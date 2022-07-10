// Flutter imports:
import 'package:flutter/widgets.dart';

/// Conditionally render a widget without breaking the code tree.
/// If the condition is false, [SizeBox.shrink()] will be used.
class ConditionalRenderWidget extends StatelessWidget {
  const ConditionalRenderWidget({
    Key? key,
    required this.condition,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final bool condition;

  @override
  Widget build(BuildContext context) {
    return condition ? child : const SizedBox.shrink();
  }
}
