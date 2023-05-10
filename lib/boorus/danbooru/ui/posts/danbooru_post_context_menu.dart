// ignore: prefer-single-widget-per-file

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';

class DanbooruPostContextMenu extends ConsumerWidget {
  const DanbooruPostContextMenu({
    super.key,
    required this.post,
    this.onMultiSelect,
    required this.hasAccount,
  });

  final DanbooruPost post;
  final void Function()? onMultiSelect;
  final bool hasAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruProvider);

    return DownloadProviderWidget(
      builder: (context, download) => GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'post.action.preview'.tr(),
            onPressed: () => goToImagePreviewPage(context, post),
          ),
          if (post.hasComment)
            ContextMenuButtonConfig(
              'post.action.view_comments'.tr(),
              onPressed: () => goToCommentPage(context, post.id),
            ),
          ContextMenuButtonConfig(
            'download.download'.tr(),
            onPressed: () => download(post),
          ),
          ContextMenuButtonConfig(
            'Add to Bookmark',
            onPressed: () => context.read<BookmarkCubit>().addBookmarkWithToast(
                  post.sampleImageUrl,
                  booru,
                  post,
                ),
          ),
          if (hasAccount)
            ContextMenuButtonConfig(
              'post.action.add_to_favorite_group'.tr(),
              onPressed: () {
                goToAddToFavoriteGroupSelectionPage(
                  context,
                  [post],
                );
              },
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

// ignore: prefer-single-widget-per-file
class FavoriteGroupsPostContextMenu extends ConsumerWidget {
  const FavoriteGroupsPostContextMenu({
    super.key,
    required this.post,
    required this.onMultiSelect,
    required this.onRemoveFromFavGroup,
  });

  final Post post;
  final void Function()? onMultiSelect;
  final void Function()? onRemoveFromFavGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationProvider);

    return DownloadProviderWidget(
      builder: (context, download) => GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'Preview',
            onPressed: () => goToImagePreviewPage(context, post),
          ),
          ContextMenuButtonConfig(
            'download.download'.tr(),
            onPressed: () => download(post),
          ),
          if (authState is Authenticated)
            ContextMenuButtonConfig(
              'Remove from favorite group',
              onPressed: () {
                onRemoveFromFavGroup?.call();
              },
            ),
          ContextMenuButtonConfig(
            'Select',
            onPressed: () {
              onMultiSelect?.call();
            },
          ),
        ],
      ),
    );
  }
}
