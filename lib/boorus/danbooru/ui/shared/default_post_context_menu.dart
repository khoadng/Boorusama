// ignore: prefer-single-widget-per-file
import 'package:boorusama/boorus/danbooru/application/authentication/authentication.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:context_menus/context_menus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DefaultPostContextMenu extends StatelessWidget {
  const DefaultPostContextMenu({
    super.key,
    required this.post,
    required this.onMultiSelect,
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
            'Preview',
            onPressed: () => goToImagePreviewPage(context, post.post),
          ),
          ContextMenuButtonConfig(
            'download.download'.tr(),
            onPressed: () => download(post.post),
          ),
          if (authState is Authenticated)
            ContextMenuButtonConfig(
              'Add to favorite group',
              onPressed: () {
                goToAddToFavoriteGroupSelectionPage(
                  context,
                  [post.post],
                );
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

// ignore: prefer-single-widget-per-file
class FavoriteGroupsPostContextMenu extends StatelessWidget {
  const FavoriteGroupsPostContextMenu({
    super.key,
    required this.post,
    required this.onMultiSelect,
    this.onRemoveFromFavGroup,
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
