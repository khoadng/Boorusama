// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../core/bookmarks/providers.dart';
import '../../../../../core/bookmarks/types.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/downloads/downloader/providers.dart';
import '../../../../../core/posts/post/providers.dart';
import '../../../../../core/posts/post/types.dart';
import '../../../../../core/router.dart';
import '../../../../../core/tags/show/routes.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../../configs/providers.dart';
import '../../../versions/routes.dart';
import '../../favgroups/favgroups/routes.dart';
import '../../post/types.dart';
import 'providers.dart';

class DanbooruPostContextMenu extends ConsumerWidget {
  const DanbooruPostContextMenu({
    required this.post,
    super.key,
    this.onMultiSelect,
  });

  final DanbooruPost post;
  final void Function()? onMultiSelect;

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

    return GenericContextMenu(
      buttonConfigs: [
        if (post.hasComment)
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
        if (hasAccount)
          ContextMenuButtonConfig(
            context.t.post.action.add_to_favorite_group,
            onPressed: () {
              goToAddToFavoriteGroupSelectionPage(
                context,
                [post],
              );
            },
          ),
        if (!loginDetails.hasStrictSFW)
          ContextMenuButtonConfig(
            context.t.post.action.view_in_browser,
            onPressed: () =>
                launchExternalUrlString(postLinkGenerator.getLink(post)),
          ),
        if (post.tags.isNotEmpty)
          ContextMenuButtonConfig(
            context.t.post.action.view_tags,
            onPressed: () {
              goToShowTaglistPage(
                ref,
                post,
                auth: booruConfig,
              );
            },
          ),
        ContextMenuButtonConfig(
          context.t.post.action.view_tag_history,
          onPressed: () => goToPostVersionPage(ref, post),
        ),
        if (hasAccount)
          ContextMenuButtonConfig(
            context.t.generic.action.edit,
            onPressed: () => ref.danbooruEdit(post),
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

// ignore: prefer-single-widget-per-file
class FavoriteGroupsPostContextMenu extends ConsumerWidget {
  const FavoriteGroupsPostContextMenu({
    required this.post,
    required this.onMultiSelect,
    required this.onRemoveFromFavGroup,
    super.key,
  });

  final Post post;
  final void Function()? onMultiSelect;
  final void Function()? onRemoveFromFavGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));

    return GenericContextMenu(
      buttonConfigs: [
        ContextMenuButtonConfig(
          context.t.download.download,
          onPressed: () {
            ref.download(post);
          },
        ),
        if (loginDetails.hasLogin())
          ContextMenuButtonConfig(
            'Remove from favorite group',
            onPressed: () {
              onRemoveFromFavGroup?.call();
            },
          ),
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
