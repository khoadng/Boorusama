// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/theme.dart';
import '../../../../../../core/widgets/widgets.dart';

class ForumCard extends ConsumerWidget {
  const ForumCard({
    required this.title,
    required this.responseCount,
    required this.createdAt,
    required this.creatorInfo,
    super.key,
    this.isSticky = false,
    this.isLocked = false,
    this.onTap,
  });

  final bool isSticky;
  final bool isLocked;
  final int responseCount;
  final String title;
  final DateTime createdAt;
  final Widget creatorInfo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSticky)
                    Icon(
                      Symbols.push_pin,
                      size: 20,
                      color: Theme.of(context).colorScheme.hintColor,
                    ),
                  if (isLocked)
                    Icon(
                      Symbols.lock_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.hintColor,
                    ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  creatorInfo,
                  const SizedBox(width: 8),
                  Text('Replies: $responseCount | '),
                  Expanded(
                    child: DateTooltip(
                      date: createdAt,
                      child: Text(createdAt.fuzzify(locale: context.locale)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
