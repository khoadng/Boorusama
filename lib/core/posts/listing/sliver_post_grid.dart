// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/errors.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

typedef PostWidgetBuilder<T extends Post> = Widget Function(
  BuildContext context,
  int index,
  T post,
);

class SliverPostGrid<T extends Post> extends ConsumerWidget {
  const SliverPostGrid({
    super.key,
    required this.constraints,
    required this.itemBuilder,
    required this.error,
    required this.multiSelectController,
    required this.postController,
    this.contextMenuBuilder,
    this.canSelect,
  });

  final BoxConstraints? constraints;
  final PostWidgetBuilder<T> itemBuilder;
  final BooruError? error;
  final MultiSelectController<T> multiSelectController;
  final PostGridController<T> postController;

  final Widget Function(T post, void Function() next)? contextMenuBuilder;
  final bool Function(T post)? canSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gestures = ref.watch(currentBooruConfigProvider
        .select((value) => value.postGestures?.preview));
    final imageGridPadding = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageGridPadding));
    final imageListType = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageListType));
    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageGridSpacing = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageGridSpacing));
    final imageGridAspectRatio = ref.watch(imageListingSettingsProvider
        .select((value) => value.imageGridAspectRatio));

    return SliverRawPostGrid(
      constraints: constraints,
      itemBuilder: itemBuilder,
      error: error,
      multiSelectController: multiSelectController,
      postController: postController,
      padding: EdgeInsets.symmetric(
        horizontal: imageGridPadding,
      ),
      listType: imageListType,
      size: gridSize,
      spacing: imageGridSpacing,
      aspectRatio: imageGridAspectRatio,
      gestures: gestures,
      contextMenuBuilder: contextMenuBuilder,
      canSelect: canSelect,
    );
  }
}

class SliverRawPostGrid<T extends Post> extends ConsumerWidget {
  const SliverRawPostGrid({
    super.key,
    required this.constraints,
    required this.itemBuilder,
    required this.error,
    required this.multiSelectController,
    required this.postController,
    required this.gestures,
    required this.contextMenuBuilder,
    required this.canSelect,
    this.padding,
    this.listType,
    this.size,
    this.spacing,
    this.aspectRatio,
    this.borderRadius,
  });

  final BoxConstraints? constraints;
  final PostWidgetBuilder<T> itemBuilder;
  final BooruError? error;
  final MultiSelectController<T> multiSelectController;
  final PostGridController<T> postController;
  final EdgeInsetsGeometry? padding;
  final ImageListType? listType;
  final GridSize? size;
  final double? spacing;
  final double? aspectRatio;
  final BorderRadius? borderRadius;

