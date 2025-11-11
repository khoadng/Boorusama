// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../../core/bookmarks/providers.dart';
import '../../../../../core/bookmarks/types.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/downloads/downloader/providers.dart';
import '../../../../../core/posts/post/providers.dart';
import '../../../../../core/router.dart';
import '../../../../../core/tags/show/routes.dart';
import '../../../../../core/widgets/booru_context_menu.dart';
import '../../../../../core/widgets/context_menu_tile.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../../configs/providers.dart';
import '../../../favgroups/favgroups/routes.dart';
import '../../../versions/routes.dart';
import '../../listing/providers.dart';
import 'danbooru_post.dart';

class DanbooruPostContextMenu extends ConsumerWidget {
  const DanbooruPostContextMenu({
    super.key,
    required this.child,
    required this.post,
    required this.index,
  });

  final Widget child;
  final DanbooruPost post;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(booruConfig));
    final bookmarkStateAsync = ref.watch(bookmarkProvider);
    final isBookmarked =
        bookmarkStateAsync.valueOrNull?.isBookmarked(
          post,
          booruConfig.booruIdHint,
        ) ??
        false;
    final isBookmarkLoading = bookmarkStateAsync.isLoading;
    final hasAccount = loginDetails.hasLogin();
    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(booruConfig));
    final selectionModeController = SelectionMode.maybeOf(context);

    return BooruContextMenu(
      menuItemsBuilder: (context) => [
        ContextMenuTile(
          title: context.t.download.download,
          onTap: () {
            ref
                .read(
                  downloadNotifierProvider(
                    ref.read(
                      downloadNotifierParamsProvider((
                        booruConfig,
                        ref.readConfigDownload,
                      )),
                    ),
                  ).notifier,
                )
                .download(post);
          },
        ),
        if (!isBookmarked)
          ContextMenuTile(
            title: context.t.post.detail.add_to_bookmark,
            enabled: !isBookmarkLoading,
            onTap: isBookmarkLoading
                ? null
                : () {
                    ref.bookmarks.addBookmarkWithToast(
                      booruConfig,
                      post,
                    );
                  },
          )
        else
          ContextMenuTile(
            title: context.t.post.detail.remove_from_bookmark,
            enabled: !isBookmarkLoading,
            onTap: isBookmarkLoading
                ? null
                : () {
                    ref.bookmarks.removeBookmarkWithToast(
                      BookmarkUniqueId.fromPost(
                        post,
                        booruConfig.booruIdHint,
                      ),
                    );
                  },
          ),
        if (hasAccount)
          ContextMenuTile(
            title: context.t.post.action.add_to_favorite_group,
            onTap: () {
              goToAddToFavoriteGroupSelectionPage(
                context,
                [post],
              );
            },
          ),
        const BooruContextMenuDivider(),
        if (post.hasComment)
          ContextMenuTile(
            title: context.t.post.action.view_comments,
            onTap: () {
              goToCommentPage(context, ref, post);
            },
          ),
        if (!loginDetails.hasStrictSFW)
          ContextMenuTile(
            title: context.t.post.action.view_in_browser,
            onTap: () {
              launchExternalUrlString(
                postLinkGenerator.getLink(post),
              );
            },
          ),
        if (post.tags.isNotEmpty)
          ContextMenuTile(
            title: context.t.post.action.view_tags,
            onTap: () {
              goToShowTaglistPage(
                ref,
                post,
                auth: booruConfig,
              );
            },
          ),
        ContextMenuTile(
          title: context.t.post.action.view_tag_history,
          onTap: () {
            goToPostVersionPage(ref, post);
          },
        ),
        const BooruContextMenuDivider(),
        if (hasAccount)
          ContextMenuTile(
            title: context.t.generic.action.edit,
            onTap: () {
              ref.danbooruEdit(post);
            },
          ),
        if (selectionModeController case final controller?)
          ContextMenuTile(
            title: context.t.generic.action.select,
            onTap: () {
              controller.enable(
                initialSelected: [index],
              );
            },
          ),
      ],
      child: child,
    );
  }
}
