// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/posts/favorites/providers.dart';
import '../../../core/posts/favorites/widgets.dart';
import '../../../core/posts/shares/widgets.dart';
import '../../../core/posts/votes/vote.dart';
import '../../../core/posts/votes/widgets.dart';
import '../../../core/router.dart';
import '../posts/types.dart';
import 'providers.dart';

class SzurubooruPostActionToolbar extends ConsumerWidget {
  const SzurubooruPostActionToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SzurubooruPost>(context);

    final config = ref.watchConfigAuth;
    final isFaved = ref.watch(favoriteProvider((config, post.id)));
    final postVote = ref.watch(szurubooruPostVoteProvider(post.id));
    final voteState = postVote?.voteState ?? VoteState.unvote;

    final favNotifier = ref.watch(favoritesProvider(config).notifier);
    final voteNotifier = ref.watch(
      szurubooruPostVotesProvider(config).notifier,
    );

    return SliverToBoxAdapter(
      child: PostActionToolbar(
        children: [
          if (config.hasLoginDetails())
            FavoritePostButton(
              isFaved: isFaved,
              isAuthorized: config.hasLoginDetails(),
              addFavorite: () => favNotifier.add(post.id),
              removeFavorite: () => favNotifier.remove(post.id),
            ),
          if (config.hasLoginDetails())
            UpvotePostButton(
              voteState: voteState,
              onUpvote: () => voteNotifier.upvote(post.id),
              onRemoveUpvote: () => voteNotifier.removeVote(post.id),
            ),
          if (config.hasLoginDetails())
            DownvotePostButton(
              voteState: voteState,
              onDownvote: () => voteNotifier.downvote(post.id),
              onRemoveDownvote: () => voteNotifier.removeVote(post.id),
            ),
          BookmarkPostButton(post: post),
          CommentPostButton(
            onPressed: () => goToCommentPage(context, ref, post.id),
          ),
          DownloadPostButton(post: post),
          SharePostButton(post: post),
        ],
      ),
    );
  }
}
