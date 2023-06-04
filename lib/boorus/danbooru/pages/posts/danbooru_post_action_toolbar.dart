// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/authentication/authentication.dart';
import 'package:boorusama/boorus/core/pages/posts.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/danbooru/features/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/features/posts/app.dart';
import 'package:boorusama/boorus/danbooru/features/posts/models.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/foundation/i18n.dart';

class DanbooruPostActionToolbar extends ConsumerWidget {
  const DanbooruPostActionToolbar({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationProvider);
    final voteState = ref.watch(danbooruPostVoteProvider(post.id))?.voteState ??
        VoteState.unvote;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ButtonBar(
        buttonPadding: EdgeInsets.zero,
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          _FavoriteButton(post: post),
          if (authState is Authenticated)
            IconButton(
              icon: Icon(
                Icons.arrow_upward,
                color: voteState == VoteState.upvoted ? Colors.redAccent : null,
              ),
              onPressed: () {
                ref.read(danbooruPostVotesProvider.notifier).upvote(post.id);
              },
            ),
          if (authState is Authenticated)
            IconButton(
              icon: Icon(
                Icons.arrow_downward,
                color:
                    voteState == VoteState.downvoted ? Colors.blueAccent : null,
              ),
              onPressed: () {
                ref.read(danbooruPostVotesProvider.notifier).downvote(post.id);
              },
            ),
          BookmarkPostButton(post: post),
          _buildCommentButton(context),
          DownloadPostButton(post: post),
          SharePostButton(post: post),
        ],
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    return IconButton(
      onPressed: () => goToCommentPage(context, post.id),
      icon: const FaIcon(
        FontAwesomeIcons.comment,
      ),
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationProvider);
    final isFaved = ref.watch(danbooruFavoriteProvider(post.id));

    return IconButton(
      onPressed: () async {
        if (authState is Unauthenticated) {
          showSimpleSnackBar(
            context: context,
            content: const Text(
              'post.detail.login_required_notice',
            ).tr(),
            duration: const Duration(seconds: 1),
          );

          return;
        }
        if (isFaved) {
          ref.danbooruFavorites.remove(post.id);
        } else {
          ref.danbooruFavorites.add(post.id);
        }
      },
      icon: isFaved
          ? const FaIcon(
              FontAwesomeIcons.solidHeart,
              color: Colors.red,
            )
          : const FaIcon(
              FontAwesomeIcons.heart,
            ),
    );
  }
}
