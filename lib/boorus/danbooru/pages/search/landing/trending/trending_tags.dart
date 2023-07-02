// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
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
            spacing: 4,
            runSpacing: isMobilePlatform() ? -4 : 8,
            children: tags!.take(20).map((e) {
              final category =
                  ref.watch(danbooruTagCategoryProvider(e.keyword));

              return RawChip(
                visualDensity: VisualDensity.compact,
                onPressed: () => onTagTap?.call(e.keyword),
                backgroundColor:
                    category == null ? null : getTagColor(category, theme),
                label: Text(
                  e.keyword.replaceAll('_', ' '),
                ),
              );
            }).toList(),
          )
        : const SizedBox.shrink();
  }
}
