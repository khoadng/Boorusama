// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../core/bookmarks/bookmark.dart';
import '../../../../../core/bookmarks/providers.dart';
import '../../../../../core/configs/ref.dart';
import '../../../../../core/downloads/downloader/providers.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../../core/posts/post/providers.dart';
import '../../../../../core/router.dart';
import '../../../../../core/tags/tag/routes.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../../versions/routes.dart';
import '../../favgroups/favgroups/routes.dart';
import '../../post/post.dart';
import 'providers.dart';

class DanbooruPostContextMenu extends ConsumerWidget {
  const DanbooruPostContextMenu({
    required this.post,
    super.key,
    this.onMultiSelect,
  });

  final DanbooruPost post;
  final void Function()? onMultiSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;
    final bookmarkState = ref.watch(bookmarkProvider);
    final isBookmarked = bookmarkState.isBookmarked(
      post,
      booruConfig.booruIdHint,
    );
    final hasAccount = booruConfig.hasLoginDetails();
    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(booruConfig));

    return GenericContextMenu(
      buttonConfigs: [
        if (post.hasComment)
          ContextMenuButtonConfig(
            context.t.post.action.view_comments,
            onPressed: () => goToCommentPage(context, ref, post.id),
          ),
        ContextMenuButtonConfig(
          context.t.download.download,
          onPressed: () {
            ref.download(post);
          },
        ),
        if (!isBookmarked)
          ContextMenuButtonConfig(
            context.t.post.detail.add_to_bookmark,
            onPressed: () => ref.bookmarks
              ..addBookmarkWithToast(
                context,
                booruConfig,
                post,
              ),
          )
        else
          ContextMenuButtonConfig(
            context.t.post.detail.remove_from_bookmark,
            onPressed: () => ref.bookmarks
              ..removeBookmarkWithToast(
                context,
                BookmarkUniqueId.fromPost(post, booruConfig.booruIdHint),
              ),
          ),
        if (hasAccount)
          ContextMenuButtonConfig(
            context.t.post.action.add_to_favorite_group,
            onPressed: () {
              goToAddToFavoriteGroupSelectionPage(
                context,
                [post],
              );
            },
          ),
        if (!booruConfig.hasStrictSFW)
          ContextMenuButtonConfig(
            context.t.post.detail.view_in_browser,
            onPressed: () =>
                launchExternalUrlString(postLinkGenerator.getLink(post)),
          ),
        if (post.tags.isNotEmpty)
          ContextMenuButtonConfig(
            'View tags',
            onPressed: () {
              goToShowTaglistPage(ref, post);
            },
          ),
        ContextMenuButtonConfig(
          'View tag history',
          onPressed: () => goToPostVersionPage(ref, post),
        ),
        if (hasAccount)
          ContextMenuButtonConfig(
            'Edit',
            onPressed: () => ref.danbooruEdit(post),
          ),
        if (onMultiSelect != null)
          ContextMenuButtonConfig(
            context.t.generic.action.select,
            onPressed: () {
              onMultiSelect?.call();
            },
          ),
      ],
    );
  }
}

// ignore: prefer-single-widget-per-file
class FavoriteGroupsPostContextMenu extends ConsumerWidget {
  const FavoriteGroupsPostContextMenu({
    required this.post,
    required this.onMultiSelect,
    required this.onRemoveFromFavGroup,
    super.key,
  });

  final Post post;
  final void Function()? onMultiSelect;
  final void Function()? onRemoveFromFavGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return GenericContextMenu(
      buttonConfigs: [
        ContextMenuButtonConfig(
          context.t.download.download,
          onPressed: () {
            ref.download(post);
          },
        ),
        if (config.hasLoginDetails())
          ContextMenuButtonConfig(
            'Remove from favorite group',
            onPressed: () {
              onRemoveFromFavGroup?.call();
            },
          ),
        ContextMenuButtonConfig(
          'Select',
          onPressed: () {
            onMultiSelect?.call();
          },
        ),
      ],
    );
  }
}
