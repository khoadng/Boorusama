// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/favorites/favorites.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/router.dart';
import '../favorites/favorites.dart';
import '../post_votes/post_votes.dart';
import 'posts.dart';

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

    return PostActionToolbar(
      children: [
        if (config.hasLoginDetails())
          FavoritePostButton(
            isFaved: isFaved,
            isAuthorized: config.hasLoginDetails(),
            addFavorite: () => ref.danbooruFavorites.add(post.id),
            removeFavorite: () => ref.danbooruFavorites.remove(post.id),
          ),
        if (config.hasLoginDetails())
          UpvotePostButton(
            voteState: voteState,
            onUpvote: () => ref.danbooruUpvote(post.id),
            onRemoveUpvote: () => ref.danbooruRemoveVote(post.id),
          ),
        if (config.hasLoginDetails())
          DownvotePostButton(
            voteState: voteState,
            onDownvote: () => ref.danbooruDownvote(post.id),
            onRemoveDownvote: () => ref.danbooruRemoveVote(post.id),
          ),
        BookmarkPostButton(post: post),
        CommentPostButton(
          onPressed: () => goToCommentPage(context, ref, post.id),
        ),
        DownloadPostButton(post: post),
        SharePostButton(post: post),
      ],
    );
  }
}
