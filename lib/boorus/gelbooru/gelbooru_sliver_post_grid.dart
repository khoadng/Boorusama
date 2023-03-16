// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:boorusama/boorus/danbooru/ui/shared/selectable_icon_button.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/common/double_utils.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';

import 'gelbooru_post.dart';

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

class GelbooruSliverPostGrid extends StatelessWidget {
  const GelbooruSliverPostGrid({
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
    this.onPostSelectChanged,
    this.multiSelect = false,
    required this.contextMenuBuilder,
  });

  final List<GelbooruPost> posts;
  final AutoScrollController scrollController;
  final ValueChanged<int>? onItemChanged;
  final void Function(Post post, int index)? onTap;
  final ImageQuality? quality;
  final GridSize gridSize;
  final BorderRadiusGeometry? borderRadius;
  final Widget Function(BuildContext context, GelbooruPost post, int index)?
      postAnnotationBuilder;
  final void Function(int postId, bool value) onFavoriteUpdated;
  final void Function(Post post, bool selected)? onPostSelectChanged;
  final bool multiSelect;
  final Widget Function(GelbooruPost post) contextMenuBuilder;

  @override
  Widget build(BuildContext context) {
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
            contextMenu: contextMenuBuilder(post),
            child: LayoutBuilder(
              builder: (context, constraints) => ImageGridItem(
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
                  onChanged: (value) => onPostSelectChanged?.call(post, value),
                ),
                isFaved: false,
                autoScrollOptions: AutoScrollOptions(
                  controller: scrollController,
                  index: index,
                ),
                image: BooruImage(
                  aspectRatio: post.aspectRatio,
                  imageUrl: post.thumbnailImageUrl,
                  placeholderUrl: post.thumbnailImageUrl,
                  borderRadius: BorderRadius.circular(
                    state.settings.imageBorderRadius,
                  ),
                  previewCacheManager: context.read<PreviewImageCacheManager>(),
                  cacheHeight: (constraints.maxHeight * 2).toIntOrNull(),
                  cacheWidth: (constraints.maxWidth * 2).toIntOrNull(),
                ),
                onTap: () => onTap?.call(post, index),
                isAnimated: post.isAnimated,
                isTranslated: post.isTranslated,
                hasComments: false,
                hasParentOrChildren: false,
              ),
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
              itemBuilder: (context, index) => buildItem(index, legacy: false),
            );
        }
      },
    );
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
