// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/posts/details/details.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/router.dart';
import '../../core/tags/tag/tag.dart';
import 'szurubooru_post.dart';

class SzurubooruTagListSection extends ConsumerWidget {
  const SzurubooruTagListSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SzurubooruPost>(context);

    return SliverToBoxAdapter(
      child: TagsTile(
        post: post,
        tags: createTagGroupItems(post.tagDetails),
        initialExpanded: true,
        tagColorBuilder: (tag) => tag.category.darkColor,
        onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
      ),
    );
  }
}

class SzurubooruFileDetailsSection extends ConsumerWidget {
  const SzurubooruFileDetailsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SzurubooruPost>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        uploaderName: post.uploaderName,
      ),
    );
  }
}

class SzurubooruStatsTileSection extends ConsumerWidget {
  const SzurubooruStatsTileSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SzurubooruPost>(context);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          SimplePostStatsTile(
            totalComments: post.commentCount,
            favCount: post.favoriteCount,
            score: post.score,
          ),
        ],
      ),
    );
  }
}
