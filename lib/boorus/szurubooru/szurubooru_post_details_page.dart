// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/widgets/widgets.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'post_votes/post_votes.dart';
import 'szurubooru_pool_page.dart';
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

  final List<Post> posts;
  final PostDetailsController<Post> controller;
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
      topRightButtonsBuilder: (currentPage, expanded, post, controller) => [
        NoteActionButtonWithProvider(
          post: posts[currentPage],
          expanded: expanded,
          noteState: ref.watch(notesControllerProvider(posts[currentPage])),
        ),
        SzurubooruMoreActionButton(
          post: posts[currentPage],
          onStartSlideshow: () => controller.startSlideshow(),
        ),
      ],
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
      toolbar: ValueListenableBuilder(
        valueListenable: controller.currentPost,
        builder: (_, rawPost, __) =>
            castOrNull<SzurubooruPost>(rawPost).toOption().fold(
                  () => SimplePostActionToolbar(post: rawPost),
                  (post) => SzurubooruPostActionToolbar(post: post),
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
  final List<Post> posts;
  final void Function(int index) onExit;
  final void Function(int page) onPageChanged;
  final PostDetailsController<Post> controller;

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
      toolbarBuilder: (context, post) => ValueListenableBuilder(
        valueListenable: controller.currentPost,
        builder: (_, rawPost, __) =>
            castOrNull<SzurubooruPost>(rawPost).toOption().fold(
                  () => SimplePostActionToolbar(post: rawPost),
                  (post) => SzurubooruPostActionToolbar(post: post),
                ),
      ),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          SzurubooruMoreActionButton(post: post),
      fileDetailsBuilder: (context, rawPost) => DefaultFileDetailsSection(
        post: rawPost,
        uploaderName: castOrNull<SzurubooruPost>(rawPost)?.uploaderName,
      ),
    );
  }
}

class SzurubooruMoreActionButton extends ConsumerWidget {
  const SzurubooruMoreActionButton({
    super.key,
    required this.post,
    this.onStartSlideshow,
    this.onDownload,
  });

  final Post post;
  final void Function(Post post)? onDownload;
  final void Function()? onStartSlideshow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watchConfig;

    return SizedBox(
      width: 40,
      child: Material(
        color: Colors.black.withOpacity(0.5),
        shape: const CircleBorder(),
        child: BooruPopupMenuButton(
          iconColor: Colors.white,
          onSelected: (value) {
            switch (value) {
              case 'download':
                if (onDownload != null) {
                  onDownload!(post);
                } else {
                  ref.download(post);
                }
                break;
              case 'add_to_pool':
                goToAddToPoolPage(context, [post]);
                break;
              case 'view_in_browser':
                launchExternalUrl(
                  post.getUriLink(booru.url),
                );
                break;
              case 'show_tag_list':
                goToShowTaglistPage(
                  ref,
                  post.extractTags(),
                );
                break;
              case 'view_original':
                goToOriginalImagePage(context, post);
                break;
              case 'start_slideshow':
                if (onStartSlideshow != null) {
                  onStartSlideshow!();
                }
                break;
              case 'settings':
                openImageViewerSettingsPage(context);
                break;
              // ignore: no_default_cases
              default:
            }
          },
          itemBuilder: {
            'download': const Text('download.download').tr(),
            if (ref.watchConfig.hasLoginDetails())
              'add_to_pool': const Text('Add to pool').tr(),
            if (!booru.hasStrictSFW)
              'view_in_browser': const Text('post.detail.view_in_browser').tr(),
            if (post.tags.isNotEmpty) 'show_tag_list': const Text('View tags'),
            if (post.hasFullView)
              'view_original':
                  const Text('post.image_fullview.view_original').tr(),
            if (onStartSlideshow != null)
              'start_slideshow': const Text('Slideshow'),
            'settings': const Text('settings.settings').tr(),
          },
        ),
      ),
    );
  }
}
