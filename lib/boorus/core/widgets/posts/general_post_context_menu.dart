// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/bookmarks/bookmark_notifier.dart';
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
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
          // if (post.hasComment)
          //   ContextMenuButtonConfig(
          //     'post.action.view_comments'.tr(),
          //     onPressed: () => goToCommentPage(context, post.id),
          //   ),
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
