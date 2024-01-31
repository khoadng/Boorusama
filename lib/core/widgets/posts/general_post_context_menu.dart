// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/i18n.dart';

class GeneralPostContextMenu extends ConsumerWidget {
  const GeneralPostContextMenu({
    super.key,
    required this.post,
    this.onMultiSelect,
    required this.hasAccount,
  });

  final Post post;
  final void Function()? onMultiSelect;
  final bool hasAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfig;
    final bookmarkState = ref.watch(bookmarkProvider);
    final isBookmarked =
        bookmarkState.isBookmarked(post, booruConfig.booruType);
    final commentPageBuilder =
        ref.watchBooruBuilder(booruConfig)?.commentPageBuilder;

    return DownloadProviderWidget(
      builder: (context, download) => GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'post.action.preview'.tr(),
            onPressed: () => goToImagePreviewPage(ref, context, post),
          ),
          if (commentPageBuilder != null && post.hasComment)
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
          ContextMenuButtonConfig(
            'View tags',
            onPressed: () {
              goToShowTaglistPage(ref, context, post.extractTags());
            },
          ),
          if (!booruConfig.hasStrictSFW)
            ContextMenuButtonConfig(
              'Open in browser',
              onPressed: () =>
                  launchExternalUrlString(post.getLink(booruConfig.url)),
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
