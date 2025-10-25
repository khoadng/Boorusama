// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_anchor/flutter_anchor.dart';
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
import '../../../../../foundation/url_launcher.dart';
import '../../../configs/providers.dart';
import '../../../versions/routes.dart';
import '../../favgroups/favgroups/routes.dart';
import '../../listing/providers.dart';
import 'danbooru_post.dart';

class DanbooruPostContextMenu extends ConsumerStatefulWidget {
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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruContextMenuState();
}

class _DanbooruContextMenuState extends ConsumerState<DanbooruPostContextMenu> {
  final _controller = AnchorContextMenuController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booruConfig = ref.watchConfigAuth;
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(booruConfig));
    final bookmarkStateAsync = ref.watch(bookmarkProvider);
    final isBookmarked =
        bookmarkStateAsync.valueOrNull?.isBookmarked(
          widget.post,
          booruConfig.booruIdHint,
        ) ??
        false;
    final isBookmarkLoading = bookmarkStateAsync.isLoading;
    final hasAccount = loginDetails.hasLogin();
    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(booruConfig));
    final selectionModeController = SelectionMode.maybeOf(context);

    return AnchorContextMenu(
      controller: _controller,
      menuBuilder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            boxShadow: kElevationToShadow[4],
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
              if (widget.post.hasComment)
                ContextMenuTile(
                  title: context.t.post.action.view_comments,
                  onTap: () {
                    _controller.hide();
                    goToCommentPage(context, ref, widget.post.id);
                  },
                ),
              ContextMenuTile(
                title: context.t.download.download,
                onTap: () {
                  _controller.hide();
                  ref.download(widget.post);
                },
              ),
              if (!isBookmarked)
                ContextMenuTile(
                  title: context.t.post.detail.add_to_bookmark,
                  enabled: !isBookmarkLoading,
                  onTap: isBookmarkLoading
                      ? null
                      : () {
                          _controller.hide();
                          ref.bookmarks.addBookmarkWithToast(
                            booruConfig,
                            widget.post,
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
                          _controller.hide();
                          ref.bookmarks.removeBookmarkWithToast(
                            BookmarkUniqueId.fromPost(
                              widget.post,
                              booruConfig.booruIdHint,
                            ),
                          );
                        },
                ),
              if (hasAccount)
                ContextMenuTile(
                  title: context.t.post.action.add_to_favorite_group,
                  onTap: () {
                    _controller.hide();
                    goToAddToFavoriteGroupSelectionPage(
                      context,
                      [widget.post],
                    );
                  },
                ),
              if (!loginDetails.hasStrictSFW)
                ContextMenuTile(
                  title: context.t.post.action.view_in_browser,
                  onTap: () {
                    _controller.hide();
                    launchExternalUrlString(
                      postLinkGenerator.getLink(widget.post),
                    );
                  },
                ),
              if (widget.post.tags.isNotEmpty)
                ContextMenuTile(
                  title: context.t.post.action.view_tags,
                  onTap: () {
                    _controller.hide();
                    goToShowTaglistPage(
                      ref,
                      widget.post,
                      auth: booruConfig,
                    );
                  },
                ),
              ContextMenuTile(
                title: context.t.post.action.view_tag_history,
                onTap: () {
                  _controller.hide();
                  goToPostVersionPage(ref, widget.post);
                },
              ),
              if (hasAccount)
                ContextMenuTile(
                  title: context.t.generic.action.edit,
                  onTap: () {
                    _controller.hide();
                    ref.danbooruEdit(widget.post);
                  },
                ),
              if (selectionModeController case final controller?)
                ContextMenuTile(
                  title: context.t.generic.action.select,
                  onTap: () {
                    _controller.hide();
                    controller.enable(
                      initialSelected: [widget.index],
                    );
                  },
                ),
            ],
          ),
        );
      },
      child: GestureDetector(
        onLongPressStart: (details) {
          _controller.show(details.globalPosition);
        },
        child: widget.child,
      ),
    );
  }
}
