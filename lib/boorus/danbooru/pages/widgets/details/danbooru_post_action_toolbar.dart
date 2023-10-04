// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class DanbooruPostActionToolbar extends ConsumerWidget {
  const DanbooruPostActionToolbar({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final isFaved = ref.watch(danbooruFavoriteProvider(post.id));
    final postVote = ref.watch(danbooruPostVoteProvider(post.id));
    final voteState = postVote?.voteState ?? VoteState.unvote;

    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: ButtonBar(
        buttonPadding: EdgeInsets.zero,
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          FavoritePostButton(
            isFaved: isFaved,
            isAuthorized: config.hasLoginDetails(),
            addFavorite: () => ref.danbooruFavorites.add(post.id),
            removeFavorite: () => ref.danbooruFavorites.remove(post.id),
          ),
          if (config.hasLoginDetails())
            IconButton(
              icon: Icon(
                Icons.arrow_upward,
                color: voteState.isUpvoted ? Colors.redAccent : null,
              ),
              splashRadius: 16,
              onPressed: () {
                ref
                    .read(danbooruPostVotesProvider(config).notifier)
                    .upvote(post.id);
              },
            ),
          if (config.hasLoginDetails())
            IconButton(
              icon: Icon(
                Icons.arrow_downward,
                color: voteState.isDownvoted ? Colors.blueAccent : null,
              ),
              splashRadius: 16,
              onPressed: () {
                ref
                    .read(danbooruPostVotesProvider(config).notifier)
                    .downvote(post.id);
              },
            ),
          BookmarkPostButton(post: post),
          CommentPostButton(
            post: post,
            onPressed: () => goToCommentPage(context, post.id),
          ),
          DownloadPostButton(post: post),
          SharePostButton(post: post),
        ],
      ),
    );
  }
}
