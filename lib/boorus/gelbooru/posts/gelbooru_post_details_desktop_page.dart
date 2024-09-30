// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/artists/artists.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'gelbooru_post_details_page.dart';

class GelbooruPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const GelbooruPostDetailsDesktopPage({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
    required this.onPageChanged,
  });

  final int initialIndex;
  final List<Post> posts;
  final void Function(int index) onExit;
  final void Function(int page) onPageChanged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruPostDetailsDesktopPageState();
}

class _DanbooruPostDetailsDesktopPageState
    extends ConsumerState<GelbooruPostDetailsDesktopPage> {
  @override
  Widget build(BuildContext context) {
    final booruConfig = ref.watchConfig;
    final gelArtistMap = ref.watch(gelbooruPostDetailsArtistMapProvider);

    return PostDetailsPageDesktopScaffold(
      posts: widget.posts,
      initialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onPageChanged: widget.onPageChanged,
      onPageLoaded: (post) {
        ref.read(tagsProvider(booruConfig).notifier).load(
          post.tags,
          onSuccess: (tags) {
            if (!mounted) return;
            ref.setGelbooruPostDetailsArtistMap(
              post: post,
              tags: tags,
            );
          },
        );
      },
      imageUrlBuilder: (post) => post.sampleImageUrl,
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
      toolbarBuilder: (context, post) => SimplePostActionToolbar(post: post),
      tagListBuilder: (context, post) => TagsTile(
        initialExpanded: true,
        tags: ref.watch(tagsProvider(booruConfig)),
        post: post,
        onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
      ),
      fileDetailsBuilder: (context, post) => FileDetailsSection(
        post: post,
        rating: post.rating,
      ),
      sliverArtistPostsBuilder: (context, post) => gelArtistMap
          .lookup(post.id)
          .fold(
            () => const [],
            (tags) => tags.isNotEmpty
                ? [
                    ArtistPostList(
                      artists: tags,
                      builder: (tag) => ref
                          .watch(gelbooruArtistPostsProvider(tag))
                          .maybeWhen(
                            data: (data) => PreviewPostGrid(
                              posts: data,
                              onTap: (postIdx) => goToPostDetailsPage(
                                context: context,
                                posts: data,
                                initialIndex: postIdx,
                              ),
                              imageUrl: (item) => item.sampleImageUrl,
                            ),
                            orElse: () => const PreviewPostGridPlaceholder(),
                          ),
                    ),
                  ]
                : [],
          ),
    );
  }
}
