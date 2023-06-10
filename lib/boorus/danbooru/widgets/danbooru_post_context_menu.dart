// ignore: prefer-single-widget-per-file

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/bookmarks/bookmark_notifier.dart';
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/foundation/i18n.dart';

class DanbooruPostContextMenu extends ConsumerWidget {
  const DanbooruPostContextMenu({
    super.key,
    required this.post,
    this.onMultiSelect,
    required this.hasAccount,
  });

  final DanbooruPost post;
  final void Function()? onMultiSelect;
  final bool hasAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruProvider);
    final bookmarkState = ref.watch(bookmarkProvider);
    final isBookmarked = bookmarkState.isBookmarked(post, booru.booruType);

    return DownloadProviderWidget(
      builder: (context, download) => GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'post.action.preview'.tr(),
            onPressed: () => goToImagePreviewPage(ref, context, post),
          ),
          if (post.hasComment)
            ContextMenuButtonConfig(
              'post.action.view_comments'.tr(),
              onPressed: () => goToCommentPage(context, post.id),
            ),
          ContextMenuButtonConfig(
            'download.download'.tr(),
            onPressed: () => download(post),
          ),
          if (!isBookmarked)
            ContextMenuButtonConfig(
              'post.detail.add_to_bookmark'.tr(),
              onPressed: () => ref.bookmarks
                ..addBookmarkWithToast(
                  post.sampleImageUrl,
                  booru,
                  post,
                ),
            )
          else
            ContextMenuButtonConfig(
              'post.detail.remove_from_bookmark'.tr(),
              onPressed: () => ref.bookmarks
                ..removeBookmarkWithToast(
                  bookmarkState.getBookmark(post, booru.booruType)!,
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
          if (onMultiSelect != null)
            ContextMenuButtonConfig(
              'post.action.select'.tr(),
              onPressed: () {
                onMultiSelect?.call();
              },
            ),
        ],
      ),
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
    final authState = ref.watch(authenticationProvider);

    return DownloadProviderWidget(
      builder: (context, download) => GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'Preview',
            onPressed: () => goToImagePreviewPage(ref, context, post),
          ),
          ContextMenuButtonConfig(
            'download.download'.tr(),
            onPressed: () => download(post),
          ),
          if (authState.isAuthenticated)
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
      ),
    );
  }
}
