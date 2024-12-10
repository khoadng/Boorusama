// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/settings/data.dart';
import '../../../../../../core/theme.dart';
import '../../../../../../core/theme/utils.dart';
import '../../../../../../widgets/widgets.dart';

class ForumCard extends ConsumerWidget {
  const ForumCard({
    super.key,
    required this.title,
    required this.responseCount,
    required this.createdAt,
    required this.creatorName,
    required this.creatorColor,
    this.isSticky = false,
    this.isLocked = false,
    this.onTap,
    this.onCreatorTap,
  });

  final bool isSticky;
  final bool isLocked;
  final int responseCount;
  final String title;
  final DateTime createdAt;
  final String creatorName;
  final Color creatorColor;
  final VoidCallback? onTap;
  final VoidCallback? onCreatorTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.generateChipColors(
      creatorColor,
      ref.watch(settingsProvider),
    );

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
                  CompactChip(
                    label: creatorName.replaceAll('_', ' '),
                    backgroundColor: colors?.backgroundColor,
                    textColor: colors?.foregroundColor,
                    onTap: onCreatorTap,
                  ),
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
