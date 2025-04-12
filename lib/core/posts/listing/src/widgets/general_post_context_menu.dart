// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../bookmarks/bookmark.dart';
import '../../../../bookmarks/providers.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../downloads/downloader.dart';
import '../../../../foundation/url_launcher.dart';
import '../../../../router.dart';
import '../../../../tags/tag/routes.dart';
import '../../../post/post.dart';
import '../../../post/tags.dart';

class GeneralPostContextMenu extends ConsumerWidget {
  const GeneralPostContextMenu({
    required this.post,
    required this.hasAccount,
    super.key,
    this.onMultiSelect,
  });

  final Post post;
  final void Function()? onMultiSelect;
  final bool hasAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;
    final bookmarkState = ref.watch(bookmarkProvider);
    final isBookmarked =
        bookmarkState.isBookmarked(post, booruConfig.booruIdHint);
    final commentPageBuilder =
        ref.watch(currentBooruBuilderProvider)?.commentPageBuilder;
    final postLinkGenerator = ref.watch(currentPostLinkGeneratorProvider);

    return GenericContextMenu(
      buttonConfigs: [
        if (commentPageBuilder != null && post.hasComment)
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
        if (post.tags.isNotEmpty)
          ContextMenuButtonConfig(
            'View tags',
            onPressed: () {
              goToShowTaglistPage(context, post.extractTags());
            },
          ),
        if (!booruConfig.hasStrictSFW && postLinkGenerator != null)
          ContextMenuButtonConfig(
            'post.detail.view_in_browser'.tr(),
            onPressed: () =>
                launchExternalUrlString(postLinkGenerator.getLink(post)),
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
