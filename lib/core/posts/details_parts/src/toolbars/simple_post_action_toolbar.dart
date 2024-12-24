// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../router.dart';
import '../../../details/details.dart';
import '../../../favorites/providers.dart';
import '../../../favorites/widgets.dart';
import '../../../post/post.dart';
import '../../../shares/widgets.dart';
import 'bookmark_post_button.dart';
import 'comment_post_button.dart';
import 'download_post_button.dart';

class SimplePostActionToolbar extends ConsumerWidget {
  const SimplePostActionToolbar({
    required this.post,
    super.key,
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
    required this.post,
    super.key,
    this.forceHideFav = false,
  });

  final Post post;
  final bool forceHideFav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final isFaved = ref.watch(favoriteProvider(post.id));
    final notifier = ref.watch(favoritesProvider(config).notifier);
    final canFavorite = ref.watch(canFavoriteProvider(config));

    return SimplePostActionToolbar(
      post: post,
      isFaved: isFaved,
      isAuthorized: config.hasLoginDetails(),
      addFavorite: canFavorite ? () => notifier.add(post.id) : null,
      removeFavorite: canFavorite ? () => notifier.remove(post.id) : null,
    );
  }
}

class PostActionToolbar extends StatelessWidget {
  const PostActionToolbar({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: Theme.of(context).colorScheme.surface,
      child: OverflowBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }
}
