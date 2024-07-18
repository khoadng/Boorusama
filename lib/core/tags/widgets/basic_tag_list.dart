// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme.dart';

class BasicTagList extends ConsumerWidget {
  const BasicTagList({
    super.key,
    required this.tags,
    required this.onTap,
    this.unknownCategoryColor,
  });

  final List<String> tags;
  final void Function(String tag) onTap;
  final Color? unknownCategoryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: tags.sorted((a, b) => a.compareTo(b)).map((tag) {
          final categoryAsync = ref.watch(booruTagTypeProvider(tag));

          return GestureDetector(
            onTap: () => onTap(tag),
            child: categoryAsync.maybeWhen(
              data: (category) {
                final colors = context.generateChipColors(
                  category != null
                      ? ref.watch(tagColorProvider(category))
                      : unknownCategoryColor,
                  ref.watch(settingsProvider),
                );

                return Chip(
                  visualDensity: const ShrinkVisualDensity(),
                  backgroundColor: colors?.backgroundColor,
                  side: colors != null
                      ? BorderSide(
                          width: 1,
                          color: colors.borderColor,
                        )
                      : null,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  label: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.screenWidth * 0.7,
                    ),
                    child: Text(
                      _getTagStringDisplayName(tag),
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors?.foregroundColor,
                      ),
                    ),
                  ),
                );
              },
              orElse: () => Chip(
                visualDensity: const ShrinkVisualDensity(),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                label: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.screenWidth * 0.7,
                  ),
                  child: Text(
                    _getTagStringDisplayName(tag),
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

String _getTagStringDisplayName(String tag) {
  final sanitized = tag.toLowerCase().replaceAll('_', ' ');

  return sanitized.length > 30 ? '${sanitized.substring(0, 30)}...' : sanitized;
}
