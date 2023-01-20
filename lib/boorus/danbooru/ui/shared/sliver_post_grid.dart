// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/booru_image_legacy.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';
import 'selectable_icon_button.dart';

class SliverPostGridDelegate extends SliverGridDelegateWithFixedCrossAxisCount {
  SliverPostGridDelegate({
    required super.crossAxisCount,
    required super.mainAxisSpacing,
    required super.crossAxisSpacing,
    required super.childAspectRatio,
    super.mainAxisExtent,
  });
  factory SliverPostGridDelegate.normal(double spacing, ScreenSize size) =>
      SliverPostGridDelegate(
        childAspectRatio: size != ScreenSize.small ? 0.9 : 0.65,
        crossAxisCount: displaySizeToGridCountWeight(size) * 2,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      );

  factory SliverPostGridDelegate.small(double spacing, ScreenSize size) =>
      SliverPostGridDelegate(
        childAspectRatio: 1,
        crossAxisCount: displaySizeToGridCountWeight(size) * 3,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      );
  factory SliverPostGridDelegate.large(double spacing, ScreenSize size) =>
      SliverPostGridDelegate(
        childAspectRatio: 0.65,
        crossAxisCount: displaySizeToGridCountWeight(size),
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      );
}

int displaySizeToGridCountWeight(ScreenSize size) {
  if (size == ScreenSize.small) return 1;
  if (size == ScreenSize.medium) return 2;

  return 3;
}

class SliverPostGrid extends HookWidget {
  const SliverPostGrid({
    super.key,
    required this.posts,
    required this.scrollController,
    required this.onFavoriteUpdated,
    this.onItemChanged,
    this.onTap,
    this.quality,
    this.gridSize = GridSize.normal,
    this.borderRadius,
    this.postAnnotationBuilder,
    this.onMultiSelect,
    this.onPostSelectChanged,
    this.multiSelect = false,
  });

  final List<PostData> posts;
  final AutoScrollController scrollController;
  final ValueChanged<int>? onItemChanged;
  final void Function(Post post, int index)? onTap;
  final ImageQuality? quality;
  final GridSize gridSize;
  final BorderRadiusGeometry? borderRadius;
  final Widget Function(BuildContext context, Post post, int index)?
      postAnnotationBuilder;
  final void Function(int postId, bool value) onFavoriteUpdated;
  final void Function()? onMultiSelect;
  final void Function(Post post, bool selected)? onPostSelectChanged;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    // Workaround to prevent memory leak, clear images every 10 seconds
    final timer = useState(Timer.periodic(const Duration(seconds: 10), (_) {
      PaintingBinding.instance.imageCache.clearLiveImages();
    }));

    useEffect(
      () {
        return () => timer.value.cancel();
      },
      [],
    );

