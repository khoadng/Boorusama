// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/details/details.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/posts/favorites/providers.dart';
import '../../../../../../core/posts/favorites/widgets.dart';
import '../../../../../../core/posts/shares/widgets.dart';
import '../../../../../../core/posts/votes/vote.dart';
import '../../../../../../core/posts/votes/widgets.dart';
import '../../../../../../core/router.dart';
import '../../../../../../core/widgets/adaptive_button_row.dart';
import '../../../../versions/routes.dart';
import '../../../favgroups/favgroups/routes.dart';
import '../../../post/post.dart';
import '../../../votes/providers.dart';

class DanbooruInheritedPostActionToolbar extends ConsumerWidget {
  const DanbooruInheritedPostActionToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.maybeOf<DanbooruPost>(context);
    final controller = PostDetails.of<DanbooruPost>(context).pageViewController;

    return post != null
        ? DanbooruPostActionToolbar(
            post: post,
            onStartSlideshow: controller.startSlideshow,
          )
        : const SizedBox.shrink();
  }
}

class DanbooruPostActionToolbar extends ConsumerWidget {
  const DanbooruPostActionToolbar({
    required this.post,
    required this.onStartSlideshow,
    super.key,
  });

  final DanbooruPost post;
  final void Function() onStartSlideshow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final params = (config, post.id);
    final isFaved = ref.watch(favoriteProvider(params));
    final postVote = ref.watch(danbooruPostVoteProvider(params));
    final voteState = postVote?.voteState ?? VoteState.unvote;
    final notifier = ref.watch(favoritesProvider(config).notifier);
    final hasLogin = config.hasLoginDetails();

    return SliverToBoxAdapter(
      child: CommonPostButtonsBuilder(
        post: post,
        onStartSlideshow: onStartSlideshow,
        config: config,
        configViewer: ref.watchConfigViewer,
        builder: (context, buttons) {
          return AdaptiveButtonRow.menu(
            buttonWidth: 48,
            maxVisibleButtons: hasLogin ? 7 : 4,
            buttons: [
              if (hasLogin)
                ButtonData(
                  required: true,
                  widget: FavoritePostButton(
                    isFaved: isFaved,
                    isAuthorized: config.hasLoginDetails(),
                    addFavorite: () => notifier.add(post.id),
                    removeFavorite: () => notifier.remove(post.id),
                  ),
                  title: context.t.post.action.favorite,
                ),
              if (hasLogin)
                ButtonData(
                  required: true,
                  widget: UpvotePostButton(
                    voteState: voteState,
                    onUpvote: () => ref.danbooruUpvote(post.id),
                    onRemoveUpvote: () => ref.danbooruRemoveVote(post.id),
                  ),
                  title: context.t.post.action.upvote,
                ),
              if (hasLogin)
                ButtonData(
                  required: true,
                  widget: DownvotePostButton(
                    voteState: voteState,
                    onDownvote: () => ref.danbooruDownvote(post.id),
                    onRemoveDownvote: () => ref.danbooruRemoveVote(post.id),
                  ),
                  title: context.t.post.action.downvote,
                ),
              ButtonData(
                required: true,
                widget: BookmarkPostButton(
                  post: post,
                  config: config,
                ),
                title: context.t.post.action.bookmark,
              ),
              ButtonData(
                widget: DownloadPostButton(post: post),
                title: context.t.download.download,
              ),
              ButtonData(
                widget: SharePostButton(
                  post: post,
                  auth: config,
                ),
                title: context.t.post.action.share,
              ),
              ButtonData(
                widget: CommentPostButton(
                  onPressed: () => goToCommentPage(context, ref, post.id),
                ),
                title: context.t.comment.comments,
                onTap: () => goToCommentPage(context, ref, post.id),
              ),
              if (hasLogin)
                SimpleButtonData(
                  icon: Icons.folder_special,
                  title: context.t.post.action.add_to_favorite_group,
                  onPressed: () =>
                      goToAddToFavoriteGroupSelectionPage(context, [post]),
                ),
              SimpleButtonData(
                icon: Icons.history,
                title: 'View tag history'.hc,
                onPressed: () => goToPostVersionPage(ref, post),
              ),
              ...buttons,
            ],
          );
        },
      ),
    );
  }
}
