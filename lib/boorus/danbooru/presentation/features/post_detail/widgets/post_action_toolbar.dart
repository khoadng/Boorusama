// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_state_notifier.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/favorites/favorite_post_repository.dart';

class PostActionToolbar extends HookWidget {
  const PostActionToolbar({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    // final comments = useProvider(_commentsProvider(post.id));
    final isLoggedIn = useProvider(isLoggedInProvider);

    bool displayNoticeIfNotLoggedIn() {
      if (!isLoggedIn) {
        final snackbar = SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 6.0,
          content: Text(
            'You need to log in to perform this action',
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        return false;
      }
      return true;
    }

    final isFaved = useState(post.isFavorited);

    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        TextButton.icon(
            onPressed: () {},
            icon: FaIcon(FontAwesomeIcons.thumbsUp, color: Colors.white),
            label: Text(
              post.upScore.toString(),
              style: TextStyle(color: Colors.white),
            )),
        TextButton.icon(
            onPressed: () {},
            icon: FaIcon(
              FontAwesomeIcons.thumbsDown,
              color: Colors.white,
            ),
            label: Text(
              post.downScore.toString(),
              style: TextStyle(color: Colors.white),
            )),
        TextButton.icon(
            onPressed: () {
              final loggedIn = displayNoticeIfNotLoggedIn();

              if (!loggedIn) {
                isFaved.value = false;
                return null;
              }

              //TODO: check for success here
              if (!isFaved.value) {
                context.read(favoriteProvider).addToFavorites(post.id);
              } else {
                context.read(favoriteProvider).removeFromFavorites(post.id);
              }

              isFaved.value = !isFaved.value;
            },
            icon: FaIcon(
              isFaved.value
                  ? FontAwesomeIcons.solidHeart
                  : FontAwesomeIcons.heart,
              color: isFaved.value ? Colors.red : Colors.white,
            ),
            label: Text(
              isFaved.value
                  ? (post.favCount + 1).toString()
                  : post.favCount.toString(),
              style: TextStyle(color: Colors.white),
            )),
      ],
    );
  }
}
