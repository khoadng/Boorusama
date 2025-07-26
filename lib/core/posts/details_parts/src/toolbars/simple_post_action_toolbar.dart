// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/url_launcher.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../configs/ref.dart';
import '../../../../images/copy.dart';
import '../../../../router.dart';
import '../../../../settings/routes.dart';
import '../../../../tags/tag/routes.dart';
import '../../../../widgets/adaptive_button_row.dart';
import '../../../details/details.dart';
import '../../../favorites/providers.dart';
import '../../../favorites/widgets.dart';
import '../../../post/post.dart';
import '../../../post/providers.dart';
import '../../../post/routes.dart';
import '../../../shares/widgets.dart';
import 'bookmark_post_button.dart';
import 'comment_post_button.dart';
import 'download_post_button.dart';

class SimplePostActionToolbar extends ConsumerWidget with CopyImageMixin {
  const SimplePostActionToolbar({
    required this.post,
    required this.config,
    required this.configViewer,
    super.key,
    this.isFaved,
    this.isAuthorized,
    this.addFavorite,
    this.removeFavorite,
    this.forceHideFav = false,
    this.onDownload,
    this.onStartSlideshow,
  });

  final Post post;
  final bool? isFaved;
  final bool? isAuthorized;
  final bool forceHideFav;
  final Future<void> Function()? addFavorite;
  final Future<void> Function()? removeFavorite;
  final void Function(Post post)? onDownload;
  final void Function()? onStartSlideshow;

  @override
  final BooruConfigAuth config;
  @override
  final BooruConfigViewer configViewer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider(ref.watchConfigAuth));
    final commentPageBuilder = booruBuilder?.commentPageBuilder;
    final config = ref.watchConfigAuth;
    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(config));

    return AdaptiveButtonRow.menu(
      buttonWidth: 52,
      buttons: [
        if (!forceHideFav &&
            isAuthorized != null &&
            addFavorite != null &&
            removeFavorite != null &&
            booruBuilder != null)
          ButtonData(
            behavior: ButtonBehavior.alwaysVisible,
            widget: FavoritePostButton(
              isFaved: isFaved,
              isAuthorized: isAuthorized!,
              addFavorite: addFavorite!,
              removeFavorite: removeFavorite!,
            ),
            title: context.t.post.action.favorite,
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
          behavior: ButtonBehavior.alwaysVisible,
          widget: SharePostButton(post: post),
          title: context.t.post.action.share,
        ),

        if (commentPageBuilder != null)
          ButtonData(
            widget: CommentPostButton(
              onPressed: () => goToCommentPage(context, ref, post.id),
            ),
            title: context.t.comment.comments,
          ),
        SimpleButtonData(
          icon: Icons.copy,
          title: 'Copy image',
          onPressed: () => copyImage(ref, post),
        ),
        if (!config.hasStrictSFW)
          SimpleButtonData(
            icon: Icons.open_in_browser,
            title: context.t.post.detail.view_in_browser,
            onPressed: () => launchExternalUrlString(
              postLinkGenerator.getLink(post),
            ),
          ),
        if (post.tags.isNotEmpty)
          SimpleButtonData(
            icon: Icons.label,
            title: 'View tags',
            onPressed: () => goToShowTaglistPage(ref, post),
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
    );
  }
}

class DefaultInheritedPostActionToolbar<T extends Post>
    extends StatelessWidget {
  const DefaultInheritedPostActionToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.maybeOf<T>(context);

    return SliverToBoxAdapter(
      child: post != null
          ? DefaultPostActionToolbar(post: post)
          : const SizedBox.shrink(),
    );
  }
}

class DefaultPostActionToolbar extends ConsumerWidget {
  const DefaultPostActionToolbar({
    required this.post,
    super.key,
    this.forceHideFav = false,
  });

  final Post post;
  final bool forceHideFav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final isFaved = ref.watch(favoriteProvider((config, post.id)));
    final notifier = ref.watch(favoritesProvider(config).notifier);
    final canFavorite = ref.watch(canFavoriteProvider(config));

    return SimplePostActionToolbar(
      post: post,
      config: config,
      configViewer: ref.watchConfigViewer,
      isFaved: isFaved,
      isAuthorized: config.hasLoginDetails(),
      addFavorite: canFavorite ? () => notifier.add(post.id) : null,
      removeFavorite: canFavorite ? () => notifier.remove(post.id) : null,
      forceHideFav: forceHideFav,
    );
  }
}

@Deprecated('Use AdaptiveButtonRow.menu instead.')
class PostActionToolbar extends StatelessWidget {
  const PostActionToolbar({
    required this.children,
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return OverflowBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }
}
