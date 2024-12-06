// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import '../../../post.dart';
import '../../../shares/share_post_button.dart';
import '../../inherited_post.dart';
import 'bookmark_post_button.dart';
import 'comment_post_button.dart';
import 'download_post_button.dart';

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
    final commentPageBuilder =
        ref.watch(currentBooruBuilderProvider)?.commentPageBuilder;
    final booruBuilder = ref.watch(currentBooruBuilderProvider);

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
            onPressed: () => goToCommentPage(context, ref, post.id),
          ),
        SharePostButton(post: post),
      ],
    );
  }
}

class DefaultInheritedPostActionToolbar<T extends Post>
    extends StatelessWidget {
  const DefaultInheritedPostActionToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.maybeOf<T>(context);

    return SliverToBoxAdapter(
      child: post != null
          ? DefaultPostActionToolbar(post: post)
          : const SizedBox.shrink(),
    );
  }
}

class DefaultPostActionToolbar extends ConsumerWidget {
  const DefaultPostActionToolbar({
    super.key,
    required this.post,
    this.forceHideFav = false,
  });

  final Post post;
  final bool forceHideFav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final isFaved = ref.watch(favoriteProvider(post.id));
    final favoriteAdder = ref.watch(addFavoriteProvider);
    final favoriteRemover = ref.watch(removeFavoriteProvider);

    return SimplePostActionToolbar(
      post: post,
      isFaved: isFaved,
      isAuthorized: config.hasLoginDetails(),
      addFavorite:
          favoriteAdder != null ? () => favoriteAdder(post.id, ref) : null,
      removeFavorite:
          favoriteRemover != null ? () => favoriteRemover(post.id, ref) : null,
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
      color: context.colorScheme.surface,
      child: OverflowBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }
}
