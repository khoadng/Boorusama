// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

class PaginationLimitView extends ConsumerWidget {
  const PaginationLimitView({
    required this.onContinueBrowsing,
    this.additionalContent,
    super.key,
  });

  final VoidCallback onContinueBrowsing;
  final Widget? additionalContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'This post cannot be reached with previous search context due to pagination limits.'
              .hc,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: 16),
        ?additionalContent,
        FilledButton.tonal(
          onPressed: () {
            Navigator.of(context).pop();
            onContinueBrowsing();
          },
          child: Text(
            'Continue from where you left off'.hc,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'.hc),
        ),
      ],
    );
  }
}