  final GestureConfig? gestures;
  final Widget Function(T post, void Function() next)? contextMenuBuilder;
  final bool Function(T post)? canSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: padding ?? EdgeInsets.zero,
      sliver: Builder(
        builder: (context) {
          if (error != null) {
            final message = translateBooruError(error!);

            return SliverToBoxAdapter(
              child: switch (error!) {
                AppError _ => ErrorBox(
                    errorMessage: message.tr(),
                    onRetry: _onErrorRetry,
                  ),
                final ServerError e => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 48, bottom: 16),
                          child: Text(
                            e.httpStatusCode.toString(),
                            style: context.textTheme.headlineMedium,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            try {
                              final data = wrapIntoJsonToCodeBlock(
                                  prettyPrintJson(e.message));

                              return MarkdownBody(
                                data: data,
                              );
                            } catch (err) {
                              return Text(
                                e.message.toString(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        if (e.isServerError)
                          FilledButton(
                            onPressed: _onErrorRetry,
                            child: const Text('Retry'),
                          ),
                      ],
                    ),
                  ),
                UnknownError _ => ErrorBox(errorMessage: message),
              },
            );
          }

          return ValueListenableBuilder(
            valueListenable: postController.refreshingNotifier,
            builder: (_, refreshing, __) {
              return refreshing
                  ? SliverPostGridPlaceHolder(
                      constraints: constraints,
                      padding: padding,
                      listType: listType,
                      size: size,
                      spacing: spacing,
                      aspectRatio: aspectRatio,
                      borderRadius: borderRadius,
                    )
                  : _buildGrid(ref, context);
            },
          );
        },
      ),
    );
  }

  void _onErrorRetry() => postController.refresh();

  Widget _buildGrid(WidgetRef ref, BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: postController.itemsNotifier,
      builder: (_, data, __) {
        final crossAxisCount = calculateGridCount(
          constraints?.maxWidth ?? context.screenWidth,
          size ?? GridSize.normal,
        );
        final imageListType = listType ?? ImageListType.standard;

        return data.isNotEmpty
            ? switch (imageListType) {
                ImageListType.standard => SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: aspectRatio ?? 1,
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: spacing ?? 4,
                      crossAxisSpacing: spacing ?? 4,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => buildItem(context, index, data),
                      childCount: data.length,
                    ),
                  ),
                ImageListType.masonry => SliverMasonryGrid.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing ?? 4,
                    crossAxisSpacing: spacing ?? 4,
                    childCount: data.length,
                    itemBuilder: (context, index) =>
                        buildItem(context, index, data),
                  ),
              }
            : const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: NoDataBox(),
                ),
              );
      },
    );
  }

  Widget buildItem(context, index, List<T> data) {
    final controller = multiSelectController;
    final post = data[index];
    final canSelect = this.canSelect?.call(post) ?? true;

    return ValueListenableBuilder(
      valueListenable: controller.multiSelectNotifier,
      builder: (_, multiSelect, __) => DefaultPostListContextMenuRegion(
        gestures: gestures,
        isEnabled: !multiSelect && canSelect,
        contextMenu: contextMenuBuilder != null
            ? contextMenuBuilder!.call(
                post,
                () {
                  multiSelectController.enableMultiSelect();
                },
              )
            : GeneralPostContextMenu(
                hasAccount: false,
                onMultiSelect: () {
                  multiSelectController.enableMultiSelect();
                },
                post: post,
              ),
        child: ExplicitContentBlockOverlay(
          rating: post.rating,
          child: multiSelect
              ? ValueListenableBuilder(
                  valueListenable: controller.selectedItemsNotifier,
                  builder: (_, selectedItems, __) => SelectableItem(
                    index: index,
                    isSelected: selectedItems.contains(post),
                    onTap: () => controller.toggleSelection(post),
                    itemBuilder: (context, isSelected) =>
                        itemBuilder(context, index, post),
                  ),
                )
              : itemBuilder(context, index, post),
        ),
      ),
    );
  }
}

class SliverPostGridPlaceHolder extends ConsumerWidget {
  const SliverPostGridPlaceHolder({
    super.key,
    this.constraints,
    this.padding,
    this.listType,
    this.size,
    this.spacing,
    this.aspectRatio,
    this.borderRadius,
  });

  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;
  final ImageListType? listType;
  final GridSize? size;
  final double? spacing;
  final double? aspectRatio;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageListType = listType ?? ImageListType.standard;
    final gridSize = size ?? GridSize.normal;
    final imageGridSpacing = spacing ?? 4;
    final imageBorderRadius = borderRadius ?? BorderRadius.zero;
    final imageGridAspectRatio = aspectRatio ?? 1;
    final postsPerPage = 20;

    return Builder(
      builder: (context) {
        final crossAxisCount = calculateGridCount(
          constraints?.maxWidth ?? context.screenWidth,
          gridSize,
        );

        return switch (imageListType) {
          ImageListType.standard => SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: imageGridAspectRatio,
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: imageGridSpacing,
                crossAxisSpacing: imageGridSpacing,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, _) => ImagePlaceHolder(
                  borderRadius: imageBorderRadius,
                ),
                childCount: postsPerPage,
              ),
            ),
          ImageListType.masonry => SliverMasonryGrid.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: imageGridSpacing,
              crossAxisSpacing: imageGridSpacing,
              childCount: postsPerPage,
              itemBuilder: (context, index) {
                return createRandomPlaceholderContainer(
                  context,
                  borderRadius: imageBorderRadius,
                );
              },
            )
        };
      },
    );
  }
}

class DefaultPostListContextMenuRegion extends StatelessWidget {
  const DefaultPostListContextMenuRegion({
    super.key,
    this.isEnabled = true,
    required this.gestures,
    required this.contextMenu,
    required this.child,
  });

  final GestureConfig? gestures;
  final bool isEnabled;
  final Widget contextMenu;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (gestures.canLongPress) return child;

    return ContextMenuRegion(
      isEnabled: isEnabled,
      contextMenu: contextMenu,
      child: child,
    );
  }
}
