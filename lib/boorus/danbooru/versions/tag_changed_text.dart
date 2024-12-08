// Flutter imports:
import 'package:flutter/material.dart';

class TagChangedText extends StatelessWidget {
  const TagChangedText({
    super.key,
    required this.title,
    required this.added,
    required this.removed,
  });

  final String title;
  final Set<String> added;
  final Set<String> removed;

  @override
  Widget build(BuildContext context) {
    final positiveStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.green,
          fontWeight: FontWeight.w800,
        );
    final negativeStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.w800,
        );

    return RichText(
      text: TextSpan(
        text: title,
        style: Theme.of(context).textTheme.titleLarge,
        children: [
          if (added.isNotEmpty && removed.isNotEmpty)
            TextSpan(
              text: '+${added.length}',
              style: positiveStyle,
              children: [
                TextSpan(
                  text: ' -${removed.length}',
                  style: negativeStyle,
                ),
              ],
            )
          else if (added.isNotEmpty)
            TextSpan(
              text: '+${added.length}',
              style: positiveStyle,
            )
          else if (removed.isNotEmpty)
            TextSpan(
              text: '-${removed.length}',
              style: negativeStyle,
            ),
        ],
      ),
    );
  }
}
