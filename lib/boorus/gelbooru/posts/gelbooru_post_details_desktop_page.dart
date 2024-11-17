// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/gelbooru/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'gelbooru_post_details_page.dart';

class GelbooruPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const GelbooruPostDetailsDesktopPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GelbooruPostDetailsDesktopPageState();
}

class _GelbooruPostDetailsDesktopPageState
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
    final data = PostDetails.of<GelbooruPost>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageDesktopScaffold(
      controller: controller,
      posts: posts,
      onPageLoaded: (post) {
        ref.read(tagsProvider(booruConfig).notifier).load(
          post.tags,
          onSuccess: (tags) {
            if (!mounted) return;
            _loadTags(post);
          },
        );
      },
      imageUrlBuilder: defaultPostImageUrlBuilder(ref),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
    );
  }
}
