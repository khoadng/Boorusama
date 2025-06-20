// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../theme.dart';

class DefaultBooruInstructionText extends StatelessWidget {
  const DefaultBooruInstructionText(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.hintColor,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
    );
  }
}
