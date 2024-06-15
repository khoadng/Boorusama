// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class SimplePostActionToolbar extends ConsumerWidget {
  const SimplePostActionToolbar({
    super.key,
    required this.post,
    this.isFaved,
    this.isAuthorized,
    this.addFavorite,
    this.removeFavorite,
    this.forceHideFav = false,
  });

  final Post post;
  final bool? isFaved;
  final bool? isAuthorized;
  final bool forceHideFav;
  final Future<void> Function()? addFavorite;
  final Future<void> Function()? removeFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfig;
    final commentPageBuilder =
        ref.watchBooruBuilder(booruConfig)?.commentPageBuilder;
    final booruBuilder = ref.watch(booruBuilderProvider);

    return PostActionToolbar(
      children: [
        if (!forceHideFav)
          if (isAuthorized != null &&
              addFavorite != null &&
              removeFavorite != null &&
              booruBuilder != null)
            FavoritePostButton(
              isFaved: isFaved,
              isAuthorized: isAuthorized!,
              addFavorite: addFavorite!,
              removeFavorite: removeFavorite!,
            ),
        BookmarkPostButton(post: post),
        DownloadPostButton(post: post),
        if (commentPageBuilder != null)
          CommentPostButton(
            post: post,
            onPressed: () => goToCommentPage(context, ref, post.id),
          ),
        SharePostButton(post: post),
      ],
    );
  }
}

class PostActionToolbar extends StatelessWidget {
  const PostActionToolbar({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: context.theme.scaffoldBackgroundColor,
      child: OverflowBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }
}
