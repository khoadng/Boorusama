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
  void _loadTags(Post post) {
    final booruConfig = ref.readConfig;

    ref.read(tagsProvider(booruConfig).notifier).load(
      post.tags,
      onSuccess: (tags) {
        if (!mounted) return;

        ref.read(tagsProvider(booruConfig).notifier).load(
              post.tags,
              onSuccess: (tags) => ref.setGelbooruPostDetailsArtistMap(
                post: post,
                tags: tags,
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final booruConfig = ref.watchConfig;

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
            _loadTags(post);
          },
        );
      },
      imageUrlBuilder: (post) => post.sampleImageUrl,
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
      toolbarBuilder: (context, post) => SimplePostActionToolbar(post: post),
      tagListBuilder: (context, post) => TagsTile(
        tags: ref.watch(tagsProvider(booruConfig)),
        post: post,
        onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
        onExpand: () {
          _loadTags(post);
        },
      ),
      fileDetailsBuilder: (context, post) => FileDetailsSection(
        post: post,
        rating: post.rating,
      ),
      sliverArtistPostsBuilder: (context, post) =>
          ref.watch(gelbooruPostDetailsArtistMapProvider).lookup(post.id).fold(
                () => [],
                (tags) => tags.isNotEmpty
                    ? tags
                        .map((tag) => ArtistPostList(
                              tag: tag,
                              builder: (tag) => ref
                                  .watch(gelbooruArtistPostsProvider(tag))
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
