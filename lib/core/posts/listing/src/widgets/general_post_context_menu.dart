// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/url_launcher.dart';
import '../../../../bookmarks/bookmark.dart';
import '../../../../bookmarks/providers.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../downloads/downloader/providers.dart';
import '../../../../router.dart';
import '../../../../tags/tag/routes.dart';
import '../../../post/post.dart';

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
    final isBookmarked = bookmarkState.isBookmarked(
      post,
      booruConfig.booruIdHint,
    );
    final commentPageBuilder = ref
        .watch(booruBuilderProvider(booruConfig))
        ?.commentPageBuilder;
    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(booruConfig));

    return GenericContextMenu(
      buttonConfigs: [
        if (commentPageBuilder != null && post.hasComment)
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
        ContextMenuButtonConfig(
          'View tags',
          onPressed: () {
            goToShowTaglistPage(ref, post);
          },
        ),
        if (!booruConfig.hasStrictSFW)
          ContextMenuButtonConfig(
            context.t.post.detail.view_in_browser,
            onPressed: () =>
                launchExternalUrlString(postLinkGenerator.getLink(post)),
          ),
        if (onMultiSelect != null)
          ContextMenuButtonConfig(
            context.t.post.action.select,
            onPressed: () {
              onMultiSelect?.call();
            },
          ),
      ],
    );
  }
}
