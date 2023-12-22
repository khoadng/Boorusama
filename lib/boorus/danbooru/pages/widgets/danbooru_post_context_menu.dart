// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
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
    final booruConfig = ref.watchConfig;
    final bookmarkState = ref.watch(bookmarkProvider);
    final isBookmarked =
        bookmarkState.isBookmarked(post, booruConfig.booruType);
    final tags = ref.watch(danbooruTagListProvider(booruConfig));

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
              onPressed: () => goToCommentPage(context, ref, post.id),
            ),
          ContextMenuButtonConfig(
            'download.download'.tr(),
            onPressed: () {
              showDownloadStartToast(context);
              download(post);
            },
          ),
          if (!isBookmarked)
            ContextMenuButtonConfig(
              'post.detail.add_to_bookmark'.tr(),
              onPressed: () => ref.bookmarks
                ..addBookmarkWithToast(
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
          if (hasAccount)
            ContextMenuButtonConfig(
              'Add to blacklist',
              onPressed: () {
                goToAddToBlacklistPage(ref, context, post.extractTags());
              },
            ),
          ContextMenuButtonConfig(
            'Add to global blacklist',
            onPressed: () {
              goToAddToGlobalBlacklistPage(ref, context, post.extractTags());
            },
          ),
          if (!booruConfig.hasStrictSFW)
            ContextMenuButtonConfig(
              'Open in browser',
              onPressed: () =>
                  launchExternalUrlString(post.getLink(booruConfig.url)),
            ),
          ContextMenuButtonConfig(
            'View tag history',
            onPressed: () => goToPostVersionPage(context, post),
          ),
          if (hasAccount)
            ContextMenuButtonConfig(
              'Edit',
              onPressed: () {
                goToTagEdiPage(
                  context,
                  post: post,
                  tags: tags.containsKey(post.id)
                      ? tags[post.id]!.allTags
                      : post.tags,
                  rating: tags.containsKey(post.id)
                      ? tags[post.id]!.rating
                      : post.rating,
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
    final config = ref.watchConfig;

    return DownloadProviderWidget(
      builder: (context, download) => GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'Preview',
            onPressed: () => goToImagePreviewPage(ref, context, post),
          ),
          ContextMenuButtonConfig(
            'download.download'.tr(),
            onPressed: () {
              showDownloadStartToast(context);
              download(post);
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
      ),
    );
  }
}
