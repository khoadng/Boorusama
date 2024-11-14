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
    required this.controller,
    required this.onExit,
    required this.onPageChanged,
    required this.posts,
    required this.initialPage,
  });

  final List<SzurubooruPost> posts;
  final PostDetailsController<SzurubooruPost> controller;
  final void Function(int page) onExit;
  final void Function(int page) onPageChanged;
  final int initialPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: initialPage,
      swipeImageUrlBuilder: defaultPostImageUrlBuilder(ref),
      onExit: onExit,
      onPageChangeIndexed: onPageChanged,
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
    required this.initialIndex,
    required this.posts,
    required this.onExit,
    required this.onPageChanged,
    required this.controller,
  });

  final int initialIndex;
  final List<SzurubooruPost> posts;
  final void Function(int index) onExit;
  final void Function(int page) onPageChanged;
  final PostDetailsController<SzurubooruPost> controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostDetailsPageDesktopScaffold(
      initialIndex: initialIndex,
      posts: posts,
      onExit: onExit,
      onPageChanged: onPageChanged,
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
