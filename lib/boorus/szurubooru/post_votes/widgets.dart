// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

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
import '../../../core/widgets/adaptive_button_row.dart';
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
      child: CommonPostButtonsBuilder(
        post: post,
        onStartSlideshow: PostDetails.of<SzurubooruPost>(
          context,
        ).pageViewController.startSlideshow,
        builder: (context, buttons) {
          return AdaptiveButtonRow.menu(
            buttonWidth: 52,
            buttons: [
              if (config.hasLoginDetails())
                ButtonData(
                  behavior: ButtonBehavior.alwaysVisible,
                  widget: FavoritePostButton(
                    isFaved: isFaved,
                    isAuthorized: config.hasLoginDetails(),
                    addFavorite: () => favNotifier.add(post.id),
                    removeFavorite: () => favNotifier.remove(post.id),
                  ),
                  title: context.t.post.action.favorite,
                ),
              if (config.hasLoginDetails())
                ButtonData(
                  behavior: ButtonBehavior.alwaysVisible,
                  widget: UpvotePostButton(
                    voteState: voteState,
                    onUpvote: () => voteNotifier.upvote(post.id),
                    onRemoveUpvote: () => voteNotifier.removeVote(post.id),
                  ),
                  title: context.t.post.action.upvote,
                ),
              if (config.hasLoginDetails())
                ButtonData(
                  behavior: ButtonBehavior.alwaysVisible,
                  widget: DownvotePostButton(
                    voteState: voteState,
                    onDownvote: () => voteNotifier.downvote(post.id),
                    onRemoveDownvote: () => voteNotifier.removeVote(post.id),
                  ),
                  title: context.t.post.action.downvote,
                ),
              ButtonData(
                behavior: ButtonBehavior.alwaysVisible,
                widget: BookmarkPostButton(post: post),
                title: context.t.post.action.bookmark,
              ),
              ButtonData(
                behavior: ButtonBehavior.alwaysVisible,
                widget: DownloadPostButton(post: post),
                title: context.t.download.download,
              ),
              ButtonData(
                widget: SharePostButton(post: post),
                title: context.t.post.action.share,
              ),
              ButtonData(
                widget: CommentPostButton(
                  onPressed: () => goToCommentPage(context, ref, post.id),
                ),
                title: context.t.post.action.view_comments,
              ),
              ...buttons,
            ],
          );
        },
      ),
    );
  }
}
