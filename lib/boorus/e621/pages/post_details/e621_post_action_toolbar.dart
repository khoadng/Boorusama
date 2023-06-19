// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/posts/favorite_post_button.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/flutter.dart';

class E621PostActionToolbar extends ConsumerWidget {
  const E621PostActionToolbar({
    super.key,
    required this.post,
  });

  final E621Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationProvider);
    final isFaved = ref.watch(e621FavoriteProvider(post.id));

    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: ButtonBar(
        buttonPadding: EdgeInsets.zero,
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          FavoritePostButton(
              isFaved: isFaved,
              isAuthorized: authState.isAuthenticated,
              addFavorite: () =>
                  ref.read(e621FavoritesProvider.notifier).add(post.id),
              removeFavorite: () =>
                  ref.read(e621FavoritesProvider.notifier).remove(post.id)),
          BookmarkPostButton(post: post),
          DownloadPostButton(post: post),
          SharePostButton(post: post),
        ],
      ),
    );
  }
}
