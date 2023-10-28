// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class BasicTagList extends ConsumerWidget {
  const BasicTagList({
    Key? key,
    required this.tags,
    required this.onTap,
  }) : super(key: key);

  final List<String> tags;
  final void Function(String tag) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.themeMode;

    return Wrap(
      spacing: 4,
      runSpacing: isMobilePlatform() ? 0 : 8,
      children: tags.sorted((a, b) => a.compareTo(b)).map((tag) {
        final categoryAsync = ref.watch(booruTagTypeProvider(tag));

        return GestureDetector(
          onTap: () => onTap(tag),
          child: categoryAsync.maybeWhen(
            data: (category) {
              final colors = category != null
                  ? generateChipColors(
                      ref.getTagColor(context, category), theme)
                  : null;

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
    );
  }
}

String _getTagStringDisplayName(String tag) {
  final sanitized = tag.toLowerCase().replaceAll('_', ' ');

  return sanitized.length > 30 ? '${sanitized.substring(0, 30)}...' : sanitized;
}
