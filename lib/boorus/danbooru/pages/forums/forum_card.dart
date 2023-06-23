// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/compact_chip.dart';

class ForumCard extends StatelessWidget {
  const ForumCard({
    super.key,
    required this.title,
    required this.responseCount,
    required this.createdAt,
    required this.creatorName,
    required this.creatorColor,
    this.isSticky = false,
    this.isLocked = false,
  });

  final bool isSticky;
  final bool isLocked;
  final int responseCount;
  final String title;
  final DateTime createdAt;
  final String creatorName;
  final Color creatorColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSticky)
                  Icon(
                    Icons.push_pin_outlined,
                    size: 20,
                    color: Theme.of(context).hintColor,
                  ),
                if (isLocked)
                  Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: Theme.of(context).hintColor,
                  ),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                )),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                CompactChip(
                  label: creatorName.replaceAll('_', ' '),
                  backgroundColor: creatorColor,
                ),
                const SizedBox(width: 8),
                Text('Replies: $responseCount | '),
                Expanded(
                    child: Text(createdAt.fuzzify(locale: context.locale))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
