// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';

class DanbooruPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const DanbooruPostDetailsDesktopPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruPostDetailsDesktopPageState();
}

class _DanbooruPostDetailsDesktopPageState
    extends ConsumerState<DanbooruPostDetailsDesktopPage> with DebounceMixin {
  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<DanbooruPost>(context);
    final posts = data.posts;
    final controller = data.controller;

    return ValueListenableBuilder(
      valueListenable: controller.currentPage,
      builder: (context, page, child) {
        final post = posts[page];
        final isFav = ref.watch(danbooruFavoriteProvider(post.id));
        final booruConfig = ref.watchConfig;

        return CallbackShortcuts(
          bindings: {
            if (booruConfig.hasLoginDetails())
              const SingleActivator(LogicalKeyboardKey.keyF): () => !isFav
                  ? ref.danbooruFavorites.add(post.id)
                  : ref.danbooruFavorites.remove(post.id),
          },
          child: child!,
        );
      },
      child: DanbooruCreatorPreloader(
        posts: posts,
        child: _buildPage(
          posts: posts,
          controller: controller,
        ),
      ),
    );
  }

  Widget _buildPage({
    required List<DanbooruPost> posts,
    required PostDetailsController<DanbooruPost> controller,
  }) {
    return PostDetailsPageDesktopScaffold(
      controller: controller,
      posts: posts,
      imageUrlBuilder: defaultPostImageUrlBuilder(ref),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          DanbooruMoreActionButton(
        post: post,
      ),
    );
  }
}
