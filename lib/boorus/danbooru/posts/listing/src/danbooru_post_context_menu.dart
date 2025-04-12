// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/bookmarks/bookmark.dart';
import '../../../../../core/bookmarks/providers.dart';
import '../../../../../core/boorus/engine/providers.dart';
import '../../../../../core/configs/ref.dart';
import '../../../../../core/downloads/downloader.dart';
import '../../../../../core/foundation/url_launcher.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../../core/router.dart';
import '../../../tags/tag/routes.dart';
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
    final isBookmarked =
        bookmarkState.isBookmarked(post, booruConfig.booruIdHint);
    final hasAccount = booruConfig.hasLoginDetails();
    final postLinkGenerator = ref.watch(currentPostLinkGeneratorProvider);

    return GenericContextMenu(
      buttonConfigs: [
        if (post.hasComment)
          ContextMenuButtonConfig(
            'post.action.view_comments'.tr(),
            onPressed: () => goToCommentPage(context, ref, post.id),
          ),
        ContextMenuButtonConfig(
          'download.download'.tr(),
          onPressed: () {
            ref.download(post);
          },
        ),
        if (!isBookmarked)
          ContextMenuButtonConfig(
            'post.detail.add_to_bookmark'.tr(),
            onPressed: () => ref.bookmarks
              ..addBookmarkWithToast(
                context,
                booruConfig.booruIdHint,
                post,
              ),
          )
        else
          ContextMenuButtonConfig(
            'post.detail.remove_from_bookmark'.tr(),
            onPressed: () => ref.bookmarks
              ..removeBookmarkWithToast(
                context,
                BookmarkUniqueId.fromPost(post, booruConfig.booruIdHint),
              ),
          ),
        if (hasAccount)
          ContextMenuButtonConfig(
            'post.action.add_to_favorite_group'.tr(),
            onPressed: () {
              goToAddToFavoriteGroupSelectionPage(
                context,
                [post],
              );
            },
          ),
        if (!booruConfig.hasStrictSFW && postLinkGenerator != null)
          ContextMenuButtonConfig(
            'post.detail.view_in_browser'.tr(),
            onPressed: () =>
                launchExternalUrlString(postLinkGenerator.getLink(post)),
          ),
        if (post.tags.isNotEmpty)
          ContextMenuButtonConfig(
            'View tags',
            onPressed: () {
              goToDanbooruShowTaglistPage(ref, post.extractTags());
            },
          ),
        ContextMenuButtonConfig(
          'View tag history',
          onPressed: () => goToPostVersionPage(context, post),
        ),
        if (hasAccount)
          ContextMenuButtonConfig(
            'Edit',
            onPressed: () => ref.danbooruEdit(post),
          ),
        if (onMultiSelect != null)
          ContextMenuButtonConfig(
            'post.action.select'.tr(),
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
          'download.download'.tr(),
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
