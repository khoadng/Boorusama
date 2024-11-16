// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/functional.dart';
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
      swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
      statsTileBuilder: (context, rawPost) =>
          castOrNull<SzurubooruPost>(rawPost).toOption().fold(
                () => const SizedBox.shrink(),
                (post) => Column(
                  children: [
                    const Divider(height: 8, thickness: 0.5),
                    SimplePostStatsTile(
                      totalComments: post.commentCount,
                      favCount: post.favoriteCount,
                      score: post.score,
                    ),
                  ],
                ),
              ),
      tagListBuilder: (context, post) =>
          castOrNull<SzurubooruPost>(post).toOption().fold(
                () => const SizedBox.shrink(),
                (post) => TagsTile(
                  post: post,
                  tags: createTagGroupItems(post.tagDetails),
                  initialExpanded: true,
                  tagColorBuilder: (tag) => tag.category.darkColor,
                  onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
                ),
              ),
      fileDetailsBuilder: (context, rawPost) => DefaultFileDetailsSection(
        post: rawPost,
        uploaderName: castOrNull<SzurubooruPost>(rawPost)?.uploaderName,
      ),
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
      statsTileBuilder: (context, rawPost) =>
          castOrNull<SzurubooruPost>(rawPost).toOption().fold(
                () => const SizedBox.shrink(),
                (post) => Column(
                  children: [
                    const Divider(height: 8, thickness: 0.5),
                    SimplePostStatsTile(
                      totalComments: post.commentCount,
                      favCount: post.favoriteCount,
                      score: post.score,
                    ),
                  ],
                ),
              ),
      tagListBuilder: (context, post) =>
          castOrNull<SzurubooruPost>(post).toOption().fold(
                () => const SizedBox.shrink(),
                (post) => TagsTile(
                  post: post,
                  tags: createTagGroupItems(post.tagDetails),
                  initialExpanded: true,
                  onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
                ),
              ),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
      fileDetailsBuilder: (context, rawPost) => DefaultFileDetailsSection(
        post: rawPost,
        uploaderName: castOrNull<SzurubooruPost>(rawPost)?.uploaderName,
      ),
    );
  }
}
