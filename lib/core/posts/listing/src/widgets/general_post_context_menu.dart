// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../../foundation/url_launcher.dart';
import '../../../../bookmarks/providers.dart';
import '../../../../bookmarks/types.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/providers.dart';
import '../../../../downloads/downloader/providers.dart';
import '../../../../router.dart';
import '../../../../tags/show/routes.dart';
import '../../../../widgets/booru_context_menu.dart';
import '../../../../widgets/context_menu_tile.dart';
import '../../../post/providers.dart';
import '../../../post/types.dart';
import 'post_grid_controller.dart';

class GeneralPostContextMenu extends ConsumerWidget {
  const GeneralPostContextMenu({
    super.key,
    required this.controller,
    required this.index,
    required this.child,
  });

  final PostGridController<Post> controller;
  final Widget child;

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;
    final loginDetails = ref.watch(booruLoginDetailsProvider(booruConfig));
    final bookmarkStateAsync = ref.watch(bookmarkProvider);
    final commentPageBuilder = ref
        .watch(booruBuilderProvider(booruConfig))
        ?.commentPageBuilder;
    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(booruConfig));
    final selectionModeController = SelectionMode.maybeOf(context);

    final isBookmarkLoading = bookmarkStateAsync.isLoading;

    return ValueListenableBuilder(
      valueListenable: controller.itemsNotifier,
      builder: (context, posts, _) {
        final post = posts[index];
        final isBookmarked =
            bookmarkStateAsync.valueOrNull?.isBookmarked(
              post,
              booruConfig.booruIdHint,
            ) ??
            false;

        return BooruContextMenu(
          menuItemsBuilder: (context) => [
            ContextMenuTile(
              title: context.t.download.download,
              onTap: () {
                ref.download(post);
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
            const BooruContextMenuDivider(),
            if (commentPageBuilder != null && post.hasComment)
              ContextMenuTile(
                title: context.t.post.action.view_comments,
                onTap: () {
                  goToCommentPage(context, ref, post.id);
                },
              ),
            if (!loginDetails.hasStrictSFW)
              ContextMenuTile(
                title: context.t.post.action.view_in_browser,
                onTap: () {
                  launchExternalUrlString(postLinkGenerator.getLink(post));
                },
              ),
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
            const BooruContextMenuDivider(),
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
      },
    );
  }
}
