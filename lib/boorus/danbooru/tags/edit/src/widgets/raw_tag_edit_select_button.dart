// Flutter imports:
import 'package:flutter/material.dart';

class RawTagEditSelectButton extends StatelessWidget {
  const RawTagEditSelectButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  final void Function() onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
