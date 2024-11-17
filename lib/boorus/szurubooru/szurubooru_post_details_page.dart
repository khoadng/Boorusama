// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/router.dart';
import 'szurubooru_post.dart';

class SzurubooruPostDetailsPage extends ConsumerWidget {
  const SzurubooruPostDetailsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = PostDetails.of<SzurubooruPost>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageScaffold(
      controller: controller,
      posts: posts,
    );
  }
}

class SzurubooruTagListSection extends ConsumerWidget {
  const SzurubooruTagListSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SzurubooruPost>(context);

    return TagsTile(
      post: post,
      tags: createTagGroupItems(post.tagDetails),
      initialExpanded: true,
      tagColorBuilder: (tag) => tag.category.darkColor,
      onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
    );
  }
}

class SzurubooruFileDetailsSection extends ConsumerWidget {
  const SzurubooruFileDetailsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SzurubooruPost>(context);

    return DefaultFileDetailsSection(
      post: post,
      uploaderName: post.uploaderName,
    );
  }
}

class SzurubooruStatsTileSection extends ConsumerWidget {
  const SzurubooruStatsTileSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SzurubooruPost>(context);

    return Column(
      children: [
        SimplePostStatsTile(
          totalComments: post.commentCount,
          favCount: post.favoriteCount,
          score: post.score,
        ),
      ],
    );
  }
}

class SzurubooruPostDetailsDesktopPage extends ConsumerWidget {
  const SzurubooruPostDetailsDesktopPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = PostDetails.of<SzurubooruPost>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageDesktopScaffold(
      controller: controller,
      posts: posts,
      imageUrlBuilder: defaultPostImageUrlBuilder(ref),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
    );
  }
}
