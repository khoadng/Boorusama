// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/tags/danbooru_tag_context_menu.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme.dart';
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
    return tags != null && tags!.isNotEmpty
        ? Wrap(
            spacing: 6,
            runSpacing: isMobilePlatform() ? -2 : 8,
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
                      color: context.isDark ? color : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        : const SizedBox.shrink();
  }
}

class TrendingTagsPlaceholder extends StatelessWidget {
  const TrendingTagsPlaceholder({
    super.key,
    required this.tags,
  });

  final List<TrendingTag> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: isMobilePlatform() ? -2 : 8,
      children: tags.map((e) {
        return BooruChip(
          chipColors: (
            backgroundColor: context.colorScheme.surfaceContainerLow,
            borderColor: Colors.transparent,
            foregroundColor: Colors.transparent,
          ),
          visualDensity: VisualDensity.compact,
          onPressed: () {},
          label: Text(
            e.name.keyword,
            style: const TextStyle(
              color: Colors.transparent,
            ),
          ),
        );
      }).toList(),
    );
  }
}
