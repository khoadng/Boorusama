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
import '../../../core/widgets/booru_menu_button_row.dart';
import '../posts/types.dart';
import 'providers.dart';

class SzurubooruPostActionToolbar extends ConsumerWidget {
  const SzurubooruPostActionToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SzurubooruPost>(context);
    final controller = PostDetails.of<SzurubooruPost>(
      context,
    ).pageViewController;

    final config = ref.watchConfigAuth;
    final configViewer = ref.watchConfigViewer;
    final download = ref.watchConfigDownload;
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
        onStartSlideshow: controller.startSlideshow,
        config: config,
        configViewer: configViewer,
        builder: (context, buttons) {
          return BooruMenuButtonRow(
            maxVisibleButtons: 5,
            buttons: [
              if (config.hasLoginDetails())
                ButtonData(
                  required: true,
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
                  required: true,
                  widget: UpvotePostButton(
                    voteState: voteState,
                    onUpvote: () => voteNotifier.upvote(post.id),
                    onRemoveUpvote: () => voteNotifier.removeVote(post.id),
                  ),
                  title: context.t.post.action.upvote,
                ),
              if (config.hasLoginDetails())
                ButtonData(
                  required: true,
                  widget: DownvotePostButton(
                    voteState: voteState,
                    onDownvote: () => voteNotifier.downvote(post.id),
                    onRemoveDownvote: () => voteNotifier.removeVote(post.id),
                  ),
                  title: context.t.post.action.downvote,
                ),
              ButtonData(
                required: true,
                widget: BookmarkPostButton(post: post, config: config),
                title: context.t.post.action.bookmark,
              ),
              ButtonData(
                required: true,
                widget: DownloadPostButton(post: post),
                title: context.t.download.download,
              ),
              ButtonData(
                widget: SharePostButton(
                  post: post,
                  auth: config,
                  configViewer: configViewer,
                  download: download,
                ),
                title: context.t.post.action.share,
              ),
              ButtonData(
                widget: CommentPostButton(
                  onPressed: () => goToCommentPage(context, ref, post.id),
                ),
                title: context.t.post.action.view_comments,
                onTap: () => goToCommentPage(context, ref, post.id),
              ),
              ...buttons,
            ],
          );
        },
      ),
    );
  }
}
