// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
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
import '../../../../../core/widgets/context_menu_tile.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../../configs/providers.dart';
import '../../../versions/routes.dart';
import '../../favgroups/favgroups/routes.dart';
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

    return AnchorContextMenu(
      backdropBuilder: (context) => Container(
        color: Colors.transparent,
      ),
      menuBuilder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            boxShadow: kElevationToShadow[4],
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          constraints: const BoxConstraints(
            maxWidth: 220,
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 4,
            ),
            shrinkWrap: true,
            children: [
              ContextMenuTile(
                title: context.t.download.download,
                onTap: () {
                  context.hideMenu();
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
                          context.hideMenu();
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
                          context.hideMenu();
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
                    context.hideMenu();
                    goToAddToFavoriteGroupSelectionPage(
                      context,
                      [post],
                    );
                  },
                ),
              const Divider(
                endIndent: 12,
                indent: 12,
                height: 8,
              ),
              if (post.hasComment)
                ContextMenuTile(
                  title: context.t.post.action.view_comments,
                  onTap: () {
                    context.hideMenu();
                    goToCommentPage(context, ref, post.id);
                  },
                ),
              if (!loginDetails.hasStrictSFW)
                ContextMenuTile(
                  title: context.t.post.action.view_in_browser,
                  onTap: () {
                    context.hideMenu();
                    launchExternalUrlString(
                      postLinkGenerator.getLink(post),
                    );
                  },
                ),
              if (post.tags.isNotEmpty)
                ContextMenuTile(
                  title: context.t.post.action.view_tags,
                  onTap: () {
                    context.hideMenu();
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
                  context.hideMenu();
                  goToPostVersionPage(ref, post);
                },
              ),
              const Divider(
                endIndent: 12,
                indent: 12,
                height: 8,
              ),
              if (hasAccount)
                ContextMenuTile(
                  title: context.t.generic.action.edit,
                  onTap: () {
                    context.hideMenu();
                    ref.danbooruEdit(post);
                  },
                ),
              if (selectionModeController case final controller?)
                ContextMenuTile(
                  title: context.t.generic.action.select,
                  onTap: () {
                    context.hideMenu();
                    controller.enable(
                      initialSelected: [index],
                    );
                  },
                ),
            ],
          ),
        );
      },
      childBuilder: (context) => AdaptiveContextMenuGestureTrigger(
        child: child,
      ),
    );
  }
}
