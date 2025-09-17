// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/providers.dart';
import '../../../../router.dart';
import '../../../../widgets/adaptive_button_row.dart';
import '../../../../widgets/booru_menu_button_row.dart';
import '../../../details/details.dart';
import '../../../favorites/providers.dart';
import '../../../favorites/widgets.dart';
import '../../../post/post.dart';
import '../../../shares/widgets.dart';
import '../common_post_buttons.dart';
import 'bookmark_post_button.dart';
import 'comment_post_button.dart';
import 'download_post_button.dart';

class SimplePostActionToolbar extends ConsumerWidget {
  const SimplePostActionToolbar({
    required this.post,
    required this.onStartSlideshow,
    super.key,
    this.isFaved,
    this.isAuthorized,
    this.addFavorite,
    this.removeFavorite,
    this.forceHideFav = false,
    this.onDownload,
    this.maxVisibleButtons,
  });

  final Post post;
  final int? maxVisibleButtons;
  final bool? isFaved;
  final bool? isAuthorized;
  final bool forceHideFav;
  final Future<void> Function()? addFavorite;
  final Future<void> Function()? removeFavorite;
  final void Function(Post post)? onDownload;
  final void Function() onStartSlideshow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider(ref.watchConfigAuth));
    final commentPageBuilder = booruBuilder?.commentPageBuilder;
    final auth = ref.watchConfigAuth;
    final viewer = ref.watchConfigViewer;
    final download = ref.watchConfigDownload;

    return CommonPostButtonsBuilder(
      post: post,
      onStartSlideshow: onStartSlideshow,
      config: auth,
      configViewer: viewer,
      builder: (context, buttons) {
        return BooruMenuButtonRow(
          maxVisibleButtons: maxVisibleButtons,
          buttons: [
            if (!forceHideFav &&
                isAuthorized != null &&
                addFavorite != null &&
                removeFavorite != null &&
                booruBuilder != null)
              ButtonData(
                required: true,
                widget: FavoritePostButton(
                  isFaved: isFaved,
                  isAuthorized: isAuthorized!,
                  addFavorite: addFavorite!,
                  removeFavorite: removeFavorite!,
                ),
                title: context.t.post.action.favorite,
              ),
            ButtonData(
              required: true,
              widget: BookmarkPostButton(post: post, config: auth),
              title: context.t.post.action.bookmark,
            ),
            ButtonData(
              required: true,
              widget: DownloadPostButton(post: post),
              title: context.t.download.download,
            ),
            ButtonData(
              required: true,
              widget: SharePostButton(
                post: post,
                auth: auth,
                configViewer: viewer,
                download: download,
              ),
              title: context.t.post.action.share,
            ),
            if (commentPageBuilder != null)
              ButtonData(
                widget: CommentPostButton(
                  onPressed: () => goToCommentPage(context, ref, post.id),
                ),
                title: context.t.comment.comments,
                onTap: () => goToCommentPage(context, ref, post.id),
              ),
            ...buttons,
          ],
        );
      },
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
          ? DefaultPostActionToolbar<T>(post: post)
          : const SizedBox.shrink(),
    );
  }
}

class DefaultPostActionToolbar<T extends Post> extends ConsumerWidget {
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
    final loginDetails = ref.watch(booruLoginDetailsProvider(config));
    final isFaved = ref.watch(favoriteProvider((config, post.id)));
    final notifier = ref.watch(favoritesProvider(config).notifier);
    final canFavorite = ref.watch(canFavoriteProvider(config));

    return SimplePostActionToolbar(
      post: post,
      isFaved: isFaved,
      isAuthorized: loginDetails.hasLogin(),
      maxVisibleButtons: 5,
      addFavorite: canFavorite ? () => notifier.add(post.id) : null,
      removeFavorite: canFavorite ? () => notifier.remove(post.id) : null,
      forceHideFav: forceHideFav,
      onStartSlideshow: PostDetailsPageViewScope.of(context).startSlideshow,
    );
  }
}
