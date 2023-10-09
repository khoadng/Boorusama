// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'widgets/gelbooru_post_action_toolbar.dart';
import 'widgets/gelbooru_recommend_artist_list.dart';
import 'widgets/tags_tile.dart';

class GelbooruPostDetailsPage extends ConsumerStatefulWidget {
  const GelbooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.onExit,
  });

  final int initialIndex;
  final List<GelbooruPost> posts;
  final void Function(int page) onExit;

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
      tagListBuilder: (context, post) =>
          ref.watchConfig.booruType == BooruType.gelbooru
              ? TagsTile(
                  tags: ref.watch(tagsProvider(booruConfig)),
                  post: post,
                  onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
                )
              : GelbooruV1TagsTile(post: post),
      onExpanded: (post) => ref.watchConfig.booruType == BooruType.gelbooru
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

class GelbooruV1TagsTile extends ConsumerStatefulWidget {
  const GelbooruV1TagsTile({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  ConsumerState<GelbooruV1TagsTile> createState() => _GelbooruV1TagsTileState();
}

class _GelbooruV1TagsTileState extends ConsumerState<GelbooruV1TagsTile> {
  var expanded = false;

  @override
  Widget build(BuildContext context) {
    return TagsTile(
      tags: expanded
          ? ref.watch(gelbooruV2TagsFromIdProvider(widget.post.id)).maybeWhen(
                data: (data) => createTagGroupItems(data),
                orElse: () => null,
              )
          : null,
      post: widget.post,
      onExpand: () => setState(() => expanded = true),
      onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
    );
  }
}
