// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../display.dart';

class RemoveLeftPaddingOnLargeScreen extends StatelessWidget {
  const RemoveLeftPaddingOnLargeScreen({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return context.isLargeScreen
        ? MediaQuery.removePadding(
            context: context,
            removeLeft: true,
            child: child,
          )
        : child;
  }
}
