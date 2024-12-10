// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/bookmarks/bookmark_provider.dart';
import '../../../../../core/configs/ref.dart';
import '../../../../../core/downloads/downloader.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../../../../router.dart';
import '../../../tags/tag/routes.dart';
import '../../../versions/routes.dart';
import '../../favgroups/favgroups/routes.dart';
import '../../post/post.dart';
import 'providers.dart';

class DanbooruPostContextMenu extends ConsumerWidget {
  const DanbooruPostContextMenu({
    super.key,
    required this.post,
    this.onMultiSelect,
  });

  final DanbooruPost post;
  final void Function()? onMultiSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;
    final bookmarkState = ref.watch(bookmarkProvider);
    final isBookmarked =
        bookmarkState.isBookmarked(post, booruConfig.booruType);
    final hasAccount = booruConfig.hasLoginDetails();

    return GenericContextMenu(
      buttonConfigs: [
        ContextMenuButtonConfig(
          'post.action.preview'.tr(),
          onPressed: () => goToImagePreviewPage(ref, context, post),
        ),
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
                booruConfig.booruId,
                booruConfig.url,
                post,
              ),
          )
        else
          ContextMenuButtonConfig(
            'post.detail.remove_from_bookmark'.tr(),
            onPressed: () => ref.bookmarks
              ..removeBookmarkWithToast(
                context,
                bookmarkState.getBookmark(post, booruConfig.booruType)!,
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
        if (!booruConfig.hasStrictSFW)
          ContextMenuButtonConfig(
            'post.detail.view_in_browser'.tr(),
            onPressed: () =>
                launchExternalUrlString(post.getLink(booruConfig.url)),
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
    super.key,
    required this.post,
    required this.onMultiSelect,
    required this.onRemoveFromFavGroup,
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
          'Preview',
          onPressed: () => goToImagePreviewPage(ref, context, post),
        ),
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
