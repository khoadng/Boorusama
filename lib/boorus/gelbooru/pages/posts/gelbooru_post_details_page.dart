// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/scaffolds/post_details_page_scaffold.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts/gelbooru_recommend_artist_list.dart';
import 'package:boorusama/widgets/widgets.dart';

class GelbooruPostDetailsPage extends ConsumerStatefulWidget {
  const GelbooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.onExit,
    this.hasDetailsTagList = true,
  });

  final int initialIndex;
  final List<Post> posts;
  final void Function(int page) onExit;
  final bool hasDetailsTagList;

  @override
  ConsumerState<GelbooruPostDetailsPage> createState() =>
      _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<GelbooruPostDetailsPage> {
  List<Post> get posts => widget.posts;

  @override
  Widget build(BuildContext context) {
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return PostDetailsPageScaffold(
      posts: posts,
      initialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onTagTap: (tag) => goToSearchPage(context, tag: tag),
      toolbarBuilder: (context, post) => GelbooruPostActionToolbar(post: post),
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
