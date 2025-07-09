// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../configs/ref.dart';
import '../../../router.dart';
import '../../../tags/tag/providers.dart';
import '../../../widgets/widgets.dart';
import '../../details/details.dart';
import '../../details/widgets.dart';
import '../../post/post.dart';

class DefaultInheritedCharacterPostsSection<T extends Post>
    extends ConsumerWidget {
  const DefaultInheritedCharacterPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<T>(context);

    return ref
        .watch(
          artistCharacterGroupProvider(
            (post: post, auth: ref.watchConfigAuth),
          ),
        )
        .maybeWhen(
          data: (data) => data.characterTags.isNotEmpty
              ? SliverCharacterPostList(
                  tags: data.characterTags,
                )
              : const SliverSizedBox.shrink(),
          orElse: () => const SliverSizedBox.shrink(),
        );
  }
}

class SliverCharacterPostList extends ConsumerWidget {
  const SliverCharacterPostList({
    required this.tags,
    super.key,
  });

  final Set<String> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tags.isEmpty) return const SliverSizedBox.shrink();

    final maxWidth = PostDetailsSheetConstraints.of(context)?.maxWidth;

    final crossAxisCount = maxWidth != null
        ? switch (maxWidth) {
            >= 550 => 4,
            >= 450 => 3,
            _ => 2,
          }
        : 2;
    final childAspectRatio = maxWidth != null
        ? switch (maxWidth) {
            >= 550 => 2.5,
            >= 450 => 3.5,
            _ => 4.0,
          }
        : 4.0;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      sliver: MultiSliver(
        children: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Text(
                    'Characters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverSizedBox(height: 4),
          SliverGrid.count(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: tags
                .map(
                  (tag) => BooruChip(
                    borderRadius: BorderRadius.circular(4),
                    color: ref.watch(
                      tagColorProvider((ref.watchConfigAuth, 'character')),
                    ),
                    onPressed: () => goToCharacterPage(ref, tag),
                    label: Text(
                      tag.replaceAll('_', ' '),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
