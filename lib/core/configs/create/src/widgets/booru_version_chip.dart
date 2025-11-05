// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';

class BooruVersionChip extends StatelessWidget {
  const BooruVersionChip({
    super.key,
    required this.version,
  });

  final Version version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      margin: const EdgeInsets.only(
        left: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Text(
        'v$version',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
