// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/pages/widgets/danbooru_tag_context_menu.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/booru_chip.dart';
import 'trending_section.dart';

class TrendingTags extends ConsumerWidget {
  const TrendingTags({
    super.key,
    required this.onTagTap,
    required this.tags,
    required this.colorBuilder,
  });

  final ValueChanged<String>? onTagTap;
  final List<TrendingTag>? tags;
  final Color? Function(BuildContext context, String name)? colorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.themeMode;

    return tags != null && tags!.isNotEmpty
        ? Wrap(
            spacing: 6,
            runSpacing: kPreferredLayout.isMobile ? -2 : 8,
            children: tags!.map((e) {
              final color = e.category == null
                  ? null
                  : colorBuilder?.call(context, e.category!.name);

              return DanbooruTagContextMenu(
                tag: e.name.keyword,
                child: BooruChip(
                  visualDensity: VisualDensity.compact,
                  color: color,
                  onPressed: () => onTagTap?.call(e.name.keyword),
                  label: Text(
                    e.name.keyword.replaceUnderscoreWithSpace(),
                    style: TextStyle(
                      color: theme.isDark ? color : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        : const SizedBox.shrink();
  }
}
