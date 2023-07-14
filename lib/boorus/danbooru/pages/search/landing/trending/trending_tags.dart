// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';
import 'package:boorusama/widgets/booru_chip.dart';

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
              final color =
                  category == null ? null : getTagColor(category, theme);

              return BooruChip(
                visualDensity: VisualDensity.comfortable,
                color: category != null ? getTagColor(category, theme) : null,
                onPressed: () => onTagTap?.call(e.keyword),
                label: Text(
                  e.keyword.replaceAll('_', ' '),
                  style: TextStyle(
                    color: theme.isDark ? color : Colors.white,
                  ),
                ),
                theme: theme,
              );
            }).toList(),
          )
        : const SizedBox.shrink();
  }
}