    // Clear live image cache everytime this widget built
    useEffect(() {
      PaintingBinding.instance.imageCache.clearLiveImages();

      // ignore: no-empty-block
      return () {};
    });

    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
      builder: (context, authState) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          buildWhen: (previous, current) =>
              previous.settings.imageBorderRadius !=
                  current.settings.imageBorderRadius ||
              previous.settings.imageGridSpacing !=
                  current.settings.imageGridSpacing ||
              previous.settings.imageQuality != current.settings.imageQuality ||
              previous.settings.imageListType != current.settings.imageListType,
          builder: (context, state) {
            Widget buildItem(
              int index, {
              required bool legacy,
            }) {
              final post = posts[index];

              return ContextMenuRegion(
                isEnabled: !multiSelect,
                contextMenu: DownloadProviderWidget(
                  builder: (context, download) => GenericContextMenu(
                    buttonConfigs: [
                      ContextMenuButtonConfig(
                        'Preview',
                        onPressed: () => showGeneralDialog(
                          context: context,
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  QuickPreviewImage(
                            child: BooruImage(
                              placeholderUrl: post.post.previewImageUrl,
                              aspectRatio: post.post.aspectRatio,
                              imageUrl: post.post.normalImageUrl,
                              previewCacheManager:
                                  context.read<PreviewImageCacheManager>(),
                            ),
                          ),
                        ),
                      ),
                      ContextMenuButtonConfig(
                        'download.download'.tr(),
                        onPressed: () => download(post.post),
                      ),
                      ContextMenuButtonConfig(
                        'Select',
                        onPressed: () {
                          onMultiSelect?.call();
                        },
                      ),
                    ],
                  ),
                ),
                child: ImageGridItem(
                  multiSelect: multiSelect,
                  multiSelectBuilder: () => SelectableIconButton(
                    unSelectedIcon: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black45,
                      ),
                      child: const Icon(
                        FontAwesomeIcons.circle,
                        size: 32,
                      ),
                    ),
                    selectedIcon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Icon(
                        Icons.check,
                      ),
                    ),
                    onChanged: (value) =>
                        onPostSelectChanged?.call(post.post, value),
                  ),
                  previewCacheManager: context.read<PreviewImageCacheManager>(),
                  isFaved: post.isFavorited,
                  enableFav: authState is Authenticated,
                  onFavToggle: (isFaved) async {
                    final success =
                        await _getFavAction(context, !isFaved, post.post.id);
                    if (success) {
                      onFavoriteUpdated.call(
                        post.post.id,
                        isFaved,
                      );
                    }
                  },
                  autoScrollOptions: AutoScrollOptions(
                    controller: scrollController,
                    index: index,
                  ),
                  borderRadius: BorderRadius.circular(
                    state.settings.imageBorderRadius,
                  ),
                  aspectRatio: post.post.aspectRatio,
                  gridSize: gridSize,
                  imageQuality: state.settings.imageQuality,
                  image: legacy
                      ? BooruImageLegacy(
                          imageUrl: getImageUrlForDisplay(
                            post.post,
                            getImageQuality(
                              size: gridSize,
                              presetImageQuality: state.settings.imageQuality,
                            ),
                          ),
                          placeholderUrl: post.post.previewImageUrl,
                          borderRadius: BorderRadius.circular(
                            state.settings.imageBorderRadius,
                          ),
                        )
                      : null,
                  onTap: () => onTap?.call(post.post, index),
                  isAnimated: post.post.isAnimated,
                  isTranslated: post.post.isTranslated,
                  hasComments: post.post.hasComment,
                  hasParentOrChildren: post.post.hasParentOrChildren,
                  previewUrl: getImageUrlForDisplay(
                    post.post,
                    getImageQuality(
                      size: gridSize,
                      presetImageQuality: state.settings.imageQuality,
                    ),
                  ),
                  previewPlaceholderUrl: post.post.previewImageUrl,
                  contextMenuAction: _buildContextMenu(post, context),
                ),
              );
            }

            switch (state.settings.imageListType) {
              case ImageListType.standard:
                return SliverGrid(
                  gridDelegate: gridSizeToGridDelegate(
                    size: gridSize,
                    spacing: state.settings.imageGridSpacing,
                    screenWidth: MediaQuery.of(context).size.width,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => buildItem(index, legacy: true),
                    childCount: posts.length,
                  ),
                );

              case ImageListType.masonry:
                final data = gridSizeToGridData(
                  size: gridSize,
                  spacing: state.settings.imageGridSpacing,
                  screenWidth: MediaQuery.of(context).size.width,
                );
                final crossAxisCount = data.first;
                final mainAxisSpacing = data[1];
                final crossAxisSpacing = data[2];

                return SliverMasonryGrid.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  childCount: posts.length,
                  itemBuilder: (context, index) =>
                      buildItem(index, legacy: false),
                );
            }
          },
        );
      },
    );
  }

  List<Widget> _buildContextMenu(PostData post, BuildContext context) {
    return [
      DownloadProviderWidget(
        builder: (context, download) => CupertinoContextMenuAction(
          trailingIcon: Icons.download,
          onPressed: () {
            Navigator.of(context).pop();
            download(post.post);
          },
          child: const Text('download.download').tr(),
        ),
      ),
      FutureBuilder<Account>(
        future: context.read<AccountRepository>().get(),
        builder: (context, snapshot) {
          return snapshot.hasData && snapshot.data! != Account.empty
              ? CupertinoContextMenuAction(
                  trailingIcon: post.isFavorited
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final action =
                        _getFavAction(context, post.isFavorited, post.post.id);
                    final success = await action;

                    if (success) {
                      onFavoriteUpdated.call(
                        post.post.id,
                        !post.isFavorited,
                      );
                    }
                  },
                  child: Text(post.isFavorited
                          ? 'favorites.unfavorite'
                          : 'favorites.favorite')
                      .tr(),
                )
              : const SizedBox.shrink();
        },
      ),
    ];
  }

  Future<bool> _getFavAction(BuildContext context, bool isFaved, int postId) {
    return isFaved
        ? context.read<FavoritePostRepository>().removeFromFavorites(postId)
        : context.read<FavoritePostRepository>().addToFavorites(postId);
  }
}

SliverGridDelegate gridSizeToGridDelegate({
  required GridSize size,
  required double spacing,
  required double screenWidth,
}) {
  final displaySize = screenWidthToDisplaySize(screenWidth);
  switch (size) {
    case GridSize.large:
      return SliverPostGridDelegate.large(spacing, displaySize);
    case GridSize.small:
      return SliverPostGridDelegate.small(spacing, displaySize);
    case GridSize.normal:
      return SliverPostGridDelegate.normal(spacing, displaySize);
  }
}

List<dynamic> gridSizeToGridData({
  required GridSize size,
  required double spacing,
  required double screenWidth,
}) {
  final displaySize = screenWidthToDisplaySize(screenWidth);
  switch (size) {
    case GridSize.large:
      return [displaySizeToGridCountWeight(displaySize), spacing, spacing];
    case GridSize.normal:
      return [displaySizeToGridCountWeight(displaySize) * 2, spacing, spacing];
    case GridSize.small:
      return [displaySizeToGridCountWeight(displaySize) * 3, spacing, spacing];
  }
}
