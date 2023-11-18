// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
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
    final theme = context.themeMode;

    return tags != null && tags!.isNotEmpty
        ? Wrap(
            spacing: 6,
            runSpacing: isMobilePlatform() ? -2 : 8,
            children: tags!.take(20).map((e) {
              final color =
                  ref.watch(danbooruTagCategoryProvider(e.keyword)).maybeWhen(
                        data: (data) => data != null
                            ? ref.getTagColor(context, data.name)
                            : null,
                        orElse: () => null,
                      );

              return BooruChip(
                visualDensity: VisualDensity.comfortable,
                color: color,
                onPressed: () => onTagTap?.call(e.keyword),
                label: Text(
                  e.keyword.replaceUnderscoreWithSpace(),
                  style: TextStyle(
                    color: theme.isDark ? color : null,
                  ),
                ),
              );
            }).toList(),
          )
        : const SizedBox.shrink();
  }
}
