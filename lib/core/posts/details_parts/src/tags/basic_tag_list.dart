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

class DefaultInheritedTagList<T extends Post> extends ConsumerWidget {
  const DefaultInheritedTagList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<T>(context);
    final config = ref.watchConfigAuth;

    return SliverToBoxAdapter(
      child: BasicTagList(
        tags: post.tags.toList(),
        unknownCategoryColor: ref.watch(tagColorProvider((config, 'general'))),
        onTap: (tag) => goToSearchPage(
          context,
          tag: tag,
        ),
        auth: config,
      ),
    );
  }
}

class BasicTagList extends ConsumerWidget {
  const BasicTagList({
    required this.tags,
    required this.onTap,
    required this.auth,
    super.key,
    this.unknownCategoryColor,
  });

  final List<String> tags;
  final void Function(String tag) onTap;
  final Color? unknownCategoryColor;
  final BooruConfigAuth auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedTags = tags.sorted((a, b) => a.compareTo(b));

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 8,
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: sortedTags.map((tag) {
          final categoryAsync = ref.watch(booruTagTypeProvider((auth, tag)));

          return GestureDetector(
            onTap: () => onTap(tag),
            child: categoryAsync.maybeWhen(
              data: (category) {
                final colors = category != null
                    ? ref.watch(
                        chipColorsFromTagStringProvider((auth, category)),
                      )
                    : ref
                        .watch(booruChipColorsProvider)
                        .fromColor(unknownCategoryColor);

                return RawTagChip(
                  text: _getTagStringDisplayName(tag),
                  backgroundColor: colors?.backgroundColor,
                  foregroundColor: colors?.foregroundColor,
                  borderColor: colors?.borderColor,
                  onTap: () => onTap(tag),
                );
              },
              orElse: () => RawTagChip(
                text: _getTagStringDisplayName(tag),
                onTap: () => onTap(tag),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

String _getTagStringDisplayName(String tag) {
  return tag.toLowerCase().replaceAll('_', ' ');
}
