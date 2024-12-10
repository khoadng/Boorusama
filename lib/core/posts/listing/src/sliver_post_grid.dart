// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../boorus/danbooru/errors.dart';
import '../../../configs/config.dart';
import '../../../foundation/error.dart';
import '../../../images/booru_image.dart';
import '../../../images/utils.dart';
import '../../../settings.dart';
import '../../../settings/data/listing_provider.dart';
import '../../post/post.dart';
import '../../post/tags.dart';
import 'grid_utils.dart';
import 'post_grid_controller.dart';

class SliverPostGrid<T extends Post> extends ConsumerWidget {
  const SliverPostGrid({
    super.key,
    required this.constraints,
    required this.itemBuilder,
    required this.postController,
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
    );
  }
}

class SliverRawPostGrid<T extends Post> extends StatelessWidget {
  const SliverRawPostGrid({
    super.key,
    required this.constraints,
    required this.postController,
    this.padding,
    this.listType,
    this.size,
    this.spacing,
    this.aspectRatio,
    this.borderRadius,
    required this.itemBuilder,
  });

  final BoxConstraints? constraints;
  final PostGridController<T> postController;
  final EdgeInsetsGeometry? padding;
  final ImageListType? listType;
  final GridSize? size;
  final double? spacing;
  final double? aspectRatio;
  final BorderRadius? borderRadius;

  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding ?? EdgeInsets.zero,
      sliver: ValueListenableBuilder(
        valueListenable: postController.errors,
        builder: (_, error, __) {
          if (error != null) {
            final message = translateBooruError(error);

            return SliverToBoxAdapter(
              child: switch (error) {
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
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            try {
                              final data = wrapIntoJsonToCodeBlock(
                                prettyPrintJson(e.message),
                              );

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
                  : _buildGrid(context);
            },
          );
        },
      ),
    );
  }

  void _onErrorRetry() => postController.refresh();

  Widget _buildGrid(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: postController.itemsNotifier,
      builder: (_, data, __) {
        final crossAxisCount = calculateGridCount(
          constraints?.maxWidth ?? MediaQuery.sizeOf(context).width,
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
                      itemBuilder,
                      childCount: data.length,
                    ),
                  ),
                ImageListType.masonry => SliverMasonryGrid.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing ?? 4,
                    crossAxisSpacing: spacing ?? 4,
                    childCount: data.length,
                    itemBuilder: itemBuilder,
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
    const postsPerPage = 20;

    return Builder(
      builder: (context) {
        final crossAxisCount = calculateGridCount(
          constraints?.maxWidth ?? MediaQuery.sizeOf(context).width,
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

class BlockOverlayItem {
  const BlockOverlayItem({
    this.onTap,
    required this.overlay,
  });

  final VoidCallback? onTap;
  final Widget overlay;
}

class SliverPostGridImageGridItem<T extends Post> extends ConsumerWidget {
  const SliverPostGridImageGridItem({
    super.key,
    required this.post,
    required this.hideOverlay,
    required this.quickActionButton,
    required this.autoScrollOptions,
    required this.onTap,
    required this.image,
    required this.score,
    this.blockOverlay,
  });

  final T post;
  final bool hideOverlay;
  final Widget? quickActionButton;
  final AutoScrollOptions? autoScrollOptions;
  final VoidCallback? onTap;
  final Widget image;
  final int? score;
  final BlockOverlayItem? blockOverlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBorderRadius = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageBorderRadius),
    );
    final showScoresInGrid = ref.watch(
      imageListingSettingsProvider.select((value) => value.showScoresInGrid),
    );

    final overlay = blockOverlay;

    return Stack(
      children: [
        ImageGridItem(
          borderRadius: BorderRadius.circular(imageBorderRadius),
          isGif: post.isGif,
          isAI: post.isAI,
          hideOverlay: hideOverlay,
          quickActionButton: quickActionButton,
          autoScrollOptions: autoScrollOptions,
          onTap: onTap,
          image: image,
          isAnimated: post.isAnimated,
          isTranslated: post.isTranslated,
          hasComments: post.hasComment,
          hasParentOrChildren: post.hasParentOrChildren,
          hasSound: post.hasSound,
          duration: post.duration,
          score: showScoresInGrid ? score : null,
        ),
        if (overlay != null) ...[
          Positioned.fill(
            child: InkWell(
              highlightColor: Colors.transparent,
              splashFactory: FasterInkSplash.splashFactory,
              splashColor: Colors.black38,
              onTap: blockOverlay?.onTap,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: overlay.overlay,
            ),
          ),
        ],
      ],
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
