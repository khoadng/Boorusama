// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/downloads/downloader/providers.dart';
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
import '../../../../../../core/widgets/overflow_button_row.dart';
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
      child: OverflowButtonRow(
        buttonWidth: 52,
        onOverflow: (index) {
          // Handle overflow button actions
          final allActions = [
            if (config.hasLoginDetails()) 'favorite',
            if (config.hasLoginDetails()) 'upvote',
            if (config.hasLoginDetails()) 'downvote',
            'bookmark',
            'comment',
            'download',
            'share',
            'copy_image',
            if (config.hasLoginDetails()) 'add_to_favgroup',
            if (post.tags.isNotEmpty) 'show_tag_list',
            'tag_history',
            if (!config.hasStrictSFW) 'view_in_browser',
            if (post.hasFullView) 'view_original',
            if (onStartSlideshow != null) 'start_slideshow',
            'settings',
          ];

          if (index < allActions.length) {
            _handleAction(
              allActions[index],
              context,
              ref,
              config,
              configViewer,
              postLinkGenerator,
            );
          }
        },
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
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => copyImage(ref, post),
            tooltip: 'Copy image',
          ),
          if (config.hasLoginDetails())
            IconButton(
              icon: const Icon(Icons.folder_special),
              onPressed: () =>
                  goToAddToFavoriteGroupSelectionPage(context, [post]),
              tooltip: context.t.post.action.add_to_favorite_group,
            ),
          if (post.tags.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.label),
              onPressed: () => goToShowTaglistPage(ref, post),
              tooltip: 'View tags',
            ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => goToPostVersionPage(ref, post),
            tooltip: 'View tag history',
          ),
          if (!config.hasStrictSFW)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () =>
                  launchExternalUrlString(postLinkGenerator.getLink(post)),
              tooltip: context.t.post.detail.view_in_browser,
            ),
          if (post.hasFullView)
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: () => goToOriginalImagePage(ref, post),
              tooltip: context.t.post.image_fullview.view_original,
            ),
          if (onStartSlideshow != null)
            IconButton(
              icon: const Icon(Icons.slideshow),
              onPressed: onStartSlideshow,
              tooltip: 'Slideshow',
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => openImageViewerSettingsPage(ref),
            tooltip: context.t.settings.settings,
          ),
        ],
      ),
    );
  }

  void _handleAction(
    String action,
    BuildContext context,
    WidgetRef ref,
    BooruConfigAuth config,
    BooruConfigViewer configViewer,
    PostLinkGenerator postLinkGenerator,
  ) {
    switch (action) {
      case 'download':
        ref.download(post);
      case 'copy_image':
        copyImage(ref, post);
      case 'add_to_favgroup':
        goToAddToFavoriteGroupSelectionPage(context, [post]);
      case 'show_tag_list':
        goToShowTaglistPage(ref, post);
      case 'view_in_browser':
        launchExternalUrlString(postLinkGenerator.getLink(post));
      case 'view_original':
        goToOriginalImagePage(ref, post);
      case 'start_slideshow':
        if (onStartSlideshow != null) {
          onStartSlideshow!();
        }
      case 'tag_history':
        goToPostVersionPage(ref, post);
      case 'settings':
        openImageViewerSettingsPage(ref);
      default:
    }
  }
}
