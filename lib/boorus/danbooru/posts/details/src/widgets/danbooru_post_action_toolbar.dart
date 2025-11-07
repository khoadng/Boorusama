// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/posts/details/types.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/posts/favorites/providers.dart';
import '../../../../../../core/posts/favorites/widgets.dart';
import '../../../../../../core/posts/shares/widgets.dart';
import '../../../../../../core/posts/votes/types.dart';
import '../../../../../../core/posts/votes/widgets.dart';
import '../../../../../../core/router.dart';
import '../../../../../../core/widgets/adaptive_button_row.dart';
import '../../../../../../core/widgets/booru_menu_button_row.dart';
import '../../../../configs/providers.dart';
import '../../../../favgroups/favgroups/routes.dart';
import '../../../../versions/routes.dart';
import '../../../post/types.dart';
import '../../../votes/providers.dart';

class DanbooruInheritedPostActionToolbar extends ConsumerWidget {
  const DanbooruInheritedPostActionToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.maybeOf<DanbooruPost>(context);
    final controller = PostDetailsPageViewScope.of(context);

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
    final configViewer = ref.watchConfigViewer;
    final download = ref.watchConfigDownload;
    final params = (config, post.id);
    final isFaved = ref.watch(favoriteProvider(params));
    final postVote = ref.watch(danbooruPostVoteProvider(params));
    final voteState = postVote?.voteState ?? VoteState.unvote;
    final notifier = ref.watch(favoritesProvider(config).notifier);
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));
    final hasLogin = loginDetails.hasLogin();

    return SliverToBoxAdapter(
      child: CommonPostButtonsBuilder(
        post: post,
        onStartSlideshow: onStartSlideshow,
        config: config,
        configViewer: configViewer,
        builder: (context, buttons) {
          return BooruMenuButtonRow(
            maxVisibleButtons: hasLogin ? 7 : 4,
            buttons: [
              if (hasLogin)
                ButtonData(
                  required: true,
                  widget: FavoritePostButton(
                    isFaved: isFaved,
                    isAuthorized: loginDetails.hasLogin(),
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
                  configViewer: configViewer,
                  download: download,
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
                title: context.t.post.action.view_tag_history,
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
