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
import '../../../../tags/show/routes.dart';
import '../../../post/post.dart';
import '../../../post/providers.dart';

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
    final bookmarkStateAsync = ref.watch(bookmarkProvider);
    final commentPageBuilder = ref
        .watch(booruBuilderProvider(booruConfig))
        ?.commentPageBuilder;
    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(booruConfig));

    final isBookmarked =
        bookmarkStateAsync.valueOrNull?.isBookmarked(
          post,
          booruConfig.booruIdHint,
        ) ??
        false;
    final isBookmarkLoading = bookmarkStateAsync.isLoading;

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
            onPressed: isBookmarkLoading
                ? null
                : () => ref.bookmarks
                    ..addBookmarkWithToast(
                      booruConfig,
                      post,
                    ),
          )
        else
          ContextMenuButtonConfig(
            context.t.post.detail.remove_from_bookmark,
            onPressed: isBookmarkLoading
                ? null
                : () => ref.bookmarks
                    ..removeBookmarkWithToast(
                      BookmarkUniqueId.fromPost(post, booruConfig.booruIdHint),
                    ),
          ),
        ContextMenuButtonConfig(
          'View tags',
          onPressed: () {
            goToShowTaglistPage(
              ref,
              post,
              auth: booruConfig,
            );
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
            context.t.generic.action.select,
            onPressed: () {
              onMultiSelect?.call();
            },
          ),
      ],
    );
  }
}
