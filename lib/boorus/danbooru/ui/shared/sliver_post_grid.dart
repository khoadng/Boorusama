// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/authentication/authentication_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/booru_image_legacy.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';

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

              return ImageGridItem(
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
                hasParentOrChildren: post.post.hasBothParentAndChildren,
                previewUrl: getImageUrlForDisplay(
                  post.post,
                  getImageQuality(
                    size: gridSize,
                    presetImageQuality: state.settings.imageQuality,
                  ),
                ),
                previewPlaceholderUrl: post.post.previewImageUrl,
                contextMenuAction: _buildContextMenu(post, context),
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
                    final successMsg = post.isFavorited
                        ? 'favorites.unfavorited'
                        : 'favorites.favorited';
                    final failMsg = post.isFavorited
                        ? 'favorites.fail_to_unfavorite'
                        : 'favorites.fail_to_favorite';
                    if (success) {
                      onFavoriteUpdated.call(
                        post.post.id,
                        !post.isFavorited,
                      );
                      showSimpleSnackBar(
                        context: context,
                        content: Text(successMsg).tr(),
                        duration: const Duration(seconds: 1),
                      );
                    } else {
                      showSimpleSnackBar(
                        context: context,
                        content: Text(failMsg).tr(),
                        duration: const Duration(seconds: 2),
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
