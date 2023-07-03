// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/platform.dart';

class TrendingTags extends ConsumerWidget {
  const TrendingTags({
    super.key,
    required this.onTagTap,
    required this.tags,
  });

  final ValueChanged<String>? onTagTap;
  final List<Search>? tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return tags != null && tags!.isNotEmpty
        ? Wrap(
            spacing: 6,
            runSpacing: isMobilePlatform() ? -2 : 8,
            children: tags!.take(20).map((e) {
              final category =
                  ref.watch(danbooruTagCategoryProvider(e.keyword));
              final colors = category == null
                  ? null
                  : generateChipColors(getTagColor(category, theme), theme);

              return RawChip(
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  width: 1.5,
                  color: colors?.borderColor ?? Colors.transparent,
                ),
                onPressed: () => onTagTap?.call(e.keyword),
                backgroundColor: colors?.backgroundColor,
                label: Text(
                  e.keyword.replaceAll('_', ' '),
                  style: TextStyle(
                    color: colors?.foregroundColor,
                  ),
                ),
              );
            }).toList(),
          )
        : const SizedBox.shrink();
  }
}
