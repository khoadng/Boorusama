// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';

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
        backgroundColor: context.colorScheme.surfaceContainerHighest,
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
