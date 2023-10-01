// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/gelbooru_post_action_toolbar.dart';
import 'widgets/gelbooru_recommend_artist_list.dart';
import 'widgets/tags_tile.dart';

class GelbooruPostDetailsPage extends ConsumerStatefulWidget {
  const GelbooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.onExit,
    this.hasDetailsTagList = true,
  });

  final int initialIndex;
  final List<GelbooruPost> posts;
  final void Function(int page) onExit;
  final bool hasDetailsTagList;

  @override
  ConsumerState<GelbooruPostDetailsPage> createState() =>
      _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<GelbooruPostDetailsPage> {
  List<GelbooruPost> get posts => widget.posts;

  @override
  Widget build(BuildContext context) {
    final booruConfig = ref.watchConfig;

    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onTagTap: (tag) => goToSearchPage(context, tag: tag),
      toolbarBuilder: (context, post) => GelbooruPostActionToolbar(post: post),
      swipeImageUrlBuilder: (post) => post.sampleImageUrl,
      sliverArtistPostsBuilder: (context, post) =>
          GelbooruRecommendedArtistList(
        artists: ref.watch(booruPostDetailsArtistProvider(post.id)),
      ),
      tagListBuilder: (context, post) => widget.hasDetailsTagList
          ? TagsTile(
              tags: ref.watch(tagsProvider(booruConfig)),
              post: post,
              onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
            )
          : BasicTagList(
              tags: post.tags,
              onTap: (tag) => goToSearchPage(context, tag: tag),
            ),
      onExpanded: (post) => widget.hasDetailsTagList
          ? ref.read(tagsProvider(booruConfig).notifier).load(
              post.tags,
              onSuccess: (tags) {
                if (!mounted) return;
                post.loadArtistPostsFrom(ref, tags);
              },
            )
          : null,
    );
  }
}
