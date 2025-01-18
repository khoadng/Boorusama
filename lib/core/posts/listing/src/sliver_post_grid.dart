// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config.dart';
import '../../../configs/ref.dart';
import '../../../settings/providers.dart';
import '../../post/post.dart';
import 'post_grid_controller.dart';
import 'sliver_raw_post_grid.dart';

class SliverPostGrid<T extends Post> extends ConsumerWidget {
  const SliverPostGrid({
    required this.constraints,
    required this.itemBuilder,
    required this.postController,
    super.key,
  });

  final BoxConstraints? constraints;
  final IndexedWidgetBuilder itemBuilder;
  final PostGridController<T> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageGridPadding = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageGridPadding),
    );
    final imageListType = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageListType),
    );
    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageGridSpacing = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageGridSpacing),
    );
    final imageGridAspectRatio = ref.watch(
      imageListingSettingsProvider
          .select((value) => value.imageGridAspectRatio),
    );
    final postsPerPage = ref.watch(
      imageListingSettingsProvider.select((value) => value.postsPerPage),
    );

    return SliverRawPostGrid(
      constraints: constraints,
      itemBuilder: itemBuilder,
      postController: postController,
      padding: EdgeInsets.symmetric(
        horizontal: imageGridPadding,
      ),
      listType: imageListType,
      size: gridSize,
      spacing: imageGridSpacing,
      aspectRatio: imageGridAspectRatio,
      postsPerPage: postsPerPage,
    );
  }
}

class DefaultPostListContextMenuRegion extends ConsumerWidget {
  const DefaultPostListContextMenuRegion({
    required this.contextMenu,
    required this.child,
    super.key,
    this.isEnabled = true,
  });

  final bool isEnabled;
  final Widget contextMenu;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gestures = ref.watchPostGestures?.preview;

    if (gestures.canLongPress) return child;

    return ContextMenuRegion(
      isEnabled: isEnabled,
      contextMenu: contextMenu,
      child: child,
    );
  }
}
