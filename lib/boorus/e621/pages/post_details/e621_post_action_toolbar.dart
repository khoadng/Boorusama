// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/posts/favorite_post_button.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
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

    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: ButtonBar(
        buttonPadding: EdgeInsets.zero,
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          FavoritePostButton(
            isFaved: post.isFavorited,
            isAuthorized: authState.isAuthenticated,
            addFavorite: () async {
              //FIXME: implement addFavorite
            },
            removeFavorite: () async {
              //FIXME: implement removeFavorite
            },
          ),
          BookmarkPostButton(post: post),
          DownloadPostButton(post: post),
          SharePostButton(post: post),
        ],
      ),
    );
  }
}
