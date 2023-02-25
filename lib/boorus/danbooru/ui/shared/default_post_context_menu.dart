// ignore: prefer-single-widget-per-file

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';

class DefaultPostContextMenu extends StatelessWidget {
  const DefaultPostContextMenu({
    super.key,
    required this.post,
    this.onMultiSelect,
  });

  final PostData post;
  final void Function()? onMultiSelect;

  @override
  Widget build(BuildContext context) {
    final authState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    return DownloadProviderWidget(
      builder: (context, download) => GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'post.action.preview'.tr(),
            onPressed: () => goToImagePreviewPage(context, post.post),
          ),
          if (post.post.hasComment)
            ContextMenuButtonConfig(
              'post.action.view_comments'.tr(),
              onPressed: () => goToCommentPage(context, post.post.id),
            ),
          ContextMenuButtonConfig(
            'download.download'.tr(),
            onPressed: () => download(post.post),
          ),
          if (authState is Authenticated)
            ContextMenuButtonConfig(
              'post.action.add_to_favorite_group'.tr(),
              onPressed: () {
                goToAddToFavoriteGroupSelectionPage(
                  context,
                  [post.post],
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
class FavoriteGroupsPostContextMenu extends StatelessWidget {
  const FavoriteGroupsPostContextMenu({
    super.key,
    required this.post,
    required this.onMultiSelect,
    required this.onRemoveFromFavGroup,
  });

  final PostData post;
  final void Function()? onMultiSelect;
  final void Function()? onRemoveFromFavGroup;

  @override
  Widget build(BuildContext context) {
    final authState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    return DownloadProviderWidget(
      builder: (context, download) => GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            'Preview',
            onPressed: () => goToImagePreviewPage(context, post.post),
          ),
          ContextMenuButtonConfig(
            'download.download'.tr(),
            onPressed: () => download(post.post),
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
