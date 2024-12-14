// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/favorites/favorite_post_button.dart';
import '../../../../../../core/favorites/providers.dart';
import '../../../../../../core/posts/details/details.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/posts/shares/widgets.dart';
import '../../../../../../core/posts/votes/vote.dart';
import '../../../../../../core/posts/votes/widgets.dart';
import '../../../../../../core/router.dart';
import '../../../post/post.dart';
import '../../../votes/providers.dart';

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
    final isFaved = ref.watch(favoriteProvider(post.id));
    final postVote = ref.watch(danbooruPostVoteProvider(post.id));
    final voteState = postVote?.voteState ?? VoteState.unvote;
    final notifier = ref.watch(favoritesProvider(config).notifier);

    return SliverToBoxAdapter(
      child: PostActionToolbar(
        children: [
          if (config.hasLoginDetails())
            FavoritePostButton(
              isFaved: isFaved,
              isAuthorized: config.hasLoginDetails(),
              addFavorite: () => notifier.add(post.id),
              removeFavorite: () => notifier.remove(post.id),
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
