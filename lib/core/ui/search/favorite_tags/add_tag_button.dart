// Flutter imports:
import 'package:flutter/material.dart';

class AddTagButton extends StatelessWidget {
  const AddTagButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 28,
      splashRadius: 20,
      onPressed: onPressed,
      icon: const Icon(Icons.add),
    );
  }
}
