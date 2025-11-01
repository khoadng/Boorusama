// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../search/search/routes.dart';
import '../../../../tags/tag/providers.dart';
import '../../../details/types.dart';
import '../../../post/types.dart';
import 'raw_tags_tile.dart';
import 'tag_chip.dart';

class DefaultInheritedBasicTagsTile<T extends Post> extends ConsumerWidget {
  const DefaultInheritedBasicTagsTile({
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
        post: post,
        tags: post.tags,
        unknownCategoryColor: ref.watch(tagColorProvider((config, 'general'))),
        auth: config,
        initialExpanded: initialExpanded,
      ),
    );
  }
}

class BasicTagsTile extends ConsumerWidget {
  const BasicTagsTile({
    required this.post,
    required this.tags,
    required this.auth,
    super.key,
    this.unknownCategoryColor,
    this.initialExpanded = true,
    this.onTagTap,
  });

  final Post post;
  final Set<String> tags;
  final Color? unknownCategoryColor;
  final BooruConfigAuth auth;
  final bool initialExpanded;
  final void Function(String tag)? onTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedTags = tags.sorted((a, b) => a.compareTo(b));

    return RawTagsTile(
      title: RawTagsTileTitle(
        auth: auth,
        post: post,
        count: tags.length,
      ),
      initiallyExpanded: initialExpanded,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 12,
          ),
          width: double.infinity,
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: sortedTags
                .map(
                  (tag) => AutoCategoryTagChip(
                    text: tag,
                    auth: auth,
                    onTap: onTagTap != null
                        ? () => onTagTap?.call(tag)
                        : () => goToSearchPage(
                            ref,
                            tag: tag,
                          ),
                    fallbackColor: unknownCategoryColor,
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
