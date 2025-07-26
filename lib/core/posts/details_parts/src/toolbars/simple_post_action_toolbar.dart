// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../router.dart';
import '../../../../widgets/adaptive_button_row.dart';
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
  });

  final Post post;
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

    return CommonPostButtonsBuilder(
      post: post,
      onStartSlideshow: onStartSlideshow,
      builder: (context, buttons) {
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
    final isFaved = ref.watch(favoriteProvider((config, post.id)));
    final notifier = ref.watch(favoritesProvider(config).notifier);
    final canFavorite = ref.watch(canFavoriteProvider(config));

    return SimplePostActionToolbar(
      post: post,
      isFaved: isFaved,
      isAuthorized: config.hasLoginDetails(),
      addFavorite: canFavorite ? () => notifier.add(post.id) : null,
      removeFavorite: canFavorite ? () => notifier.remove(post.id) : null,
      forceHideFav: forceHideFav,
      onStartSlideshow: PostDetails.of<T>(
        context,
      ).pageViewController.startSlideshow,
    );
  }
}
