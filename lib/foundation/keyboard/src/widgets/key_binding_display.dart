// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../types/key_binding.dart';

class KeyBindingDisplay extends StatelessWidget {
  const KeyBindingDisplay({
    required this.binding,
    super.key,
    this.style,
  });

  final KeyBinding binding;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      binding.displayLabel(),
      style:
          style ??
          TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
    );
  }
}
