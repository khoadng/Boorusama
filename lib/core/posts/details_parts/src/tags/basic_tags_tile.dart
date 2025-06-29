// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../../configs/ref.dart';
import '../../../../search/search/routes.dart';
import '../../../../tags/categories/providers.dart';
import '../../../../tags/tag/providers.dart';
import '../../../../theme/providers.dart';
import '../../../details/details.dart';
import '../../../post/post.dart';
import 'raw_tag_chip.dart';
import 'raw_tags_tile.dart';

class DefaultInheritedTagsTile<T extends Post> extends ConsumerWidget {
  const DefaultInheritedTagsTile({
    super.key,
    this.initialExpanded = true,
  });

  final bool initialExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<T>(context);
    final config = ref.watchConfigAuth;

    return SliverToBoxAdapter(
      child: BasicTagsTile(
        tags: post.tags.toList(),
        unknownCategoryColor: ref.watch(tagColorProvider((config, 'general'))),
        auth: config,
        initialExpanded: initialExpanded,
      ),
    );
  }
}

class BasicTagsTile extends StatelessWidget {
  const BasicTagsTile({
    required this.tags,
    required this.auth,
    super.key,
    this.unknownCategoryColor,
    this.initialExpanded = true,
  });

  final List<String> tags;
  final Color? unknownCategoryColor;
  final BooruConfigAuth auth;
  final bool initialExpanded;

  @override
  Widget build(BuildContext context) {
    final sortedTags = tags.sorted((a, b) => a.compareTo(b));

    return RawTagsTile(
      title: RawTagsTileTitle(
        count: tags.length,
      ),
      initiallyExpanded: initialExpanded,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: sortedTags
                .map(
                  (tag) => _Chip(
                    tag: tag,
                    onTap: () => goToSearchPage(
                      context,
                      tag: tag,
                    ),
                    unknownCategoryColor: unknownCategoryColor,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Chip extends ConsumerWidget {
  const _Chip({
    required this.tag,
    required this.onTap,
    required this.unknownCategoryColor,
  });

  final String tag;
  final VoidCallback onTap;
  final Color? unknownCategoryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watchConfigAuth;
    final category = ref.watch(booruTagTypeProvider((auth, tag))).valueOrNull;
    final colors = category != null
        ? ref.watch(
            chipColorsFromTagStringProvider((auth, category)),
          )
        : ref.watch(booruChipColorsProvider).fromColor(unknownCategoryColor);

    return RawTagChip(
      text: tag.toLowerCase().replaceAll('_', ' '),
      backgroundColor: colors?.backgroundColor,
      foregroundColor: colors?.foregroundColor,
      borderColor: colors?.borderColor,
      onTap: onTap,
    );
  }
}
