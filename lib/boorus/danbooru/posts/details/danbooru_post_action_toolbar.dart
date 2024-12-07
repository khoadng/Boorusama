// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/favorites/favorites_notifier.dart';
import 'package:boorusama/boorus/danbooru/posts/post/danbooru_post.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/favorites/favorite_post_button.dart';
import 'package:boorusama/core/posts/details.dart';
import 'package:boorusama/core/posts/shares.dart';
import 'package:boorusama/core/posts/votes.dart';
import 'package:boorusama/router.dart';
import '../votes/post_votes_notifier.dart';

class DanbooruInheritedPostActionToolbar extends StatelessWidget {
  const DanbooruInheritedPostActionToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.maybeOf<DanbooruPost>(context);

    return post != null
        ? DanbooruPostActionToolbar(post: post)
        : const SizedBox.shrink();
  }
}

class DanbooruPostActionToolbar extends ConsumerWidget {
  const DanbooruPostActionToolbar({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final isFaved = ref.watch(danbooruFavoriteProvider(post.id));
    final postVote = ref.watch(danbooruPostVoteProvider(post.id));
    final voteState = postVote?.voteState ?? VoteState.unvote;

    return SliverToBoxAdapter(
      child: PostActionToolbar(
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
      ),
    );
  }
}
