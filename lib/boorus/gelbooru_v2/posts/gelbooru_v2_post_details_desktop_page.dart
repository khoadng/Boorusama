// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/gelbooru_v2/artists/artists.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'gelbooru_v2_post_details_page.dart';

class GelbooruV2PostDetailsDesktopPage extends ConsumerStatefulWidget {
  const GelbooruV2PostDetailsDesktopPage({
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
    extends ConsumerState<GelbooruV2PostDetailsDesktopPage> {
  @override
  Widget build(BuildContext context) {
    return PostDetailsPageDesktopScaffold(
      posts: widget.posts,
      initialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onPageChanged: widget.onPageChanged,
      imageUrlBuilder: defaultPostImageUrlBuilder(ref),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
      toolbarBuilder: (context, post) => SimplePostActionToolbar(post: post),
      tagListBuilder: (context, post) => GelbooruV2TagsTile(
        post: post,
        onTagsLoaded: (tags) => ref.setGelbooruPostDetailsArtistMap(
          post: post,
          tags: tags,
        ),
      ),
      sliverArtistPostsBuilder: (context, post) => ref
          .watch(gelbooruV2PostDetailsArtistMapProvider)
          .lookup(post.id)
          .fold(
            () => const [],
            (tags) => tags.isNotEmpty
                ? tags
                    .map((tag) => ArtistPostList(
                          tag: tag,
                          builder: (tag) => ref
                              .watch(gelbooruV2ArtistPostsProvider(tag))
                              .maybeWhen(
                                data: (data) => SliverPreviewPostGrid(
                                  posts: data,
                                  onTap: (postIdx) => goToPostDetailsPage(
                                    context: context,
                                    posts: data,
                                    initialIndex: postIdx,
                                  ),
                                  imageUrl: (item) => item.sampleImageUrl,
                                ),
                                orElse: () =>
                                    const SliverPreviewPostGridPlaceholder(),
                              ),
                        ))
                    .toList()
                : [],
          ),
    );
  }
}
