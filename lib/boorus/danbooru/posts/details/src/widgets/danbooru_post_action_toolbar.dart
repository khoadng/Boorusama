// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/images/copy.dart';
import '../../../../../../core/posts/details/details.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/posts/favorites/providers.dart';
import '../../../../../../core/posts/favorites/widgets.dart';
import '../../../../../../core/posts/post/post.dart';
import '../../../../../../core/posts/post/providers.dart';
import '../../../../../../core/posts/post/routes.dart';
import '../../../../../../core/posts/shares/widgets.dart';
import '../../../../../../core/posts/votes/vote.dart';
import '../../../../../../core/posts/votes/widgets.dart';
import '../../../../../../core/router.dart';
import '../../../../../../core/settings/routes.dart';
import '../../../../../../core/tags/tag/routes.dart';
import '../../../../../../core/widgets/adaptive_button_row.dart';
import '../../../../../../foundation/url_launcher.dart';
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
    final config = ref.watchConfigAuth;
    final configViewer = ref.watchConfigViewer;

    return post != null
        ? DanbooruPostActionToolbar(
            post: post,
            config: config,
            configViewer: configViewer,
            onStartSlideshow: controller.startSlideshow,
          )
        : const SizedBox.shrink();
  }
}

class DanbooruPostActionToolbar extends ConsumerWidget with CopyImageMixin {
  const DanbooruPostActionToolbar({
    required this.post,
    required this.config,
    required this.configViewer,
    super.key,
    this.onStartSlideshow,
  });

  final DanbooruPost post;
  @override
  final BooruConfigAuth config;
  @override
  final BooruConfigViewer configViewer;
  final void Function()? onStartSlideshow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (config, post.id);
    final isFaved = ref.watch(favoriteProvider(params));
    final postVote = ref.watch(danbooruPostVoteProvider(params));
    final voteState = postVote?.voteState ?? VoteState.unvote;
    final notifier = ref.watch(favoritesProvider(config).notifier);
    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(config));

    return SliverToBoxAdapter(
      child: AdaptiveButtonRow.menu(
        buttonWidth: 52,
        buttons: [
          if (config.hasLoginDetails())
            ButtonData(
              behavior: ButtonBehavior.alwaysVisible,
              widget: FavoritePostButton(
                isFaved: isFaved,
                isAuthorized: config.hasLoginDetails(),
                addFavorite: () => notifier.add(post.id),
                removeFavorite: () => notifier.remove(post.id),
              ),
              title: context.t.post.action.favorite,
            ),
          if (config.hasLoginDetails())
            ButtonData(
              behavior: ButtonBehavior.alwaysVisible,

              widget: UpvotePostButton(
                voteState: voteState,
                onUpvote: () => ref.danbooruUpvote(post.id),
                onRemoveUpvote: () => ref.danbooruRemoveVote(post.id),
              ),
              title: 'Upvote',
            ),
          if (config.hasLoginDetails())
            ButtonData(
              behavior: ButtonBehavior.alwaysVisible,

              widget: DownvotePostButton(
                voteState: voteState,
                onDownvote: () => ref.danbooruDownvote(post.id),
                onRemoveDownvote: () => ref.danbooruRemoveVote(post.id),
              ),
              title: 'Downvote',
            ),
          ButtonData(
            behavior: ButtonBehavior.alwaysVisible,
            widget: BookmarkPostButton(post: post),
            title: context.t.post.action.bookmark,
          ),
          ButtonData(
            widget: CommentPostButton(
              onPressed: () => goToCommentPage(context, ref, post.id),
            ),
            title: context.t.comment.comments,
          ),
          ButtonData(
            widget: DownloadPostButton(post: post),
            title: context.t.download.download,
          ),
          ButtonData(
            widget: SharePostButton(post: post),
            title: context.t.post.action.share,
          ),
          SimpleButtonData(
            icon: Icons.copy,
            title: 'Copy image',
            onPressed: () => copyImage(ref, post),
          ),
          if (config.hasLoginDetails())
            SimpleButtonData(
              icon: Icons.folder_special,
              title: context.t.post.action.add_to_favorite_group,
              onPressed: () =>
                  goToAddToFavoriteGroupSelectionPage(context, [post]),
            ),
          if (post.tags.isNotEmpty)
            SimpleButtonData(
              icon: Icons.label,
              title: 'View tags',
              onPressed: () => goToShowTaglistPage(ref, post),
            ),
          SimpleButtonData(
            icon: Icons.history,
            title: 'View tag history',
            onPressed: () => goToPostVersionPage(ref, post),
          ),
          if (!config.hasStrictSFW)
            SimpleButtonData(
              icon: Icons.open_in_browser,
              title: context.t.post.detail.view_in_browser,
              onPressed: () =>
                  launchExternalUrlString(postLinkGenerator.getLink(post)),
            ),
          if (post.hasFullView)
            SimpleButtonData(
              icon: Icons.fullscreen,
              title: context.t.post.image_fullview.view_original,
              onPressed: () => goToOriginalImagePage(ref, post),
            ),
          if (onStartSlideshow != null)
            SimpleButtonData(
              icon: Icons.slideshow,
              title: 'Slideshow',
              onPressed: onStartSlideshow!,
            ),
          SimpleButtonData(
            icon: Icons.settings,
            title: context.t.settings.settings,
            onPressed: () => openImageViewerSettingsPage(ref),
          ),
        ],
      ),
    );
  }
}
