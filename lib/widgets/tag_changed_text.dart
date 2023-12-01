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
    return RichText(
      text: TextSpan(
        text: title,
        style: Theme.of(context).textTheme.titleLarge,
        children: [
          if (added.isNotEmpty && removed.isNotEmpty)
            TextSpan(
              text: ' (${added.length} added, ${removed.length} removed)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            )
          else if (added.isNotEmpty)
            TextSpan(
              text: ' (${added.length} added)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            )
          else if (removed.isNotEmpty)
            TextSpan(
              text: ' (${removed.length} removed)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
        ],
      ),
    );
  }
}
